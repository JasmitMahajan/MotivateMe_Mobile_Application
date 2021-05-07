import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:motivateme_mobile_app/service/goal_manager.dart';

import 'model/subgoal.dart';

class CollagePage extends StatefulWidget {
  @override
  CollagePageState createState() => CollagePageState();
}

class CollagePageState extends State<CollagePage> {
  final goalManager = GoalManager();

  String retrieveDatesForCurrentWeek() {
    DateTime now = DateTime.now();
    int daysUntilMonday = now.weekday - DateTime.monday;
    int daysUntilSunday = DateTime.sunday - now.weekday;
    DateTime startOfWeek = now.subtract(Duration(days: daysUntilMonday));
    DateTime endOfWeek = now.add(Duration(days: daysUntilSunday));

    return DateFormat.yMd().format(startOfWeek) +
        ' to ' +
        DateFormat.yMd().format(endOfWeek);
  }

  Widget completedGoalCard(String filePath, String goalTitle) {
    return Card(
        elevation: 2.5,
        child: Container(
            child: Padding(
                padding: EdgeInsets.all(25.0),
                child: Column(children: [
                  Image.file(File(filePath)),
                  Padding(padding: EdgeInsets.only(top: 10.0, bottom: 10.0)),
                  Text('You completed ' + goalTitle + ' this week!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18.0))
                ]))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
              appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
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
              tileMode:
                  TileMode.repeated, // repeats the gradient over the canvas
            ),
          ),
          child: FutureBuilder(
              future: goalManager.retrieveSubGoalsForWeek(DateTime.now()),
              builder: (context, snapshot) {
                List<Widget> completedGoalsToDisplay = [];
                List<Widget> incompleteGoalsToDisplay = [];
                var listOfSubgoals = snapshot.data;
                if (snapshot.hasData) {
                  print('length of subgoals: ' +
                      listOfSubgoals.length.toString());
                  for (var subGoal in listOfSubgoals.entries) {
                    List<Widget> images = [];

                    for (var goal in subGoal.value) {
                      if (goal.completed == null) {
                        continue;
                      } else if (goal.completed && goal.pathToPicture != null) {
                        print('goal completed + path to picture not null');
                        File(goal.pathToPicture).exists().then((value) {
                          if (value) {
                            // images.add(Image.file(File(goal.pathToPicture)));
                            // images.add(Text(
                            //     'You completed ' + subGoal.key + ' this week!',
                            //     textAlign: TextAlign.center,
                            //     style: TextStyle(fontSize: 18.0)));
                            images.add(CompletedGoalCard(
                                goalTitle: subGoal.key,
                                pathToPicture: goal.pathToPicture));
                            completedGoalsToDisplay.add(Column(
                              children: images,
                            ));
                          } else {
                            completedGoalsToDisplay.add(CompletedGoalCard(
                              goalTitle: goal.title,
                            ));
                          }
                        });
                      } else if (goal.completed) {
                        completedGoalsToDisplay.add(CompletedGoalCard(
                          goalTitle: goal.title,
                        ));
                      } else if (!goal.completed && goal.comment != null) {
                        incompleteGoalsToDisplay.add(IncompleteGoalCard(
                            goalTitle: goal.title, goalComment: goal.comment));
                      } else {
                        incompleteGoalsToDisplay
                            .add(IncompleteGoalCard(goalTitle: goal.title));
                      }
                    }
                  }
                  return FutureBuilder(
                      future: Future.delayed(Duration(milliseconds: 500)),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return SingleChildScrollView(
                              physics: ScrollPhysics(),
                              child: Column(children: [
                                Padding(padding: EdgeInsets.only(top: 25.0)),
                                Text(retrieveDatesForCurrentWeek(),
                                    style: TextStyle(
                                        fontSize: 25.0,
                                        fontWeight: FontWeight.bold)),
                                Padding(
                                    padding: EdgeInsets.only(
                                        top: 10.0, bottom: 10.0)),
                                completedGoalsToDisplay.length == 0 &&
                                        incompleteGoalsToDisplay.length == 0
                                    ? Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.height,
                                        child: Text(
                                          'Nothing to see here 	╮(￣ω￣;)╭',
                                          style: TextStyle(
                                              fontSize: 25.0,
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ))
                                    : Container(height: 0, width: 0),
                                completedGoalsToDisplay.length == 0
                                    ? Container(height: 0, width: 0)
                                    : Text(
                                        'You completed the following!',
                                        style: TextStyle(
                                            fontSize: 25.0,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: completedGoalsToDisplay.length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        Column(
                                          children: [
                                            Padding(
                                                padding:
                                                    EdgeInsets.only(top: 50.0)),
                                            completedGoalsToDisplay
                                                .elementAt(index),
                                            Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 20.0)),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                Padding(
                                    padding: EdgeInsets.only(
                                        top: 10.0, bottom: 10.0)),
                                incompleteGoalsToDisplay.length == 0
                                    ? Container(height: 0, width: 0)
                                    : Text(
                                        "You weren't able to complete these goals",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 25.0,
                                            fontWeight: FontWeight.bold)),
                                ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: incompleteGoalsToDisplay.length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        Column(
                                          children: [
                                            Padding(
                                                padding:
                                                    EdgeInsets.only(top: 50.0)),
                                            incompleteGoalsToDisplay
                                                .elementAt(index),
                                            Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 50.0)),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                /* incompleteGoalsToDisplay.length == 0
                                    ? Container(height: 0, width: 0)
                                    : Center(
                                        child: Text(
                                            "Let's work hard to complete these goals! (* ^ ω ^)",
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.clip,
                                            style: TextStyle(
                                                fontSize: 25.0,
                                                fontWeight: FontWeight.bold)) ),*/
                              ]));
                        } else {
                          return Center(child: CircularProgressIndicator());
                        }
                      });
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              }),
        ));
  }
}

class CompletedGoalCard extends StatelessWidget {
  final String goalTitle;
  final String pathToPicture;

  CompletedGoalCard({Key key, this.goalTitle, this.pathToPicture})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 2.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Container(
            child: Padding(
                padding: EdgeInsets.all(25.0),
                child: Column(children: [
                  pathToPicture == null
                      ? Image.network(
                          'https://brobible.com/wp-content/uploads/2019/11/istock-153696622.jpg')
                      : Image.file(File(pathToPicture)),
                  Padding(padding: EdgeInsets.only(top: 10.0, bottom: 10.0)),
                  Text('You completed ' + goalTitle + ' this week!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18.0))
                ]))));
  }
}

class IncompleteGoalCard extends StatelessWidget {
  final String goalTitle;
  final String goalComment;

  IncompleteGoalCard({Key key, this.goalTitle, this.goalComment})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 2.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Container(
            child: Padding(
                padding: EdgeInsets.all(25.0),
                child: Column(children: [
                  Image.network(
                      'https://i.pinimg.com/originals/ec/6f/d9/ec6fd9522192b95eaba1318d79c9d6ae.jpg'),
                  Padding(padding: EdgeInsets.only(top: 10.0, bottom: 10.0)),
                  Text(
                      this.goalComment == null
                          ? "You didn't complete " +
                              this.goalTitle +
                              ' this week.'
                          : "You didn't complete " +
                              this.goalTitle +
                              " this week due to " +
                              this.goalComment +
                              ".",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18.0))
                ]))));
  }
}
