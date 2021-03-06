import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:test2/data_container.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:ui';
import 'dart:math';

Map months = {
  1: "january",
  2: "febuary",
  3: "march",
  4: "april",
  5: "may",
  6: "june",
  7: "july",
  8: "august",
  9: "september",
  10: "october",
  11: "november",
  12: "december"
};
String apiAdress =
    "http://ec2-3-14-87-243.us-east-2.compute.amazonaws.com/app/api";
//String apiAdress = "https://10.0.2.2:5000/api";
ThemeData jdDarkTheme() {
  return ThemeData(
    // Define the default Brightness and Colors
    brightness: Brightness.dark,
    primaryColor: Colors.grey[850],
    accentColor: Colors.green,
    buttonColor: Colors.green,
    backgroundColor: Colors.grey[300],

    primaryColorDark: Colors.grey[800],

    hintColor: Colors.grey[500],

    // Define the default Font Family
    fontFamily: 'Montserrat',

    // Define the default TextTheme. Use this to specify the default
    // text styling for headlines, titles, bodies of text, and more.
    textTheme: TextTheme(
      headline: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
      title: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
      body1: TextStyle(fontSize: 14.0, fontFamily: 'Hind', color: Colors.black),
      body2: TextStyle(
          fontSize: 14.0, fontFamily: 'Hind', color: Colors.grey[300]),
    ),
  );
}

ThemeData jdLightTheme() {
  return ThemeData(
    // Define the default Brightness and Colors
    //brightness: Brightness.light,
    primaryColor: Colors.white,
    accentColor: Colors.lightBlue,
    buttonColor: Colors.white,
    backgroundColor: Colors.grey[275],
    scaffoldBackgroundColor: Colors.grey[275],

    primaryColorDark: Colors.white,

    //hintColor: Colors.grey[500],

    // Define the default Font Family
    fontFamily: 'Montserrat',

    // Define the default TextTheme. Use this to specify the default
    // text styling for headlines, titles, bodies of text, and more.
    textTheme: TextTheme(
      headline: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
      title: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
      body1: TextStyle(fontSize: 14.0, fontFamily: 'Hind', color: Colors.black),
      body2: TextStyle(fontSize: 14.0, fontFamily: 'Hind', color: Colors.black),
    ),
  );
}

Future<void> giveReview(double rating, DateTime date, String triptype,
    String attraction, BuildContext context) async {
  Map months = {
    1: "January",
    2: "Febuary",
    3: "March",
    4: "April",
    5: "May",
    6: "June",
    7: "July",
    8: "August",
    9: "September",
    10: "October",
    11: "November",
    12: "December"
  };
  String _date = months[date.month] + " " + date.year.toString();
  var preEncode = {
    "rating": rating,
    "date": _date,
    "triptype": triptype,
    "attraction": attraction,
    "username": await loadInt("currentUserID")
  };
  var postEncode = jsonEncode(preEncode);
  try {
    String _apiadress = apiAdress + '/give-review/';
    var response = await http.post(_apiadress,
        body: postEncode, headers: {"Content-Type": "application/json"});

    if (response.statusCode != 200) {
      print('Error: ' + response.statusCode.toString());
    }
  } catch (e) {
    print(e);
  }
}

Future<void> updatePreferences(BuildContext context) async {
  DataContainerState data = DataContainer.of(context);
  var ratings = data.getCategoryRatings();
  var preEncode = {
    "username": await loadInt('currentUserID'),
    "Museums": ratings['Museums'],
    "Art Museums": ratings['Art Museums'],
    "Sights & Landmarks": ratings['Sights & Landmarks'],
    "Points of Interest & Landmarks": ratings['Points of Interest & Landmarks'],
    "Historic Sites": ratings['Historic Sites'],
    "Concerts & Shows": ratings['Concerts & Shows'],
    "Theaters": ratings['Theaters'],
    "Nature & Parks": ratings['Nature & Parks'],
    "Churches & Cathedrals": ratings['Churches & Cathedrals'],
    "Gardens": ratings['Gardens'],
    "Cafe": ratings['Cafe'],
    "Seafood": ratings['Seafood'],
    "Steakhouse": ratings['Steakhouse'],
    "Indian": ratings['Indian'],
    "British": ratings['British'],
    "Mediterranean": ratings['Mediterranean'],
    "French": ratings['French'],
    "Italian": ratings['Italian'],
    "European": ratings['European'],
  };
  var postEncode = jsonEncode(preEncode);
  try {
    String _apiAdress = apiAdress + '/update-preferences/';
    var response = await http.post(_apiAdress,
        body: postEncode, headers: {"Content-Type": "application/json"});

    if (response.statusCode != 200) {
      displayMsg('Error: ' + response.statusCode.toString(), context);
    }
  } catch (e) {
    print(e);
  }
}

