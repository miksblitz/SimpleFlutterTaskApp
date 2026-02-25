import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/task_model.dart';
import '../data/queries/task_queries.dart';

class TaskController extends GetxController {
  final TaskQueries _taskQueries = TaskQueries();

  // Reactive list of tasks
  var tasks = <Task>[].obs;
  var isLoading = false.obs;
  
  // Reactive selected tab ('Pending' or 'Completed')
  var selectedTab = 'Pending'.obs;
  
  // Map to track which tasks are being saved (for preventing race conditions)
  final _savingTasks = <int, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTasks();
  }

  // Fetch all tasks from database and sort by due date
  Future<void> fetchTasks() async {
    try {
      isLoading(true);
      final fetchedTasks = await _taskQueries.getTasks();
      
      // Sort tasks by due date/time (closest to farthest)
      final sortedTasks = List<Task>.from(fetchedTasks);
      sortedTasks.sort((a, b) {
        // Pending tasks with due dates come first (sorted by date)
        if (a.status == 'Pending' && b.status == 'Pending') {
          if (a.dueDate != null && b.dueDate != null) {
            return a.dueDate!.compareTo(b.dueDate!);
          } else if (a.dueDate != null) {
            return -1; // Task with due date comes first
          } else if (b.dueDate != null) {
            return 1; // Task without due date comes last
          }
        }
        return 0; // Maintain original order for completed tasks
      });
      
      tasks.assignAll(sortedTasks);
    } catch (e) {
      Get.closeCurrentSnackbar();
      Get.snackbar('Error', 'Failed to fetch tasks: $e');
    } finally {
      isLoading(false);
    }
  }

  // Add a new task
  Future<void> addTask(Task task) async {
    try {
      isLoading(true);
      final id = await _taskQueries.insertTask(task);
      final newTask = task.copyWith(id: id);
      tasks.insert(0, newTask);
      tasks.refresh();
      Get.closeCurrentSnackbar();
      Get.snackbar('Success', 'Task added successfully');
    } catch (e) {
      Get.closeCurrentSnackbar();
      Get.snackbar('Error', 'Failed to add task: $e');
    } finally {
      isLoading(false);
    }
  }

  // Update task (e.g., change status) - OPTIMIZED with background save
  Future<void> updateTask(Task task) async {
    try {
      // 🔒 Lock: prevent updating completed tasks
      if (task.status == 'Completed') {
        Get.closeCurrentSnackbar();
        Get.snackbar(
          '🔒 Task Locked',
          'Cannot update completed tasks',
          backgroundColor: Colors.orange.withValues(alpha: 0.3),
          colorText: Colors.white,
          isDismissible: true,
          duration: const Duration(seconds: 2),
        );
        return;
      }
      
      // UPDATE UI IMMEDIATELY (Optimistic Update)
      final index = tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        tasks[index] = task;
        tasks.refresh();
      }
      
      // Mark as saving to prevent duplicate saves
      _savingTasks[task.id!] = true;
      
      // SAVE TO DATABASE IN BACKGROUND (Non-blocking)
      _taskQueries.updateTask(task).then((_) {
        _savingTasks.remove(task.id!);
      }).catchError((e) {
        _savingTasks.remove(task.id!);
        // Revert UI on error
        if (index != -1) {
          tasks[index] = task;
          tasks.refresh();
        }
      });
      
      Get.closeCurrentSnackbar();
      Get.snackbar('Success', 'Task updated successfully');
    } catch (e) {
      Get.closeCurrentSnackbar();
      Get.snackbar('Error', 'Failed to update task: $e');
    }
  }

  // Delete a task - OPTIMIZED
  Future<void> deleteTask(int id) async {
    try {
      // REMOVE FROM UI IMMEDIATELY
      tasks.removeWhere((task) => task.id == id);
      
      // DELETE FROM DATABASE IN BACKGROUND
      _taskQueries.deleteTask(id).catchError((e) {
        // Revert if deletion fails
        Get.closeCurrentSnackbar();
        Get.snackbar('Error', 'Failed to delete task: $e');
        return 0;
      });
      
      Get.closeCurrentSnackbar();
      Get.snackbar('Success', 'Task deleted successfully');
    } catch (e) {
      Get.closeCurrentSnackbar();
      Get.snackbar('Error', 'Failed to delete task: $e');
    }
  }

  // Toggle task status - OPTIMIZED FOR SPEED (locked: completed tasks cannot be toggled back)
  void toggleTaskStatus(Task task) {
    // Prevent toggling completed tasks - they are locked once completed
    if (task.status == 'Completed') {
      return;
    }
    
    // Prevent multiple toggles while saving
    if (_savingTasks[task.id] == true) {
      return;
    }
    
    final newStatus = task.status == 'Pending' ? 'Completed' : 'Pending';
    final updatedTask = task.copyWith(status: newStatus);
    
    // Update UI instantly
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      tasks[index] = updatedTask;
      tasks.refresh();
    }
    
    // Save silently in background (no snackbar for toggle)
    _savingTasks[task.id!] = true;
    _taskQueries.updateTask(updatedTask).then((_) {
      _savingTasks.remove(task.id!);
    }).catchError((e) {
      _savingTasks.remove(task.id!);
      // Revert on error
      if (index != -1) {
        tasks[index] = task;
        tasks.refresh();
      }
    });
  }

  // Delete all tasks - OPTIMIZED
  Future<void> deleteAllTasks() async {
    try {
      // Clear UI immediately
      tasks.clear();
      
      // Delete from database in background
      _taskQueries.deleteAllTasks().catchError((e) {
        // Revert if deletion fails
        Get.closeCurrentSnackbar();
        Get.snackbar('Error', 'Failed to delete all tasks: $e');
        fetchTasks(); // Reload tasks
        return 0;
      });
      
      Get.closeCurrentSnackbar();
      Get.snackbar('Success', 'All tasks deleted successfully');
    } catch (e) {
      Get.closeCurrentSnackbar();
      Get.snackbar('Error', 'Failed to delete all tasks: $e');
    }
  }

  // Mark task as pending (move from completed to pending)
  void markAsPending(Task task) {
    // Only allow if task is completed
    if (task.status != 'Completed') {
      return;
    }
    
    // Prevent multiple toggles while saving
    if (_savingTasks[task.id] == true) {
      return;
    }
    
    // Update task: change status to Pending and clear dateCompleted
    final updatedTask = task.copyWith(
      status: 'Pending',
      dateCompleted: null,
    );
    
    // Mark as saving to prevent duplicate saves
    _savingTasks[task.id!] = true;
    
    // Update UI instantly
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      tasks[index] = updatedTask;
      tasks.refresh();
    }
    
    // Save to database and reload all tasks to ensure consistency
    _taskQueries.updateTask(updatedTask).then((_) {
      _savingTasks.remove(task.id!);
      // Reload all tasks from database to ensure UI is in sync
      fetchTasks();
    }).catchError((e) {
      _savingTasks.remove(task.id!);
      // Revert on error
      if (index != -1) {
        tasks[index] = task;
        tasks.refresh();
      }
      Get.closeCurrentSnackbar();
      Get.snackbar('Error', 'Failed to mark as pending: $e');
    });
  }

  // Delete all completed tasks - OPTIMIZED
  Future<void> deleteAllCompletedTasks() async {
    try {
      // Get completed tasks before clearing
      final completedTasks = tasks.where((t) => t.status == 'Completed').toList();
      
      // Remove completed tasks from UI immediately
      tasks.removeWhere((t) => t.status == 'Completed');
      
      // Delete from database in background
      Future.wait(
        completedTasks.map((t) => _taskQueries.deleteTask(t.id!))
      ).catchError((e) {
        // Revert if deletion fails
        Get.closeCurrentSnackbar();
        Get.snackbar('Error', 'Failed to delete completed tasks: $e');
        fetchTasks(); // Reload tasks
        return <int>[];
      });
      
      Get.closeCurrentSnackbar();
      Get.snackbar('Success', 'All completed tasks deleted successfully');
    } catch (e) {
      Get.closeCurrentSnackbar();
      Get.snackbar('Error', 'Failed to delete completed tasks: $e');
    }
  }

  // Delete all pending tasks - OPTIMIZED
  Future<void> deleteAllPendingTasks() async {
    try {
      // Get pending tasks before clearing
      final pendingTasks = tasks.where((t) => t.status == 'Pending').toList();
      
      // Remove pending tasks from UI immediately
      tasks.removeWhere((t) => t.status == 'Pending');
      
      // Delete from database in background
      Future.wait(
        pendingTasks.map((t) => _taskQueries.deleteTask(t.id!))
      ).catchError((e) {
        // Revert if deletion fails
        Get.closeCurrentSnackbar();
        Get.snackbar('Error', 'Failed to delete pending tasks: $e');
        fetchTasks(); // Reload tasks
        return <int>[];
      });
      
      Get.closeCurrentSnackbar();
      Get.snackbar('Success', 'All pending tasks deleted successfully');
    } catch (e) {
      Get.closeCurrentSnackbar();
      Get.snackbar('Error', 'Failed to delete pending tasks: $e');
    }
  }

  // Get latest task by ID (for reactive updates)
  Task? getTaskById(int id) {
    try {
      return tasks.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get task count
  int getTaskCount() => tasks.length;

  // Get completed tasks count
  int getCompletedCount() => tasks.where((t) => t.status == 'Completed').length;

  // Get pending tasks count
  int getPendingCount() => tasks.where((t) => t.status == 'Pending').length;

  // Get filtered tasks by tab
  List<Task> getFilteredTasks() {
    if (selectedTab.value == 'Pending') {
      return tasks.where((t) => t.status == 'Pending').toList();
    } else {
      return tasks.where((t) => t.status == 'Completed').toList();
    }
  }

  // Get pending tasks only
  List<Task> getPendingTasks() => tasks.where((t) => t.status == 'Pending').toList();

  // Get completed tasks only
  List<Task> getCompletedTasks() => tasks.where((t) => t.status == 'Completed').toList();

  // Complete task: marks a task as completed with a timestamp
  Future<void> completeTask(Task task) async {
    try {
      // Create updated task with Completed status and current timestamp
      final updatedTask = task.copyWith(
        status: 'Completed',
        dateCompleted: DateTime.now(),
      );
      
      // Update in database
      await _taskQueries.updateTask(updatedTask);
      
      // Reload all tasks to reflect the change in Obx-wrapped UI
      await fetchTasks();
      
      Get.closeCurrentSnackbar();
      Get.snackbar('Success', 'Task marked as completed');
    } catch (e) {
      Get.closeCurrentSnackbar();
      Get.snackbar('Error', 'Failed to complete task: $e');
    }
  }
}
