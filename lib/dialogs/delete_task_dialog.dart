import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/task_model.dart';
import '../controllers/task_controller.dart';
import '../widgets/styled_button.dart';
import '../widgets/styled_dialog_container.dart';

class DeleteTaskDialog {
  static void show(Task task, TaskController controller) {
    Get.dialog(
      StyledDialogContainer(
        title: '🗑️ Delete Task',
        content: Text(
          'Are you sure you want to delete "${task.title}"?',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 14,
            letterSpacing: 0.2,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          StyledButton(
            label: 'Delete',
            backgroundColor: Colors.red.withValues(alpha: 0.3),
            onPressed: () {
              Get.back();
              controller.deleteTask(task.id!);
            },
          ),
        ],
      ),
    );
  }
}
