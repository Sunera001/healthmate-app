import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/health_provider.dart';
import '../widgets/record_tile.dart';
import 'add_edit_screen.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final TextEditingController _dateCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dateCtl.text = '';
  }

  @override
  void dispose() {
    _dateCtl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && context.mounted) {
      _dateCtl.text = DateFormat('yyyy-MM-dd').format(picked);
      // call search
      Provider.of<HealthProvider>(
        context,
        listen: false,
      ).searchByDate(_dateCtl.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HealthProvider>(context);
    final records = provider.records;
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Records'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              provider.loadRecords();
              _dateCtl.clear();
            },
          ),
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () => _pickDate(context),
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'delete_all') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (c) => AlertDialog(
                    title: const Text('Delete All Records'),
                    content: const Text(
                      'Are you sure you want to delete ALL records? This cannot be undone.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(c).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(c).pop(true),
                        child: const Text(
                          'Delete All',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await provider.deleteAllRecords();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('All records deleted')),
                    );
                  }
                }
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'delete_all',
                  child: Text(
                    'Delete All Records',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _dateCtl,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Filter by date (tap calendar)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_dateCtl.text.isEmpty) {
                      provider.loadRecords();
                    } else {
                      provider.searchByDate(_dateCtl.text);
                    }
                  },
                  child: const Text('Apply'),
                ),
              ],
            ),
          ),
          Expanded(
            child: records.isEmpty
                ? const Center(child: Text('No records. Add one with +'))
                : ListView.builder(
                    itemCount: records.length,
                    itemBuilder: (context, idx) {
                      final r = records[idx];
                      return RecordTile(
                        record: r,
                        onEdit: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AddEditScreen(existing: r),
                            ),
                          );
                          provider.loadRecords();
                        },
                        onDelete: (id) async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (c) => AlertDialog(
                              title: const Text('Confirm delete'),
                              content: const Text(
                                'Are you sure you want to delete this record?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(c).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(c).pop(true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            await provider.deleteRecord(id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Deleted')),
                              );
                            }
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const AddEditScreen()));
          provider.loadRecords();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
