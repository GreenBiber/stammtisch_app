class Event {
  final String groupId;
  final DateTime date;
  final Map<String, String> participation;

  Event({
    required this.groupId,
    required this.date,
    required this.participation,
  });

  bool get isConfirmed {
    final yesVotes =
        participation.values.where((response) => response == 'yes').length;
    return yesVotes >= 4;
  }

  int get yesCount {
    return participation.values.where((response) => response == 'yes').length;
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      groupId: json['groupId'],
      date: DateTime.parse(json['date']),
      participation: Map<String, String>.from(json['participation']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'date': date.toIso8601String(),
      'participation': participation,
    };
  }
}
