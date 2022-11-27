import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/constants.dart';
import '../models/user_model.dart';
import '../utils/utils.dart';

Widget exitDialog(context) {
  return AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    title: const Text('Exit App'),
    content: const Text('Do you want to exit the app?'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text(
          'No',
          style: TextStyle(color: CalendarColors.activeStateHigh),
        ),
      ),
      TextButton(
        onPressed: () => SystemNavigator.pop(animated: true),
        child: const Text(
          'Yes',
          style: TextStyle(color: CalendarColors.activeStateHigh),
        ),
      ),
    ],
  );
}

Widget customDialog(Widget child) {
  return Dialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    elevation: 0,
    backgroundColor: Colors.white,
    child: child,
  );
}

Widget inviteFailedDialog(BuildContext context) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Invite Failed',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        const Text('Please try again later.'),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'OK',
                style: TextStyle(color: CalendarColors.activeStateHigh),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget inviteDialog(BuildContext context, UserModel userData, Event event) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Invite Successful',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Invite sent to ${userData.data.email}',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 20),
        ClipOval(
            child: Image.network(
          userData.data.avatar,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? (loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!)
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade300,
                ),
                child: const Icon(Icons.error));
          },
        )),
        Container(
          margin: const EdgeInsets.only(top: 20),
          width: double.infinity,
          height: SizeConfig.blockSizeVertical * 5,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: getStateColor(event),
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
            ),
            child: const Text('Close'),
          ),
        ),
      ],
    ),
  );
}
