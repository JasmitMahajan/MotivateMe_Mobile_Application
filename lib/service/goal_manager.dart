import 'package:motivateme_mobile_app/model/goal.dart';
import 'package:motivateme_mobile_app/model/subgoal.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';

// class that manages the user's goals
// allows insertion, update, and deletion of goals on local sqlite database
class GoalManager {
  Future<void> createGoalTable(Goal goal) async {
    final Future<Database> database =
        openDatabase(join(await getDatabasesPath(), 'motivate_me.db'));
    final Database db = await database;
    String formattedTitle = goal.title.replaceAll(' ', '_');
    String goalTableCreation = 'CREATE TABLE IF NOT EXISTS ' +
        formattedTitle +
        '(gid INTEGER PRIMARY KEY, id INTEGER, ' +
        'date' +
        ' DATETIME, ' +
        'completed' +
        ' INTEGER, ' +
        'comment' +
        ' TEXT, ' +
        'path_to_picture' +
        ' TEXT)';
    await db.execute(goalTableCreation);
    print('goal table created!');
  }

  // inserts a goal into the sqlite database
  // param: goal   -   the goal to insert into the database
  Future<void> insertGoal(Goal goal) async {
    final Future<Database> database =
        openDatabase(join(await getDatabasesPath(), 'motivate_me.db'));
    final Database db = await database;
    for (var thing in goal.formatForDatabase().entries) {
      print(thing.key + ' ' + thing.value.toString());
    }
    await db.insert('Goals', goal.formatForDatabase(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    await createGoalTable(goal);
    await initializeGoalDates(goal);
  }


  Future<void> initializeGoalDates(Goal goal) async {
    final Future<Database> database =
        openDatabase(join(await getDatabasesPath(), 'motivate_me.db'));
    final Database db = await database;
    int counter = 1;
    DateTime currentDate = goal.startDate;
    String formattedGoalTitle = goal.title.toString().replaceAll(' ', '_');
    String day = DateFormat.EEEE().format(currentDate);
    while (currentDate != goal.endDate) {
      if (goal.goalDays[DateFormat.EEEE().format(currentDate)] == true) {
        await db.insert(formattedGoalTitle, {
          'gid': counter,
          'id': goal.id,
          'date': currentDate.toIso8601String(),
          'completed': null,
          'comment': null,
          'path_to_picture': null,
        });
        counter++;
        print('added the goal!');
      }
      currentDate = currentDate.add(Duration(days: 1));
    }

    if (currentDate == goal.endDate && goal.goalDays[day] == true) {
      await db.insert(formattedGoalTitle, {
        'gid': counter,
        'id': goal.id,
        'date': currentDate.toIso8601String(),
        'completed': null,
        'comment': null,
        'path_to_picture': null,
      });
    }
    print('goal table initialized!');
  }

  // retrieves a list of the user's goals from the database

  Future<List<Goal>> retrieveGoals() async {
    final Future<Database> database =
        openDatabase(join(await getDatabasesPath(), 'motivate_me.db'));

    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query('Goals');

    return List.generate(maps.length, (i) {
      return Goal(
        id: maps[i]['id'],
        title: maps[i]['title'],
        description: maps[i]['description'],
        goalDays: {
          'monday': maps[i]['monday'] == 1 ? true : false,
          'tuesday': maps[i]['tuesday'] == 1 ? true : false,
          'wednesday': maps[i]['wednesday'] == 1 ? true : false,
          'thursday': maps[i]['thursday'] == 1 ? true : false,
          'friday': maps[i]['friday'] == 1 ? true : false,
          'saturday': maps[i]['saturday'] == 1 ? true : false,
          'sunday': maps[i]['sunday'] == 1 ? true : false
        },
        startDate: DateTime.parse(maps[i]['start_date']),
        endDate: DateTime.parse(maps[i]['end_date']),
        startTime: DateTime.parse(maps[i]['start_time']),
        endTime: DateTime.parse(maps[i]['end_time']),
        isComplete: maps[i]['is_complete'] == 1 ? true : false,
      );
    });
  }

  // retrieves the list of sub goals that the user hasn't completed
  // returns a list of subgoals
  Future<List<SubGoal>> retrieveSubGoalsForToday() async {
    final Future<Database> database =
        openDatabase(join(await getDatabasesPath(), 'motivate_me.db'));

    final Database db = await database;
    String today = DateFormat.EEEE().format(DateTime.now());
    List<SubGoal> subGoals = [];
    String retrieveGoalDetailsForTodayQuery = 'SELECT * FROM Goals WHERE ' +
        today +
        ' = 1'; // check the goals table for goals that occur on the current day
    List<Map<String, Object>> result =
        await db.rawQuery(retrieveGoalDetailsForTodayQuery);
    for (var goal in result) {
      // look through the subgoals table for the goal that is supposed to occur today
      String formattedGoalTitle = goal['title'].toString().replaceAll(' ', '_');
      String currentMonth = DateTime.now().month.toString();
      String currentDay = DateTime.now().day.toString();
      if (DateTime.now().month < 10) {
        // format month to be two digits if month is less than 10, ie '01', '02', etc.
        currentMonth = '0' + DateTime.now().month.toString();
      }
      if (DateTime.now().day < 10) {
        currentDay = '0' + DateTime.now().day.toString();
      }
      String today = DateTime.now().year.toString() +
          '-' +
          currentMonth +
          '-' +
          currentDay +
          'T00:00:00.000'; // ISO8601 format string for the date
      String retrieveSubGoalsQuery = 'SELECT * FROM ' +
          formattedGoalTitle +
          ' WHERE date = ' +
          '"' +
          today +
          '"' +
          ' AND completed IS NULL'; // query to find the specific goal for today that isn't completed

      String startTime =
          DateFormat('h:mma').format(DateTime.parse(goal['start_time']));
      String endTime =
          DateFormat('h:mma').format(DateTime.parse(goal['end_time']));
      String timeFrame =
          startTime + ' to ' + endTime; // store the time frame of the goal
      List<Map<String, Object>> subGoalResult =
          await db.rawQuery(retrieveSubGoalsQuery);
      if (subGoalResult.length == 0) {
        // ignore the subgoal if it is already completed
        continue;
      }
      Map<String, Object> subGoal = subGoalResult.first;

      SubGoal subGoalToAdd = SubGoal(
          gid: subGoal['gid'],
          id: subGoal['id'],
          date: DateTime.parse(subGoal['date']),
          completed: subGoal['completed'] == 1 ? true : false,
          comment: subGoal['comment'],
          pathToPicture: subGoal['path_to_picture'],
          title: goal['title'],
          description: goal['description'],
          timeFrame: timeFrame,
          startDate: DateTime.parse(goal['start_date']),
          endDate: DateTime.parse(goal['end_date']),
          startTime: DateTime.parse(goal['start_time']),
          endTime: DateTime.parse(goal['end_time']),
          goalDays: {
            'monday': goal['monday'] == null
                ? null
                : goal['monday'] == 1
                    ? true
                    : false,
            'tuesday': goal['tuesday'] == null
                ? null
                : goal['tuesday'] == 1
                    ? true
                    : false,
            'wednesday': goal['wednesday'] == null
                ? null
                : goal['wednesday'] == 1
                    ? true
                    : false,
            'thursday': goal['thursday'] == null
                ? null
                : goal['thursday'] == 1
                    ? true
                    : false,
            'friday': goal['friday'] == null
                ? null
                : goal['friday'] == 1
                    ? true
                    : false,
            'saturday': goal['saturday'] == null
                ? null
                : goal['saturday'] == 1
                    ? true
                    : false,
            'sunday': goal['sunday'] == null
                ? null
                : goal['sunday'] == 1
                    ? true
                    : false,
          });
      subGoals.add(subGoalToAdd);
    }
    print('length of subgoals for today!!!' + subGoals.length.toString());
    return subGoals;
  }

  // retrieves all subgoals that the user currently has
  Future<List<SubGoal>> retrieveSubGoals() async {
    final Future<Database> database =
        openDatabase(join(await getDatabasesPath(), 'motivate_me.db'));

    final Database db = await database;
    List<SubGoal> subGoals = [];
    String retrieveGoalDetailsQuery =
        'SELECT id, title, description, start_time, end_time FROM Goals'; // check the goals table for goals that occur on the current day
    List<Map<String, Object>> result =
        await db.rawQuery(retrieveGoalDetailsQuery);
    for (var goal in result) {
      // look through the subgoals table for the goal that is supposed to occur today
      String formattedGoalTitle = goal['title'].toString().replaceAll(' ', '_');
      String retrieveSubGoalsQuery = 'SELECT * FROM ' +
          formattedGoalTitle; // query to find the specific goal for today that isn't completed
      print(retrieveSubGoalsQuery);
      List<Map<String, Object>> subGoalResult =
          await db.rawQuery(retrieveSubGoalsQuery);
      if (subGoalResult.length == 0) {
        // ignore the subgoal if it is already completed
        print('list has zero elements');
        continue;
      }

      for (var subGoal in subGoalResult) {
        String startTime =
            DateFormat('h:mma').format(DateTime.parse(goal['start_time']));
        String endTime =
            DateFormat('h:mma').format(DateTime.parse(goal['end_time']));
        String timeFrame = startTime + ' to ' + endTime;
        print(timeFrame);
        SubGoal subGoalToAdd = SubGoal(
            gid: subGoal['gid'],
            id: subGoal['id'],
            date: DateTime.parse(subGoal['date']),
            completed: subGoal['completed'] == 1 ? true : false,
            comment: subGoal['comment'],
            pathToPicture: subGoal['path_to_picture'],
            title: goal['title'],
            description: goal['description'],
            timeFrame: timeFrame);
        subGoals.add(subGoalToAdd);
      }
    }
    print('length from goal manager: ' + subGoals.length.toString());
    return subGoals;
  }

  Future<int> retrieveNumberOfGoals() async {
    final Future<Database> database =
        openDatabase(join(await getDatabasesPath(), 'motivate_me.db'));

    final Database db = await database;

    final String countQuery = 'SELECT COUNT(*) FROM Goals';

    var tableCount = await db.rawQuery(countQuery);

    return tableCount.first['COUNT(*)'];
  }

  // marks a goal as complete; changes the appropriate table and subgoal row
  Future<void> markGoalAsComplete(SubGoal subgoal) async {
    final Future<Database> database =
        openDatabase(join(await getDatabasesPath(), 'motivate_me.db'));

    final Database db = await database;
    String findGoalTitleQuery =
        'SELECT title FROM Goals WHERE id = ' + subgoal.id.toString();
    List<Map<String, Object>> title = await db.rawQuery(findGoalTitleQuery);
    String formattedGoalTitle =
        title.first['title'].toString().replaceAll(' ', '_');
    String completeGoalQuery = 'UPDATE ' +
        formattedGoalTitle +
        ' SET completed = 1 WHERE gid = ' +
        subgoal.gid.toString();
    db.execute(completeGoalQuery);
  }

  // mark a goal as incompleted; changes the appropriate table and subgoal row
  Future<void> markGoalAsIncomplete(SubGoal subgoal) async {
    final Future<Database> database =
        openDatabase(join(await getDatabasesPath(), 'motivate_me.db'));
    final Database db = await database;
    String findGoalTitleQuery =
        'SELECT title FROM Goals WHERE id = ' + subgoal.id.toString();
    List<Map<String, Object>> title = await db.rawQuery(findGoalTitleQuery);
    String formattedGoalTitle =
        title.first['title'].toString().replaceAll(' ', '_');

    String updateGoalQuery = 'UPDATE ' +
        formattedGoalTitle +
        ' SET completed = 0 WHERE gid = ' +
        subgoal.gid.toString();
    db.execute(updateGoalQuery);
  }

  Future<void> setCommentForSubGoal(SubGoal subGoal, String comment) async {
    final Future<Database> database =
        openDatabase(join(await getDatabasesPath(), 'motivate_me.db'));
    final Database db = await database;
    String findGoalTitleQuery =
        'SELECT title FROM Goals WHERE id = ' + subGoal.id.toString();
    List<Map<String, Object>> title = await db.rawQuery(findGoalTitleQuery);
    String formattedGoalTitle =
        title.first['title'].toString().replaceAll(' ', '_');
    String setCommentQuery = 'UPDATE ' +
        formattedGoalTitle +
        ' SET comment = ' +
        '"' +
        comment +
        '"' +
        ' WHERE gid = ' +
        subGoal.gid.toString();
    db.execute(setCommentQuery);
  }

  // function when goal is deleted
  Future<void> deleteGoal(SubGoal subgoal) async {
    final Future<Database> database =
        openDatabase(join(await getDatabasesPath(), 'motivate_me.db'));
    final Database db = await database;
    String findGoalTitleQuery =
        'SELECT title FROM Goals WHERE id = ' + subgoal.id.toString();
    List<Map<String, Object>> title = await db.rawQuery(findGoalTitleQuery);
    String formattedGoalTitle =
        title.first['title'].toString().replaceAll(' ', '_');
    String deleteGoalTable = 'DROP TABLE IF EXISTS ' + formattedGoalTitle;
    String deleteGoalQuery =
        'DELETE FROM Goals WHERE id = ' + subgoal.id.toString();
    db.execute(deleteGoalQuery);
    db.execute(deleteGoalTable);
  }

  // updates the subgoal's path to picture
  // params: subgoal - the subgoal to set the path to
  //         imagePath - the path to set the subgoal's attribute to
  Future<void> savePicturePath(SubGoal subgoal, String imagePath) async {
    final Future<Database> database =
        openDatabase(join(await getDatabasesPath(), 'motivate_me.db'));
    final Database db = await database;
    String formattedGoalTitle = subgoal.title.replaceAll(' ', '_');
    print(imagePath);
    String setSubGoalPathQuery = 'UPDATE ' +
        formattedGoalTitle +
        ' SET path_to_picture = ' +
        "'" +
        imagePath +
        "'" +
        ' WHERE gid = ' +
        subgoal.gid.toString();
    print(setSubGoalPathQuery);
    await db.execute(setSubGoalPathQuery);
  }

  Future<Map<String, List<SubGoal>>> retrieveSubGoalsForWeek(
      DateTime date) async {
    print('getting the goals for the week!');
    final Future<Database> database =
        openDatabase(join(await getDatabasesPath(), 'motivate_me.db'));
    final Database db = await database;

    int daysUntilMonday = date.weekday - DateTime.monday;
    int daysUntilSunday = DateTime.sunday - date.weekday;
    DateTime startOfWeek = date.subtract(Duration(days: daysUntilMonday));
    startOfWeek = DateTime(
        startOfWeek.year, startOfWeek.month, startOfWeek.day, 0, 0, 0, 0, 0);
    DateTime endOfWeek = date.add(Duration(days: daysUntilSunday));
    Map<String, List<SubGoal>> subGoalsForWeek = {};
    print('start: ' + startOfWeek.toString());
    print('end: ' + endOfWeek.toString());
    var goals = await db.query('Goals');
    for (var goal in goals) {
      String formattedTitle = goal['title'].toString().replaceAll(' ', '_');
      var subGoals = await db.query(formattedTitle);
      for (var subGoal in subGoals) {
        DateTime subGoalDate = DateTime.parse(subGoal['date']);
        if (subGoalDate.isAtSameMomentAs(startOfWeek) ||
            (subGoalDate.isBefore(endOfWeek) &&
                subGoalDate.isAfter(startOfWeek))) {
          SubGoal sub = SubGoal(
              gid: subGoal['gid'],
              id: goal['id'],
              date: DateTime.parse(subGoal['date']),
              completed: subGoal['completed'] == null
                  ? null
                  : subGoal['completed'] == 1
                      ? true
                      : false,
              comment: subGoal['comment'],
              pathToPicture: subGoal['path_to_picture'],
              title: goal['title']);
          if (!subGoalsForWeek.keys.contains(goal['title'])) {
            subGoalsForWeek[goal['title']] = [sub];
          } else {
            subGoalsForWeek[goal['title']].add(sub);
          }
        } else {
          continue;
        }
      }
    }
    return subGoalsForWeek;
  }

  Future<List<String>> retrieveGoalTitles() async {
    final Future<Database> database =
        openDatabase(join(await getDatabasesPath(), 'motivate_me.db'));
    final Database db = await database;
    List<String> goalTitles = [];
    String retrieveGoalNamesQuery = 'SELECT title FROM Goals';
    List<Map<String, Object>> goals = await db.rawQuery(retrieveGoalNamesQuery);
    for (var goal in goals) {
      for (var title in goal.values) {
        goalTitles.add(title);
      }
    }
    return goalTitles;
  }

  Future<void> updateGoal(Goal goal) async {
    final Future<Database> database =
        openDatabase(join(await getDatabasesPath(), 'motivate_me.db'));
    final Database db = await database;
    db.update('Goals', goal.formatForDatabase(),
        where: 'id = ?', whereArgs: [goal.id]);
    String formattedGoalTitle = goal.title.toString().replaceAll(' ', '_');
    db.execute('DROP TABLE IF EXISTS ' + formattedGoalTitle);
    createGoalTable(goal);
    initializeGoalDates(goal);
  }
}
