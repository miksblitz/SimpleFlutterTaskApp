import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../controllers/task_controller.dart';
import '../dialogs/task_options_bottom_sheet.dart';
import '../dialogs/task_details_dialog.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final TaskController controller;

  const TaskCard({
    Key? key,
    required this.task,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Always get the latest task state from controller
      final currentTask = controller.getTaskById(task.id!);
      
      // If task not found, return empty
      if (currentTask == null) return const SizedBox.shrink();
      
      return GestureDetector(
        onTap: () {
          TaskDetailsDialog.show(currentTask, controller);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: ListTile(
            leading: currentTask.status == 'Completed'
                ? Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.6),
                        width: 2,
                      ),
                      color: Colors.green.withOpacity(0.7),
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    ),
                  )
                : null,
            title: Text(
              currentTask.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w600,
                decoration: currentTask.status == 'Completed'
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                decorationColor: Colors.white.withOpacity(0.9),
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Task description
                if (currentTask.description.isNotEmpty)
                  Text(
                    currentTask.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                // Assigned to
                if (currentTask.assignedTo != null && currentTask.assignedTo!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Assigned to: ${currentTask.assignedTo}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.blue.withOpacity(0.8),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                // Due date and time
                if (currentTask.dueDate != null && currentTask.dueTime != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Due: ${DateFormat('MMM dd').format(currentTask.dueDate!)} at ${currentTask.dueTime}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                // Priority badge
                if (currentTask.priority != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(currentTask.priority!).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: _getPriorityColor(currentTask.priority!).withOpacity(0.6),
                            ),
                          ),
                          child: Text(
                            currentTask.priority!,
                            style: TextStyle(
                              fontSize: 10,
                              color: _getPriorityColor(currentTask.priority!),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                // dateCompleted: only show if exists
                if (currentTask.dateCompleted != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Completed: ${DateFormat('yyyy-MM-dd HH:mm').format(currentTask.dateCompleted!)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.green.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.more_vert,
                color: Colors.white.withOpacity(0.6),
              ),
              onPressed: () {
                TaskOptionsBottomSheet.show(currentTask, controller);
              },
            ),
          ),
        ),
      );
    });
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Low':
        return Colors.blue;
      case 'High':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}
