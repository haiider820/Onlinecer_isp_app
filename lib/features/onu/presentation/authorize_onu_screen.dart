import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exceptions.dart';
import '../../../core/router/app_router.dart';
import '../../../models/connection_request.dart';
import '../../../models/direct_olt.dart';
import '../../../models/waiting_onu.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../lookups/presentation/sub_branch_providers.dart';
import '../../survey/presentation/connection_request_providers.dart';
import 'authorize_onu_providers.dart';
import 'olt_providers.dart';

/// Authorize one ONU (ISPFINAL §9–§10).
///
/// The OLT is fixed from Phase E; the ONU is pre-filled from the waiting
/// row ([onuId] given) or entered by serial number ([onuId] null — the
/// serial fallback, guide §9 shape 2). The description is pre-filled with
/// the customer name. Profile fields are pre-filled from the OLT's
/// `authorization_preset` when `ready == true` and are required manual
/// input when `ready == false`.
///
/// After a 201 the controller polls the job every 3 s (max ~5 min). The
/// Authorize button stays disabled while a job is pending/running, and no
/// second POST is possible from this screen (guide §14).
class AuthorizeOnuScreen extends ConsumerStatefulWidget {
  const AuthorizeOnuScreen({
    super.key,
    required this.requestId,
    required this.oltId,
    this.onuId,
  });

  final String requestId;
  final String oltId;

  /// Waiting-ONU id from Phase E, or `null` for the serial fallback.
  final String? onuId;

  @override
  ConsumerState<AuthorizeOnuScreen> createState() => _AuthorizeOnuScreenState();
}

class _AuthorizeOnuScreenState extends ConsumerState<AuthorizeOnuScreen> {
  final _formKey = GlobalKey<FormState>();
  final _description = TextEditingController();
  final _serial = TextEditingController();
  final _lineProfile = TextEditingController();
  final _serviceProfile = TextEditingController();
  final _vlan = TextEditingController();
  final _userVlan = TextEditingController();
  final _gemport = TextEditingController();
  bool _seeded = false;

  @override
  void dispose() {
    _description.dispose();
    _serial.dispose();
    _lineProfile.dispose();
    _serviceProfile.dispose();
    _vlan.dispose();
    _userVlan.dispose();
    _gemport.dispose();
    super.dispose();
  }

