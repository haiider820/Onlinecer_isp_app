import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/field_ops_design_tokens.dart';

/// "Navigate" quick action, used on request-detail screens and dispatch cards.
///
/// Launches an external map app pointed at [latitude]/[longitude] when
/// coordinates are available:
///  - Android: `geo:` URI
///  - iOS:     `http://maps.apple.com/?daddr=` maps URI
///  - fallback: Google Maps `https://www.google.com/maps/dir/?api=1&destination=`
///
/// When no coordinates exist the button renders disabled with a tooltip
/// ("Navigate is off until a location is captured."). The full-width variant
/// additionally prints that explanation as a caption underneath, because a
/// tooltip alone is not discoverable on touch devices and the greyed-out
/// control otherwise reads as broken.
class NavigateButton extends StatelessWidget {
  const NavigateButton({
    super.key,
    this.latitude,
    this.longitude,
    this.label = 'Navigate',
    this.compact = false,
  });

  final double? latitude;
  final double? longitude;
  final String label;

  /// Renders as dashed-map compact style instead of full-width button.
  final bool compact;

  bool get _hasCoords => latitude != null && longitude != null;

  Future<void> _navigate(BuildContext context) async {
    if (!_hasCoords) return;
    final lat = latitude!.toStringAsFixed(6);
    final lng = longitude!.toStringAsFixed(6);

    final Uri uri;
    if (Theme.of(context).platform == TargetPlatform.android) {
      uri = Uri.parse('geo:$lat,$lng?q=$lat,$lng');
    } else if (Theme.of(context).platform == TargetPlatform.iOS) {
      uri = Uri.parse('http://maps.apple.com/?daddr=$lat,$lng');
    } else {
      uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
      );
    }

    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        _snack(context);
      }
    } catch (_) {
      if (context.mounted) _snack(context);
    }
  }

  void _snack(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open the map application.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (compact) {
      // Rounded-square icon button matching the mockup's primaryContainer
      // treatment; disabled with a tooltip when no coordinates exist.
      return Tooltip(
        message: _hasCoords ? label : AppStrings.navigateUnavailable,
        child: InkWell(
          borderRadius: BorderRadius.circular(FieldOpsDesignTokens.radiusLg),
          onTap: _hasCoords ? () => _navigate(context) : null,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _hasCoords
                  ? scheme.primaryContainer
                  : scheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(FieldOpsDesignTokens.radiusLg),
            ),
            child: Icon(
              Icons.navigation_outlined,
              size: 20,
              color: _hasCoords
                  ? scheme.onPrimaryContainer
                  : scheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
          ),
        ),
      );
    }
    // Full-width primary-container action (mockup "Navigate" map CTA).
    //
    // The CTA sits inside a Tooltip so pointer users get the reason it is
    // inactive, and when disabled a visible caption is rendered underneath so
    // the greyed-out state is self-explanatory on touch devices too.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: _hasCoords
              ? 'Open $label in the map application'
              : AppStrings.navigateUnavailable,
          child: SizedBox(
            height: 48,
            child: Material(
              color: _hasCoords
                  ? scheme.primaryContainer
                  : scheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius:
                  BorderRadius.circular(FieldOpsDesignTokens.controlRadius),
              child: InkWell(
                borderRadius:
                    BorderRadius.circular(FieldOpsDesignTokens.controlRadius),
                onTap: _hasCoords ? () => _navigate(context) : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.navigation_outlined,
                        size: 18,
                        color: _hasCoords
                            ? scheme.onPrimaryContainer
                            : scheme.onSurfaceVariant.withValues(alpha: 0.4),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          label,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(
                                color: _hasCoords
                                    ? scheme.onPrimaryContainer
                                    : scheme.onSurfaceVariant
                                        .withValues(alpha: 0.4),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (!_hasCoords) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                size: 13,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  AppStrings.navigateUnavailable,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}