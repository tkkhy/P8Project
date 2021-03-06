import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'data_provider.dart';
import 'data_container.dart';
import 'utility.dart';

void clearSharedPrefs() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.clear();
}

class Settings extends State<SettingsState> {
  int _n =  1;
  String dropdownValue = 'Solo';
  bool createRecAttOnly = true;
  bool distPenEnabled = true;
  bool isDarkTheme = false;

  @override
  void initState() {
    loadInt('dist').then(loadDistance);
    loadString('tripType').then(loadTripType);
    loadBool('createRecAttOnly').then(loadcreateRecAttOnly);
    loadBool('distPenEnabled').then(loadDistPenEnabled);
    loadBool('theme').then(loadTheme);
    //clearSharedPrefs();
    super.initState();
  }

  void loadDistPenEnabled(enabled) {
    setState(() {
     this.distPenEnabled = enabled ?? true; 
    });
  }

  void loadTheme(theme) {
    setState(() {
      this.isDarkTheme = theme;
    });
  }

  void loadTripType(String tripType) {
    setState(() {
      this.dropdownValue = tripType ?? 'Solo';
    });
  }

  loadcreateRecAttOnly(bool onlyRec){
    setState(() {
      this.createRecAttOnly = onlyRec ?? false;
    });
  }

  void loadDistance(int distance) {
    setState(() {
      this._n = distance ?? 1;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getPreferences(context);
    loadInt('dist').then(loadDistance);
    loadString('tripType').then(loadTripType);
    loadBool('createRecAttOnly').then(loadcreateRecAttOnly);
    loadBool('distPenEnabled').then(loadDistPenEnabled);
    loadBool('theme').then(loadTheme);
  }

  @override
  Widget build(BuildContext context) {
    DataContainerState data = DataContainer.of(context);    
    return Theme(
      data: data.getTheme(),
      child: Scaffold(      
      appBar: AppBar(
        title: Row(
          //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text('Settings  '),
            Icon(Icons.settings),
          ],
        )        
      ),
      body: WillPopScope(
        onWillPop: (){

          if(loadInt('dist') != _n || loadString('tripType') != dropdownValue){
            data.setUpdateRecs(true);
          }

          data.setDist(_n);
          saveInt('dist', _n);
          data.setTripType(dropdownValue);
          saveString('tripType', dropdownValue);
          data.setcreateRecAttOnly(createRecAttOnly);
          saveBool('createRecAttOnly', createRecAttOnly);
          data.setDistPenEnabled(distPenEnabled);
          saveBool('distPenEnabled', distPenEnabled);
          data.setTheme(isDarkTheme ? jdDarkTheme() : jdLightTheme()); 
          saveBool('theme', isDarkTheme);

          print('saved');
          return new Future.value(true);
        },
        child:_customSettings(),
      )
      //primary: false,
    ));
  }

  Widget _customSettings() {    
    DataContainerState data = DataContainer.of(context); 
    double width = MediaQuery.of(context).size.width;
    return SizedBox(
      width: width,
      child: ListView(
        children: <Widget>[
          Divider(),
          ListTile(
            title: Container(
              constraints: BoxConstraints(maxWidth: width),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  SizedBox(
                    width: width / 2,
                    child: Text('Max recommendation distance (km)'),
                  ),
                  Row(
                    children: <Widget>[
                      SizedBox(
                        width: width / 10,
                        child: FlatButton(
                          onPressed: decrement,
                          child: Center(
                            child: Icon(
                              Icons.arrow_left,
                            ),
                          ),
                        ),
                      ),
                      Text('$_n'),
                      SizedBox(
                        width: width / 10,
                        child: FlatButton(
                          onPressed: increment,
                          child: Icon(
                            Icons.arrow_right,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          Divider(),
          ListTile(
            title: Container(
              constraints: BoxConstraints(maxWidth: width),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  SizedBox(
                    width: width / 2,
                    child: Text('How are you traveling'),
                  ),
                  DropdownButton<String>(
                    value: dropdownValue,
                    onChanged: (String newValue) {
                      setState(() {
                        dropdownValue = newValue;
                      });
                    },
                    items: <String>['Solo', 'Couple', 'Family', 'Business']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          Divider(),
          ListTile(
            title: Text('Change your category ratings'),
            trailing: Icon(Icons.border_color),
            onTap: () {
              Navigator.pushNamed(context, '/select_interests');
            },
          ),
          Divider(),
          SwitchListTile(
            title: Text('Show only recommended attractions'),
            value: createRecAttOnly,

            onChanged: (value) {
              createRecAttOnly = !createRecAttOnly;
            }
          ),
          Divider(),          
          SwitchListTile(
            title: Text('Recommendations are distance sensitive'),
            value: distPenEnabled,

            onChanged: (value) {
              distPenEnabled = !distPenEnabled;
            }
          ),
          Divider(),
          SwitchListTile(
            title: Text('Dark theme'),
            value: isDarkTheme,

            onChanged: (value) {
              isDarkTheme = !isDarkTheme;            
            }
          ),
          Divider(),
          ListTile(
            title: Text('Delete local data'),
            trailing: Icon(Icons.warning),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Delete local data?'),
                    content: Text('This will remove all data from your device such as rating information, favorite places, login information etc.'),
                    actions: <Widget>[
                      FlatButton(
                        child: const Text('Delete'),
                        onPressed: () {
                          clearSharedPrefs();
                          Navigator.pushNamedAndRemoveUntil(context, '/LogIn', (Route<dynamic> route) => false);
                        },
                      ),
                      FlatButton(
                        child: const Text('Cancel'),
                        onPressed: (){Navigator.of(context).pop();},
                      ),
                    ],
                  );
                }
              );
            },
          ),
          Divider(),
          ListTile(
            title: Text('Log out'),
            trailing: Icon(Icons.exit_to_app),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Are you sure you want to log out?'),
                    actions: <Widget>[
                      FlatButton(
                        child: const Text('Log out'),
                        onPressed: () {
                          deleteString('currentUser');
                          Navigator.pushNamedAndRemoveUntil(context, '/LogIn', (Route<dynamic> route) => false);
                        },
                      ),
                      FlatButton(
                        child: const Text('Cancel'),
                        onPressed: (){Navigator.of(context).pop();},
                      ),
                    ],
                  );
                }
              );
            },
          ),
        ],
      ),
    );
  }

  void decrement() {
    setState(() {
      if (_n != 1) _n--;
    });
  }

  void increment() {
    setState(() {
      if (_n != 9) _n++;
    });
  }
}

class SettingsState extends StatefulWidget {
  @override
  Settings createState() => Settings();
}
