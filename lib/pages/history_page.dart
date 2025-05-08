import 'package:flutter/material.dart';
import 'package:workout_tracker/services/log_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<Map<String, dynamic>>> logsFuture;

  @override
  void initState() {
    super.initState();
    logsFuture = LogService.getUserLogs();
  }

  // refresh logs after deletion
  void _refreshLogs() {
    setState(() {
      logsFuture = LogService.getUserLogs();
    });
  }

  // method to handle delete action
  Future<void> _deleteLog(String createdAt) async {
    await LogService.deleteLog(createdAt);
    _refreshLogs();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Workout History', style: TextStyle(color: textColor)),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: logsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty)
            return Center(
              child: Text("No logs yet.", style: TextStyle(color: textColor)),
            );

          final logs = snapshot.data!;
          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return ListTile(
                leading: Icon(Icons.fitness_center, color: textColor),
                title: Text(
                  log['exercise'],
                  style: TextStyle(color: textColor),
                ),
                subtitle: Text(
                  'Duration: ${log['duration_minutes']} min\n'
                  'Date: ${DateTime.parse(log['created_at']).toLocal().toString().substring(0, 16)}',
                  style: TextStyle(color: textColor),
                ),

                // Add delete icon button
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  // In delete:
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: Text('Delete Log'),
                            content: Text(
                              'Are you sure you want to delete this log?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                    );
                    if (confirm == true) {
                      await _deleteLog(
                        log['created_at'],
                      ); // <-- use the raw value
                      _refreshLogs();
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
