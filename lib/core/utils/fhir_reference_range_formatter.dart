/// Format the *display* of a FHIR Observation reference interval.
///
/// Convert each Quantity using its own original unit. Never interpret the
/// lower bound's converted display unit as the upper bound's source unit.
/// This pure helper does not change the underlying FHIR data.
typedef DisplayQuantity = ({double value, String unit});
typedef QuantityDisplayConverter = DisplayQuantity Function(
  double value,
  String sourceUnit,
);

String? formatFhirReferenceRange({
  required double? lowValue,
  required double? highValue,
  String? lowSourceUnit,
  String? highSourceUnit,
  required QuantityDisplayConverter convert,
}) {
  if (lowValue == null && highValue == null) return null;

  // Some FHIR ranges omit a unit on one side. Use the other original source
  // unit only as a fallback, never a unit produced by a display conversion.
  final lowUnit = lowSourceUnit ?? highSourceUnit ?? '';
  final highUnit = highSourceUnit ?? lowSourceUnit ?? '';
  final low = lowValue == null ? null : convert(lowValue, lowUnit);
  final high = highValue == null ? null : convert(highValue, highUnit);

  if (low != null && high != null) {
    if (low.unit == high.unit) {
      return '\${low.value.toStringAsFixed(2)} - '
          '\${high.value.toStringAsFixed(2)} \${low.unit}';
    }
    // Do not incorrectly label mixed (or only partially converted) units.
    return '\${low.value.toStringAsFixed(2)} \${low.unit} - '
        '\${high.value.toStringAsFixed(2)} \${high.unit}';
  }
  if (low != null) return '> \${low.value.toStringAsFixed(2)} \${low.unit}';
  return '< \${high!.value.toStringAsFixed(2)} \${high.unit}';
}
