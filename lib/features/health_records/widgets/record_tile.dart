import 'package:flutter/material.dart';
import '../models/health_record.dart';

class RecordTile extends StatelessWidget {
  final HealthRecord record;
  final VoidCallback onEdit;
  final Function(int id) onDelete;

  const RecordTile({
    super.key,
    required this.record,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(record.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (dir) async {
        final res = await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('Confirm delete'),
            content: const Text('Delete this record?'),
            actions: [
              TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('No')),
              TextButton(onPressed: () => Navigator.of(c).pop(true), child: const Text('Yes')),
            ],
          ),
        );
        if (res == true) {
          onDelete(record.id!);
        }
        return res ?? false;
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: ListTile(
          leading: CircleAvatar(child: Text(record.date.split('-').last)),
          title: Text(record.date),
          subtitle: Text('Steps: ${record.steps}  •  Cal: ${record.calories}  •  Water: ${record.water}ml'),
          trailing: IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
        ),
      ),
    );
  }
}
