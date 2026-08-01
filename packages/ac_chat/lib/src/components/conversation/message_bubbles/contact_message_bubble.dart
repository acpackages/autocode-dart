import 'package:flutter/material.dart';
import '../../../core/ac_chat.dart';

class ContactMessageBubble extends StatelessWidget {
  final AcChatMessage message;
  final AcChatTheme ct;

  const ContactMessageBubble({
    super.key,
    required this.message,
    required this.ct,
  });

  @override
  Widget build(BuildContext context) {
    // The message text stores the contact details, e.g. "John Doe\n+1 (555) 123-4567"
    final lines = message.text.split('\n');
    final name = lines.isNotEmpty ? lines[0] : 'Unknown Contact';
    final phone = lines.length > 1 ? lines[1] : '';
    final initials = name.isNotEmpty ? name[0].toUpperCase() : 'C';

    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: ct.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ct.subText.withOpacity(0.15)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Contact Avatar
              CircleAvatar(
                radius: 22,
                backgroundColor: ct.activeTabColor.withOpacity(0.15),
                child: Text(
                  initials,
                  style: TextStyle(
                    color: ct.activeTabColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Contact Name & Phone
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: ct.text,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    if (phone.isNotEmpty)
                      Text(
                        phone,
                        style: TextStyle(
                          color: ct.subText,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: ct.subText.withOpacity(0.1), height: 1),
          const SizedBox(height: 8),
          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: () {
                  // Simulate Call
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Calling $name...'), duration: const Duration(seconds: 1)),
                  );
                },
                icon: Icon(Icons.call_rounded, color: ct.activeTabColor, size: 16),
                label: Text(
                  'Call',
                  style: TextStyle(
                    color: ct.activeTabColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              Container(
                width: 1,
                height: 16,
                color: ct.subText.withOpacity(0.15),
              ),
              TextButton.icon(
                onPressed: () {
                  // Simulate Save Contact
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Saved $name to contacts!'), duration: const Duration(seconds: 1)),
                  );
                },
                icon: Icon(Icons.person_add_alt_1_rounded, color: ct.activeTabColor, size: 16),
                label: Text(
                  'Save',
                  style: TextStyle(
                    color: ct.activeTabColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
