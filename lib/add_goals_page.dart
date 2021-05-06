import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:motivateme_mobile_app/model/goal.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'service/auth.dart';
import 'model/sign_up_result.dart';
import 'package:day_picker/day_picker.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'service/goal_manager.dart';

class AddGoalsPage extends StatefulWidget {
  AddGoalsPage({Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _AddGoalsPageState();
}

class _AddGoalsPageState extends State<AddGoalsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AutovalidateMode _autoValidate = AutovalidateMode.disabled;
  final _goalTitleController = TextEditingController();
  final _goalDescriptionController = TextEditingController();
  DateTime startDate;
  DateTime endDate;
  DateTime startTime;
  DateTime endTime;

  final goalManager = GoalManager();

  Map<String, bool> goalDays = {
    'Monday': false,
    'Tuesday': false,
    'Wednesday': false,
    'Thursday': false,
    'Friday': false,
    'Saturday': false,
    'Sunday': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Goals Page'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color(0xffB7F8DB), const Color(0xff50A7C2)],
          )),
        ),
      ),
      body: new GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment
                  .centerRight, // 10% of the width, so there are ten blinds.
              colors: [
                const Color(0xffB7F8DB),
                const Color(0xff50A7C2)
              ], // red to yellow
              tileMode:
                  TileMode.repeated, // repeats the gradient over the canvas
            ),
            boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.9),
                  spreadRadius: 4,
                  blurRadius: 10,
                  offset: Offset(0, 3),
                )
            ]
          ),
          child: Center(
            child: Container(
                child: Stack(children: [
              SingleChildScrollView(
                padding: EdgeInsets.only(top: 20.0, left: 10.0, right: 10.0),
                child: Column(children: <Widget>[
                  Form(
                    key: _formKey,
                    autovalidateMode: _autoValidate,
                    child: _addGoalForm(),
                  ),
                  SizedBox(height: 40.0),
                  SizedBox(
                    width: 300.0,
                    height: 40.0,
                    child: OutlinedButton(
                      child: new Text(
                        'Add',
                        style:
                            new TextStyle(fontSize: 17.0, color: Colors.black),
                      ),
                      onPressed: _validateInputs,
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.tealAccent),
                        elevation: MaterialStateProperty.all<double>(10.0),
                        //side: MaterialStateProperty.all<BorderSide>(
                          //BorderSide(width: 3.0, color: Colors.black),
                        //),
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32.0),
                            //side: BorderSide(width: 3, color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ])),
          ),
        ),
      ),
    );
  }

  Widget _addGoalForm() {
    final timeFormat = DateFormat("HH:mm");
    final dateFormat = DateFormat("MM/dd/yyyy");

    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      TextFormField(
        validator: validateGoalTitle,
        controller: _goalTitleController,
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          hintText: 'New Goal',
          contentPadding:
              new EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          border: OutlineInputBorder(
            borderSide: BorderSide(width: 3.0, color: Colors.red),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(10.0),
      ),
      Row(
        children: [
          Flexible(child: Text("Start Date: ")),
          Expanded(
            child: DateTimeField(
              format: dateFormat,
              onShowPicker: (context, currentValue) async {
                final time = await showDatePicker(
                    context: context,
                    firstDate: DateTime(1900),
                    initialDate: currentValue ?? DateTime.now(),
                    lastDate: DateTime(2100));
                setState(() {
                  this.startDate = time;
                });
                return time;
              },
            ),
          ),
          Flexible(child: Text("End Date: ")),
          Expanded(
            child: DateTimeField(
              format: dateFormat,
              onShowPicker: (context, currentValue) async {
                final time = await showDatePicker(
                    context: context,
                    firstDate: DateTime(1900),
                    initialDate: currentValue ?? DateTime.now(),
                    lastDate: DateTime(2100));
                setState(() {
                  this.endDate = time;
                });
                return time;
              },
            ),
          )
        ],
      ),
      Padding(
        padding: const EdgeInsets.all(10.0),
      ),
      Row(
        children: [
          Flexible(child: Text("Start Time: ")),
          Expanded(
            child: DateTimeField(
              format: timeFormat,
              onShowPicker: (context, currentValue) async {
                final time = await showTimePicker(
                  context: context,
                  initialTime:
                      TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                );
                setState(() {
                  startTime = DateTimeField.convert(time);
                });
                return DateTimeField.convert(time);
              },
            ),
          ),
          Flexible(child: Text("End Time: ")),
          Expanded(
            child: DateTimeField(
              format: timeFormat,
              onShowPicker: (context, currentValue) async {
                final time = await showTimePicker(
                  context: context,
                  initialTime:
                      TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                );

                setState(() {
                  endTime = DateTimeField.convert(time);
                });
                print(endTime);

                return DateTimeField.convert(time);
              },
            ),
          )
        ],
      ),
      Padding(
        padding: const EdgeInsets.all(10.0),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: SelectWeekDays(
          border: false,
          boxDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              colors: [const Color(0xFFE55CE4), const Color(0xFFBB75FB)],
              tileMode:
                  TileMode.repeated, // repeats the gradient over the canvas
            ),
            boxShadow: [
                BoxShadow(
                  color: Colors.pink.withOpacity(0.2),
                  spreadRadius: 4,
                  blurRadius: 10,
                  offset: Offset(0, 3),
                )
            ]
          ),
          onSelect: (values) {
            // <== Callback to handle the selected days
            print(values);
            for (var entry in goalDays.entries) {
              goalDays[entry.key] = values.contains(entry.key);
            }

            for (var entry in goalDays.entries) {
              print(entry);
            }
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(10.0),
      ),
      TextFormField(
        validator: validateDescription,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        inputFormatters: [
          new LengthLimitingTextInputFormatter(200),
        ],
        controller: _goalDescriptionController,
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          hintText: 'Description',
          contentPadding:
              new EdgeInsets.symmetric(vertical: 30.0, horizontal: 10.0),
          border: OutlineInputBorder(
            //borderRadius: BorderRadius.circular(50.0),
            borderSide: BorderSide(width: 5.0, color: Colors.red),
          ),
        ),
      ),
    ]);
  }

  void _validateInputs() {
    if (_formKey.currentState.validate()) {
      for (var entry in goalDays.entries) {
        if (entry.value == true) {
          _addGoal();
          //TODO refresh home page
          Navigator.pop(
            context,
          );
          return;
        }
      }
      _showMyDialog();
    } else {
      setState(() {
        _autoValidate = AutovalidateMode.onUserInteraction;
      });
    }
  }

  String validateGoalTitle(String value) {
    if (value.length == 0)
      return 'Goal title is required';
    else
      return null;
  }

  String validateDescription(String value) {
    if (value.length == 0)
      return 'Description is required';
    else
      return null;
  }

  void _addGoal() async {
    final goalTitle = _goalTitleController.text.trim();
    final goalDescription = _goalDescriptionController.text.trim();
    print('goal: $goalTitle');

    int goalID = await goalManager.retrieveNumberOfGoals() + 1;

    Goal goal = Goal(
      id: goalID,
      title: goalTitle,
      description: goalDescription,
      startDate: this.startDate,
      endDate: this.endDate,
      startTime: this.startTime,
      endTime: this.endTime,
      goalDays: goalDays,
      isComplete: false,
    );
    await goalManager.insertGoal(goal);
    print('success!');
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('No days are selected'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Please select a day'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
