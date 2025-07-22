import 'package:bbb/components/common_network_image.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:bbb/values/app_colors.dart';
import 'package:flutter/material.dart';

class NewspaperLayoutWidget extends StatelessWidget {
  final String text;
  final String imageUrl;
  final double imageWidth;
  final double imageHeight;
  final TextStyle? textStyle;
  final EdgeInsets padding;

  const NewspaperLayoutWidget({
    super.key,
    required this.text,
    required this.imageUrl,
    this.imageWidth = 120,
    this.imageHeight = 120,
    this.textStyle,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return _buildNewspaperLayout(context, constraints);
        },
      ),
    );
  }

  Widget _buildNewspaperLayout(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    final defaultTextStyle = textStyle ??
        Theme.of(context).textTheme.bodyMedium ??
        const TextStyle(fontSize: 16, height: 1.5);
    final spacing = 18.0;
    final availableWidthNextToImage =
        constraints.maxWidth - imageWidth - spacing;
    final textPainter = TextPainter(
      // textAlign: TextAlign.left,
      text: TextSpan(
        text: 'Ag',
        style: defaultTextStyle,
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final actualLineHeight = textPainter.height;
    final linesNextToImage = (imageHeight / actualLineHeight).floor();
    final textNextToImage = _getTextForLines(
      text,
      defaultTextStyle,
      availableWidthNextToImage,
      linesNextToImage,
    );
    final remainingText = text.substring(textNextToImage.length).trim();

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: imageWidth,
                height: imageHeight,
                margin: EdgeInsets.only(right: spacing),
                child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(ScreenUtil.verticalScale(500)),
                    child: appShimmerImage(
                      color: Colors.transparent,
                      height: imageHeight,
                      width: imageWidth,
                      networkImageUrl: imageUrl,
                      fit: BoxFit.cover,
                      borderRadius:
                          BorderRadius.circular(ScreenUtil.verticalScale(500)),
                    )
                    // Image.network(
                    //   imageUrl,
                    //   width: imageWidth,
                    //   height: imageHeight,
                    //   fit: BoxFit.cover,
                    //   errorBuilder: (context, error, stackTrace) {
                    //     return Container(
                    //       color: Colors.grey[300],
                    //       child: const Icon(
                    //         Icons.image_not_supported,
                    //         color: Colors.grey,
                    //         size: 40,
                    //       ),
                    //     );
                    //   },
                    // ),
                    ),
              ),
              Expanded(
                child: SizedBox(
                  height: imageHeight,
                  child: Text(
                    textNextToImage,
                    style: defaultTextStyle.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color),
                    // textAlign: TextAlign.justify,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
            ],
          ),
          if (remainingText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Text(
                remainingText,
                style: defaultTextStyle.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color),
                // textAlign: TextAlign.justify,
              ),
            ),
        ],
      ),
    );
  }

  String _getTextForLines(
    String fullText,
    TextStyle style,
    double maxWidth,
    int maxLines,
  ) {
    if (maxLines <= 0 || fullText.isEmpty) return '';

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      maxLines: maxLines,
    );

    int low = 0;
    int high = fullText.length;
    String result = '';

    while (low <= high) {
      int mid = (low + high) ~/ 2;
      String testText = fullText.substring(0, mid);

      textPainter.text = TextSpan(text: testText, style: style);
      textPainter.layout(maxWidth: maxWidth);

      if (textPainter.didExceedMaxLines ||
          textPainter.height > maxLines * textPainter.preferredLineHeight) {
        high = mid - 1;
      } else {
        result = testText;
        low = mid + 1;
      }
    }

    if (result.length < fullText.length) {
      int lastSpace = result.lastIndexOf(' ');
      int lastNewline = result.lastIndexOf('\n');
      int breakPoint = [lastSpace, lastNewline].reduce((a, b) => a > b ? a : b);

      if (breakPoint > result.length * 0.7) {
        result = result.substring(0, breakPoint);
      }
    }

    return result.trim();
  }
}