  /// Seeds the form once, when the request detail + OLT (+ waiting row, for
  /// the discovered flow) have all arrived. Never re-seeds: the
  /// technician's edits must survive a detail refetch.
  void _seedOnce({
    required ConnectionRequest? request,
    required DirectOlt? olt,
    required WaitingOnu? onu,
  }) {
    if (_seeded || request == null || olt == null) return;
    if (widget.onuId != null && onu == null) return;
    _seeded = true;
    final preset = olt.authorizationPreset;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _description.text = request.customerName ?? '';
        _serial.text = onu?.serialNumber ?? '';
        _lineProfile.text = preset?.lineProfile ?? '';
        _serviceProfile.text = preset?.serviceProfile ?? '';
        _vlan.text = preset?.vlan?.toString() ?? '';
        _userVlan.text = preset?.userVlan?.toString() ?? '';
        _gemport.text = (preset?.gemport ?? 1).toString();
      });
    });
  }

  static int? _asInt(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed);
  }

  Future<void> _submit({
    required bool presetReady,
    required int presetGemport,
  }) async {
    if (!_formKey.currentState!.validate()) return;
    final controller = ref.read(authorizeOnuControllerProvider.notifier);
    final description = _description.text.trim();
    if (widget.onuId != null) {
      await controller.submitDiscovered(
        requestId: widget.requestId,
        oltId: widget.oltId,
        onuId: widget.onuId!,
        description: description,
      );
    } else {
      await controller.submitBySerial(
        requestId: widget.requestId,
        oltId: widget.oltId,
        serialNumber: _serial.text.trim(),
        lineProfile: _lineProfile.text.trim().isEmpty
            ? null
            : _lineProfile.text.trim(),
        serviceProfile: _serviceProfile.text.trim().isEmpty
            ? null
            : _serviceProfile.text.trim(),
        vlan: _asInt(_vlan.text),
        userVlan: _asInt(_userVlan.text),
        gemport: _asInt(_gemport.text) ?? presetGemport,
        description: description,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync =
        ref.watch(connectionRequestDetailProvider(widget.requestId));
    final scope = ref.watch(subBranchStateProvider);
    final olts = ref.watch(directOltsProvider(scope.effectiveId));
    final onus = ref.watch(waitingOnusProvider(widget.oltId));
    final state = ref.watch(authorizeOnuControllerProvider);

    final request = detailAsync.valueOrNull?.request;
    final olt = olts.valueOrNull?.data
        .where((o) => o.id == widget.oltId)
        .firstOrNull;
    final onu = widget.onuId == null
        ? null
        : onus.valueOrNull?.data
            .where((o) => o.id == widget.onuId)
            .firstOrNull;
    _seedOnce(request: request, olt: olt, onu: onu);

    final preset = olt?.authorizationPreset;
    final presetReady = preset?.ready == true;
    final presetGemport = preset?.gemport ?? 1;
    final isDiscovered = widget.onuId != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Authorize ONU')),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(
          message: e is ApiException
              ? e.message
              : 'Could not load this request.',
          onRetry: () => ref.invalidate(
            connectionRequestDetailProvider(widget.requestId),
          ),
        ),
        data: (_) {
          if (olt == null) {
            return _ErrorView(
              message: 'Could not load this OLT.',
              onRetry: () =>
                  ref.invalidate(directOltsProvider(scope.effectiveId)),
            );
          }
          if (isDiscovered &&
              onus is AsyncData &&
              onu == null) {
            return _ErrorView(
              message: 'That waiting ONU is no longer on this OLT. '
                  'Authorize by serial number instead.',
              onRetry: () => context.pushReplacement(
                Routes.authorizeOnuSerialFor(widget.requestId, widget.oltId),
              ),
            );
          }
          return _AuthorizeBody(
            formKey: _formKey,
            state: state,
            isDiscovered: isDiscovered,
            onu: onu,
            olt: olt,
            presetReady: presetReady,
            presetGemport: presetGemport,
            description: _description,
            serial: _serial,
            lineProfile: _lineProfile,
            serviceProfile: _serviceProfile,
            vlan: _vlan,
            userVlan: _userVlan,
            gemport: _gemport,
            onSubmit: () => _submit(
              presetReady: presetReady,
              presetGemport: presetGemport,
            ),
          );
        },
      ),
    );
  }
}

class _AuthorizeBody extends ConsumerWidget {
  const _AuthorizeBody({
    required this.formKey,
    required this.state,
    required this.isDiscovered,
    required this.onu,
    required this.olt,
    required this.presetReady,
    required this.presetGemport,
    required this.description,
    required this.serial,
    required this.lineProfile,
    required this.serviceProfile,
    required this.vlan,
    required this.userVlan,
    required this.gemport,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final AuthorizeOnuState state;
  final bool isDiscovered;
  final WaitingOnu? onu;
  final DirectOlt olt;
  final bool presetReady;
  final int presetGemport;
  final TextEditingController description;
  final TextEditingController serial;
  final TextEditingController lineProfile;
  final TextEditingController serviceProfile;
  final TextEditingController vlan;
  final TextEditingController userVlan;
  final TextEditingController gemport;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final phase = state.phase;
    final showForm = phase == AuthorizePhase.idle;
    // Local copy so the null check below promotes the type.
    final discoveredOnu = onu;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        SectionCard(
          title: 'OLT',
          icon: Icons.router_outlined,
          children: [
            InfoRow(label: 'Name', value: olt.name ?? olt.id),
            if (olt.vendor != null) InfoRow(label: 'Vendor', value: olt.vendor!),
            InfoRow(
              label: 'Authorization preset',
              value: presetReady
                  ? 'Ready — profiles pre-filled'
                  : 'Not ready — enter profiles manually',
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (showForm)
          Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isDiscovered && discoveredOnu != null)
                  SectionCard(
                    title: 'ONU',
                    icon: Icons.settings_input_component_outlined,
                    children: [
                      InfoRow(
                        label: 'Serial',
                        value: discoveredOnu.serialNumber ?? discoveredOnu.id,
                      ),
                      if (discoveredOnu.ponPort != null)
                        InfoRow(label: 'PON port', value: discoveredOnu.ponPort!),
                      if (discoveredOnu.detectedOnuType != null)
                        InfoRow(label: 'Type', value: discoveredOnu.detectedOnuType!),
                    ],
                  )
                else
                  TextFormField(
                    controller: serial,
                    decoration: const InputDecoration(
                      labelText: 'Serial number',
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Serial number is required.'
                        : null,
                  ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: description,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Description is required.'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: lineProfile,
                  decoration: InputDecoration(
                    labelText: presetReady
                        ? 'Line profile (from preset)'
                        : 'Line profile',
                  ),
                  validator: (v) => !presetReady &&
                          (v == null || v.trim().isEmpty)
                      ? 'Line profile is required — this OLT has no saved preset.'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: serviceProfile,
                  decoration: InputDecoration(
                    labelText: presetReady
                        ? 'Service profile (from preset)'
                        : 'Service profile',
                  ),
                  validator: (v) => !presetReady &&
                          (v == null || v.trim().isEmpty)
                      ? 'Service profile is required — this OLT has no saved preset.'
                      : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: vlan,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'VLAN'),
                        validator: (v) => _intError(v, 'VLAN'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: userVlan,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'User VLAN'),
                        validator: (v) => _intError(v, 'User VLAN'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: gemport,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'GEM port'),
                        validator: (v) => _intError(v, 'GEM port'),
                      ),
                    ),
                  ],
                ),
                if (!presetReady)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'This OLT has no saved authorization preset, so the '
                      'profiles above are required. GEM port defaults to '
                      '$presetGemport when left blank.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      state.errorMessage!,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: state.isJobActive ? null : onSubmit,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Authorize ONU'),
                  ),
                ),
              ],
            ),
          )
        else
          _JobStatusCard(state: state),
      ],
    );
  }

  static String? _intError(String? value, String label) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed) == null ? '$label must be a number.' : null;
  }
}

