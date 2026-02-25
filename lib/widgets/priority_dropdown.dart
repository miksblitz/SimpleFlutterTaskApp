import 'package:flutter/material.dart';

class PriorityDropdown extends StatelessWidget {
  final String? selectedPriority;
  final Function(String?) onChanged;

  const PriorityDropdown({
    Key? key,
    this.selectedPriority,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Priority',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: DropdownButton<String>(
            value: selectedPriority ?? 'Medium',
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: const Color.fromARGB(255, 52, 52, 54),
            style: const TextStyle(color: Colors.white, fontSize: 14),
            items: ['Low', 'Medium', 'High']
                .map((priority) => DropdownMenuItem(
                      value: priority,
                      child: Row(
                        children: [
                          Icon(
                            _getPriorityIcon(priority),
                            color: _getPriorityColor(priority),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(priority),
                        ],
                      ),
                    ))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority) {
      case 'Low':
        return Icons.arrow_downward;
      case 'High':
        return Icons.arrow_upward;
      default:
        return Icons.drag_handle;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Low':
        return Colors.blue;
      case 'High':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}
