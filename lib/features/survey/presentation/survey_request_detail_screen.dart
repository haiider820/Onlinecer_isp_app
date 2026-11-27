import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/network/api_exceptions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/router/functional_team.dart';
import '../../../core/router/team_module.dart';
import '../../../core/theme/field_ops_design_tokens.dart';
import '../../../models/connection_request.dart';
import '../../../models/item_request.dart';
import '../../../models/locations.dart';
import '../../../shared/widgets/branded_header.dart';
import '../../../shared/widgets/location_map.dart';
import '../../../shared/widgets/navigate_action.dart';
import '../../../shared/widgets/pppoe_inventory_cards.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/stage_chips.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/formatting/format_minor_price.dart';
import 'connection_request_providers.dart';

/// Full detail for one survey connection request
/// (`GET /connection-requests/{id}`).
///
/// Matches the stitch request-detail mockup's structure — banner + customer
/// contact, drop-route map preview, feeding point, assignment/logistics and a
/// sticky bottom action shelf — while rendering ONLY the fields the backend
/// actually returns. Blocks the mockup draws from data the API doesn't provide
/// (scheduled window, port capacity, site photos) are omitted until a real
/// source exists.
class SurveyRequestDetailScreen extends ConsumerWidget {
  const SurveyRequestDetailScreen({super.key, required this.requestId});

  final String requestId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(connectionRequestDetailProvider(requestId));

    return Scaffold(
      appBar: BrandedHeader(
        title: TeamModule.forTeam(FunctionalTeamType.survey).detailTitle,
        onBack: () => context.pop(),
      ),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(
          message: e is ApiException ? e.message : 'Something went wrong.',
          onRetry: () => ref.invalidate(connectionRequestDetailProvider(requestId)),
        ),
        data: (d) => _DetailBody(detail: d),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.detail});

  final ConnectionRequestDetail detail;

  @override
  Widget build(BuildContext context) {
    final request = detail.request;
    // Phase D: every stage button renders only when its wire value is in
    // `actions` (plural `allowed_actions`, singular fallback via the model).
    // The review case is driven by `allowed_action` too — never by status:
    // `review_survey` means Inventory approved the items and the surveyor
    // confirms them, on the same complete-survey endpoint.
    final canCompleteSurvey =
        detail.actions.contains(ConnectionRequestAction.completeSurvey);
    final canReviewSurvey =
        detail.actions.contains(ConnectionRequestAction.reviewSurvey);
    // D19: Plan Route is an action too — it must not show when the backend
    // offers no action (e.g. `inventory_pending`, whose approval is
    // web-only). The old `actions.isEmpty || canCompleteSurvey` left the
    // button on every read-only survey detail.
    final canPlanRoute = canCompleteSurvey || canReviewSurvey;

    return Column(
      children: [
        Expanded(
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              // ── Status banner ──
              _StatusBanner(request: request),
              const SizedBox(height: 8),

              // ── Customer contact card ──
              _CustomerContactCard(request: request),
              const SizedBox(height: 8),

              // ── Drop-route map preview ──
              _MapPreviewCard(request: request),
              const SizedBox(height: 8),

              // ── Feeding point (FAT node) card ──
              if (request.locations?.fatNode != null)
                _FeedingPointCard(fatNode: request.locations!.fatNode!),
              if (request.locations?.fatNode != null) const SizedBox(height: 8),

              // ── Prior notes quote ──
              if (request.stageData?.surveyNotes != null) ...[
                _NotesQuoteCard(notes: request.stageData!.surveyNotes!),
                const SizedBox(height: 8),
              ],

              // ── What Inventory approved (review case only) ──
              // D21: another team's data — collapsed behind a top chip by
              // default, like the other stages' previous-stage blocks.
              if (request.itemRequests != null &&
                  request.itemRequests!.isNotEmpty) ...[
                CollapsibleStageSection(
                  label: 'Inventory approval',
                  child: _InventoryApprovalCard(
                    itemRequests: request.itemRequests!,
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // ── Assignment & logistics ──
              _AssignmentCard(request: request),
              const SizedBox(height: 8),

              // ── PPPoE credentials + inventory approval state (guide §6,
              // Rev 1.0) — read-only; each card renders nothing when its
              // block is absent from the detail payload.
              PppoeCredentialsCard(credentials: request.pppoeCredentials),
              InstallationInventoryCard(inventory: request.installationInventory),

              // ── Plan / charges summary ──
              _PlanSummaryCard(request: request),
            ],
          ),
        ),
        // ── Sticky bottom action shelf ──
        _BottomShelf(
          canPlanRoute: canPlanRoute,
          canCompleteSurvey: canCompleteSurvey,
          canReviewSurvey: canReviewSurvey,
          onPlanRoute: () => context.push(Routes.surveyRouteFor(request.id)),
          onCompleteSurvey: () => context.push(Routes.submitSurveyFor(request.id)),
          onReviewSurvey: () => context.push(Routes.reviewSurveyFor(request.id)),
        ),
      ],
    );
  }
}

