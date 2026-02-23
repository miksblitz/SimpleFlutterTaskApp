import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    return GestureDetector(
      onTap: () {
        TaskDetailsDialog.show(task, controller);
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
        leading: GestureDetector(
          onTap: () {
            controller.toggleTaskStatus(task);
          },
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.6),
                width: 2,
              ),
              color: task.status == 'Completed'
                  ? Colors.green.withOpacity(0.7)
                  : Colors.transparent,
            ),
            child: task.status == 'Completed'
                ? const Icon(
                    Icons.check,
                    size: 14,
                    color: Colors.white,
                  )
                : null,
          ),
        ),
        title: Text(
          task.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w600,
            decoration: task.status == 'Completed'
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            decorationColor: Colors.white.withOpacity(0.9),
          ),
        ),
        subtitle: task.description.isNotEmpty
            ? Text(
                task.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              )
            : null,
        trailing: IconButton(
          icon: Icon(
            Icons.more_vert,
            color: Colors.white.withOpacity(0.6),
          ),
          onPressed: () {
            TaskOptionsBottomSheet.show(task, controller);
          },
        ),
        ),
      ),
    );
  }
}
