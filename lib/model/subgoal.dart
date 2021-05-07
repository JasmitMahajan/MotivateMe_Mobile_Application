class SubGoal {
  final int gid;
  final int id;
  final DateTime date;
  final bool completed;
  final String comment;
  final String pathToPicture;
  String title;
  String description;
  String timeFrame;
  DateTime startDate;
  DateTime endDate;
  DateTime startTime;
  DateTime endTime;
  Map<String, bool> goalDays;

  SubGoal({this.gid, this.id, this.date, this.completed, this.comment, this.pathToPicture, this.title = '', this.description = '', this.timeFrame='', 
  this.startDate, this.endDate, this.startTime, this.endTime, this.goalDays});
  

  Map<String, dynamic> toMap() {
    return {
      'gid': this.gid,
      'id': this.id,
      'date': this.date.toIso8601String(),
      'completed': this.completed,
      'comment': this.comment,
      'pathToPicture': this.pathToPicture
    };
  }

  SubGoal.fromJson(Map<String, dynamic> json)
  : gid = json['gid'],
    id = json['id'],
    date = json['date'],
    completed = json['completed'] == 1 ? true: false,
    comment =  json['comment'],
    pathToPicture = json['pathToPicture'];

  Map<String, dynamic> formattedMapForDatabase() {
    return {
      'gid': this.gid,
      'id': this.id,
      'date': this.date.toIso8601String(),
      'completed': this.completed ? 1 : 0,
      'comment': this.comment,
      'path_to_picture': this.pathToPicture
    };
  }

}