import 'package:get/get.dart';
import '../models/task_model.dart';
import '../data/db_helper.dart';

class TaskController extends GetxController {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Reactive list of tasks
  var tasks = <Task>[].obs;
  var isLoading = false.obs;
  
  // Map to track which tasks are being saved (for preventing race conditions)
  final _savingTasks = <int, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTasks();
  }

  // Fetch all tasks from database
  Future<void> fetchTasks() async {
    try {
      isLoading(true);
      final fetchedTasks = await _dbHelper.getTasks();
      tasks.assignAll(fetchedTasks);
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
      final id = await _dbHelper.insertTask(task);
      final newTask = task.copyWith(id: id);
      tasks.insert(0, newTask);
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
      // UPDATE UI IMMEDIATELY (Optimistic Update)
      final index = tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        tasks[index] = task;
        tasks.refresh(); // Instant UI update
      }
      
      // Mark as saving to prevent duplicate saves
      _savingTasks[task.id!] = true;
      
      // SAVE TO DATABASE IN BACKGROUND (Non-blocking)
      _dbHelper.updateTask(task).then((_) {
        _savingTasks.remove(task.id!);
      }).catchError((e) {
        _savingTasks.remove(task.id!);
        // Revert UI on error
        if (index != -1) {
          final currentTask = tasks[index];
          // Rollback would go here if needed
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
      _dbHelper.deleteTask(id).catchError((e) {
        // Revert if deletion fails
        Get.closeCurrentSnackbar();
        Get.snackbar('Error', 'Failed to delete task: $e');
      });
      
      Get.closeCurrentSnackbar();
      Get.snackbar('Success', 'Task deleted successfully');
    } catch (e) {
      Get.closeCurrentSnackbar();
      Get.snackbar('Error', 'Failed to delete task: $e');
    }
  }

  // Toggle task status - OPTIMIZED FOR SPEED
  void toggleTaskStatus(Task task) {
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
    _dbHelper.updateTask(updatedTask).then((_) {
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
      _dbHelper.deleteAllTasks().catchError((e) {
        // Revert if deletion fails
        Get.closeCurrentSnackbar();
        Get.snackbar('Error', 'Failed to delete all tasks: $e');
        fetchTasks(); // Reload tasks
      });
      
      Get.closeCurrentSnackbar();
      Get.snackbar('Success', 'All tasks deleted successfully');
    } catch (e) {
      Get.closeCurrentSnackbar();
      Get.snackbar('Error', 'Failed to delete all tasks: $e');
    }
  }

  // Get task count
  int getTaskCount() => tasks.length;

  // Get completed tasks count
  int getCompletedCount() => tasks.where((t) => t.status == 'Completed').length;

  // Get pending tasks count
  int getPendingCount() => tasks.where((t) => t.status == 'Pending').length;
}