Future<void> getPreferences(BuildContext context) async {
  DataContainerState data = DataContainer.of(context);
  try {
    int user = await loadInt('currentUserID');
    var preEncode = {"username": user, "un": user};
    var postEncode = jsonEncode(preEncode);
    String _apiAdress = apiAdress + '/get-preferences/';
    var response = await http.post(_apiAdress,
        body: postEncode, headers: {"Content-Type": "application/json"});
    if (response.statusCode == 200) {
      var prefspre = response.headers['prefs'];
      var prefspost = jsonDecode(prefspre);

      data.getCategoryRatings()['Museums'] = prefspost['Museums'];
      data.getCategoryRatings()['Art Museums'] = prefspost['Art Museums'];
      data.getCategoryRatings()['Sights & Landmarks'] =
          prefspost['Sights & Landmarks'];
      data.getCategoryRatings()['Points of Interest & Landmarks'] =
          prefspost['Points of Interest & Landmarks'];
      data.getCategoryRatings()['Historic Sites'] = prefspost['Historic Sites'];
      data.getCategoryRatings()['Concerts & Shows'] =
          prefspost['Concerts & Shows'];
      data.getCategoryRatings()['Theaters'] = prefspost['Theaters'];
      data.getCategoryRatings()['Nature & Parks'] = prefspost['Nature & Parks'];
      data.getCategoryRatings()['Churches & Cathedrals'] =
          prefspost['Churches & Cathedrals'];
      data.getCategoryRatings()['Gardens'] = prefspost['Gardens'];
      data.getCategoryRatings()['Cafe'] = prefspost['Cafe'];
      data.getCategoryRatings()['Seafood'] = prefspost['Seafood'];
      data.getCategoryRatings()['Steakhouse'] = prefspost['Steakhouse'];
      data.getCategoryRatings()['Indian'] = prefspost['Indian'];
      data.getCategoryRatings()['British'] = prefspost['British'];
      data.getCategoryRatings()['Mediterranean'] = prefspost['Mediterranean'];
      data.getCategoryRatings()['French'] = prefspost['French'];
      data.getCategoryRatings()['Italian'] = prefspost['Italian'];
      data.getCategoryRatings()['European'] = prefspost['European'];
    }
  } catch (e) {
    print(e);
  }
}

Future<int> getRecCount(Coordinate coordinate) async {
  if (coordinate == null) {
    return 0;
  }
  DateTime dt = DateTime.now();
  String tt = await loadString('triptype') ?? 'alone';
  int distance = await loadInt('dist') ?? 1;
  tt = tt.toLowerCase() == 'solo' ? 'alone' : tt;
  String usercontext =
      "month_visited:" + months[dt.month] + ",company:" + (tt ?? 'alone');
  var jsonstring = {
    "id": await loadInt('currentUserID'),
    "context": usercontext.toLowerCase(),
    "coordinate": "(" +
        coordinate.getLat().toString() +
        "," +
        coordinate.getLong().toString() +
        ")",
    "dist": distance ?? 1
  };
  var jsonedString = jsonEncode(jsonstring);
  try {
    String _apiAdress = apiAdress + '/request-recommendations/';
    var response = await http.post(_apiAdress,
        body: jsonedString, headers: {"Content-Type": "application/json"});
    var attracts = response.headers['attractions'];
    var decoded = jsonDecode(attracts);
    var t = decoded as List;
    return t.length;
  } catch (e) {
    print(e);
  }
  return 0;
}

