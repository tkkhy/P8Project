import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'select_interests.dart';
import 'settings.dart';
import 'sign_in.dart';
import 'home_screen.dart';
import 'data_provider.dart';
import 'data_container.dart';
import 'notification_helper.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'dart:async';
import 'location_manager.dart';
import 'utility.dart'; 
import 'package:background_fetch/background_fetch.dart';
import 'dart:io' show Platform;
//import 'package:permission_handler/permission_handler.dart';

//AndroidAlarmManager aAM = new AndroidAlarmManager();

main() async {
  final int helloAlarmID = 0;
  if (Platform.isAndroid) {
    await AndroidAlarmManager.initialize();
    runApp(MyApp());
    getUserLocationAndGPSPermissionAndInitPushNotif();
    await AndroidAlarmManager.periodic(const Duration(seconds: 60), helloAlarmID, locationChecker);
  } else {
    
    runApp(MyApp());
    getUserLocationAndGPSPermissionAndInitPushNotif();

  /*  
    PermissionStatus permissionA = await PermissionHandler().checkPermissionStatus(PermissionGroup.locationAlways);
    PermissionStatus permissionWIU = await PermissionHandler().checkPermissionStatus(PermissionGroup.locationWhenInUse);
    print('A: ' + permissionA.toString() + ' WIU: ' + permissionWIU.toString());

    
    Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler().requestPermissions([PermissionGroup.location]);


    PermissionStatus permissionA1 = await PermissionHandler().checkPermissionStatus(PermissionGroup.locationAlways);
    PermissionStatus permissionWIU1 = await PermissionHandler().checkPermissionStatus(PermissionGroup.locationWhenInUse);
    print('A1: ' + permissionA1.toString() + ' WIU1: ' + permissionWIU1.toString());
*/

    

    BackgroundFetch.registerHeadlessTask(bgfFired);
    
    print('bgf started');

  }
}

void bgfFired() {
  DateTime a = new DateTime.now();
  print(a.toString() + ' backgroundFetch fired-------------------------------------');
  BackgroundFetch.finish();
}

//void main() => runApp(MyApp());

void getrecinit(BuildContext context) async {
  var _geolocator = Geolocator();
  Position position = await _geolocator.getLastKnownPosition(
      desiredAccuracy: LocationAccuracy.high);

  getRecommendations(
      new Coordinate(position.latitude, position.longitude), context);
}

class MyApp extends StatelessWidget {
  bool loggedIn = false;

  static Widget determineHome() {
    if (loadString('currentUser') == null) {
      return LogInState();
    } else {
      return HomeScreenState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DataProvider(
      dataContainer: DataContainer(),
      child: MaterialApp(
        title: 'Sign in',
        theme: utilTheme(),
        home: determineHome(),
        onGenerateRoute: (RouteSettings settings) {
          switch (settings.name) {
            case '/':
              getrecinit(context);
              return MaterialPageRoute(builder: (context) => HomeScreenState());
              break;
            case '/LogIn':
              return MaterialPageRoute(builder: (context) => LogInState());
              break;
            case '/settings':
              return MaterialPageRoute(builder: (context) => SettingsState());
              break;
            case '/select_interests':
              return MaterialPageRoute(builder: (context) => InterestsState());
              break;
          }
        },
      ),
    );
  }
}