/// Header card: REQ id + semantic status, customer area on the second line.
class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.request});

  final ConnectionRequest request;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(FieldOpsDesignTokens.cardRadius),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: FieldOpsDesignTokens.shadowLevel1,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.requestNumber,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (request.customerArea != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          request.customerArea!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          StatusBadge(status: request.status),
        ],
      ),
    );
  }
}

/// Customer identity card: initials avatar, name + plan, address box, call.
class _CustomerContactCard extends StatelessWidget {
  const _CustomerContactCard({required this.request});

  final ConnectionRequest request;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = request.customerName ?? 'Customer';
    final planName = request.requestedPlan?.name;
    final address = request.customerAddress;
    final phone = request.customerPhone;
    final hasPhone = (request.customerPhone?.replaceAll(RegExp(r'[^\d+]'), '') ?? '').isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(FieldOpsDesignTokens.cardRadius),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: FieldOpsDesignTokens.shadowLevel1,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    _initials(name),
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (planName != null)
                        Text(
                          planName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
                if (hasPhone)
                  // Call quick-action (48dp target).
                  IconButton(
                    tooltip: 'Call customer',
                    onPressed: () => _call(context),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.12),
                    ),
                    icon: Icon(
                      Icons.call_outlined,
                      size: 20,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
              ],
            ),
            // Address snippet in a quiet box.
            if (address != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(FieldOpsDesignTokens.radiusLg),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.home_outlined,
                      size: 16,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        address,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (phone != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.phone_outlined,
                    size: 15,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    phone,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Map preview card: drop-route map (or placeholder) + navigate CTA.
class _MapPreviewCard extends StatelessWidget {
  const _MapPreviewCard({required this.request});

  final ConnectionRequest request;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dpLoc = request.locations?.dp;
    final userLoc = request.locations?.userDevice;
    final latLng = dpLoc != null && dpLoc.latitude != null && dpLoc.longitude != null
        ? LatLng(dpLoc.latitude!, dpLoc.longitude!)
        : null;
    final userLatLng = userLoc != null && userLoc.latitude != null && userLoc.longitude != null
        ? LatLng(userLoc.latitude!, userLoc.longitude!)
        : null;
    // Straight-line fallback route when both landmarks exist.
    final route = (latLng != null && userLatLng != null)
        ? [userLatLng, latLng]
        : null;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(FieldOpsDesignTokens.cardRadius),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: FieldOpsDesignTokens.shadowLevel1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Icon(
                  Icons.map_outlined,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Drop Route & Proximity',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (latLng != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: FieldOpsDesignTokens.primaryContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'OPTIMAL LINE',
                      style: TextStyle(
                        color: FieldOpsDesignTokens.onPrimaryContainer,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.05,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LocationMap(
              userLocation: userLatLng,
              dpLocation: latLng,
              route: route,
              height: 200,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: NavigateButton(
              latitude: dpLoc?.latitude,
              longitude: dpLoc?.longitude,
              label: 'Navigate to Customer',
            ),
          ),
        ],
      ),
    );
  }
}

/// Feeding point (FAT node) card — only node reference data the backend sends.
class _FeedingPointCard extends StatelessWidget {
  const _FeedingPointCard({required this.fatNode});

  final GeoPoint fatNode;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'FAT Node & Feeding Point',
      icon: Icons.account_tree_outlined,
      children: [
        if (fatNode.nodeId != null)
          InfoRow(label: 'Node ID', value: fatNode.nodeId),
        if (fatNode.address != null)
          InfoRow(label: 'Address', value: fatNode.address),
        if (fatNode.latitude != null || fatNode.longitude != null)
          InfoRow(
            label: 'Coordinates',
            value: [fatNode.latitude, fatNode.longitude]
                .whereType<double>()
                .map((c) => c.toStringAsFixed(6))
                .join(', '),
          ),
      ],
    );
  }
}

/// Surveyor's prior instructions, rendered as an italic quote block.
class _NotesQuoteCard extends StatelessWidget {
  const _NotesQuoteCard({required this.notes});

  final String notes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(FieldOpsDesignTokens.cardRadius),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: FieldOpsDesignTokens.shadowLevel1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.format_quote,
                size: 18,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Prior Notes',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            notes,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Assignment & logistics card: operational stage, plan, field crew.
class _AssignmentCard extends StatelessWidget {
  const _AssignmentCard({required this.request});

