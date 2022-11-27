import 'dart:collection';
import 'dart:math';

import 'package:table_calendar/table_calendar.dart';

import '../constants/constants.dart';

class Event {
  final String title;
  final String description;
  final CalendarState state;

  const Event(this.title, this.state, this.description);

  @override
  String toString() => title;
}

final kEvents = LinkedHashMap<DateTime, List<Event>>(
  equals: isSameDay,
  hashCode: getHashCode,
)..addAll(_kEventSource);

final _kEventSource = {
  for (var item in List.generate(50, (index) => index))
    DateTime.utc(kFirstDay.year, kFirstDay.month, item * 5): List.generate(
        item % 4 + 1,
        (index) => Event(
            'Event $item | ${index + 1}',
            CalendarState.values[Random().nextInt(3)],
            'Description $item | ${index + 1}')),
}..addAll({
    kToday: [
      const Event('Today\'s Event 1', CalendarState.activeHigh,
          'Description Today\'s Event 1'),
      const Event('Today\'s Event 2', CalendarState.activeLow,
          'Description Today\'s Event 2'),
    ],
  });

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);
