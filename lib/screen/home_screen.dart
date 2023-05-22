import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<DateTime> _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = _prefs.then((SharedPreferences prefs) {
      return DateTime.fromMillisecondsSinceEpoch(prefs.getInt('meetDate') ?? DateTime.now().millisecondsSinceEpoch);
    });
  }

  static void setLocalStorage(DateTime date) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();

    int timeStamp = date.millisecondsSinceEpoch;

    pref.setInt('meetDate', timeStamp);

    print(await getDateTime());
  }

  static Future<DateTime> getDateTime() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();

    int? timeStamp = pref.getInt('meetDate');

    timeStamp ??= DateTime.now().millisecondsSinceEpoch;

    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timeStamp);

    return dateTime;
  }

  DateTime selectedDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.pink[100],
        body: SafeArea(
          bottom: false,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: FutureBuilder<DateTime>(
                future: _selectedDate,
                builder: (BuildContext context, AsyncSnapshot<DateTime> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return const CircularProgressIndicator();
                    case ConnectionState.active:
                    case ConnectionState.done:
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return Column(
                          children: [
                            _TopPart(
                              selectedDate: snapshot.data!,
                              onPressed: onHeartPressed,
                            ),
                            const _BottomPart(),
                          ],
                        );
                      }
                  }
                }),
          ),
        ));
  }

  onHeartPressed() {
    final now = DateTime.now();

    showCupertinoDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 300.0,
              color: Colors.white,
              child: FutureBuilder<DateTime>(
                  future: _selectedDate,
                  builder: (BuildContext context, AsyncSnapshot<DateTime> snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                        return const CircularProgressIndicator();
                      case ConnectionState.active:
                      case ConnectionState.done:
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return CupertinoTheme(
                              data: CupertinoThemeData(
                                brightness: Theme.of(context).brightness,
                                textTheme: const CupertinoTextThemeData(
                                  dateTimePickerTextStyle: TextStyle(
                                    fontSize: 28,
                                  ),
                                ),
                              ),
                              child: CupertinoDatePicker(
                                mode: CupertinoDatePickerMode.date,
                                initialDateTime: snapshot.data,
                                maximumDate: DateTime(
                                  now.year,
                                  now.month,
                                  now.day,
                                ),
                                onDateTimeChanged: (DateTime date) {
                                  setState(() {
                                    selectedDate = date;
                                  });
                                  setLocalStorage(date);
                                },
                              ));
                        }
                    }
                  }),
            ),
          );
        });
  }
}

class _TopPart extends StatelessWidget {
  final now = DateTime.now();
  final DateTime selectedDate;
  final VoidCallback onPressed;

  _TopPart({required this.selectedDate, required this.onPressed, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            'U&I',
            style: theme.textTheme.displayLarge,
          ),
          Column(
            children: [
              Text(
                '우리 처음 만난 날',
                style: theme.textTheme.bodyLarge,
              ),
              Text(
                '${selectedDate.year}.${selectedDate.month}.${selectedDate.day}',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
          IconButton(
            iconSize: 60.0,
            onPressed: onPressed,
            icon: const Icon(
              Icons.favorite,
              color: Colors.red,
            ),
          ),
          Text(
            'D+${DateTime(
                  now.year,
                  now.month,
                  now.day,
                ).difference(selectedDate).inDays + 1}',
            style: theme.textTheme.displayMedium,
          ),
        ],
      ),
    );
  }
}

class _BottomPart extends StatelessWidget {
  const _BottomPart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Image.asset(
        'asset/img/middle_image.png',
      ),
    );
  }
}