Future<List<Attraction>> getAllAttractions(
    Coordinate coordinate, BuildContext context) async {
  if (coordinate == null) {
    return new List<Attraction>();
  }
  DataContainerState data = DataContainer.of(context);
  int distance = data.getDist() ?? await loadInt('dist');
  var jsonstring = {
    "coordinate": "(" +
        coordinate.getLat().toString() +
        "," +
        coordinate.getLong().toString() +
        ")",
    "dist": distance ?? 1
  };
  var jsonedString = jsonEncode(jsonstring);
  try {
    String _apiAdress = apiAdress + '/request-all-attractions/';
    var response = await http.post(_apiAdress,
        body: jsonedString, headers: {"Content-Type": "application/json"});
    if (response.statusCode == 200) {
      var attracts = response.headers['attractions'];
      var decoded = attracts == null ? [] : jsonDecode(attracts);
      var t = decoded as List;
      List<Attraction> recAttractions = List<Attraction>();
      for (var i = 0; i < t.length; i++) {
        List<String> open = [];
        if (t[i]['opening_hours'] == "NA") {
          open.add('Not Available');
          open.add('Not Available');
          open.add('Not Available');
          open.add('Not Available');
          open.add('Not Available');
          open.add('Not Available');
          open.add('Not Available');
        } else {
          var oh = jsonDecode(t[i]['opening_hours']);
          for (var item in oh) {
            open.add(item.toString());
          }
        }

        recAttractions.add(new Attraction(
            t[i]['id'],
            t[i]['name'],
            open,
            t[i]['img_path'],
            !t[i]['isFoodPlace'],
            t[i]['rating'],
            t[i]['description'],
            t[i]['url'],
            t[i]['lat'],
            t[i]['long']));
      }
      return recAttractions;
      DataContainerState data = DataContainer.of(context);
      if (recAttractions.length != 0) {
        data.setAllNearbyAttractions(recAttractions);
      }
    } else {
      displayMsg('No connection to server.\nGAA', context);
    }
  } catch (e) {
    print('gaa ');
    print(e);
  }
}

