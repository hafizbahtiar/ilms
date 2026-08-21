/// `dd/MM/yyyy` formatting shared by every plain-text date field in the app
/// (no `intl` dependency needed for this one fixed format).
String formatDdMmYyyy(DateTime? date) {
  if (date == null) return '';
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(date.day)}/${two(date.month)}/${date.year}';
}

DateTime? parseDdMmYyyy(String? value) {
  if (value == null || value.isEmpty) return null;
  final parts = value.split('/');
  if (parts.length != 3) return null;
  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(parts[2]);
  if (day == null || month == null || year == null) return null;
  return DateTime(year, month, day);
}

/// `yyyy-MM-dd` for API query params (e.g. premise search date range).
String formatIsoDate(DateTime date) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${date.year}-${two(date.month)}-${two(date.day)}';
}

/// `yyyy-MM-dd HH:mm:ss` formatting (24-hour, local time) — e.g. server
/// `time_created`/`time_updated` stamps.
String formatYyyyMmDdHhMmSs(DateTime date) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${date.year}-${two(date.month)}-${two(date.day)} ${two(date.hour)}:${two(date.minute)}:${two(date.second)}';
}

/// Best-effort pretty print for server audit stamps (`yyyy-MM-dd HH:mm:ss`
/// or ISO-8601) — renders as e.g. `21 Aug 2026 · 10:30 AM`. Returns the raw
/// string unchanged when it cannot be parsed so nothing silently disappears.
String? formatAuditStamp(String? raw) {
  final text = raw?.trim();
  if (text == null || text.isEmpty) return null;
  final parsed = DateTime.tryParse(text.replaceFirst(' ', 'T'))?.toLocal();
  if (parsed == null) return text;

  String two(int n) => n.toString().padLeft(2, '0');
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final hour12 = parsed.hour % 12 == 0 ? 12 : parsed.hour % 12;
  final meridiem = parsed.hour < 12 ? 'AM' : 'PM';
  return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year} · $hour12:${two(parsed.minute)} $meridiem';
}
