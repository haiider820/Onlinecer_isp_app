import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/field_ops_design_tokens.dart';
import '../../../models/create_data.dart';
import '../../lookups/presentation/sub_branch_providers.dart';
import '../../lookups/presentation/sub_branch_selector.dart';
import '../data/create_request_repository.dart';
import '../presentation/create_request_providers.dart';
import '../../../shared/widgets/ops_widgets.dart';

/// Create a connection request (ISPFINAL §3 + §4).
///
/// Flow: sub-branch gate (Phase B — the form never opens without a fresh
/// list + a resolved id) → create-data loading (skeleton) → form (every
/// dropdown fed ONLY by create-data, never hardcoded) → submit → success
/// (201: request number + "Open request").
///
/// The form is a local draft: text + picked file paths live in
/// [createRequestControllerProvider] while the screen lives. A failed submit
/// keeps the draft on screen with the error and a Retry button. There is no
/// queued offline submit in v1 (no outbox exists) — the error says so.
class CreateRequestScreen extends ConsumerWidget {
  const CreateRequestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subBranchState = ref.watch(subBranchStateProvider);
    final formState = ref.watch(createRequestControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('New Request')),
      body: Builder(
        builder: (context) {
          if (formState.created != null) {
            return _SuccessView(response: formState.created!);
          }
          if (subBranchState.isLoading &&
              subBranchState.lastKnownList == null) {
            return const _LoadingSkeleton();
          }
          if (subBranchState.errorMessage != null &&
              subBranchState.lastKnownList == null) {
            return _ErrorView(
              message: subBranchState.errorMessage!,
              onRetry: () =>
                  ref.read(subBranchStateProvider.notifier).refresh(),
            );
          }
          if (!subBranchState.canProceed) {
            return _ScopeGateView(state: subBranchState);
          }
          return _CreateRequestForm(
            subBranchId: subBranchState.effectiveId!,
          );
        },
      ),
    );
  }
}

/// Shown while the sub-branch gate is closed: the list failed, is empty, is
/// stale, or (centralized mode) nothing is picked yet. Never a free-text
/// field and never an invented id — only the selector, fed by the endpoint.
class _ScopeGateView extends ConsumerWidget {
  const _ScopeGateView({required this.state});

  final SubBranchState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final list = state.lastKnownList;
    final needsPick =
        list != null && list.data.isNotEmpty && state.effectiveId == null;

    // SingleChildScrollView + Column (not ListView): the gate's children
    // change shape across states, and swapping ListViews at this position
    // trips the sliver child-order assertion in debug builds.
    return SingleChildScrollView(
      padding: const EdgeInsets.all(FieldOpsDesignTokens.pageMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.isStale) ...[
          _ErrorBanner(
            message: state.errorMessage!,
            onRetry: () =>
                ref.read(subBranchStateProvider.notifier).refresh(),
          ),
          const SizedBox(height: FieldOpsDesignTokens.spaceMd),
        ],
        if (list != null && list.data.isEmpty) ...[
          Text(
            'No sub-branch assigned — contact the office',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: FieldOpsDesignTokens.spaceMd),
          FilledButton(
            onPressed: () =>
                ref.read(subBranchStateProvider.notifier).refresh(),
            child: const Text('Retry'),
          ),
        ] else ...[
          const SubBranchSelectorButton(),
          const SizedBox(height: FieldOpsDesignTokens.spaceSm),
          Text(
            state.isStale
                ? 'Couldn’t refresh the sub-branch list — create is paused until it loads.'
                : needsPick
                ? 'Choose a sub-branch to continue.'
                : 'Loading sub-branches…',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (needsPick) ...[
            const SizedBox(height: FieldOpsDesignTokens.spaceMd),
            FilledButton(
              onPressed: () => showSubBranchSelector(context),
              child: const Text('Choose sub-branch'),
            ),
          ],
        ],
      ],
      ),
    );
  }
}

/// The create form itself. Mounted only once the sub-branch gate is open,
/// so [subBranchId] is always a resolved endpoint id here.
class _CreateRequestForm extends ConsumerStatefulWidget {
  const _CreateRequestForm({required this.subBranchId});

  final String subBranchId;

  @override
  ConsumerState<_CreateRequestForm> createState() => _CreateRequestFormState();
}

