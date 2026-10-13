/// Pure Dart regression for the production range formatter.
/// No pub get, private Git dependencies, Flutter engine, or patient records.
import '../lib/core/utils/fhir_reference_range_formatter.dart';

void check(String name, String? actual, String? expected) {
  if (actual != expected) {
    throw StateError('$name: expected "$expected", got "$actual"');
  }
  print('PASS $name');
}

// Synthetic conversion delegates, matching the published regional factors.
DisplayQuantity european(double value, String sourceUnit) {
  if (sourceUnit == 'mg/dL') {
    return (value: value / 18.0182, unit: 'mmol/L');
  }
  return (value: value, unit: sourceUnit);
}

DisplayQuantity us(double value, String sourceUnit) {
  if (sourceUnit == 'Cel') {
    return (value: value * 9 / 5 + 32, unit: '°F');
  }
  if (sourceUnit == 'kg') {
    return (value: value * 2.20462, unit: 'lbs');
  }
  return (value: value, unit: sourceUnit);
}

void main() {
  check('glucose both bounds',
      formatFhirReferenceRange(lowValue: 70, highValue: 100,
          lowSourceUnit: 'mg/dL', highSourceUnit: 'mg/dL', convert: european),
      '3.88 - 5.55 mmol/L');
  check('Celsius both bounds',
      formatFhirReferenceRange(lowValue: 36, highValue: 38,
          lowSourceUnit: 'Cel', highSourceUnit: 'Cel', convert: us),
      '96.80 - 100.40 °F');
  check('weight both bounds',
      formatFhirReferenceRange(lowValue: 50, highValue: 70,
          lowSourceUnit: 'kg', highSourceUnit: 'kg', convert: us),
      '110.23 - 154.32 lbs');
  check('unchanged mmHg',
      formatFhirReferenceRange(lowValue: 80, highValue: 120,
          lowSourceUnit: 'mm[Hg]', highSourceUnit: 'mm[Hg]', convert: european),
      '80.00 - 120.00 mm[Hg]');
  check('mixed matching target',
      formatFhirReferenceRange(lowValue: 70, highValue: 5.55,
          lowSourceUnit: 'mg/dL', highSourceUnit: 'mmol/L', convert: european),
      '3.88 - 5.55 mmol/L');
  check('unknown unit not falsely relabeled',
      formatFhirReferenceRange(lowValue: 70, highValue: 6,
          lowSourceUnit: 'mg/dL', highSourceUnit: 'unknown', convert: european),
      '3.88 mmol/L - 6.00 unknown');
  check('upper-only',
      formatFhirReferenceRange(lowValue: null, highValue: 100,
          highSourceUnit: 'mg/dL', convert: european),
      '< 5.55 mmol/L');
  check('lower-only',
      formatFhirReferenceRange(lowValue: 70, highValue: null,
          lowSourceUnit: 'mg/dL', convert: european),
      '> 3.88 mmol/L');
  check('unit fallback uses original unit',
      formatFhirReferenceRange(lowValue: 70, highValue: 100,
          lowSourceUnit: 'mg/dL', convert: european),
      '3.88 - 5.55 mmol/L');
  check('no bounds',
      formatFhirReferenceRange(lowValue: null, highValue: null,
          convert: european), null);
}
