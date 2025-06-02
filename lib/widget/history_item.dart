import 'package:flutter/material.dart';

class HistoryItem extends StatelessWidget {
  final String date;
  final String month;
  final String name;
  final String location;
  final String time;
  final String status;
  final Color statusColor;

  const HistoryItem({
    super.key,
    required this.date,
    required this.month,
    required this.name,
    required this.location,
    required this.time,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(month, style: const TextStyle(fontSize: 10)),
            ],
          ),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(location),
            const SizedBox(height: 4),
            Row(
              children: [
                Flexible(child: Text(time, style: TextStyle(fontSize: 12))),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(color: statusColor, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
