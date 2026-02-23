class Task {
  final int? id;
  final String title;
  final String description;
  final String status; // 'Pending' or 'Completed'
  final DateTime createdAt;

  Task({
    this.id,
    required this.title,
    this.description = '',
    this.status = 'Pending',
    required this.createdAt,
  });

  // Convert Task to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
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
    );
  }

  // Copy with method for updating task
  Task copyWith({
    int? id,
    String? title,
    String? description,
    String? status,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
