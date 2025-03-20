import 'package:strumok/download/manager/models.dart';

String cleanupQuery(String text) {
  return text.trim().replaceAll('\\s', '\\s');
}

final wordRegExp = RegExp(r'\b\w+\b');

List<String> splitWords(String text) {
  return wordRegExp.allMatches(text).map((m) => m.group(0)!).toList();
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

String downloadTaskDescription(DownloadTask task) {
  final title = (task.request as ContentDownloadRequest).info.title;
  final speed = task.speed();

  if (speed != null) {
    return "$title $speed/s";
  }

  return title;
}
