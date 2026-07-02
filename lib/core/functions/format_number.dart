String formatAmount(double amount) {
  if (amount % 1 == 0) {
    return amount.toInt().toString();
  }
  return amount.toStringAsFixed(2).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
}
