import 'package:flutter/material.dart';
import '../../../core/ac_chat.dart';

class LocationMessageBubble extends StatelessWidget {
  final AcChatMessage message;
  final AcChatTheme ct;

  const LocationMessageBubble({
    super.key,
    required this.message,
    required this.ct,
  });

  @override
  Widget build(BuildContext context) {
    // The message text stores the location description, e.g. "Times Square, NY (40.7580° N, 73.9855° W)"
    final locText = message.text;

    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: ct.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ct.subText.withOpacity(0.15)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Map preview container (mock map)
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade100, Colors.green.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                // Mock grid lines representing a map
                Positioned.fill(
                  child: GridPaper(
                    color: Colors.blue.withOpacity(0.1),
                    divisions: 1,
                    subdivisions: 1,
                    interval: 60,
                  ),
                ),
                // Map Pin
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        color: Colors.red.shade600,
                        size: 38,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Container(
                        width: 8,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Info row
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shared Location',
                  style: TextStyle(
                    color: ct.text,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  locText,
                  style: TextStyle(
                    color: ct.subText,
                    fontSize: 11,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.map_rounded, color: ct.activeTabColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Open in Maps',
                      style: TextStyle(
                        color: ct.activeTabColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
