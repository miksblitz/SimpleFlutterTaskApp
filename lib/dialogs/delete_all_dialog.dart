import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/task_controller.dart';
import '../widgets/styled_button.dart';
import '../widgets/styled_dialog_container.dart';

class DeleteAllDialog {
  static void show(TaskController controller) {
    Get.dialog(
      StyledDialogContainer(
        title: '⚠️ Delete All Tasks',
        content: Text(
          'Are you sure? This will permanently delete ALL tasks and cannot be undone.',
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
            label: 'Delete All',
            backgroundColor: Colors.red.withValues(alpha: 0.3),
            onPressed: () {
              Get.back();
              controller.deleteAllTasks();
            },
          ),
        ],
      ),
    );
  }

  static void showCompletedOnly(TaskController controller) {
    Get.dialog(
      StyledDialogContainer(
        title: '⚠️ Delete Completed Tasks',
        content: Text(
          'Are you sure? This will permanently delete all ${controller.getCompletedCount()} completed tasks and cannot be undone.',
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
            label: 'Delete Completed',
            backgroundColor: Colors.red.withValues(alpha: 0.3),
            onPressed: () {
              Get.back();
              controller.deleteAllCompletedTasks();
            },
          ),
        ],
      ),
    );
  }

  static void showPendingOnly(TaskController controller) {
    Get.dialog(
      StyledDialogContainer(
        title: '⚠️ Delete All Pending Tasks',
        content: Text(
          'Are you sure? This will permanently delete all ${controller.getPendingCount()} pending tasks and cannot be undone.',
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
            label: 'Delete Pending',
            backgroundColor: Colors.red.withValues(alpha: 0.3),
            onPressed: () {
              Get.back();
              controller.deleteAllPendingTasks();
            },
          ),
        ],
      ),
    );
  }
}
