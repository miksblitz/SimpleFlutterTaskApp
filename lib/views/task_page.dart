import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/task_controller.dart';
import '../dialogs/add_task_dialog.dart';
import '../dialogs/delete_all_dialog.dart';
import '../widgets/task_card.dart';
import '../widgets/empty_state_widget.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({Key? key}) : super(key: key);

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final TaskController controller = Get.put(TaskController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/assets/peace.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // Dark overlay for better text visibility
          Container(
            color: Colors.black.withOpacity(0.3),
          ),

          // Main content
          Column(
            children: [
              // Top right delete all button
              Padding(
                padding: const EdgeInsets.only(right: 20, top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (controller.tasks.isNotEmpty)
                      GestureDetector(
                        onTap: () => DeleteAllDialog.show(controller),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.3),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.red.withOpacity(0.6),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            Icons.delete_outline,
                            color: Colors.red.withOpacity(0.8),
                            size: 22,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    );
                  }

                  if (controller.tasks.isEmpty) {
                    return const EmptyStateWidget();
                  }

                  return _buildTasksList();
                }),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildTasksList() {
    return Obx(() => SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // Stats badge - Long press to delete all
          GestureDetector(
            onLongPress: controller.tasks.isNotEmpty
                ? () => DeleteAllDialog.show(controller)
                : null,
            child: Container(
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
              child: Obx(() => Text(
                '${controller.getCompletedCount()} of ${controller.getTaskCount()} done!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              )),
            ),
          ),
          const SizedBox(height: 20),
          // Tasks list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.tasks.length,
            itemBuilder: (context, index) {
              final task = controller.tasks[index];
              return TaskCard(task: task, controller: controller);
            },
          ),
        ],
      ),
    ));
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
        child: const Icon(Icons.add, size: 32, color: Color(0xFF6366F1)),
      ),
    );
  }
}

