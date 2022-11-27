import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../constants/constants.dart';
import '../utils/utils.dart';

class DataSource extends CalendarDataSource {
  DataSource(List<Appointment> source) {
    appointments = source;
  }
}

DataSource getCalendarDataSource() {
  List<Appointment> appointments = <Appointment>[];

  //add appointments from kEvents map
  kEvents.forEach((key, value) {
    for (var element in value) {
      appointments.add(
        Appointment(
          startTime: key,
          endTime: key.add(const Duration(hours: 2)),
          isAllDay: true,
          subject: element.title,
          color: getStateColor(element),
          startTimeZone: '',
          endTimeZone: '',
        ),
      );
    }
  });

  return DataSource(appointments);
}
