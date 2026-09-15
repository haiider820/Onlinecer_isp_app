import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:latlong2/latlong.dart';

import '../../core/theme/field_ops_design_tokens.dart';
import '../../models/connection_request.dart';
import 'status_badge.dart';

/// Reusable dispatch card showing a connection request summary, matching the
/// stitch DESIGN.md "Dispatch & Work Order Cards" spec:
///  - pure white surface, 14px radius, `1px #E2E8F0` hairline border, ambient
///    Level-1 shadow;
///  - header row separates the REQ id from the semantic status pill;
///  - body carries customer, address and equipment details;
///  - bottom action bar provides direct quick-actions (Call / Navigate).
///
/// Used by the survey dashboard (recent requests) and the request list. Tap
/// invokes [onTap]; [onAction] (with [actionLabel]) renders the primary
/// "Start Survey / Resume" style button. Call / Navigate are only enabled
/// when the request actually carries a phone number / coordinates.
class RequestCard extends StatelessWidget {
  const RequestCard({
    super.key,
    required this.request,
    this.onTap,
    this.onAction,
    this.actionLabel,
  });

  final ConnectionRequest request;
  final VoidCallback? onTap;

  /// Primary action callback (e.g. "Start Survey"); `null` hides the button.
  final VoidCallback? onAction;

  /// Label for the primary action button.
  final String? actionLabel;

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  Future<void> _call(BuildContext context) async {
    final phone = request.customerPhone?.replaceAll(RegExp(r'[^\d+]'), '');
    if (phone == null || phone.isEmpty) return;
    final uri = Uri.parse('tel:$phone');
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) _snack(context, 'Could not open the phone app.');
    } catch (_) {
      if (context.mounted) _snack(context, 'Could not open the phone app.');
    }
  }

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  bool get _hasCoords {
    final locs = request.locations;
    if (locs == null) return false;
    return [locs.installation, locs.userDevice, locs.dp, locs.fatNode]
        .any((p) => p?.latitude != null && p?.longitude != null);
  }

  LatLng? _targetLatLng() {
    final locs = request.locations;
    if (locs == null) return null;
    final points = [locs.installation, locs.dp, locs.userDevice, locs.fatNode];
    for (final p in points) {
      if (p != null && p.latitude != null && p.longitude != null) {
        return LatLng(p.latitude!, p.longitude!);
      }
    }
    return null;
  }

  Future<void> _navigate(BuildContext context) async {
    final latLng = _targetLatLng();
    if (latLng == null) return;
    final uri = Uri.parse(
        'geo:${latLng.latitude.toStringAsFixed(6)},${latLng.longitude.toStringAsFixed(6)}');
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        _snack(context, 'Could not open the map application.');
      }
    } catch (_) {
      if (context.mounted) _snack(context, 'Could not open the map application.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasPhone = (request.customerPhone?.replaceAll(RegExp(r'[^\d+]'), '') ?? '').isNotEmpty;
    final hasActionRow = hasPhone || onAction != null || _hasCoords;

    // Equipment line: plan name or stage flag, guarding against nulls.
    final planName = request.requestedPlan?.name;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(FieldOpsDesignTokens.cardRadius),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: FieldOpsDesignTokens.shadowLevel1,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer initials avatar.
                  CircleAvatar(
                    radius: 22,
                                        backgroundColor: FieldOpsDesignTokens.avatarBackground,
                    child: Text(
                      _initials(request.customerName ?? request.customerArea ?? '?'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                request.requestNumber,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            StatusBadge(status: request.status),
                          ],
                        ),
                        if (request.customerName != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            request.customerName!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location row (area + address).
                  if (request.customerArea != null || request.customerAddress != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            [request.customerAddress, request.customerArea]
                                .whereType<String>()
                                .join(', '),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  // Equipment / plan line.
                  if (planName != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.router_outlined,
                          size: 16,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            planName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 10),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                ],
              ),
            ),
            // Bottom quick-action bar (48dp touch targets).
            if (hasActionRow)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        tooltip: 'Call Customer',
                        onPressed: hasPhone ? () => _call(context) : null,
                        icon: const Icon(Icons.call_outlined, size: 20),
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    if (_hasCoords)
                      Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          tooltip: 'Navigate',
                          onPressed: () => _navigate(context),
                          icon: const Icon(Icons.navigation_outlined, size: 20),
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    const Spacer(),
                    if (onAction != null && actionLabel != null)
                      SizedBox(
                        height: 40,
                        child: FilledButton.icon(
                          onPressed: onAction,
                          icon: const Icon(Icons.play_arrow, size: 18),
                          label: Text(actionLabel!),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 40),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            textStyle: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    if (hasPhone && onAction == null)
                      Text(
                        'Tap to view',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}