Future<List<Attraction>> getRecommendations(
    Coordinate coordinate, BuildContext context) async {
  if (coordinate == null) {
    return List<Attraction>();
  }
  DataContainerState data = DataContainer.of(context);
  DateTime dt = DateTime.now();
  int distance = await loadInt('dist') ??
      1; //ID, Context (commpany:triptype, monthvisited:måned)
  String tt = await loadString('triptype') ?? 'alone';
  tt = tt.toLowerCase() == 'solo' ? 'alone' : tt;
  String usercontext =
      "month_visited:" + months[dt.month] + ",company:" + (tt ?? 'alone');
  if (coordinate == null) {
    if (await PermissionHandler()
            .checkPermissionStatus(PermissionGroup.location) ==
        PermissionStatus.granted) {
      try {
        Position pos = await Geolocator()
            .getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);
        coordinate = new Coordinate(pos.latitude, pos.longitude);
      } catch (e) {
        print(e);
      }
    }
  }

  var jsonstring = {
    "id": await loadInt('currentUserID'),
    "context": usercontext.toLowerCase(),
    "coordinate": "(" +
        coordinate.getLat().toString() +
        "," +
        coordinate.getLong().toString() +
        ")",
    "dist": distance ?? 1
  };
  var jsonedString = jsonEncode(jsonstring);
  try {
    String _apiAdress = apiAdress + '/request-recommendations/';
    var response = await http.post(_apiAdress,
        body: jsonedString, headers: {"Content-Type": "application/json"});
    if (response.statusCode == 200) {
      var attracts = response.headers['attractions'];
      var decoded = attracts == null ? [] : jsonDecode(attracts);
      var t = decoded as List;
      List<Attraction> recAttractions = List<Attraction>();
      String temp = "";
      for (var i = 0; i < t.length; i++) {
        bool toadd = true;
        List<String> open = [];
        if (t[i]['opening_hours'] == "NA") {
          open.add('Not Available');
          open.add('Not Available');
          open.add('Not Available');
          open.add('Not Available');
          open.add('Not Available');
          open.add('Not Available');
          open.add('Not Available');
        } else {
          var oh = jsonDecode(t[i]['opening_hours']);

          String dayoh = oh[dt.weekday -1];

          List<String> dayopenhours = dayoh.split(',');
            if (dayopenhours.length > 1) {
              int interValCounter = 0;
              for (var time in dayopenhours) {
                List<String> splitonspace = time.split(' ');
                if (interValCounter == 0) {
                  splitonspace.removeAt(0);
                  interValCounter++;
                }
                if (splitonspace[0] == 'Closed') {
                  toadd = false;
                  break;
                } else if (splitonspace[1] == 'AM') {
                  if (splitonspace[0].split(':')[0] == '12') {
                    splitonspace[0] = '0:' + splitonspace[0].split(':')[1];
                  }
                  if (splitonspace[4] == 'PM') {
                    int temptime = int.parse(splitonspace[3].split(':')[0]);
                    temptime += splitonspace[3].split(':')[0] == '12' ? 0 : 12;
                    splitonspace[3] = temptime.toString() +
                        ':' +
                        splitonspace[2].split(':')[1];
                  }
                  splitonspace.removeAt(1);
                } else if (splitonspace[1] == 'PM') {
                  int temptime = int.parse(splitonspace[0].split(':')[0]);
                  temptime += splitonspace[0].split(':')[0] == '12' ? 0 : 12;
                  splitonspace[0] =
                      temptime.toString() + ':' + splitonspace[0].split(':')[1];
                  if (splitonspace[4] == 'AM') {
                    if (splitonspace[3].split(':')[0] == '12') {
                      splitonspace[3] = '0:' + splitonspace[0].split(':')[1];
                    }
                  } else if (splitonspace[4] == 'PM') {
                    int temptime = int.parse(splitonspace[3].split(':')[0]);
                    temptime += splitonspace[3].split(':')[0] == '12' ? 0 : 12;
                    splitonspace[3] = temptime.toString() +
                        ':' +
                        splitonspace[3].split(':')[1];
                  }
                  splitonspace.removeAt(1);
                } else if (splitonspace[1] == '–') {
                  if (splitonspace[3] == 'AM') {
                    if (splitonspace[2].split(':')[2] == '12') {
                      splitonspace[2] = '0:' + splitonspace[2].split(':')[1];
                    }
                    if (splitonspace[0].split(':')[0] == '12') {
                      splitonspace[0] = '0:' + splitonspace[0].split(':')[1];
                    }
                  } else if (splitonspace[3] == 'PM') {
                    int temptime = int.parse(splitonspace[2].split(':')[2]);
                    temptime += splitonspace[2].split(':')[0] == '12' ? 0 : 12;
                    splitonspace[2] = temptime.toString() +
                        ':' +
                        splitonspace[2].split(':')[1];
                    temptime = int.parse(splitonspace[0].split(':')[0]);
                    temptime += splitonspace[0].split(':')[0] == '12' ? 0 : 12;
                    ;
                    splitonspace[0] = temptime.toString() +
                        ':' +
                        splitonspace[0].split(':')[1];
                  }
                }

                if (int.parse(dt.hour.toString()) >
                    int.parse(splitonspace[0].split(':')[0])) {
                  if (int.parse(dt.hour.toString()) <
                      int.parse(splitonspace[2].split(':')[0])) {
                    break;
                  } else if (int.parse(splitonspace[2].split(':')[0]) <
                      int.parse(splitonspace[0].split(':')[0])) {
                    break;
                  }
                }
                toadd = false;
              }
            } else {
              List<String> splitonspace = dayoh.split(' ');
              splitonspace.removeAt(0);
              if (splitonspace[0] == 'Closed') {
                toadd = false;
              } else if (splitonspace[1] == 'AM') {
                if (splitonspace[0].split(':')[0] == '12') {
                  splitonspace[0] = '0:' + splitonspace[0].split(':')[1];
                }
                if (splitonspace[4] == 'PM') {
                  int temptime = int.parse(splitonspace[3].split(':')[0]);
                  temptime += splitonspace[3].split(':')[0] == '12' ? 0 : 12;
                  splitonspace[3] =
                      temptime.toString() + ':' + splitonspace[3].split(':')[1];
                }
                splitonspace.removeAt(1);
              } else if (splitonspace[1] == 'PM') {
                int temptime = int.parse(splitonspace[0].split(':')[0]);
                temptime += splitonspace[0].split(':')[0] == '12' ? 0 : 12;
                splitonspace[0] =
                    temptime.toString() + ':' + splitonspace[0].split(':')[1];
                if (splitonspace[4] == 'AM') {
                  if (splitonspace[3].split(':')[0] == '12') {
                    splitonspace[3] = '0:' + splitonspace[0].split(':')[1];
                  }
                } else if (splitonspace[4] == 'PM') {
                  int temptime = int.parse(splitonspace[3].split(':')[0]);
                  temptime += splitonspace[3].split(':')[0] == '12' ? 0 : 12;
                  splitonspace[0] =
                      temptime.toString() + ':' + splitonspace[3].split(':')[1];
                }
                splitonspace.removeAt(1);
              } else if (splitonspace[1] == "–") {
                if (splitonspace[3] == 'AM') {
                  if (splitonspace[2].split(':')[2] == '12') {
                    splitonspace[2] = '0:' + splitonspace[2].split(':')[1];
                  }
                  if (splitonspace[0].split(':')[0] == '12') {
                    splitonspace[0] = '0:' + splitonspace[0].split(':')[1];
                  }
                } else if (splitonspace[3] == 'PM') {
                  int temptime = int.parse(splitonspace[2].split(':')[0]);
                  temptime += splitonspace[2].split(':')[0] == '12' ? 0 : 12;
                  splitonspace[2] =
                      temptime.toString() + ':' + splitonspace[2].split(':')[1];
                  temptime = int.parse(splitonspace[0].split(':')[0]);
                  temptime += splitonspace[0].split(':')[0] == '12' ? 0 : 12;
                  splitonspace[0] =
                      temptime.toString() + ':' + splitonspace[0].split(':')[1];
                }
              }

              if (int.parse(dt.hour.toString()) >
                  int.parse(splitonspace[0].split(':')[0])) {
                if (int.parse(dt.hour.toString()) <
                    int.parse(splitonspace[2].split(':')[0])) {
                } else if (int.parse(splitonspace[2].split(':')[0]) <
                    int.parse(splitonspace[0].split(':')[0])) {
                } else {
                  toadd = false;
                }
              } else {
                toadd = false;
              }
            }

          for (var item in oh) {
            open.add(item.toString());
          }
        }
        double score = t[i]['score'];
        score = score > 5 ? 5 : score;

        temp += (t[i]['id']).toString() + '|';

        if (toadd) {
          recAttractions.add(new Attraction(
              t[i]['id'],
              t[i]['name'],
              open,
              t[i]['img_path'],
              !t[i]['isFoodPlace'],
              t[i]['rating'],
              t[i]['description'],
              t[i]['url'],
              t[i]['lat'],
              t[i]['long'],
              score,
              //t[i]['distance']
              distanceBetweenCoordinates(
                  new Coordinate(t[i]['lat'], t[i]['long']), coordinate)));
        }
      }
      print(temp);
      return recAttractions;
    } else {
      displayMsg('No connection to server: \nGR', context);
    }
  } catch (e) {
    print('gr: ');
    print(e);
  }
}

