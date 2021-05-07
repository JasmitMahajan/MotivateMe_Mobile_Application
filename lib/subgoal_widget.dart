import 'package:flutter/material.dart';
import 'package:motivateme_mobile_app/edit_goal_page.dart';
import 'package:motivateme_mobile_app/model/subgoal.dart';

import 'model/goal.dart';

// represents a subgoal widget
class SubGoalWidget extends StatefulWidget {
  final SubGoal subgoal;
  final String title;
  final String description;
  SubGoalWidget({Key key, this.subgoal, this.title, this.description})
      : super(key: key);

  @override
  SubGoalWidgetState createState() => SubGoalWidgetState();
}

class SubGoalWidgetState extends State<SubGoalWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: Text(widget.title,
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
            subtitle:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(padding: EdgeInsets.only(top: 1.0, bottom: 1.0)),
              Text(
                widget.subgoal.timeFrame,
                style: TextStyle(
                  fontSize: 15.0,
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 1.0, bottom: 1.0)),
              Text(widget.description,
                  style: TextStyle(
                    fontSize: 15.0,
                  )),
            ]),
            isThreeLine: true,
            trailing: Container(
                height: 50,
                width: 50,
                child: TextButton(
                    child: Text('Edit'),
                    onPressed: () {
                      print(widget.title);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => EditGoalPage(
                                    subGoal: widget.subgoal,
                                    title: widget.title,
                                    description: widget.description,
                                  )));
                    })),

          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(height: 25.0),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
    );
  }
}
