import 'package:flutter/material.dart';

class RatingInputWidget extends StatefulWidget {
  final String? title;
  final int maxStars;
  final String? label;
  final bool allowHalf;

  /// Screen-reader value when nothing is selected.
  final String noRatingLabel;

  /// Screen-reader word between the rating and the maximum ("3 out of 5").
  final String outOfLabel;

  /// Called with `rating_submitted` and `{rating, maxStars}`.
  final void Function(String event, Map<String, Object> context) dispatchEvent;

  const RatingInputWidget({
    super.key,
    this.title,
    required this.maxStars,
    this.label,
    required this.allowHalf,
    required this.dispatchEvent,
    this.noRatingLabel = 'No rating',
    this.outOfLabel = 'out of',
  });

  @override
  State<RatingInputWidget> createState() => _RatingInputWidgetState();
}

class _RatingInputWidgetState extends State<RatingInputWidget> {
  double _rating = 0;

  void _onTap(int starIndex, bool isHalf) {
    _rate(isHalf ? starIndex - 0.5 : starIndex.toDouble());
  }

  void _rate(double rating) {
    setState(() => _rating = rating);
    widget.dispatchEvent('rating_submitted', {
      // 4 rather than 4.0 when half stars are off.
      'rating': rating % 1 == 0 ? rating.toInt() : rating,
      'maxStars': widget.maxStars,
    });
  }

  String _describe(double rating) =>
      '$rating ${widget.outOfLabel} ${widget.maxStars}';

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
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
            ],
            if (widget.label != null && widget.label!.isNotEmpty) ...[
              Text(
                widget.label!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
            ],
            Semantics(
              slider: true,
              value: _rating == 0 ? widget.noRatingLabel : _describe(_rating),
              increasedValue: _rating < widget.maxStars
                  ? _describe(
                      (_rating + (widget.allowHalf ? 0.5 : 1)).clamp(
                        0,
                        widget.maxStars.toDouble(),
                      ),
                    )
                  : null,
              decreasedValue: _rating > 0
                  ? _describe(
                      (_rating - (widget.allowHalf ? 0.5 : 1)).clamp(
                        0,
                        widget.maxStars.toDouble(),
                      ),
                    )
                  : null,
              onIncrease: _rating < widget.maxStars
                  ? () => _rate(
                      (_rating + (widget.allowHalf ? 0.5 : 1)).clamp(
                        0.0,
                        widget.maxStars.toDouble(),
                      ),
                    )
                  : null,
              onDecrease: _rating > 0
                  ? () => _rate(
                      (_rating - (widget.allowHalf ? 0.5 : 1)).clamp(
                        0.0,
                        widget.maxStars.toDouble(),
                      ),
                    )
                  : null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(widget.maxStars, (index) {
                  final starNumber = index + 1;
                  final filled = _rating >= starNumber;
                  final halfFilled = !filled && _rating >= starNumber - 0.5;

                  final icon = Icon(
                    halfFilled
                        ? Icons.star_half
                        : filled
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                    size: 36,
                  );

                  if (!widget.allowHalf) {
                    return GestureDetector(
                      onTap: () => _onTap(starNumber, false),
                      child: icon,
                    );
                  }

                  // Split each star into two independent hit areas so the
                  // position is always relative to the star itself, not the
                  // parent widget.
                  return SizedBox(
                    width: 36,
                    height: 36,
                    child: Stack(
                      children: [
                        icon,
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _onTap(starNumber, true),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _onTap(starNumber, false),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
            if (_rating > 0) ...[
              const SizedBox(height: 8),
              Text(
                '$_rating / ${widget.maxStars}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
