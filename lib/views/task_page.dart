import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/task_controller.dart';
import '../dialogs/add_task_dialog.dart';
import '../dialogs/delete_all_dialog.dart';
import '../widgets/task_card.dart';
import '../widgets/empty_state_widget.dart';
import '../models/task_model.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({Key? key}) : super(key: key);

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  late TaskController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(TaskController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          const SizedBox(height: 28),
              
          // Tab Bar for Pending and Completed
          Obx(() => Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Pending Tab
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      controller.selectedTab.value = 'Pending';
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: controller.selectedTab.value == 'Pending'
                            ? Colors.white.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.assignment,
                            color: controller.selectedTab.value == 'Pending'
                                ? Colors.amber
                                : Colors.white.withOpacity(0.6),
                            size: 20,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Pending',
                            style: TextStyle(
                              color: controller.selectedTab.value == 'Pending'
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.6),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Obx(
                            () => Text(
                              '${controller.getPendingCount()}',
                              style: TextStyle(
                                color: controller.selectedTab.value == 'Pending'
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.5),
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Completed Tab
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      controller.selectedTab.value = 'Completed';
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: controller.selectedTab.value == 'Completed'
                            ? Colors.white.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: controller.selectedTab.value == 'Completed'
                                ? Colors.green
                                : Colors.white.withOpacity(0.6),
                            size: 20,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Completed',
                            style: TextStyle(
                              color: controller.selectedTab.value == 'Completed'
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.6),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Obx(
                            () => Text(
                              '${controller.getCompletedCount()}',
                              style: TextStyle(
                                color: controller.selectedTab.value == 'Completed'
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.5),
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            )),
              const SizedBox(height: 12),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color.fromARGB(66, 61, 58, 58),
                        strokeWidth: 3,
                      ),
                    );
                  }

                  final filteredTasks = controller.getFilteredTasks();
                  if (filteredTasks.isEmpty) {
                    return EmptyStateWidget(
                      message: controller.selectedTab.value == 'Completed'
                          ? 'No completed tasks yet'
                          : 'No tasks yet',
                      subtitle: controller.selectedTab.value == 'Completed'
                          ? 'Complete some tasks to see them here'
                          : 'Tap the + button to add your first task',
                    );
                  }

                  return _buildTasksList(filteredTasks);
                }),
              ),
            ],
          ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildTasksList(List<Task> tasks) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // Stats badge with Refresh and Delete icons
          Obx(() {
            final completed = controller.getCompletedCount();
            final total = controller.getTaskCount();
            
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Refresh Icon (Left, Always visible)
                Tooltip(
                  message: 'Refresh tasks',
                  child: GestureDetector(
                    onTap: () => controller.fetchTasks(),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.blue.withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.refresh,
                        color: Colors.blue.withValues(alpha: 0.8),
                        size: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Stats badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(4, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    '$completed of $total done!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Trash Icon (Right, For current tab)
                Obx(() => Visibility(
                  visible: (controller.selectedTab.value == 'Completed' &&
                      controller.getCompletedCount() > 0) ||
                      (controller.selectedTab.value == 'Pending' &&
                          controller.getPendingCount() > 0),
                  child: Tooltip(
                    message: controller.selectedTab.value == 'Completed'
                        ? 'Delete all completed tasks'
                        : 'Delete all pending tasks',
                    child: GestureDetector(
                      onTap: () {
                        if (controller.selectedTab.value == 'Completed') {
                          DeleteAllDialog.showCompletedOnly(controller);
                        } else {
                          DeleteAllDialog.showPendingOnly(controller);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.6),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.delete_outline,
                          color: Colors.red.withValues(alpha: 0.8),
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                )),
              ],
            );
          }),
          const SizedBox(height: 20),
          // Tasks list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return TaskCard(
                key: ValueKey(task.id),
                task: task,
                controller: controller,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return GestureDetector(
      onTap: () => AddTaskDialog.show(controller),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.white, Color(0xFFF5F5F5)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(6, 6),
            ),
          ],
        ),
        child: const Icon(Icons.add, size: 32, color: Color.fromARGB(255, 2, 2, 2)),
      ),
    );
  }
}

