import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../utils.dart';
import 'model/subgoal.dart';

class TableEventsExample extends StatefulWidget {
  @override
  _TableEventsExampleState createState() => _TableEventsExampleState();
}

class _TableEventsExampleState extends State<TableEventsExample> {
  CalendarController _controller;
  List<dynamic> _selectedEvents;
  Map<DateTime, List<dynamic>> _events;

  _TableEventsExampleState();

  final calendarUtils = CalendarUtils();

  @override
  void initState() {
    super.initState();
    _controller = CalendarController();
    _selectedEvents = [];
    _events = {};
  }

  // List<SubGoal> _getEventsForDay(DateTime day) {
  //   // Implementation example
  //   return calendarUtils.kEvents[day] ?? [];
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: FutureBuilder(
          future: calendarUtils.fetchSubGoals(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              _events = snapshot.data;
              return Column(children: [
                TableCalendar(
                  events: _events,
                  initialCalendarFormat: CalendarFormat.month,
                  calendarStyle: CalendarStyle(
                      canEventMarkersOverflow: true,
                      todayColor: Colors.orange,
                      selectedColor: Theme.of(context).primaryColor,
                      todayStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          color: Colors.white)),
                  headerStyle: HeaderStyle(
                    centerHeaderTitle: true,
                    formatButtonDecoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    formatButtonTextStyle: TextStyle(color: Colors.white),
                    formatButtonShowsNext: false,
                  ),
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  onDaySelected: (date, events, _) {
                    setState(() {
                      _selectedEvents = events;
                    });
                  },
                  builders: CalendarBuilders(
                    selectedDayBuilder: (context, date, events) => Container(
                        margin: const EdgeInsets.all(4.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(10.0)),
                        child: Text(
                          date.day.toString(),
                          style: TextStyle(color: Colors.white),
                        )),
                    todayDayBuilder: (context, date, events) => Container(
                        margin: const EdgeInsets.all(4.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(10.0)),
                        child: Text(
                          date.day.toString(),
                          style: TextStyle(color: Colors.white),
                        )),
                  ),
                  calendarController: _controller,
                ),
                Expanded(
                    child: ListView.builder(
                        itemCount: _selectedEvents.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(_selectedEvents.elementAt(index).title),
                            trailing: Text(
                                _selectedEvents.elementAt(index).timeFrame),
                          );
                        }))
              ]);
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    ));
  }
}