Future<void> updateLikedAttraction(BuildContext context) async {
  DataContainerState data = DataContainer.of(context);
  String liked = "";
  for (var item in data.getFavourites()) {
    liked += (item.getID().toString() + "|");
  }
  if (liked.length != 0) {
    var preEncode = {
      "username": await loadInt('currentUserID'),
      "liked": liked
    };
    var postEncode = jsonEncode(preEncode);
    try {
      String _apiAdress = apiAdress + '/update-liked-attractions/';
      var response = await http.post(_apiAdress,
          body: postEncode, headers: {"Content-Type": "application/json"});
      if (response.statusCode != 200) {
        displayMsg('Error: ' + response.statusCode.toString(), context);
      }
    } catch (e) {
      print(e);
    }
  }
}

Future<List<Attraction>> getLikedAttraction(BuildContext context) async {
  var jsonstring = {"username": await loadInt('currentUserID')};
  var jsonedString = jsonEncode(jsonstring);
  try {
    String _apiAdress = apiAdress + '/request-liked-attractions/';
    var response = await http.post(_apiAdress,
        body: jsonedString, headers: {"Content-Type": "application/json"});
    if (response.statusCode == 200) {
      var attracts = response.headers['attractions'];
      var decoded = attracts == null ? [] : jsonDecode(attracts);
      var t = decoded as List;
      List<Attraction> recAttractions = List<Attraction>();
      for (var i = 0; i < t.length; i++) {
        List<String> open = [];
        if (t[i]['opening_hours'] == "NA") {
          open.add('Not Available');
          open.add('Not Available');
          open.add('Not Available');
          open.add('Not Available');
          open.add('Not Available');
          open.add('Not Available');
          open.add('Not Available');
        } else {
          var oh = jsonDecode(t[i]['opening_hours']);
          for (var item in oh) {
            open.add(item.toString());
          }
        }

        recAttractions.add(new Attraction(
            t[i]['id'],
            t[i]['name'],
            open,
            t[i]['img_path'],
            !t[i]['isFoodPlace'],
            t[i]['rating'],
            t[i]['description'],
            t[i]['url'],
            t[i]['lat'],
            t[i]['long']));
      }
      return recAttractions;
      DataContainerState data = DataContainer.of(context);
      if (recAttractions.length != 0) {
        data.setFavourites(recAttractions);
      }
    } else {
      displayMsg('No connection to server.\nGLA', context);
    }
  } catch (e) {
    print('gla ');
    print(e);
  }
}

