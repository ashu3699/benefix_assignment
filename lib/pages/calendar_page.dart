import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:table_calendar/table_calendar.dart';

import '../constants/constants.dart';
import '../models/calendar_model.dart';
import '../models/user_model.dart';
import '../utils/utils.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/custom_icon_button.dart';
import '../widgets/dialog_widget.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final CalendarController calendarController = CalendarController();
  late final ValueNotifier<List<Event>> _selectedEvents;
  late final ValueNotifier<DateTime> _displayDate;
  DateTime? _selectedDay;
  Event? selectedEvent;
  bool isWeekFormat = false;
  bool isInvited = false;
  DateTime _focusedDay = DateTime.now();

  var des =
      'Amazon.com, Inc. is an American multinational technology company focusing on e-commerce,digital streaming, and artificial intelligence.';

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    _displayDate = ValueNotifier(_getCurrentDate(_focusedDay));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    _displayDate.dispose();
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) => kEvents[day] ?? [];

  DateTime _getCurrentDate(DateTime date) =>
      calendarController.selectedDate ?? _focusedDay;

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        calendarController.displayDate = focusedDay;
        _selectedEvents.value = _getEventsForDay(selectedDay);
      });
    }
  }

  UserModel? userData;
  Future<bool> getUserData() async {
    var url = Uri.parse('https://reqres.in/api/users/3');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);
      var data = json.encode(responseJson);
      log(data);
      final userModel = userModelFromJson(data);
      setState(() {
        userData = userModel;
      });
      return true;
    } else {
      log('Request failed with status: ${response.statusCode}.');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return WillPopScope(
      onWillPop: () async {
        if (selectedEvent != null) {
          setState(() => selectedEvent = null);
        } else {
          await showDialog(context: context, builder: (_) => exitDialog(_));
        }
        return false;
      },
      child: Scaffold(
        appBar: appBar(),
        bottomNavigationBar: bottomNavigationBar(),
        body: Container(
          child: isWeekFormat
              ? weekFormat()
              : SingleChildScrollView(
                  child: monthFormat(),
                ),
        ),
      ),
    );
  }

  //-------------

  Widget weekFormat() {
    return ValueListenableBuilder(
      valueListenable: _displayDate,
      builder: (context, currentDate, __) {
        return SfCalendar(
          headerHeight: 0,
          controller: calendarController,
          view: CalendarView.schedule,
          backgroundColor: Colors.transparent,
          dataSource: getCalendarDataSource(),
          allowDragAndDrop: false,
          scheduleViewSettings: ScheduleViewSettings(
            appointmentItemHeight: SizeConfig.blockSizeVertical * 10,
            monthHeaderSettings: const MonthHeaderSettings(height: 0),
            hideEmptyScheduleWeek: true,
            dayHeaderSettings: DayHeaderSettings(
              width: 60,
              dayTextStyle: const TextStyle(
                color: Colors.black,
                fontFamily: 'Aileron',
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
              dateTextStyle: GoogleFonts.roboto(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            weekHeaderSettings: const WeekHeaderSettings(
              startDateFormat: 'dd',
              endDateFormat: 'dd MMMM',
              weekTextStyle: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Aileron',
                  fontSize: 13,
                  fontWeight: FontWeight.w400),
            ),
          ),
          scheduleViewMonthHeaderBuilder: (_, d) => const SizedBox(),
          appointmentBuilder: (context, calendarAppointmentDetails) {
            var appointments = calendarAppointmentDetails.appointments;
            List<Appointment> value = appointments
                .map((e) => Appointment(
                    startTime: e.startTime,
                    endTime: e.endTime,
                    subject: e.subject,
                    color: e.color,
                    isAllDay: e.isAllDay))
                .toList();
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: value.length,
              itemBuilder: (context, index) {
                Color color = value[index].color;
                return GestureDetector(
                  onTap: () {
                    kEvents.forEach((key, list) {
                      for (var element in list) {
                        if (element.title == value[index].subject) {
                          setState(() {
                            selectedEvent = element;
                            isWeekFormat = false;
                          });
                          break;
                        }
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      value[index].subject,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Aileron',
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  //-------------

  Widget monthFormat() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selectedEvent == null)
          AnimatedSize(
            alignment: Alignment.topCenter,
            reverseDuration: const Duration(milliseconds: 300),
            duration: const Duration(milliseconds: 300),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _selectedEvents.value.isNotEmpty
                      ? SizeConfig.screenHeight * 0.45
                      : SizeConfig.screenHeight * 0.70,
                  child: TableCalendar(
                    headerVisible: false,
                    shouldFillViewport: true,
                    firstDay: kFirstDay,
                    lastDay: kLastDay,
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    eventLoader: _getEventsForDay,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    rowHeight: SizeConfig.blockSizeHorizontal * 13,
                    onDaySelected: _onDaySelected,
                    daysOfWeekHeight: SizeConfig.blockSizeHorizontal * 13,
                    onPageChanged: (focusedDay) =>
                        setState(() => _focusedDay = focusedDay),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      dowTextFormatter: (date, locale) {
                        return DateFormat.E(locale)
                            .format(date)
                            .substring(0, 1);
                      },
                    ),
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        return Container(
                          margin: const EdgeInsets.all(4),
                          alignment: Alignment.center,
                          height: SizeConfig.blockSizeHorizontal * 13,
                          decoration: BoxDecoration(
                            color: isSameDay(_selectedDay, day)
                                ? Colors.blue
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            day.day.toString(),
                            style: GoogleFonts.museoModerno(
                                fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                        );
                      },
                      outsideBuilder: (context, day, focusedDay) {
                        return Container(
                          margin: const EdgeInsets.all(4),
                          alignment: Alignment.center,
                          height: SizeConfig.blockSizeHorizontal * 13,
                          decoration: BoxDecoration(
                            color: isSameDay(_selectedDay, day)
                                ? Colors.blue
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            day.day.toString(),
                            style: GoogleFonts.museoModerno(
                                color: isSameDay(_selectedDay, day)
                                    ? Colors.white
                                    : Colors.grey,
                                fontSize: 18,
                                fontWeight: FontWeight.w500),
                          ),
                        );
                      },
                      selectedBuilder: (context, date, events) => Container(
                        margin: const EdgeInsets.all(4.0),
                        alignment: Alignment.center,
                        height: SizeConfig.blockSizeHorizontal * 13,
                        decoration: BoxDecoration(
                          color: CalendarColors.activeStateHigh,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Text(
                          date.day.toString(),
                          style: GoogleFonts.museoModerno(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      todayBuilder: (context, date, events) => Container(
                        margin: const EdgeInsets.all(4.0),
                        alignment: Alignment.center,
                        height: SizeConfig.blockSizeHorizontal * 13,
                        decoration: BoxDecoration(
                          color: CalendarColors.inActiveState,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Text(
                          date.day.toString(),
                          style: GoogleFonts.museoModerno(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      dowBuilder: (context, day) {
                        return Container(
                          alignment: Alignment.center,
                          child: Text(
                            DateFormat.E().format(day).substring(0, 1),
                            style: const TextStyle(
                              color: Colors.black,
                              fontFamily: 'Aileron',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        );
                      },
                      markerBuilder:
                          (BuildContext context, date, List<Event> events) {
                        if (isSameDay(date, _selectedDay)) {
                          return const SizedBox();
                        }
                        return ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: events.length,
                            itemBuilder: (context, index) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: EdgeInsets.only(
                                    top: (_selectedEvents.value.isEmpty)
                                        ? 70
                                        : 30),
                                padding: const EdgeInsets.all(2),
                                child: Container(
                                  width: 5,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: getStateColor(events[index]),
                                  ),
                                ),
                              );
                            });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (_selectedEvents.value.isNotEmpty) const SizedBox(height: 20),
        if (_selectedEvents.value.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 10),
            child: Text(
              DateFormat.MMMEd().format(_selectedDay!),
              textAlign: TextAlign.left,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Aileron'),
            ),
          ),
        if (selectedEvent == null)
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            firstCurve: Curves.easeInOut,
            secondCurve: Curves.easeInOut,
            firstChild: const SizedBox(),
            secondChild: eventList(),
            crossFadeState: _selectedEvents.value.isNotEmpty
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
          ),
        if (selectedEvent != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 1,
                  child: Container(
                    margin: const EdgeInsets.only(top: 20),
                    height: SizeConfig.blockSizeHorizontal * 10,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 2,
                        color: getStateColor(selectedEvent!),
                      ),
                    ),
                    child: Text('%',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: SizeConfig.blockSizeHorizontal * 5,
                          color: getStateColor(selectedEvent!),
                        )),
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: getStateColor(selectedEvent!).withOpacity(0.3),
                          spreadRadius: 10,
                          blurRadius: 20,
                          offset: const Offset(10, 5),
                        ),
                      ],
                    ),
                    child: Card(
                      color: getStateColor(selectedEvent!),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            trailing: const Icon(
                              Icons.expand_less_rounded,
                              color: Colors.white,
                            ),
                            onTap: () => setState(() {
                              selectedEvent = null;
                              isInvited = false;
                            }),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 20, bottom: 40),
                            child: Text(
                              selectedEvent!.title,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontFamily: 'Aileron',
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(
                                      Icons.location_on_rounded,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Amazon',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontFamily: 'Aileron',
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 40),
                                Text(
                                  'Description',
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 14,
                                      fontFamily: 'Aileron',
                                      fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 25),
                                Text(
                                  '${selectedEvent!.description}\n$des',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'Aileron',
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 40),
                                GestureDetector(
                                  onTap: () async {
                                    if (!isInvited) {
                                      bool res = await getUserData();
                                      if (!res) {
                                        showDialog(
                                            context: context,
                                            builder: (context) => customDialog(
                                                inviteFailedDialog(context)));
                                      } else {
                                        setState(() {
                                          isInvited = res;
                                        });
                                        if (isInvited) {
                                          showDialog(
                                            context: context,
                                            builder: (context) => customDialog(
                                              inviteDialog(context, userData!,
                                                  selectedEvent!),
                                            ),
                                          );
                                        }
                                      }
                                    } else {
                                      //show snackbar
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          behavior: SnackBarBehavior.floating,
                                          content: Text(
                                              'You have already been invited'),
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    height: SizeConfig.blockSizeVertical * 7,
                                    width: SizeConfig.blockSizeHorizontal * 30,
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.white,
                                    ),
                                    child: Text(
                                        isInvited ? 'Invited' : 'Invite',
                                        style: TextStyle(
                                          color: getStateColor(selectedEvent!),
                                          fontWeight: FontWeight.w900,
                                          fontFamily: 'Aileron',
                                          fontSize: 14,
                                        )),
                                  ),
                                ),
                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Flexible(
                                flex: 5,
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 20),
                                  child: const Text(
                                    'Edit',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontFamily: 'Aileron',
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                              Flexible(
                                flex: 5,
                                child: Container(
                                  margin: EdgeInsets.zero,
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 20),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                    ),
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                  child: const Text(
                                    'Reminder On',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontFamily: 'Aileron',
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  //-------------

  Widget eventList() {
    return ValueListenableBuilder<List<Event>>(
      valueListenable: _selectedEvents,
      builder: (context, value, _) {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: value.length,
          itemBuilder: (context, index) {
            Color color = getStateColor(value[index]);
            return Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  flex: 1,
                  child: Container(
                    height: SizeConfig.blockSizeHorizontal * 10,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 2,
                        color: color,
                      ),
                    ),
                    child: Text('%',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: SizeConfig.blockSizeHorizontal * 5,
                          color: color,
                        )),
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: GestureDetector(
                    onTap: () {
                      setState(() => selectedEvent = value[index]);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        value[index].toString(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'Aileron',
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  //-------------

  AppBar appBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: CustomIconButton(
        icon: const Icon(
          Icons.sort_rounded,
          color: Colors.black,
          size: 30,
        ),
        onTap: () {
          setState(() {
            isWeekFormat = !isWeekFormat;
          });
        },
      ),
      title: ValueListenableBuilder(
          valueListenable: _displayDate,
          builder: (context, value, _) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: [
                CustomIconButton(
                  icon: const Icon(
                    Icons.chevron_left_rounded,
                    color: Colors.grey,
                  ),
                  onTap: () {
                    var x = DateTime(_focusedDay.year, _focusedDay.month - 1);
                    if (x.isAfter(kFirstDay)) {
                      setState(() {
                        _focusedDay = x;
                        value = x;
                        calendarController.displayDate = x;
                      });
                    }
                  },
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  // mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat.MMMM().format(_focusedDay),
                      style: const TextStyle(
                        fontFamily: 'Aileron',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      _focusedDay.year.toString(),
                      style: GoogleFonts.museoModerno(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                CustomIconButton(
                  icon: const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey,
                  ),
                  onTap: () {
                    var x = DateTime(_focusedDay.year, _focusedDay.month + 1);
                    if (x.isBefore(kLastDay)) {
                      setState(() {
                        _focusedDay = x;
                        value = x;
                        calendarController.displayDate = x;
                      });
                    }
                  },
                ),
              ],
            );
          }),
      actions: [
        CustomIconButton(
          icon: const Icon(
            Icons.notifications_none_outlined,
            color: Colors.black,
            size: 30,
          ),
          onTap: () {},
        ),
      ],
    );
  }

  //-------------

}