  final ConnectionRequest request;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Assignment & Logistics',
      icon: Icons.assignment_outlined,
      children: [
        InfoRow(label: 'Stage', value: request.status.replaceAll('_', ' ')),
        if (request.requestedPlan != null)
          InfoRow(label: 'Plan', value: request.requestedPlan!.name),
        if (request.currentTeam != null)
          InfoRow(label: 'Field crew', value: request.currentTeam!.name),
        if (request.customerType != null)
          InfoRow(label: 'Customer type', value: request.customerType),
      ],
    );
  }
}

/// Plan summary — real values only (name + price when the backend sends one).
class _PlanSummaryCard extends StatelessWidget {
  const _PlanSummaryCard({required this.request});

  final ConnectionRequest request;

  @override
  Widget build(BuildContext context) {
    final plan = request.requestedPlan;
    if (plan == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final priceText = plan.priceMinor != null
        ? formatMinorPrice(plan.priceMinor!)
        : null;
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(FieldOpsDesignTokens.cardRadius),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: FieldOpsDesignTokens.shadowLevel1,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.payments_outlined,
                size: 20,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (priceText != null)
                    Text(
                      'Monthly plan · $priceText',
                      style: theme.textTheme.bodySmall?.copyWith(
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

/// What Inventory decided on the items this request asked for — shown on
/// the review screen (`survey_review` / `review_survey`) so the surveyor
/// confirms against the approved quantities, not from memory.
class _InventoryApprovalCard extends StatelessWidget {
  const _InventoryApprovalCard({required this.itemRequests});

  final List<ItemRequest> itemRequests;

  static String _qty(num? value) {
    if (value == null) return '—';
    if (value % 1 == 0) return value.toInt().toString();
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Inventory Approval',
      icon: Icons.inventory_2_outlined,
      children: [
        for (final itemRequest in itemRequests) ...[
          if (itemRequest.status != null)
            InfoRow(label: 'Status', value: itemRequest.status!),
          if (itemRequest.approvalNotes != null)
            InfoRow(label: 'Approval notes', value: itemRequest.approvalNotes!),
          if (itemRequest.requestedByTeamName != null)
            InfoRow(label: 'Requested by', value: itemRequest.requestedByTeamName!),
          for (final item in itemRequest.items)
            InfoRow(
              label: item.itemName ?? 'Item',
              value:
                  'Requested ${_qty(item.quantityRequested)}${item.unit == null ? '' : ' ${item.unit}'}'
                  ' · Approved ${_qty(item.quantityApproved)}${item.unit == null ? '' : ' ${item.unit}'}',
            ),
        ],
      ],
    );
  }
}

/// Sticky bottom shelf: Flag issue (UI shell) + Plan Route + Complete Survey / Review.
class _BottomShelf extends StatelessWidget {
  const _BottomShelf({
    required this.canPlanRoute,
    required this.canCompleteSurvey,
    required this.canReviewSurvey,
    required this.onPlanRoute,
    required this.onCompleteSurvey,
    required this.onReviewSurvey,
  });

  final bool canPlanRoute;
  final bool canCompleteSurvey;
  final bool canReviewSurvey;
  final VoidCallback onPlanRoute;
  final VoidCallback onCompleteSurvey;
  final VoidCallback onReviewSurvey;

  void _flag(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Issue flagging is not available in this build yet.'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerLowest,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              if (canPlanRoute) ...[
                OutlinedButton.icon(
                  onPressed: onPlanRoute,
                  icon: const Icon(Icons.route_outlined, size: 18),
                  label: const Text('Plan Route'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 52),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    foregroundColor: theme.colorScheme.primary,
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              // Flag is icon-only (D15): at 360px the three-button row gave
              // the Flag button ~55px and its "Flag" label wrapped to one
              // letter per line, squeezing "Complete Survey" until it
              // wrapped and clipped at 52px. The 52x52 icon button keeps the
              // same error colour, border and "not available yet" snackbar;
              // the Semantics label keeps it identifiable as "Flag issue".
              Semantics(
                label: 'Flag issue',
                button: true,
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => _flag(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(52, 52),
                      padding: EdgeInsets.zero,
                      foregroundColor: theme.colorScheme.error,
                      side: BorderSide(
                        color: theme.colorScheme.errorContainer,
                      ),
                    ),
                    child: const Icon(Icons.flag_outlined, size: 18),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (canCompleteSurvey)
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: onCompleteSurvey,
                      icon: const Icon(Icons.check_circle_outline, size: 20),
                      label: const Text('Complete Survey'),
                      style: FilledButton.styleFrom(
                        textStyle: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              if (canReviewSurvey)
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: onReviewSurvey,
                      icon: const Icon(Icons.rate_review_outlined, size: 20),
                      label: const Text('Review'),
                      style: FilledButton.styleFrom(
                        textStyle: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}