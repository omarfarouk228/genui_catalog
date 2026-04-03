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
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 12),
            ],
            Semantics(
              slider: true,
              value: _rating == 0 ? 'No rating' : '$_rating out of ${widget.maxStars}',
              increasedValue: _rating < widget.maxStars
                  ? '${(_rating + (widget.allowHalf ? 0.5 : 1)).clamp(0, widget.maxStars.toDouble())} out of ${widget.maxStars}'
                  : null,
              decreasedValue: _rating > 0
                  ? '${(_rating - (widget.allowHalf ? 0.5 : 1)).clamp(0, widget.maxStars.toDouble())} out of ${widget.maxStars}'
                  : null,
              onIncrease: _rating < widget.maxStars
                  ? () {
                      final next = (_rating + (widget.allowHalf ? 0.5 : 1))
                          .clamp(0.0, widget.maxStars.toDouble());
                      setState(() => _rating = next);
                      widget.dispatchEvent('rating_submitted');
                    }
                  : null,
              onDecrease: _rating > 0
                  ? () {
                      final prev = (_rating - (widget.allowHalf ? 0.5 : 1))
                          .clamp(0.0, widget.maxStars.toDouble());
                      setState(() => _rating = prev);
                      widget.dispatchEvent('rating_submitted');
                    }
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
            )),
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
