import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/task_model.dart';
import '../controllers/task_controller.dart';

class AddTaskDialog {
  static void show(TaskController controller) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color.fromARGB(255, 52, 52, 54).withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          '🚀 Create New Task',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                maxLength: 10000,
                decoration: InputDecoration(
                  hintText: 'What\'s your next adventure? 🚀',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                  prefixIcon: Icon(Icons.title,
                      color: Colors.white.withOpacity(0.7), size: 20),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                maxLines: 4,
                maxLength: 10000,
                decoration: InputDecoration(
                  hintText: 'Describe your task (optional)',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                  prefixIcon: Icon(Icons.description,
                      color: Colors.white.withOpacity(0.7), size: 20),
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              Future.delayed(const Duration(milliseconds: 100), () {
                titleController.dispose();
                descriptionController.dispose();
              });
            },
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.white, Color(0xFFF5F5F5)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  final task = Task(
                    title: titleController.text,
                    description: descriptionController.text,
                    createdAt: DateTime.now(),
                  );
                  controller.addTask(task);
                  Get.back();
                  Future.delayed(const Duration(milliseconds: 100), () {
                    titleController.dispose();
                    descriptionController.dispose();
                  });
                } else {
                  if (!Get.isSnackbarOpen) {
                    Get.snackbar(
                      '⚠️ Required',
                      'Please enter a task title',
                      backgroundColor: Colors.red.withOpacity(0.4),
                      colorText: Colors.white,
                      isDismissible: true,
                      duration: const Duration(seconds: 2),
                    );
                  }
                }
              },
              child: const Text(
                'Add!',
                style: TextStyle(
                  color: Color(0xFF6366F1),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
