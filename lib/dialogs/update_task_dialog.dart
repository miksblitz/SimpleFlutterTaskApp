import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/task_model.dart';
import '../controllers/task_controller.dart';
import '../widgets/styled_text_field.dart';
import '../widgets/styled_button.dart';
import '../widgets/styled_dialog_container.dart';
import '../widgets/date_time_picker_field.dart';
import '../widgets/priority_dropdown.dart';

class UpdateTaskDialog {
  static void show(Task task, TaskController controller) {
    // 🔒 Lock: prevent editing completed tasks
    if (task.status == 'Completed') {
      Get.snackbar(
        '🔒 Task Locked',
        'Cannot edit completed tasks',
        backgroundColor: Colors.orange.withValues(alpha: 0.3),
        colorText: Colors.white,
        isDismissible: true,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    final titleController = TextEditingController(text: task.title);
    final descriptionController = TextEditingController(text: task.description);
    final assignedToController = TextEditingController(text: task.assignedTo ?? '');
    
    DateTime? selectedDueDate = task.dueDate;
    String? selectedDueTime = task.dueTime;
    String selectedPriority = task.priority ?? 'Medium';

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return StyledDialogContainer(
            title: '✏️ Update Task',
            content: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  StyledTextField(
                    controller: titleController,
                    hintText: 'Task title',
                    prefixIcon: Icons.title,
                  ),
                  const SizedBox(height: 16),
                  StyledTextField(
                    controller: descriptionController,
                    hintText: 'Describe your task (optional)',
                    prefixIcon: Icons.description,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  StyledTextField(
                    controller: assignedToController,
                    hintText: 'Assigned to (optional)',
                    prefixIcon: Icons.person,
                  ),
                  const SizedBox(height: 16),
                  PriorityDropdown(
                    selectedPriority: selectedPriority,
                    onChanged: (value) {
                      setState(() {
                        selectedPriority = value ?? 'Medium';
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DateTimePickerField(
                    label: 'Due Date & Time',
                    selectedDate: selectedDueDate,
                    selectedTime: selectedDueTime,
                    onDateTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDueDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2101),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: Colors.white,
                                onPrimary: Colors.black,
                                surface: Colors.black,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setState(() {
                          selectedDueDate = picked;
                        });
                      }
                    },
                    onTimeTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: Colors.white,
                                onPrimary: Colors.black,
                                surface: Colors.black,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setState(() {
                          selectedDueTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                        });
                      }
                    },
                    onClear: () {
                      setState(() {
                        selectedDueDate = null;
                        selectedDueTime = null;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Future.delayed(const Duration(milliseconds: 50), () {
                    titleController.dispose();
                    descriptionController.dispose();
                    assignedToController.dispose();
                  });
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              StyledButton(
                label: 'Update',
                isGradient: true,
                textColor: const Color(0xFF6366F1),
                onPressed: () {
                  // Validate required fields
                  final missingFields = <String>[];
                  
                  if (titleController.text.trim().isEmpty) {
                    missingFields.add('📝 Task title');
                  }
                  
                  // Show error if validation fails
                  if (missingFields.isNotEmpty) {
                    if (!Get.isSnackbarOpen) {
                      Get.snackbar(
                        '⚠️ Missing Required Fields',
                        'Please fill: ${missingFields.join(', ')}',
                        backgroundColor: Colors.red.withValues(alpha: 0.4),
                        colorText: Colors.white,
                        isDismissible: true,
                        duration: const Duration(seconds: 3),
                      );
                    }
                    return; // Stop execution
                  }
                  
                  // All validations passed - update task
                  final updatedTask = task.copyWith(
                    title: titleController.text.trim(),
                    description: descriptionController.text.trim(),
                    dueDate: selectedDueDate,
                    dueTime: selectedDueTime,
                    priority: selectedPriority,
                    assignedTo: assignedToController.text.trim().isEmpty
                        ? null
                        : assignedToController.text.trim(),
                  );
                  controller.updateTask(updatedTask);
                  Navigator.pop(context);
                  Future.delayed(const Duration(milliseconds: 50), () {
                    titleController.dispose();
                    descriptionController.dispose();
                    assignedToController.dispose();
                  });
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