Future<void> checkLogIn(
    String username, String password, BuildContext context) async {
  var jsonstring = {"username": username, "password": password};
  var jsonedString = jsonEncode(jsonstring);
  try {
    String _apiadress = apiAdress + '/login/';
    var response = await http.post(_apiadress,
        body: jsonedString, headers: {"Content-Type": "application/json"});
    if (response.statusCode == 200) {
      saveString('currentUser', username.toString());
      //print(await loadString('currentUser'));
      var t = jsonDecode(response.headers['id']);
      int v = t['id'];
      saveInt('currentUserID', v);
      getPreferences(context);
      Navigator.pushNamed(context, '/');
    } else if (response.statusCode == 204) {
      displayMsg(
          'Coulnd\'t find a user with that username, or the password was wrong',
          context);
    } else {
      displayMsg('No connection to server.\nLI', context);
    }
  } catch (e) {
    print('checkLogIn');
    print(e);
  }
}

Future<void> checkSignUp(
    String username, String password, BuildContext context) async {
  var jsonstring = {"username": username, "password": password};
  var jsonedString = jsonEncode(jsonstring);
  try {
    String _apiAdress = apiAdress + '/create-user/';
    var response = await http.post(_apiAdress,
        body: jsonedString, headers: {"Content-Type": "application/json"});
    if (response.statusCode == 200) {
      saveString('currentUser', username.toString());
      var id = jsonDecode(response.headers['id']);
      saveInt('currentUserID', id);
      Navigator.pushNamedAndRemoveUntil(
          context, '/context_prompt', (Route<dynamic> route) => false);
    } else if (response.statusCode == 208) {
      displayMsg('Username already taken.', context);
    } else {
      displayMsg('No connection to server.\nSU', context);
    }
  } catch (e) {
    print('checkSignUp');
    print(e);
  }
}

void clearSharedPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.clear();
}

void deleteString(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove(key);
}

void saveString(String key, String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString(key, value);
}

void saveInt(String key, int value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt(key, value);
}

Future<int> loadInt(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getInt(key);
}

Future<String> loadString(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(key);
}

void saveBool(String key, bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool(key, value);
}

Future<bool> loadBool(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool(key);
}

void displayMsg(String msg, BuildContext context) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(msg),
        );
      });
}

void launchWebsite(String url, var context) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    displayMsg('Could not connect to $url', context);
  }
}

