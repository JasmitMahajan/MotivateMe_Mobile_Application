import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:flutter/material.dart';
import 'package:motivateme_mobile_app/add_goals_page.dart';
import 'package:motivateme_mobile_app/camera_page.dart';
import 'package:motivateme_mobile_app/service/inspire_me.dart';
import 'package:motivateme_mobile_app/subgoal_widget.dart';
import 'model/subgoal.dart';
import 'service/goal_manager.dart';
import 'service/auth.dart';

class HomePage extends StatefulWidget {
  HomePage({
    Key key,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService authService = AuthService();
  final InspireMeService inspireMeService = InspireMeService();
  TextEditingController _textFieldController = TextEditingController();

  List<int> items = List<int>.generate(20, (int index) => index);

  final GoalManager goalManager = GoalManager();

  callback(newValue) {
    if (newValue == true) {
      setState(() {});
    }
  }

  Future<void> removeSubGoal(
      List<SubGoal> subGoals, int index, bool completed) async {
    Future.delayed(Duration(milliseconds: 500)).then((_) {
      if (completed) {
        goalManager.markGoalAsComplete(subGoals.elementAt(index));
      } else {
        goalManager.markGoalAsIncomplete(subGoals.elementAt(index));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 2
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => AddGoalsPage()))
              .then((value) {
            if (value == true) {
              print("value is true");
              setState(() {
                print("set state");
              });
            }
          });
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.lightGreen,
      ),
      body: Container(
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
            tileMode: TileMode.repeated, // repeats the gradient over the canvas
          ),
        ),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Center(
              child: Column(children: [
            Padding(padding: EdgeInsets.only(top: 55.0)),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: <
                Widget>[
              Container(
                alignment: Alignment.topRight,
                width: 58.75,
                height: 62.75,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('icon/motivatemelogo.png'),
                    fit: BoxFit.fill,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              SizedBox(
                width: 80,
              ),
              Container(
                  alignment: Alignment.topLeft,
                  child: FutureBuilder(
                      future: Amplify.Auth.fetchUserAttributes(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          List<AuthUserAttribute> firstName = snapshot.data
                              .where((element) =>
                                  element.userAttributeKey ==
                                  'custom:first_name')
                              .toList();

                          DateTime now = DateTime.now();
                          String currentMonth = DateTime.now().month.toString();
                          String currentDay = DateTime.now().day.toString();

                          if (int.parse(currentMonth) < 10) {
                            currentMonth =
                                '0' + DateTime.now().month.toString();
                          }
                          if (int.parse(currentDay) < 10) {
                            currentDay = '0' + DateTime.now().day.toString();
                          }

                          String currentDate = DateTime.now().year.toString() +
                              '-' +
                              currentMonth +
                              '-' +
                              currentDay;

                          DateTime afternoon =
                              DateTime.parse(currentDate + ' 12:00:00');
                          DateTime evening =
                              DateTime.parse(currentDate + ' 17:00:00');
                          DateTime night =
                              DateTime.parse(currentDate + ' 20:00:00');

                          if (firstName.isEmpty) {
                            if (now.isBefore(afternoon)) {
                              return Text('Good Morning!',
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                  ));
                            } else if (now.isAfter(afternoon) &&
                                now.isBefore(evening)) {
                              return Text('Good Afternoon!',
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                  ));
                            } else if (now.isAfter(evening) &&
                                now.isBefore(night)) {
                              return Text('Good Evening!',
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                  ));
                            } else {
                              return Text('Good Night!',
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                  ));
                            }
                          }

                          if (now.isBefore(afternoon)) {
                            return Text(
                                'Good Morning ' +
                                    firstName.first.value.toString() +
                                    '!',
                                style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                ));
                          } else if (now.isAfter(afternoon) &&
                              now.isBefore(evening)) {
                            return Text(
                                'Good Afternoon ' +
                                    firstName.first.value.toString() +
                                    '!',
                                style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                ));
                          } else if (now.isAfter(evening) &&
                              now.isBefore(night)) {
                            return Text(
                                'Good Evening ' +
                                    firstName.first.value.toString() +
                                    '!',
                                style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                ));
                          } else {
                            return Text(
                                'Good Night ' +
                                    firstName.first.value.toString() +
                                    '!',
                                style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                ));
                          }
                        } else {
                          DateTime now = DateTime.now();
                          String currentMonth = DateTime.now().month.toString();
                          String currentDay = DateTime.now().day.toString();

                          if (int.parse(currentMonth) < 10) {
                            currentMonth =
                                '0' + DateTime.now().month.toString();
                          }
                          if (int.parse(currentDay) < 10) {
                            currentDay = '0' + DateTime.now().day.toString();
                          }

                          String currentDate = DateTime.now().year.toString() +
                              '-' +
                              currentMonth +
                              '-' +
                              currentDay;

                          DateTime afternoon =
                              DateTime.parse(currentDate + ' 12:00:00');
                          DateTime evening =
                              DateTime.parse(currentDate + ' 17:00:00');
                          DateTime night =
                              DateTime.parse(currentDate + ' 20:00:00');

                          if (now.isBefore(afternoon)) {
                            return Text('Good Morning!',
                                style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                ));
                          } else if (now.isAfter(afternoon) &&
                              now.isBefore(night)) {
                            return Text('Good Afternoon!',
                                style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                ));
                          } else if (now.isAfter(evening) &&
                              now.isBefore(night)) {
                            return Text(
                              'Good Evening!',
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          } else {
                            return Text('Good Night!',
                                style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                ));
                          }
                        }
                      })),
            ]),
            Container(
              padding: EdgeInsets.only(top: 10.0),
              alignment: Alignment.topCenter,
              child: OutlinedButton(
                  onPressed: () async {
                    var url = await inspireMeService.inspireMe();
                    return showDialog<void>(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('You are now... inspired'),
                            content: SingleChildScrollView(
                                child: Image.network(url)),
                            actions: [
                              TextButton(
                                  child: Text('Back to work!',
                                      style: TextStyle(
                                          color:
                                              Theme.of(context).primaryColor)),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  })
                            ],
                          );
                        });
                  },
                  child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        'Inspire Me',
                        style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      )),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Color(0xfff5855b)),
                    elevation: MaterialStateProperty.all<double>(10.0),
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32.0),
                      ),
                    ),
                  )),
            ),
            Padding(padding: EdgeInsets.only(top: 20.0)),
            Text('Your goals for today!',
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                )),
            Padding(padding: EdgeInsets.only(bottom: 10.0)),
            FutureBuilder<List<SubGoal>>(
                future: Future.delayed(Duration(milliseconds: 500),
                    goalManager.retrieveSubGoalsForToday),
                builder: (BuildContext context,
                    AsyncSnapshot<List<SubGoal>> snapshot) {
                  if (snapshot.hasData) {
                    List<SubGoal> subGoals = snapshot.data;
                    return ListView.builder(
                      // physics: const AlwaysScrollableScrollPhysics(),
                      physics: ClampingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: subGoals.length,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      itemBuilder: (BuildContext context, int index) {
                        print(index.toString() +
                            " " +
                            subGoals.elementAt(index).startDate.toString());
                        return Dismissible(
                          child: SubGoalWidget(
                              subgoal: subGoals.elementAt(index),
                              title: subGoals.elementAt(index).title,
                              description:
                                  subGoals.elementAt(index).description,
                              callback: this.callback),
                          background: Container(
                              height: 50,
                              width: 50,
                              padding: EdgeInsets.only(left: 60.0),
                              alignment: Alignment.centerLeft,
                              color: Colors.green,
                              child: Icon(Icons.check,
                                  color: Colors.white, size: 50)),
                          secondaryBackground: Container(
                              height: 50,
                              width: 50,
                              padding: EdgeInsets.only(right: 60.0),
                              alignment: Alignment.centerRight,
                              color: Colors.red,
                              child: Icon(Icons.clear,
                                  color: Colors.white, size: 50)),
                          key: UniqueKey(),
                          onDismissed: (DismissDirection direction) {
                            var markedSubGoal = subGoals.elementAt(index);

                            if (direction == DismissDirection.startToEnd) {
                              removeSubGoal(subGoals, index, true);
                              setState(() {
                                removeSubGoal(subGoals, index, true);
                              });
                              completedGoals(markedSubGoal);
                            }
                            if (direction == DismissDirection.endToStart) {
                              removeSubGoal(subGoals, index, false);
                              setState(() {
                                removeSubGoal(subGoals, index, false);
                              });
                              incompleteGoals(markedSubGoal);
                            }
                          },
                        );
                      },
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(
                          backgroundColor: Colors.green),
                    );
                  }
                })
          ])),
        ),
      ),
    );
  }

  Future<void> completedGoals(SubGoal subGoal) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Congrats!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.camera_alt),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                CameraPage(subGoal: subGoal))).then((value) {
                      print('value: ' + value.toString());
                      if (value == true) {
                        print("value is true");
                        Navigator.of(context).pop();
                        setState(() {});
                      } else {}
                    });
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Skip'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {});
              },
            ),
          ],
        );
      },
    );
  }

  String valueText;
  String codeDialog;
  Future<void> incompleteGoals(SubGoal subGoal) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Incomplete Goals'),
            content: TextFormField(
              onChanged: (value) {
                setState(() {
                  valueText = value;
                });
              },
              keyboardType: TextInputType.multiline,
              maxLines: null,
              controller: _textFieldController,
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                hintText: 'Reason for not completing goal',
                contentPadding:
                    new EdgeInsets.symmetric(vertical: 30.0, horizontal: 10.0),
                border: OutlineInputBorder(
                  borderSide: BorderSide(width: 5.0, color: Colors.red),
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text("Skip"),
                style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.red)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.green)),
                onPressed: () {
                  setState(() {
                    codeDialog = valueText;
                    goalManager.setCommentForSubGoal(subGoal, codeDialog);
                    Navigator.pop(context);
                  });
                },
                child: Text('Submit'),
              ),
            ],
          );
        });
  }
}
