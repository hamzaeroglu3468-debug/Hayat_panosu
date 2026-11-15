import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Uygulama genelinde 24 saatlik zaman formatını (HH:mm ve HH:mm:ss) zorunlu kılan
/// ve cihaz saatiyle (`DateTime.now()`) gerçek zamanlı senkronizasyon sağlayan yardımcı sınıf.
class AppTimeUtils {
  AppTimeUtils._();

  static final DateFormat _timeFormat24 = DateFormat('HH:mm', 'tr_TR');
  static final DateFormat _timeWithSecondsFormat24 =
      DateFormat('HH:mm:ss', 'tr_TR');
  static final DateFormat _dateTimeFormat24 =
      DateFormat('dd.MM.yyyy HH:mm', 'tr_TR');
  static final DateFormat _dateFormat = DateFormat('dd.MM.yyyy', 'tr_TR');

  /// Cihazın yerel saatini (`DateTime.now()`) saniyede bir yayınlayan gerçek zamanlı Stream.
  static Stream<DateTime> liveClockStream() async* {
    yield DateTime.now();
    yield* Stream<DateTime>.periodic(
      const Duration(seconds: 1),
      (_) => DateTime.now(),
    );
  }

  /// [DateTime] nesnesini "HH:mm" (24 saat) formatında döndürür.
  static String formatTime(DateTime dateTime) {
    return _timeFormat24.format(dateTime);
  }

  /// [DateTime] nesnesini "HH:mm:ss" (24 saat + saniye) formatında döndürür.
  static String formatTimeWithSeconds(DateTime dateTime) {
    return _timeWithSecondsFormat24.format(dateTime);
  }

  /// [DateTime] nesnesini "dd.MM.yyyy HH:mm" (24 saat) formatında döndürür.
  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormat24.format(dateTime);
  }

  /// [DateTime] nesnesini "dd.MM.yyyy" formatında döndürür.
  static String formatDate(DateTime dateTime) {
    return _dateFormat.format(dateTime);
  }

  /// [TimeOfDay] nesnesini "HH:mm" (24 saat) formatında döndürür.
  static String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// "HH:mm" formatındaki metni [TimeOfDay] nesnesine dönüştürür.
  static TimeOfDay parseTimeOfDay(String hhMm) {
    final parts = hhMm.split(':');
    if (parts.length >= 2) {
      final h = int.tryParse(parts[0]) ?? 9;
      final m = int.tryParse(parts[1]) ?? 0;
      return TimeOfDay(hour: h.clamp(0, 23), minute: m.clamp(0, 59));
    }
    return TimeOfDay.now();
  }

  /// verilen "HH:mm" saatini bugünün (veya saat geçtiyse yarının) [DateTime] nesnesine çevirir.
  static DateTime nextOccurrenceOfTime(String hhMm) {
    final now = DateTime.now();
    final tod = parseTimeOfDay(hhMm);
    var scheduled = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// Flutter `showTimePicker` bileşenini `alwaysUse24HourFormat: true` zorunluluğu ile açar.
  static Future<TimeOfDay?> show24HourTimePicker(
    BuildContext context, {
    TimeOfDay? initialTime,
    String? helpText,
  }) {
    return showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
      helpText: helpText ?? 'SAAT SEÇİN (24 SAAT FORMATI)',
      cancelText: 'İPTAL',
      confirmText: 'TAMAM',
      hourLabelText: 'Saat',
      minuteLabelText: 'Dakika',
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: true,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
