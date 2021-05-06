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

  Future<void> removeSubGoal(List<SubGoal> subGoals, int index) async {
    Future.delayed(Duration(milliseconds: 500)).then((_) {
      goalManager.markGoalAsComplete(subGoals.elementAt(index));
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
                  builder: (BuildContext context) => AddGoalsPage()));
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
            Container(
              padding: EdgeInsets.only(top: 10.0),
              alignment: Alignment.topCenter,
              child: TextButton(
                onPressed: () async {
                  var url = await inspireMeService.inspireMe();
                  return showDialog<void>(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('AWS Test'),
                          content:
                              SingleChildScrollView(child: Image.network(url)),
                          actions: [
                            TextButton(
                                child: Text('Very Nice'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                })
                          ],
                        );
                      });
                },
                child: Padding(
                  padding: const EdgeInsets.all(35.0),
                child: new Text(
                  'Inspire Me',
                  style: new TextStyle(fontSize: 16.0, color: Colors.black),
                ),
                ),
              ),
            ),
            Padding(
                  padding: const EdgeInsets.all(10.0),
            ),
            FutureBuilder<List<SubGoal>>(
                future: goalManager.retrieveSubGoalsForToday(),
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
                            subGoals.elementAt(index).hashCode.toString());
                        return Dismissible(
                          child: SubGoalWidget(
                              subgoal: subGoals.elementAt(index),
                              title: subGoals.elementAt(index).title,
                              description:
                                  subGoals.elementAt(index).description),
                          background: Container(
                              padding: EdgeInsets.only(left: 60.0),
                              alignment: Alignment.centerLeft,
                              color: Colors.green,
                              child: Icon(Icons.check)),
                          secondaryBackground:
                              Container(color: Colors.red, child: Text("left")),
                          key: UniqueKey(),
                          onDismissed: (DismissDirection direction) async {
                            await removeSubGoal(subGoals, index);
                            if (direction == DismissDirection.startToEnd) {
                              completedGoals();
                            }
                            if (direction == DismissDirection.endToStart) {
                              incompleteGoals();
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

  Future<void> completedGoals() async {
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
                            builder: (BuildContext context) => CameraPage()));
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
              },
            ),
          ],
        );
      },
    );
  }

  String valueText;
  String codeDialog;
  Future<void> incompleteGoals() async {
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
