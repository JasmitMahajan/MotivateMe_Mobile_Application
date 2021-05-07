import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:motivateme_mobile_app/model/goal.dart';
import 'package:day_picker/day_picker.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:weekday_selector/weekday_selector.dart';
import 'model/subgoal.dart';
import 'service/goal_manager.dart';

class EditGoalPage extends StatefulWidget {
  final SubGoal subGoal;
  final String title;
  final String description;
  EditGoalPage({Key key, this.subGoal, this.title, this.description})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => _EditGoalPageState();
}

class _EditGoalPageState extends State<EditGoalPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AutovalidateMode _autoValidate = AutovalidateMode.disabled;
  final _goalTitleController = TextEditingController();
  final _goalDescriptionController = TextEditingController();
  DateTime startDate;
  DateTime endDate;
  DateTime startTime;
  DateTime endTime;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final goalManager = GoalManager();
  final values = List.filled(7, false);
  final Map<int, String> indexToDay = {
    0: 'sunday',
    1: 'monday',
    2: 'tuesday',
    3: 'wednesday',
    4: 'thursday',
    5: 'friday',
    6: 'saturday'
  };
  final Map<String, int> dayToIndex = {
    'sunday': 0,
    'monday': 1,
    'tuesday': 2,
    'wednesday': 3,
    'thursday': 4,
    'friday': 5,
    'saturday': 6,
  };

  Map<String, bool> goalDays = {
    'monday': false,
    'tuesday': false,
    'wednesday': false,
    'thursday': false,
    'friday': false,
    'saturday': false,
    'sunday': false,
  };

  @override
  void initState() {
    super.initState();
    _goalTitleController.text = widget.subGoal.title;
    _goalDescriptionController.text = widget.subGoal.description;
    this.startDate = widget.subGoal.startDate;
    this.endDate = widget.subGoal.endDate;
    this.startTime = widget.subGoal.startTime;
    this.endTime = widget.subGoal.endTime;
    for (var entry in widget.subGoal.goalDays.entries) {
      goalDays[entry.key] = entry.value;
      this.values[dayToIndex[entry.key]] = entry.value;
    }
    print('setting state: ' + this.startDate.toString());
    print('setting state: ' + this.endDate.toString());
    print('setting state: ' + this.startTime.toString());
    print('setting state: ' + this.endTime.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            onPressed: () {
              confirmedDelete().then((value) {
                if(value) {
                  Navigator.pop(context, true);
                }
              });
            },
            icon: Icon(Icons.delete),
            color: Colors.grey[800],
          )
        ],
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
          height: MediaQuery.of(context).size.height,
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
          ),
          child: Container(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Column(children: <Widget>[
                Padding(padding: EdgeInsets.only(top: 30.0)),
                Container(
                  padding: EdgeInsets.only(bottom: 30.0),
                  child: Text('Edit Goal',
                      style: TextStyle(
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold,
                      )),
                ),
                Form(
                  key: _formKey,
                  autovalidateMode: _autoValidate,
                  child: _editGoalForm(),
                ),
                SizedBox(height: 40.0),
                SizedBox(
                  width: 300.0,
                  height: 40.0,
                  child: OutlinedButton(
                    child: new Text(
                      'Save',
                      style: new TextStyle(fontSize: 17.0, color: Colors.white),
                    ),
                    onPressed: _validateInputs,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Theme.of(context).primaryColor),
                      elevation: MaterialStateProperty.all<double>(10.0),
                      shape: MaterialStateProperty.all<OutlinedBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32.0),
                        ),
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _editGoalForm() {
    final timeFormat = DateFormat("hh:mm a");
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
          Flexible(
            child: DateTimeField(
              decoration: InputDecoration(
                  labelText: "Start Date",
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 1.0))),
              format: dateFormat,
              initialValue: widget.subGoal.startDate,
              onShowPicker: (context, currentValue) async {
                final time = await showDatePicker(
                    context: context,
                    firstDate: widget.subGoal.startDate,
                    initialDate: currentValue ?? widget.subGoal.startDate,
                    lastDate: DateTime(2100));
                setState(() {
                  this.startDate = time;
                });
                return time;
              },
            ),
          ),
          SizedBox(
            width: 20,
          ),
          Flexible(
            child: DateTimeField(
              decoration: InputDecoration(
                  labelText: "End Date",
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 1.0))),
              format: dateFormat,
              initialValue: widget.subGoal.endDate,
              onShowPicker: (context, currentValue) async {
                final time = await showDatePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    initialDate: currentValue ?? widget.subGoal.endDate,
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
          Flexible(
            child: DateTimeField(
              decoration: InputDecoration(
                  labelText: "Start Time",
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 1.0))),
              format: timeFormat,
              initialValue: widget.subGoal.startTime,
              onShowPicker: (context, currentValue) async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(
                      currentValue ?? widget.subGoal.startTime),
                );
                setState(() {
                  this.startTime = DateTimeField.convert(time);
                });
                return DateTimeField.convert(time);
              },
            ),
          ),
          SizedBox(
            width: 20.0,
          ),
          Flexible(
            child: DateTimeField(
              decoration: InputDecoration(
                  labelText: "End Time",
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 1.0))),
              format: timeFormat,
              initialValue: widget.subGoal.endTime,
              onShowPicker: (context, currentValue) async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(
                      currentValue ?? widget.subGoal.endTime),
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
      WeekdaySelector(
        firstDayOfWeek: DateTime.sunday,
        shortWeekdays: [
          'Sun',
          'Mon',
          'Tue',
          'Wed',
          'Thu',
          'Fri',
          'Sat',
        ],
        onChanged: (int day) {
          setState(() {
            // Use module % 7 as Sunday's index in the array is 0 and
            // DateTime.sunday constant integer value is 7.
            final index = day % 7;
            // We "flip" the value in this example, but you may also
            // perform validation, a DB write, an HTTP call or anything
            // else before you actually flip the value,
            // it's up to your app's needs.
            values[index] = !values[index];
            this.goalDays[indexToDay[index]] = values[index];
          });
          for (var entry in this.goalDays.entries) {
            print(entry.key + ' ' + entry.value.toString());
          }
        },
        values: values,
        selectedFillColor: Theme.of(context).primaryColor,
        selectedShape: RoundedRectangleBorder(),
        shape: RoundedRectangleBorder(
          side: BorderSide(),
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
          Navigator.pop(context, true);
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

    int goalID = widget.subGoal.id;

    Map<String, bool> formattedGoalDays = {
      'Monday': this.goalDays['monday'],
      'Tuesday': this.goalDays['tuesday'],
      'Wednesday': this.goalDays['wednesday'],
      'Thursday': this.goalDays['thursday'],
      'Friday': this.goalDays['friday'],
      'Saturday': this.goalDays['saturday'],
      'Sunday': this.goalDays['sunday'],
    };

    Goal goal = Goal(
      id: goalID,
      title: goalTitle,
      description: goalDescription,
      startDate: this.startDate,
      endDate: this.endDate,
      startTime: this.startTime,
      endTime: this.endTime,
      goalDays: formattedGoalDays,
      isComplete: false,
    );

    print('start date: ' + goal.startDate.toString());
    print('end date: ' + goal.endDate.toString());
    await goalManager.updateGoal(goal);
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

  Future<bool> confirmedDelete() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure you want to delete this goal?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                goalManager.deleteGoal(widget.subGoal);
                Navigator.pop(context, true);
              },
            ),
          ],
        );
      },
    );
  }
}