Coordinate findMiddlePoint(Coordinate one, Coordinate two) {
  double latdiff = one.getLat() < two.getLat()
      ? two.getLat() - one.getLat()
      : one.getLat() - two.getLat();
  double longdiff = one.getLong() < two.getLong()
      ? two.getLong() - one.getLong()
      : one.getLong() - two.getLong();
  longdiff = longdiff / 2;
  latdiff = latdiff / 2;
  double lat = one.getLat() < two.getLat()
      ? one.getLat() + latdiff
      : two.getLat() + latdiff;
  double long = one.getLong() < two.getLong()
      ? one.getLong() + longdiff
      : two.getLong() + longdiff;
  return new Coordinate(lat, long);
}

double distanceBetweenCoordinates(Coordinate c1, Coordinate c2) {
  var r = 6371000;
  double phi_1 = c1.getLat() * (pi / 180);
  double phi_2 = c2.getLat() * (pi / 180);
  double deltaPhi = (c2.getLat() - c1.getLat()) * (pi / 180);
  double deltaLambda = (c2.getLong() - c1.getLong()) * (pi / 180);
  var a = sin(deltaPhi / 2) * sin(deltaPhi / 2) +
      cos(phi_1) * cos(phi_2) * sin(deltaLambda / 2) * sin(deltaLambda / 2);
  var c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return r * c;
}

double zoomLevel(double distance) {
  var dist = (6371000 / distance);
  return log(dist) * 1.7;
}

class Coordinate {
  double _lat;
  double _long;
  Coordinate(double lat, double long) {
    _lat = lat;
    _long = long;
  }
  double getLat() {
    return _lat;
  }

  double getLong() {
    return _long;
  }
}

class User {
  String name;
  String email;
  User([String nameIn, String emailIn]) {
    name = nameIn;
    email = emailIn;
  }

  @override
  String toString() {
    return 'Name: ' + name + ' \n' + 'Email : ' + email;
  }
}

class Attraction {
  int _id;
  String _name;
  List<String> _openingHours;
  String _imgPath;
  String _description;
  double _rating;
  double _score;
  double _distance;
  bool _isFoodPlace;
  String _url;
  Coordinate _coordinate;
  String _phone_number;
  double _penalisedScore;

  Attraction(int id, String name, List<String> openingHours, String imgPath,
      bool isFoodPlace,
      [double rating,
      String description,
      String url,
      double lat,
      double long,
      double score,
      double distance,
      String phone_number]) {
    _id = id;
    _name = name;
    _openingHours = openingHours;
    _imgPath = imgPath;
    rating != null ? _rating = rating : _rating = 0;
    description != null
        ? description.length < 850
            ? _description = description
            : _description = description.substring(0, 850) + '...'
        : _description = 'No information is available for this attraction';
    url != null ? _url = url : _url = null;
    lat != null && long != null
        ? _coordinate = new Coordinate(lat, long)
        : _coordinate = null;
    _isFoodPlace = isFoodPlace;
    _score = score;
    _distance = distance;
    _phone_number = phone_number;
  }

  double getPenalisedScore() {
    return _penalisedScore;
  }

  void setPenalisedScore(double val) {
    this._penalisedScore = val;
  }

  int getID() {
    return _id;
  }

  String getName() {
    return _name;
  }

  List<String> getOpeningHours() {
    return _openingHours;
  }

  String getImgPath() {
    return _imgPath;
  }

  double getRating() {
    return _rating;
  }

  bool getIsFoodPlace() {
    return _isFoodPlace;
  }

  String getDescription() {
    return _description;
  }

  String getURL() {
    return _url;
  }

  Coordinate getCoordinate() {
    return _coordinate;
  }

  double getScore() => _score;

  double setScore(score) {
    _score = score;
  }

  double getDistance() => _distance;

  void setDistance(dist) {
    _distance = dist;
  }

  String getPhoneNumber() => _phone_number;

  void setPhoneNumber(pn) {
    _phone_number = pn;
  }

  @override
  bool operator ==(other) {
    return (other is Attraction && this._id == other.getID());
  }
}
