import 'package:flutter/material.dart';

class RatingInputWidget extends StatefulWidget {
  final String? title;
  final int maxStars;
  final String? label;
  final bool allowHalf;
  final void Function(String event) dispatchEvent;

  const RatingInputWidget({
    super.key,
    this.title,
    required this.maxStars,
    this.label,
    required this.allowHalf,
    required this.dispatchEvent,
  });

  @override
  State<RatingInputWidget> createState() => _RatingInputWidgetState();
}

class _RatingInputWidgetState extends State<RatingInputWidget> {
  double _rating = 0;

  void _onTap(int starIndex, bool isHalf) {
    setState(() {
      _rating = isHalf ? starIndex - 0.5 : starIndex.toDouble();
    });
    widget.dispatchEvent('rating_submitted');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.title != null && widget.title!.isNotEmpty) ...[
              Text(
                widget.title!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
            ],
            if (widget.label != null && widget.label!.isNotEmpty) ...[
              Text(
                widget.label!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(widget.maxStars, (index) {
                final starNumber = index + 1;
                final filled = _rating >= starNumber;
                final halfFilled = !filled && _rating >= starNumber - 0.5;

                return GestureDetector(
                  onTapDown: widget.allowHalf
                      ? (details) {
                          final box = context.findRenderObject() as RenderBox;
                          final localPos = box.globalToLocal(details.globalPosition);
                          // approximate: if tap is in left half of star, it's a half star
                          final starWidth = 36.0;
                          final starOffset = index * starWidth;
                          final tapX = localPos.dx - starOffset;
                          final isHalf = tapX < starWidth / 2;
                          _onTap(starNumber, isHalf);
                        }
                      : null,
                  onTap: widget.allowHalf
                      ? null
                      : () => _onTap(starNumber, false),
                  child: Icon(
                    halfFilled
                        ? Icons.star_half
                        : filled
                            ? Icons.star
                            : Icons.star_border,
                    color: Colors.amber,
                    size: 36,
                  ),
                );
              }),
            ),
            if (_rating > 0) ...[
              const SizedBox(height: 8),
              Text(
                '$_rating / ${widget.maxStars}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
