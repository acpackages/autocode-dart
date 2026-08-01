import 'package:flutter/material.dart';

import '../../common/chat_colors.dart';

class Attachments extends StatelessWidget {
  final AcChatTheme ct;
  final bool isDark;
  final void Function(String) onSelect;

  const Attachments(
      {required this.ct, required this.isDark, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final items = [
      _AttachItem(icon: Icons.insert_drive_file_rounded,
          label: 'Document', color: ct.attachDocumentBg),
      _AttachItem(icon: Icons.camera_alt_rounded,
          label: 'Camera', color: ct.attachCameraBg),
      _AttachItem(icon: Icons.image_rounded,
          label: 'Gallery', color: ct.attachGalleryBg),
      _AttachItem(icon: Icons.headset_rounded,
          label: 'Audio', color: ct.attachAudioBg),
      _AttachItem(icon: Icons.location_on_rounded,
          label: 'Location', color: ct.attachLocationBg),
      _AttachItem(icon: Icons.person_rounded,
          label: 'Contact', color: ct.attachContactBg),
      _AttachItem(icon: Icons.currency_rupee_rounded,
          label: 'Payment', color: ct.attachPaymentBg),
    ];

    return Container(
      decoration: BoxDecoration(
        color: ct.surface,
        borderRadius:
        const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
              color: ct.subText.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 16,
          children: items
              .map((item) => GestureDetector(
            onTap: () => onSelect(item.label),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: item.color.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item.icon,
                        color: item.color, size: 26),
                  ),
                  const SizedBox(height: 6),
                  Text(item.label,
                      style: TextStyle(
                          color: ct.subText, fontSize: 11)),
                ]),
          ))
              .toList(),
        ),
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Recent Media',
            style: TextStyle(
              color: ct.text,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            itemBuilder: (context, index) {
              final mockMedias = [
                'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=150',
                'https://images.unsplash.com/photo-1534972195531-d756b9bda9f2?w=150',
                'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=150',
                'https://images.unsplash.com/photo-1586281380349-632531db7ed4?w=150',
              ];
              return GestureDetector(
                onTap: () => onSelect('Recent Media ${index + 1}'),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(mockMedias[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}

class _AttachItem {
  final IconData icon;
  final String label;
  final Color color;
  const _AttachItem(
      {required this.icon, required this.label, required this.color});
}