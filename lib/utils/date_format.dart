import 'package:flutter/material.dart';

String formatDateTime(BuildContext context, DateTime value) {
  final l10n = MaterialLocalizations.of(context);
  final date = l10n.formatMediumDate(value);
  final time = l10n.formatTimeOfDay(TimeOfDay.fromDateTime(value));
  return '$date, $time';
}

String timeAgo(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} h ago';
  if (diff.inDays == 1) return 'Yesterday';
  return '${diff.inDays} days ago';
}