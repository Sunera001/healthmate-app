import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/health_provider.dart';
import '../widgets/health_metric_card.dart';
import 'list_screen.dart';
import 'add_edit_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HealthProvider>(context);
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final totals = provider.totalsForDate(today);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8), // Light grey background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'HealthMate',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list, color: Colors.black),
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ListScreen())),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await provider.loadRecords();
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Today, ${DateFormat('d MMM').format(DateTime.now())}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.4,
              children: [
                HealthMetricCard(
                  title: 'Steps',
                  value: totals['steps'].toString(),
                  unit: 'steps',
                  icon: Icons.directions_walk,
                  iconColor: const Color(0xFFEAB308), // Yellowish
                  iconBgColor: const Color(0xFFFEF9C3),
                ),
                HealthMetricCard(
                  title: 'Calories Burnt',
                  value: totals['calories'].toString(),
                  unit: 'kCal',
                  icon: Icons.local_fire_department,
                  iconColor: const Color(0xFFEF4444), // Red/Orange
                  iconBgColor: const Color(0xFFFEE2E2),
                ),
                HealthMetricCard(
                  title: 'Water',
                  value: (totals['water'] ?? 0).toString(),
                  unit: 'ml',
                  icon: Icons.water_drop,
                  iconColor: const Color(0xFF3B82F6), // Blue
                  iconBgColor: const Color(0xFFDBEAFE),
                ),
                // Placeholder for balance or another metric if needed,
                // or we can make the Water card full width if we wanted,
                // but GridView is rigid.
                // Let's add a dummy "Distance" card to fill the grid
                // and match the image better, calculating distance from steps roughly.
                HealthMetricCard(
                  title: 'Distance',
                  value: ((totals['steps'] ?? 0) * 0.0008).toStringAsFixed(
                    1,
                  ), // Approx 0.8m per step
                  unit: 'km',
                  icon: Icons.map,
                  iconColor: const Color(0xFF10B981), // Green
                  iconBgColor: const Color(0xFFD1FAE5),
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddEditScreen()),
                );
                provider.loadRecords();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text(
                'Add New Record',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Recent Records',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            provider.records.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'No records yet. Start tracking!',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : Column(
                    children: provider.records.take(5).map((r) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          title: Text(
                            r.date,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${r.steps} steps  •  ${r.calories} kCal  •  ${r.water} ml',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: Colors.grey,
                                ),
                                onPressed: () async {
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          AddEditScreen(existing: r),
                                    ),
                                  );
                                  provider.loadRecords();
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (BuildContext dialogContext) {
                                      return AlertDialog(
                                        title: const Text('Confirm Deletion'),
                                        content: const Text(
                                          'Are you sure you want to delete this record?',
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () => Navigator.of(
                                              dialogContext,
                                            ).pop(false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.of(
                                              dialogContext,
                                            ).pop(true),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (confirm == true) {
                                    if (r.id != null) {
                                      await provider.deleteRecord(r.id!);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Record deleted successfully',
                                            ),
                                          ),
                                        );
                                      }
                                    } else {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Error: Record ID is null',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  }
                                  provider.loadRecords();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }
}
