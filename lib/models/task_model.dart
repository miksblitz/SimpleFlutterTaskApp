class Task {
  final int? id;
  final String title;
  final String description;
  final String status; // 'Pending' or 'Completed'
  final DateTime createdAt;
  final DateTime? dateCompleted; // timestamp when task was marked complete
  final DateTime? dueDate; // Due date of the task
  final String? dueTime; // Due time (HH:mm format)
  final String? priority; // 'Low', 'Medium', 'High'
  final String? assignedTo; // Name of person assigned to

  Task({
    this.id,
    required this.title,
    this.description = '',
    this.status = 'Pending',
    required this.createdAt,
    this.dateCompleted,
    this.dueDate,
    this.dueTime,
    this.priority = 'Medium',
    this.assignedTo,
  });

  // Convert Task to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'dateCompleted': dateCompleted?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'dueTime': dueTime,
      'priority': priority,
      'assignedTo': assignedTo,
    };
  }

  // Create Task from Map (database)
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      dateCompleted: map['dateCompleted'] != null ? DateTime.parse(map['dateCompleted'] as String) : null,
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate'] as String) : null,
      dueTime: map['dueTime'] as String?,
      priority: map['priority'] as String?,
      assignedTo: map['assignedTo'] as String?,
    );
  }

  // Copy with method for updating task
  Task copyWith({
    int? id,
    String? title,
    String? description,
    String? status,
    DateTime? createdAt,
    Object? dateCompleted = const _Unset(),
    Object? dueDate = const _Unset(),
    Object? dueTime = const _Unset(),
    Object? priority = const _Unset(),
    Object? assignedTo = const _Unset(),
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      dateCompleted: dateCompleted is _Unset ? this.dateCompleted : (dateCompleted as DateTime?),
      dueDate: dueDate is _Unset ? this.dueDate : (dueDate as DateTime?),
      dueTime: dueTime is _Unset ? this.dueTime : (dueTime as String?),
      priority: priority is _Unset ? this.priority : (priority as String?),
      assignedTo: assignedTo is _Unset ? this.assignedTo : (assignedTo as String?),
    );
  }
}

class _Unset {
  const _Unset();
}
