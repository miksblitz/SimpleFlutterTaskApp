import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/task_model.dart';
import '../controllers/task_controller.dart';
import 'delete_task_dialog.dart';
import 'update_task_dialog.dart';

class TaskOptionsBottomSheet {
  static void show(Task task, TaskController controller) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 52, 52, 54).withValues(alpha: 0.95),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Icon(
                task.status == 'Pending'
                    ? Icons.check_circle_outline
                    : Icons.restore_outlined,
                color: Colors.white,
              ),
              title: Text(
                task.status == 'Pending'
                    ? 'Mark as Completed'
                    : 'Mark as Pending',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                // When marking as Completed for the first time, use completeTask to set dateCompleted
                if (task.status == 'Pending') {
                  controller.completeTask(task);
                } else {
                  // When marking as Pending from Completed, use markAsPending
                  controller.markAsPending(task);
                }
                Get.back();
              },
            ),
            ListTile(
              enabled: task.status != 'Completed', // 🔒 disabled for completed tasks
              leading: Icon(
                Icons.edit_outlined,
                color: task.status == 'Completed'
                    ? Colors.white.withOpacity(0.3)
                    : Colors.white,
              ),
              title: Text(
                'Edit Task',
                style: TextStyle(
                  color: task.status == 'Completed'
                      ? Colors.white.withOpacity(0.3)
                      : Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Get.back();
                UpdateTaskDialog.show(task, controller);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.white),
              title: const Text(
                'Delete Task',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Get.back();
                DeleteTaskDialog.show(task, controller);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      isScrollControlled: false,
    );
  }
}