class _CreateRequestFormState extends ConsumerState<_CreateRequestForm> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _areaController = TextEditingController();
  final _addressController = TextEditingController();
  final _customPriceController = TextEditingController();
  final _discountTypeController = TextEditingController();
  final _discountValueController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final notifier = ref.read(createRequestControllerProvider.notifier);
    final state = ref.read(createRequestControllerProvider);
    _nameController.text = state.customerName;
    _phoneController.text = state.customerPhone;
    _areaController.text = state.customerArea;
    _addressController.text = state.customerAddress;
    _customPriceController.text = state.customPrice;
    _discountTypeController.text = state.discountType;
    _discountValueController.text = state.discountValue;
    _nameController.addListener(
      () => notifier.updateCustomerName(_nameController.text),
    );
    _phoneController.addListener(
      () => notifier.updateCustomerPhone(_phoneController.text),
    );
    _areaController.addListener(
      () => notifier.updateCustomerArea(_areaController.text),
    );
    _addressController.addListener(
      () => notifier.updateCustomerAddress(_addressController.text),
    );
    _customPriceController.addListener(
      () => notifier.updateCustomPrice(_customPriceController.text),
    );
    _discountTypeController.addListener(
      () => notifier.updateDiscountType(_discountTypeController.text),
    );
    _discountValueController.addListener(
      () => notifier.updateDiscountValue(_discountValueController.text),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _areaController.dispose();
    _addressController.dispose();
    _customPriceController.dispose();
    _discountTypeController.dispose();
    _discountValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final createData = ref.watch(createDataProvider(widget.subBranchId));

    return createData.when(
      loading: () => const _LoadingSkeleton(),
      error: (error, _) => _ErrorView(
        message: error is ApiException
            ? error.message
            : 'Couldn’t load the form. Please try again.',
        onRetry: () => ref.invalidate(createDataProvider(widget.subBranchId)),
      ),
      data: (response) => _buildForm(context, response.data),
    );
  }

  Widget _buildForm(BuildContext context, CreateData? data) {
    final state = ref.watch(createRequestControllerProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final typeOptions = (data?.customerTypes ?? const [])
        .where((option) => option.value != null && option.value!.isNotEmpty)
        .toList();
    // The controller defaults to 'home'; if the backend's list does not
    // contain it, fall back to its first option (synced post-frame so the
    // submitted value always matches what the dropdown shows).
    if (typeOptions.isNotEmpty &&
        !typeOptions.any((o) => o.value == state.customerType)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref
              .read(createRequestControllerProvider.notifier)
              .selectCustomerType(typeOptions.first.value!);
        }
      });
    }
    final typeValue = typeOptions.any((o) => o.value == state.customerType)
        ? state.customerType
        : null;

    final plans = (data?.plans ?? const [])
        .where((plan) => plan.id != null && plan.id!.isNotEmpty)
        .toList();
    final planValue = plans.any((p) => p.id == state.requestedPlanId)
        ? state.requestedPlanId
        : null;

    final teamFlows = (data?.teamFlows ?? const [])
        .where((flow) => flow.id != null && flow.id!.isNotEmpty)
        .toList();
    final teamFlowValue = teamFlows.any((f) => f.id == state.teamFlowId)
        ? state.teamFlowId
        : null;

    // Backend default (D17): `default_team_flow_id` from create-data is the
    // initial selection when it names a flow in this scope's list. Applied
    // post-frame, like the customer-type fallback above, so the submitted
    // value always matches what the dropdown shows.
    //
    // The selection is re-applied on every fresh create-data response, so a
    // sub-branch change never keeps a stale pre-selection from the old
    // scope: if the current selection is not in the new scope's list it is
    // replaced by the new scope's default (or cleared when there is none).
    // A manual pick that is still in the list is never overridden.
    final defaultFlowId = data?.defaultTeamFlowId;
    final defaultInList =
        defaultFlowId != null &&
        defaultFlowId.isNotEmpty &&
        teamFlows.any((f) => f.id == defaultFlowId);
    if (state.teamFlowId != null &&
        !teamFlows.any((f) => f.id == state.teamFlowId)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref
              .read(createRequestControllerProvider.notifier)
              .selectTeamFlow(defaultInList ? defaultFlowId : null);
        }
      });
    } else if (state.teamFlowId == null && defaultInList) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref
              .read(createRequestControllerProvider.notifier)
              .selectTeamFlow(defaultFlowId);
        }
      });
    }

    // SingleChildScrollView + Column (not ListView): the form's children
    // change shape across states (dropdowns, custom-price field, error
    // banner), and a ListView here trips the sliver child-order assertion.
    return SingleChildScrollView(
      padding: const EdgeInsets.all(FieldOpsDesignTokens.pageMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SubBranchSelectorButton(),
        const SizedBox(height: FieldOpsDesignTokens.spaceMd),

        OpsTextField(
          controller: _nameController,
          label: 'Customer name *',
          hint: 'Full name',
          textInputAction: TextInputAction.next,
        ),
        _fieldError(state, 'customer_name'),
        const SizedBox(height: FieldOpsDesignTokens.spaceMd),

        OpsTextField(
          controller: _phoneController,
          label: 'Customer phone *',
          hint: '03xx xxxxxxx',
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
        ),
        _fieldError(state, 'customer_phone'),
        const SizedBox(height: FieldOpsDesignTokens.spaceMd),

        if (typeOptions.isNotEmpty) ...[
          _FieldLabel('Customer type'),
          DropdownButtonFormField<String>(
            key: ValueKey('type-$typeValue'),
            initialValue: typeValue,
            hint: const Text('Choose customer type'),
            decoration: _dropdownDecoration(context),
            items: [
              for (final option in typeOptions)
                DropdownMenuItem<String>(
                  value: option.value,
                  child: Text(option.label ?? option.value!),
                ),
            ],
            onChanged: (value) {
              if (value != null) {
                ref
                    .read(createRequestControllerProvider.notifier)
                    .selectCustomerType(value);
              }
            },
          ),
          const SizedBox(height: FieldOpsDesignTokens.spaceMd),
        ],

        OpsTextField(
          controller: _areaController,
          label: 'Customer area',
          hint: 'Area / locality',
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: FieldOpsDesignTokens.spaceMd),

        OpsTextField(
          controller: _addressController,
          label: 'Customer address',
          hint: 'House, street, area',
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: FieldOpsDesignTokens.spaceMd),

        if (plans.isNotEmpty) ...[
          _FieldLabel('Requested plan'),
          DropdownButtonFormField<String>(
            key: ValueKey('plan-$planValue'),
            initialValue: planValue,
            hint: const Text('Choose a plan'),
            decoration: _dropdownDecoration(context),
            items: [
              for (final plan in plans)
                DropdownMenuItem<String>(
                  value: plan.id,
                  child: Text(plan.name ?? plan.id!),
                ),
            ],
            onChanged: (value) => ref
                .read(createRequestControllerProvider.notifier)
                .selectPlan(value),
          ),
          const SizedBox(height: FieldOpsDesignTokens.spaceMd),
        ],

        if (teamFlows.isNotEmpty) ...[
          _FieldLabel('Team flow'),
          DropdownButtonFormField<String>(
            key: ValueKey('flow-$teamFlowValue'),
            initialValue: teamFlowValue,
            hint: const Text('Choose a team flow'),
            decoration: _dropdownDecoration(context),
            items: [
              for (final flow in teamFlows)
                DropdownMenuItem<String>(
                  value: flow.id,
                  child: Text(flow.name ?? flow.id!),
                ),
            ],
            onChanged: (value) => ref
                .read(createRequestControllerProvider.notifier)
                .selectTeamFlow(value),
          ),
          const SizedBox(height: FieldOpsDesignTokens.spaceMd),
        ] else ...[
          // D17: no flow is configured for this scope — say so plainly
          // instead of hiding the section. The rest of the form still
          // works; the request goes in without a flow and stays pending
          // for flow assignment (backend rule), so nothing is blocked.
          _FieldLabel('Team flow'),
          Text(
            'No team flow is configured for this sub-branch. The request will stay pending for flow assignment.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: FieldOpsDesignTokens.spaceMd),
        ],

        _FieldLabel('Price mode'),
        DropdownButtonFormField<String>(
          key: ValueKey('price-${state.priceMode}'),
          initialValue: state.priceMode,
          hint: const Text('Choose a price mode'),
          decoration: _dropdownDecoration(context),
          items: const [
            DropdownMenuItem(
              value: 'selling_price',
              child: Text('Selling price'),
            ),
            DropdownMenuItem(
              value: 'custom_price',
              child: Text('Custom price'),
            ),
            DropdownMenuItem(value: 'other', child: Text('Other')),
          ],
          onChanged: (value) => ref
              .read(createRequestControllerProvider.notifier)
              .selectPriceMode(value),
        ),
        const SizedBox(height: FieldOpsDesignTokens.spaceMd),

        if (state.priceMode == 'custom_price') ...[
          OpsTextField(
            controller: _customPriceController,
            label: 'Custom price *',
            hint: 'Amount',
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
          ),
          _fieldError(state, 'custom_price'),
          const SizedBox(height: FieldOpsDesignTokens.spaceMd),
        ],

        OpsTextField(
          controller: _discountTypeController,
          label: 'Discount type',
          hint: 'Discount type, if any',
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: FieldOpsDesignTokens.spaceMd),

        OpsTextField(
          controller: _discountValueController,
          label: 'Discount value',
          hint: 'Discount amount, if any',
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: FieldOpsDesignTokens.spaceMd),

        _FileSlotRow(
          slot: CreateRequestFileSlot.idCardFront,
          label: 'ID card — front',
          required: true,
          file: state.idCardFront,
          error: state.fieldErrors['id_card_front'],
          onPick: () => _pickFile(CreateRequestFileSlot.idCardFront),
          onRemove: () => ref
              .read(createRequestControllerProvider.notifier)
              .clearFile(CreateRequestFileSlot.idCardFront),
        ),
        const SizedBox(height: FieldOpsDesignTokens.spaceSmMd),

        _FileSlotRow(
          slot: CreateRequestFileSlot.idCardBack,
          label: 'ID card — back',
          required: true,
          file: state.idCardBack,
          error: state.fieldErrors['id_card_back'],
          onPick: () => _pickFile(CreateRequestFileSlot.idCardBack),
          onRemove: () => ref
              .read(createRequestControllerProvider.notifier)
              .clearFile(CreateRequestFileSlot.idCardBack),
        ),
        const SizedBox(height: FieldOpsDesignTokens.spaceSmMd),

        _FileSlotRow(
          slot: CreateRequestFileSlot.utilityBill,
          label: 'Utility bill',
          file: state.utilityBill,
          onPick: () => _pickFile(CreateRequestFileSlot.utilityBill),
          onRemove: () => ref
              .read(createRequestControllerProvider.notifier)
              .clearFile(CreateRequestFileSlot.utilityBill),
        ),
        const SizedBox(height: FieldOpsDesignTokens.spaceSmMd),

        _FileSlotRow(
          slot: CreateRequestFileSlot.connectionForm,
          label: 'Connection form',
          file: state.connectionForm,
          onPick: () => _pickFile(CreateRequestFileSlot.connectionForm),
          onRemove: () => ref
              .read(createRequestControllerProvider.notifier)
              .clearFile(CreateRequestFileSlot.connectionForm),
        ),
        const SizedBox(height: FieldOpsDesignTokens.spaceMd),

        Text(
          'ID card photos only (JPG, PNG, WebP — max 10 MB each).',
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: FieldOpsDesignTokens.spaceMd),

        if (state.errorMessage != null) ...[
          _ErrorBanner(
            message: state.errorMessage!,
            onRetry: _submit,
          ),
          const SizedBox(height: FieldOpsDesignTokens.spaceMd),
        ],

        FilledButton(
          onPressed: state.isSubmitting ? null : _submit,
          child: state.isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create request'),
        ),
          const SizedBox(height: FieldOpsDesignTokens.spaceMd),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    await ref
        .read(createRequestControllerProvider.notifier)
        .submit(subBranchId: widget.subBranchId);
  }

  /// Camera / gallery choice, then the same MIME + size guards the
  /// repository applies before upload (mirror the installation-photo pick
  /// flow). Images only — no PDF (Haider's call, 2026-11-23).
  Future<void> _pickFile(CreateRequestFileSlot slot) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () =>
                  Navigator.of(sheetContext).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;
    try {
      final file = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (file == null) return;
      final mime = CreateRequestRepository.mimeTypeForExtension(file.name);
      if (!allowedIdCardMimeTypes.contains(mime)) {
        _snack('Unsupported photo type: $mime');
        return;
      }
      // Sync length read: async dart:io never returns inside flutter_tester
      // on this VM (see AGENTS.md, 2026-11-15) — same reason the repository
      // validates with lengthSync().
      final size = File(file.path).lengthSync();
      if (size > maxIdCardBytes) {
        _snack('Photo is too large (max 10 MB).');
        return;
      }
      if (mounted) {
        ref
            .read(createRequestControllerProvider.notifier)
            .setFile(slot, (path: file.path, mime: mime));
      }
    } on Exception {
      // No platform implementation (tests) or the picker failed.
      _snack('Could not add photo.');
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Dropdown decoration matching [OpsTextField] (label above, radius 14,
  /// same field fill in light/dark).
  InputDecoration _dropdownDecoration(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final fill = dark
        ? FieldOpsDarkTokens.fieldFill
        : FieldOpsDesignTokens.fieldFill;
    return InputDecoration(
      filled: true,
      fillColor: fill,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  /// Inline validation error under a field (theme error colour, no
  /// hardcoded colour).
  Widget _fieldError(CreateRequestState state, String field) {
    final message = state.fieldErrors[field];
    if (message == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.error,
        ),
      ),
    );
  }
}

/// Label above a dropdown, matching [OpsTextField]'s label style.
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// One file slot: label + required/optional tag, then either an "Add photo"
/// button or the picked file name with a remove action. Inline error shown
/// under the row when the slot failed validation.
class _FileSlotRow extends StatelessWidget {
  const _FileSlotRow({
    required this.slot,
    required this.label,
    this.required = false,
    required this.file,
    this.error,
    required this.onPick,
    required this.onRemove,
  });

  final CreateRequestFileSlot slot;
  final String label;
  final bool required;
  final CreateRequestFile? file;
  final String? error;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fileName = file?.path.split('/').last;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              required ? '$label *' : label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (fileName == null)
              OutlinedButton.icon(
                onPressed: onPick,
                icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                label: const Text('Add photo'),
              )
            else
              IconButton(
                tooltip: 'Remove photo',
                onPressed: onRemove,
                icon: Icon(Icons.delete_outline, color: scheme.error),
              ),
          ],
        ),
        if (fileName != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Icon(
                  Icons.image_outlined,
                  size: 18,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    fileName,
                    style: theme.textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              error!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.error,
              ),
            ),
          ),
      ],
    );
  }
}

