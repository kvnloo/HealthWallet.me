import 'package:fhir_r4/fhir_r4.dart' as fhir;
import 'package:flutter_test/flutter_test.dart';
import 'package:health_wallet/core/config/constants/region_preset.dart';
import 'package:health_wallet/features/records/domain/entity/observation/observation.dart'
    as wallet;

/// Reproduces the regional display path used in Observation record details.
/// Synthetic FHIR R4 only: no patient identity, server or health-effect claim.
String referenceRangeDisplay({
  required RegionPreset region,
  Map<String, Object?>? low,
  Map<String, Object?>? high,
}) {
  final resource = fhir.Observation.fromJson({
    'resourceType': 'Observation',
    'status': 'final',
    'code': {
      'coding': [
        {'system': 'http://loinc.org', 'code': '2339-0'}
      ]
    },
    'referenceRange': [
      {
        if (low != null) 'low': low,
        if (high != null) 'high': high,
      },
    ],
  });
  final observation = wallet.Observation(
    id: 'synthetic-reference-range',
    referenceRange: resource.referenceRange,
  );
  return observation
      .additionalInfoForRegion(region)
      .map((line) => line.info)
      .singleWhere((line) => line.startsWith('Reference Range: '));
}

Map<String, Object?> bound(num value, String unit) => {
      'value': value,
      'unit': unit,
      'system': 'http://unitsofmeasure.org',
      'code': unit,
    };

void main() {
  group('FHIR Observation reference-range regional display', () {
    test('converts BOTH glucose bounds mg/dL → mmol/L', () {
      expect(
        referenceRangeDisplay(
          region: RegionPreset.europe,
          low: bound(70, 'mg/dL'),
          high: bound(100, 'mg/dL'),
        ),
        'Reference Range: 3.88 - 5.55 mmol/L',
      );
    });

    test('converts BOTH temperature bounds Celsius → Fahrenheit', () {
      expect(
        referenceRangeDisplay(
          region: RegionPreset.us,
          low: bound(36, 'Cel'),
          high: bound(38, 'Cel'),
        ),
        'Reference Range: 96.80 - 100.40 °F',
      );
    });

    test('converts BOTH weight bounds kg → lbs', () {
      expect(
        referenceRangeDisplay(
          region: RegionPreset.us,
          low: bound(50, 'kg'),
          high: bound(70, 'kg'),
        ),
        'Reference Range: 110.23 - 154.32 lbs',
      );
    });

    test('preserves bounds with no known conversion', () {
      expect(
        referenceRangeDisplay(
          region: RegionPreset.europe,
          low: bound(80, 'mm[Hg]'),
          high: bound(120, 'mm[Hg]'),
        ),
        'Reference Range: 80.00 - 120.00 mm[Hg]',
      );
    });

    test('handles each bound supplied in a different unit', () {
      expect(
        referenceRangeDisplay(
          region: RegionPreset.europe,
          low: bound(70, 'mg/dL'),
          high: bound(5.55, 'mmol/L'),
        ),
        'Reference Range: 3.88 - 5.55 mmol/L',
      );
    });

    test('never applies a known unit label to an unknown-unit bound', () {
      expect(
        referenceRangeDisplay(
          region: RegionPreset.europe,
          low: bound(70, 'mg/dL'),
          high: bound(6, 'unit-not-recognized'),
        ),
        'Reference Range: 3.88 mmol/L - 6.00 unit-not-recognized',
      );
    });

    test('continues to display a single upper bound', () {
      expect(
        referenceRangeDisplay(
          region: RegionPreset.europe,
          high: bound(100, 'mg/dL'),
        ),
        'Reference Range: < 5.55 mmol/L',
      );
    });

    test('continues to display a single lower bound', () {
      expect(
        referenceRangeDisplay(
          region: RegionPreset.europe,
          low: bound(70, 'mg/dL'),
        ),
        'Reference Range: > 3.88 mmol/L',
      );
    });
  });
}
