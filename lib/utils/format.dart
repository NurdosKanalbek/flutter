const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String formatDate(DateTime date) => '${date.day} ${_months[date.month - 1]}';
String formatTime(DateTime date) =>
    '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
String formatWhen(DateTime date) => '${formatDate(date)}, ${formatTime(date)}';
