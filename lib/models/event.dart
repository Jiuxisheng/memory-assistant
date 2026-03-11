class Event {
  int? id;
  final DateTime timestamp;
  final String category;
  final String who;
  final String what;
  final String location;
  final String why;
  final String notes;

  Event({
    this.id,
    required this.timestamp,
    required this.category,
    required this.who,
    required this.what,
    required this.location,
    required this.why,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'category': category,
      'who': who,
      'what': what,
      'location': location,
      'why': why,
      'notes': notes,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      timestamp: DateTime.parse(map['timestamp']),
      category: map['category'],
      who: map['who'],
      what: map['what'],
      location: map['location'],
      why: map['why'],
      notes: map['notes'],
    );
  }

  @override
  String toString() {
    return 'Event{id: $id, timestamp: $timestamp, category: $category, who: $who, what: $what, location: $location, why: $why, notes: $notes}';
  }
}