import 'package:flutter/material.dart';

import '../constants/constants.dart';

BottomNavigationBar bottomNavigationBar() {
  return BottomNavigationBar(
    currentIndex: 0,
    showSelectedLabels: false,
    showUnselectedLabels: false,
    items: [
      const BottomNavigationBarItem(
        icon: Icon(
          Icons.calendar_today_outlined,
          color: Colors.black,
        ),
        label: 'Calendar',
      ),
      BottomNavigationBarItem(
        backgroundColor: CalendarColors.activeStateHigh,
        label: 'Add Event',
        icon: Container(
          height: SizeConfig.blockSizeHorizontal * 15,
          width: SizeConfig.blockSizeHorizontal * 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: CalendarColors.activeStateHigh,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            '+',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: SizeConfig.blockSizeHorizontal * 10,
            ),
          ),
        ),
      ),
      const BottomNavigationBarItem(
        icon: Icon(
          Icons.search_rounded,
          color: Colors.black,
        ),
        label: 'Search',
      ),
    ],
  );
}