/// Live job status after the 201: never leaves the technician guessing
/// whether the command was sent.
class _JobStatusCard extends ConsumerWidget {
  const _JobStatusCard({required this.state});

  final AuthorizeOnuState state;

  static String _badgeStatus(String? raw) => switch (raw) {
        'pending' => 'pending',
        'running' => 'in_progress',
        'succeeded' => 'completed',
        'failed' => 'failed',
        _ => 'pending',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final controller = ref.read(authorizeOnuControllerProvider.notifier);
    final job = state.job;
    final title = switch (state.phase) {
      AuthorizePhase.submitting => 'Sending authorization…',
      AuthorizePhase.polling => 'Authorization in progress',
      AuthorizePhase.succeeded => 'ONU authorized',
      AuthorizePhase.failed => 'Authorization failed',
      AuthorizePhase.timedOut => 'Still running',
      AuthorizePhase.cancelled => 'Waiting stopped',
      AuthorizePhase.idle => 'Authorize ONU',
    };
    return SectionCard(
      title: title,
      icon: Icons.router_outlined,
      children: [
        if (state.message != null)
          Text(state.message!, style: theme.textTheme.bodyMedium),
        if (state.jobId != null) ...[
          const SizedBox(height: 8),
          InfoRow(label: 'Job', value: state.jobId!),
        ],
        if (job?.status != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Status',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              StatusBadge(status: _badgeStatus(job!.status)),
            ],
          ),
        ],
        if (job?.serialNumber != null)
          InfoRow(label: 'Serial', value: job!.serialNumber!),
        if (job?.ponPort != null)
          InfoRow(label: 'PON port', value: job!.ponPort!),
        if (state.phase == AuthorizePhase.succeeded && job?.ontId != null)
          InfoRow(label: 'ONT ID', value: job!.ontId!),
        if (state.pollCount > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Checked ${state.pollCount} time${state.pollCount == 1 ? '' : 's'}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        if (state.pollErrorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              state.pollErrorMessage!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        if (state.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              state.errorMessage!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        const SizedBox(height: 16),
        if (state.phase == AuthorizePhase.polling ||
            state.phase == AuthorizePhase.submitting)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: state.phase == AuthorizePhase.polling
                  ? controller.cancelWait
                  : null,
              child: const Text('Stop waiting (job keeps running)'),
            ),
          ),
        if (state.phase == AuthorizePhase.cancelled ||
            state.phase == AuthorizePhase.timedOut)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: controller.resumePolling,
              child: const Text('Check job again'),
            ),
          ),
        if (state.phase == AuthorizePhase.failed) ...[
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: controller.resetForRetry,
              child: const Text('Retry authorization'),
            ),
          ),
        ],
        if (state.phase == AuthorizePhase.succeeded) ...[
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: () => context.go(
                Routes.installationDetailFor(
                  state.requestId ?? '',
                ),
              ),
              child: const Text('Back to request'),
            ),
          ),
        ],
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

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
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
