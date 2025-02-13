String cleanupQuery(String text) {
  return text.trim().replaceAll('\\s', '\\s');
}

String formatBytes(int size) {
  if (size < 0) {
    throw ArgumentError("Size must be a non-negative integer.");
  }

  const List<String> units = ['B', 'KB', 'MB', 'GB', 'TB'];
  int index = 0;

  double formattedSize = size.toDouble();
  while (formattedSize >= 1024 && index < units.length - 1) {
    formattedSize /= 1024;
    index++;
  }

  return "${formattedSize.toStringAsFixed(2)} ${units[index]}";
}
