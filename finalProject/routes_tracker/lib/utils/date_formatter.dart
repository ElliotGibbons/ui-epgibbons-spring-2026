String formatDateMMDDYYYY(String isoString) {
  try {
    final dateTime = DateTime.parse(isoString);
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final year = dateTime.year.toString();

    return '$month/$day/$year';
  } catch (e) {
    return isoString;
  }
}