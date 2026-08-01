import 'package:flutter/material.dart';
import '../../../core/ac_chat.dart';
import '../../../common/chat_colors.dart';

class DocumentMessageBubble extends StatelessWidget {
  final AcChatMessage message;
  final AcChatTheme ct;
  const DocumentMessageBubble({required this.message, required this.ct});

  @override
  Widget build(BuildContext context) {
    final fileName = message.fileName ?? 'Document.pdf';
    final lowerName = fileName.toLowerCase();

    // Determine type
    bool isPdf = lowerName.endsWith('.pdf');
    bool isExcel = lowerName.endsWith('.xlsx') || lowerName.endsWith('.xls');
    bool isWord = lowerName.endsWith('.docx') || lowerName.endsWith('.doc');
    bool isZip = lowerName.endsWith('.zip') || lowerName.endsWith('.rar');

    // Get styling
    Color iconColor;
    IconData iconData;
    Color bgColor;

    if (isPdf) {
      iconColor = ct.docIconPdf;
      iconData = Icons.picture_as_pdf_rounded;
      bgColor = ct.docBgPdf;
    } else if (isExcel) {
      iconColor = ct.docIconExcel;
      iconData = Icons.grid_on_rounded;
      bgColor = ct.docBgExcel;
    } else if (isWord) {
      iconColor = ct.docIconWord;
      iconData = Icons.description_rounded;
      bgColor = ct.docBgWord;
    } else if (isZip) {
      iconColor = ct.docIconPpt;
      iconData = Icons.folder_zip_rounded;
      bgColor = ct.docBgPpt;
    } else {
      iconColor = ct.subText;
      iconData = Icons.article_rounded;
      bgColor = ct.subText.withOpacity(0.12);
    }

    if (isPdf) {
      // Return a premium PDF Thumbnail preview card
      return Container(
        width: 200,
        decoration: BoxDecoration(
          color: ct.messageBubbleSystemBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: ct.subText.withOpacity(0.15), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PDF Visual Thumbnail representation
            Container(
              height: 90,
              width: double.infinity,
              decoration: BoxDecoration(
                color: ct.messageBubbleAttachmentPreviewBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Page layout mockup
                  Container(
                    width: 55,
                    height: 70,
                    decoration: BoxDecoration(
                      color: ct.white,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: ct.black.withOpacity(0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 18,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: ct.docIconPdf,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'PDF',
                            style: TextStyle(
                              color: ct.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(height: 3, width: 40, color: ct.greyShade300),
                                Container(height: 3, width: 35, color: ct.greyShade300),
                                Container(height: 3, width: 25, color: ct.greyShade300),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(width: 8, height: 8, color: ct.docIconPdf.withOpacity(0.3)),
                                    Container(width: 20, height: 3, color: ct.greyShade300),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: ct.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        '1 Page',
                        style: TextStyle(color: ct.white, fontSize: 8, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                ],
              ),
            ),
            // Info Row
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(Icons.picture_as_pdf, color: ct.docIconPdf, size: 20),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fileName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: ct.text,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          message.fileSize ?? 'Unknown size',
                          style: TextStyle(
                            color: ct.subText,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Default Document row with custom styling
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: ct.messageBubbleSystemBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ct.subText.withOpacity(0.12), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(iconData, color: iconColor, size: 24),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                fileName,
                style: TextStyle(
                  color: ct.text,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                message.fileSize ?? '',
                style: TextStyle(
                  color: ct.subText,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}