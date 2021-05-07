import 'dart:collection';

import 'package:motivateme_mobile_app/service/goal_manager.dart';
import 'package:table_calendar/table_calendar.dart';

import 'model/subgoal.dart';

// loop through all goals in goals table
// get all subgoals from the subgoals table
// return a map of them
class CalendarUtils {
  final goalManager = GoalManager();

  Future<Map<DateTime, List<dynamic>>> fetchSubGoals() async {
    List<dynamic> subGoals = await goalManager.retrieveSubGoals();

    Map<DateTime, List<dynamic>> _kEventSource = {};

    for (SubGoal subGoal in subGoals) {
      if (!_kEventSource.keys.contains(subGoal.date)) {
        _kEventSource[subGoal.date] = [subGoal];
      } else {
        _kEventSource[subGoal.date].add(subGoal);
      }
    }
    return _kEventSource;
  }
}

/// Example events.
///
/// Using a [LinkedHashMap] is highly recommended if you decide to use a map.