/// Error banner with exactly one Retry button (APP_BRIEF rule 6). Used for
/// load failures and for a failed submit — the draft stays on screen behind
/// it.
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(FieldOpsDesignTokens.cardPadding),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(FieldOpsDesignTokens.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: scheme.onErrorContainer,
            ),
          ),
          const SizedBox(height: FieldOpsDesignTokens.spaceSmMd),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

/// Full-screen error state (nothing loaded yet): message + one Retry.
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

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

/// Skeleton rows in the shape of the form (APP_BRIEF rule 6).
class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(FieldOpsDesignTokens.pageMargin),
      child: Column(
        children: [
          for (var i = 0; i < 6; i++) ...[
            Container(
              height: 56,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(
                  FieldOpsDesignTokens.radiusMd,
                ),
              ),
            ),
            const SizedBox(height: FieldOpsDesignTokens.spaceMd),
          ],
        ],
      ),
    );
  }
}

/// Success view after the 201: request number, status, next action, and
/// "Open request" into the survey detail when the new request is with the
/// survey team (it always starts there per guide §4).
class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.response});

  final CreateConnectionRequestResponse response;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final data = response.data;
    final isSurvey =
        data?.status == ConnectionStatus.surveyAssigned ||
        response.allowedAction == 'complete_survey';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(FieldOpsDesignTokens.pageMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: FieldOpsDesignTokens.spaceMd),
        Icon(Icons.check_circle_outline, size: 64, color: scheme.primary),
        const SizedBox(height: FieldOpsDesignTokens.spaceMd),
        Text(
          'Request created',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: FieldOpsDesignTokens.spaceMd),
        if (data != null) ...[
          _SuccessRow(label: 'Request number', value: data.requestNumber),
          _SuccessRow(label: 'Status', value: data.status),
          if (response.allowedAction != null)
            _SuccessRow(
              label: 'Next step',
              value: response.allowedAction!,
            ),
          const SizedBox(height: FieldOpsDesignTokens.spaceMd),
        ],
        if (isSurvey && data != null && data.id.isNotEmpty)
          FilledButton(
            onPressed: () => context.push(Routes.surveyDetailFor(data.id)),
            child: const Text('Open request'),
          )
        else
          Text(
            'The request is with another team.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SuccessRow extends StatelessWidget {
  const _SuccessRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
