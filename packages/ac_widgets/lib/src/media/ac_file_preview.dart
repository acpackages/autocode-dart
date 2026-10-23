import 'package:flutter/material.dart';

/// Supported preview file types.
enum AcFileType {
  image,
  pdf,
  video,
  audio,
  document,
  code,
  archive,
  generic,
}

/// A file previewer card displaying appropriate icons/thumbnails, metadata, and full-screen view.
class AcFilePreview extends StatelessWidget {
  final String fileName;
  final String? fileSize;
  final String? fileUrl;
  final AcFileType fileType;
  final VoidCallback? onDownload;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const AcFilePreview({
    super.key,
    required this.fileName,
    this.fileSize,
    this.fileUrl,
    this.fileType = AcFileType.generic,
    this.onDownload,
    this.onDelete,
    this.onTap,
  });

  IconData _getFileIcon() {
    switch (fileType) {
      case AcFileType.image:
        return Icons.image_outlined;
      case AcFileType.pdf:
        return Icons.picture_as_pdf_outlined;
      case AcFileType.video:
        return Icons.video_file_outlined;
      case AcFileType.audio:
        return Icons.audio_file_outlined;
      case AcFileType.document:
        return Icons.description_outlined;
      case AcFileType.code:
        return Icons.code;
      case AcFileType.archive:
        return Icons.folder_zip_outlined;
      case AcFileType.generic:
        return Icons.insert_drive_file_outlined;
    }
  }

  Color _getFileColor() {
    switch (fileType) {
      case AcFileType.image:
        return Colors.green;
      case AcFileType.pdf:
        return Colors.red;
      case AcFileType.video:
        return Colors.purple;
      case AcFileType.audio:
        return Colors.orange;
      case AcFileType.document:
        return Colors.blue;
      case AcFileType.code:
        return Colors.teal;
      case AcFileType.archive:
        return Colors.amber.shade800;
      case AcFileType.generic:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = _getFileColor();

    return Card(
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_getFileIcon(), color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      fileName,
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (fileSize != null)
                      Text(
                        fileSize!,
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                      ),
                  ],
                ),
              ),
              if (onDownload != null)
                IconButton(
                  icon: const Icon(Icons.download_rounded, size: 20),
                  tooltip: 'Download',
                  onPressed: onDownload,
                ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                  tooltip: 'Delete',
                  onPressed: onDelete,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
