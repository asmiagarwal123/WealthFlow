String formatInr(num value, {bool compact = false}) {
  final negative = value < 0;
  final amount = value.abs();
  if (compact && amount >= 10000000) {
    return '${negative ? '-' : ''}₹${(amount / 10000000).toStringAsFixed(2)} Cr';
  }
  if (compact && amount >= 100000) {
    return '${negative ? '-' : ''}₹${(amount / 100000).toStringAsFixed(1)} L';
  }
  final parts = amount.toStringAsFixed(0).split('');
  if (parts.length > 3) {
    var index = parts.length - 3;
    parts.insert(index, ',');
    index -= 2;
    while (index > 0) {
      parts.insert(index, ',');
      index -= 2;
    }
  }
  return '${negative ? '-' : ''}₹${parts.join()}';
}
