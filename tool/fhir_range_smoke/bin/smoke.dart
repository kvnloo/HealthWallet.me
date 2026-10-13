// Real fhir_r4 0.4.2 decode/serialize + HealthWallet production range helper.
// Synthetic public fixture; no Flutter, private packages, networks, or patient data.
import 'dart:convert';
import 'dart:io';
import 'package:fhir_r4/fhir_r4.dart' as fhir;
import '../../../lib/core/utils/fhir_reference_range_formatter.dart';

int passed = 0;

void verify(String name, bool ok) {
  if (!ok) throw StateError('FAIL ' + name);
  passed++;
  print('PASS ' + name);
}

Map<String, dynamic> recordMap(Object? value) =>
    Map<String, dynamic>.from(value as Map);

Map<String, dynamic> observationById(
  List<Map<String, dynamic>> rows,
  String id,
) => rows.singleWhere((row) => row['id'] == id);

DisplayQuantity europeanGlucose(double value, String unit) {
  if (unit == 'mg/dL') return (value: value / 18.0182, unit: 'mmol/L');
  return (value: value, unit: unit);
}

DisplayQuantity usTemperature(double value, String unit) {
  if (unit == 'Cel') return (value: value * 9 / 5 + 32, unit: '°F');
  return (value: value, unit: unit);
}

void main() {
  final payload = recordMap(jsonDecode(File('data/observations.json').readAsStringSync()));
  final metadata = recordMap(payload['metadata']);
  verify('fixture uses synthetic-only data', metadata['synthetic_only'] == true &&
      metadata['no_personal_data'] == true);

  final inputs = (payload['observations'] as List).map(recordMap).toList();
  verify('five public-safe FHIR R4 scenarios', inputs.length == 5);

  final decoded = <Map<String, dynamic>>[];
  for (final input in inputs) {
    final parsed = fhir.Observation.fromJson(input);
    final output = recordMap(parsed.toJson());
    decoded.add(output);
    final id = input['id'] as String;
    verify('R4 decode+encode resource type ' + id, output['resourceType'] == 'Observation');
    verify('R4 identity ' + id, output['id'] == id);
    verify('LOINC code ' + id,
        recordMap((recordMap(output['code'])['coding'] as List).first)['code'] ==
        recordMap((recordMap(input['code'])['coding'] as List).first)['code']);
    final sourceDate = input['effectiveDateTime'] as String;
    final outDate = output['effectiveDateTime'] as String;
    print('FHIR_TIME ' + id + ' original=' + sourceDate + ' serialized=' + outDate);
    verify('UTC instant ' + id,
        DateTime.parse(sourceDate).isAtSameMomentAs(DateTime.parse(outDate)));
    verify('original local day ' + id,
        sourceDate.substring(0, 10) == outDate.substring(0, 10));
    verify('no subject injected ' + id, !output.containsKey('subject'));
  }

  final glucose = observationById(decoded, 'synthetic-glucose');
  final sourceGlucose = observationById(inputs, 'synthetic-glucose');
  verify('glucose UCUM code retained',
      recordMap(glucose['valueQuantity'])['code'] == 'mg/dL');
  verify('glucose source quantity retained',
      recordMap(glucose['valueQuantity'])['value'] == 88);
  final glucoseRange = recordMap((glucose['referenceRange'] as List).single);
  final glucoseLow = recordMap(glucoseRange['low']);
  final glucoseHigh = recordMap(glucoseRange['high']);
  final glucoseDisplay = formatFhirReferenceRange(
    lowValue: (glucoseLow['value'] as num).toDouble(),
    highValue: (glucoseHigh['value'] as num).toDouble(),
    lowSourceUnit: glucoseLow['unit'] as String?,
    highSourceUnit: glucoseHigh['unit'] as String?,
    convert: europeanGlucose,
  );
  verify('actual FHIR quantities render as 3.88-5.55 mmol/L',
      glucoseDisplay == '3.88 - 5.55 mmol/L');
  verify('glucose unmodified after regional display',
      jsonEncode(glucose) == jsonEncode(fhir.Observation.fromJson(sourceGlucose).toJson()));

  final temp = observationById(decoded, 'synthetic-temperature');
  final tempRange = recordMap((temp['referenceRange'] as List).single);
  final tempLow = recordMap(tempRange['low']);
  final tempHigh = recordMap(tempRange['high']);
  verify('actual FHIR temperature range converts both bounds',
      formatFhirReferenceRange(
        lowValue: (tempLow['value'] as num).toDouble(),
        highValue: (tempHigh['value'] as num).toDouble(),
        lowSourceUnit: tempLow['unit'] as String?,
        highSourceUnit: tempHigh['unit'] as String?,
        convert: usTemperature,
      ) == '96.80 - 100.40 °F');
  verify('negative offset keeps expected local day',
      (temp['effectiveDateTime'] as String).startsWith('2026-10-13'));

  final panel = observationById(decoded, 'synthetic-blood-pressure');
  verify('panel has no fabricated aggregate value', !panel.containsKey('valueQuantity'));
  final components = panel['component'] as List;
  verify('two blood pressure components retained', components.length == 2);
  final codes = components.map((element) {
    final component = recordMap(element);
    final coding = recordMap((recordMap(component['code'])['coding'] as List).first);
    return coding['code'];
  }).toSet();
  verify('systolic/diastolic LOINC codes retained',
      codes.contains('8480-6') && codes.contains('8462-4'));

  final absent = observationById(decoded, 'synthetic-missing');
  verify('missing measurement stays missing', !absent.containsKey('valueQuantity'));
  verify('explicit absent reason retained',
      recordMap((recordMap(absent['dataAbsentReason'])['coding'] as List).first)['code'] ==
      'unknown');

  final zero = observationById(decoded, 'synthetic-zero');
  verify('actual zero remains a numeric zero',
      recordMap(zero['valueQuantity'])['value'] == 0);
  verify('zero is distinct from missing', zero.containsKey('valueQuantity') &&
      !absent.containsKey('valueQuantity'));

  print('ALL ' + passed.toString() + ' FHIR R4 checks passed (synthetic, no app runtime).');
}
