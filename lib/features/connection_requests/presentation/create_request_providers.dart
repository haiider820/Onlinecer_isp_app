import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exceptions.dart';
import '../../../models/create_data.dart';
import '../../auth/presentation/providers.dart';
import '../../survey/presentation/connection_request_providers.dart';
import '../data/create_request_network.dart';
import '../data/create_request_repository.dart';

/// Real HTTP-backed create-request network.
final createRequestNetworkProvider = Provider<CreateRequestNetwork>((ref) {
  return DioCreateRequestNetwork(ref.watch(apiClientProvider));
});

/// Create-request repository wiring the network layer.
final createRequestRepositoryProvider = Provider<CreateRequestRepository>((
  ref,
) {
  return CreateRequestRepository(
    network: ref.watch(createRequestNetworkProvider),
  );
});

/// Create-data for the create form, keyed by the resolved sub-branch id
/// (ISPFINAL §3). Reloads when the selection changes — the screen watches
/// this with the id from [subBranchStateProvider], so a sub-branch switch
/// refetches plans / FAT nodes / team flows for the new scope.
final createDataProvider =
    FutureProvider.family<CreateDataResponse, String?>((ref, subBranchId) {
      return ref
          .watch(createRequestRepositoryProvider)
          .fetchCreateData(subBranchId: subBranchId);
    });

/// Immutable create-form state exposed to the create screen.
///
/// The form is a local draft: text + picked file paths live here while the
/// screen lives. A failed submit keeps the draft on screen (the controller
/// only flips `isSubmitting` / `errorMessage`); there is no queued offline
/// submit in v1 — no outbox exists — so the screen says so and offers Retry.
class CreateRequestState {
  const CreateRequestState({
    this.customerName = '',
    this.customerPhone = '',
    this.customerType = 'home',
    this.customerArea = '',
    this.customerAddress = '',
    this.requestedPlanId,
    this.teamFlowId,
    this.priceMode,
    this.customPrice = '',
    this.discountType = '',
    this.discountValue = '',
    this.idCardFront,
    this.idCardBack,
    this.utilityBill,
    this.connectionForm,
    this.fieldErrors = const {},
    this.isSubmitting = false,
    this.errorMessage,
    this.created,
  });

  final String customerName;
  final String customerPhone;

  /// Wire value from create-data `customer_types`; defaults to `'home'`.
  final String customerType;
  final String customerArea;
  final String customerAddress;

  /// Selected ids from the create-data dropdowns (never hardcoded).
  final String? requestedPlanId;
  final String? teamFlowId;

  /// `selling_price` / `custom_price` / `other` (guide §4).
  final String? priceMode;
  final String customPrice;
  final String discountType;
  final String discountValue;

  final CreateRequestFile? idCardFront;
  final CreateRequestFile? idCardBack;
  final CreateRequestFile? utilityBill;
  final CreateRequestFile? connectionForm;

  /// Inline validation errors, keyed by wire field name.
  final Map<String, String> fieldErrors;
  final bool isSubmitting;
  final String? errorMessage;

  /// The 201 response once the request is created; the screen shows the
  /// success view from this instead of the form.
  final CreateConnectionRequestResponse? created;

  bool get hasError => errorMessage != null;
  bool get isDone => created != null;

  static const _unset = Object();

  CreateRequestState copyWith({
    String? customerName,
    String? customerPhone,
    String? customerType,
    String? customerArea,
    String? customerAddress,
    Object? requestedPlanId = _unset,
    Object? teamFlowId = _unset,
    Object? priceMode = _unset,
    String? customPrice,
    String? discountType,
    String? discountValue,
    Object? idCardFront = _unset,
    Object? idCardBack = _unset,
    Object? utilityBill = _unset,
    Object? connectionForm = _unset,
    Map<String, String>? fieldErrors,
    bool? isSubmitting,
    Object? errorMessage = _unset,
    Object? created = _unset,
  }) {
    return CreateRequestState(
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerType: customerType ?? this.customerType,
      customerArea: customerArea ?? this.customerArea,
      customerAddress: customerAddress ?? this.customerAddress,
      requestedPlanId: requestedPlanId == _unset
          ? this.requestedPlanId
          : requestedPlanId as String?,
      teamFlowId: teamFlowId == _unset
          ? this.teamFlowId
          : teamFlowId as String?,
      priceMode: priceMode == _unset
          ? this.priceMode
          : priceMode as String?,
      customPrice: customPrice ?? this.customPrice,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      idCardFront: idCardFront == _unset
          ? this.idCardFront
          : idCardFront as CreateRequestFile?,
      idCardBack: idCardBack == _unset
          ? this.idCardBack
          : idCardBack as CreateRequestFile?,
      utilityBill: utilityBill == _unset
          ? this.utilityBill
          : utilityBill as CreateRequestFile?,
      connectionForm: connectionForm == _unset
          ? this.connectionForm
          : connectionForm as CreateRequestFile?,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
      created: created == _unset
          ? this.created
          : created as CreateConnectionRequestResponse?,
    );
  }
}

/// Drives the create-request form: holds the draft, validates it, and posts
/// it. Populates [CreateRequestState.created] on success so the screen can
/// show the request number and the "Open request" action.
class CreateRequestController extends Notifier<CreateRequestState> {
  @override
  CreateRequestState build() => const CreateRequestState();

  Map<String, String> _withoutError(String field) {
    if (!state.fieldErrors.containsKey(field)) return state.fieldErrors;
    final next = Map<String, String>.of(state.fieldErrors)..remove(field);
    return next;
  }

  void updateCustomerName(String value) => state = state.copyWith(
    customerName: value,
    fieldErrors: _withoutError('customer_name'),
  );

  void updateCustomerPhone(String value) => state = state.copyWith(
    customerPhone: value,
    fieldErrors: _withoutError('customer_phone'),
  );

  void updateCustomerArea(String value) => state = state.copyWith(
    customerArea: value,
    fieldErrors: _withoutError('customer_area'),
  );

  void updateCustomerAddress(String value) => state = state.copyWith(
    customerAddress: value,
    fieldErrors: _withoutError('customer_address'),
  );

  void updateCustomPrice(String value) => state = state.copyWith(
    customPrice: value,
    fieldErrors: _withoutError('custom_price'),
  );

  void updateDiscountType(String value) => state = state.copyWith(
    discountType: value,
    fieldErrors: _withoutError('discount_type'),
  );

  void updateDiscountValue(String value) => state = state.copyWith(
    discountValue: value,
    fieldErrors: _withoutError('discount_value'),
  );

  void selectCustomerType(String type) =>
      state = state.copyWith(customerType: type);

  void selectPlan(String? id) => state = state.copyWith(requestedPlanId: id);

  void selectTeamFlow(String? id) =>
      state = state.copyWith(teamFlowId: id);

  void selectPriceMode(String? mode) => state = state.copyWith(
    priceMode: mode,
    fieldErrors: _withoutError('custom_price'),
  );

  void setFile(CreateRequestFileSlot slot, CreateRequestFile file) {
    state = switch (slot) {
      CreateRequestFileSlot.idCardFront => state.copyWith(
        idCardFront: file,
        fieldErrors: _withoutError('id_card_front'),
      ),
      CreateRequestFileSlot.idCardBack => state.copyWith(
        idCardBack: file,
        fieldErrors: _withoutError('id_card_back'),
      ),
      CreateRequestFileSlot.utilityBill => state.copyWith(utilityBill: file),
      CreateRequestFileSlot.connectionForm => state.copyWith(
        connectionForm: file,
      ),
    };
  }

  void clearFile(CreateRequestFileSlot slot) {
    state = switch (slot) {
      CreateRequestFileSlot.idCardFront => state.copyWith(idCardFront: null),
      CreateRequestFileSlot.idCardBack => state.copyWith(idCardBack: null),
      CreateRequestFileSlot.utilityBill => state.copyWith(utilityBill: null),
      CreateRequestFileSlot.connectionForm => state.copyWith(
        connectionForm: null,
      ),
    };
  }

  /// Validates the draft, then posts it. Returns the 201 response on
  /// success, `null` on validation / submit failure — in both failure cases
  /// the draft stays exactly as the user left it, with either inline field
  /// errors or [CreateRequestState.errorMessage] + a Retry.
  ///
  /// [subBranchId] is the resolved id from Phase B ([subBranchStateProvider]
  /// `effectiveId`); `null` means no scope was resolved and the submit is
  /// refused here — the controller is the last line of defence behind the
  /// screen's `canProceed` gate, so a null scope never reaches the network.
  Future<CreateConnectionRequestResponse?> submit({
    required String? subBranchId,
  }) async {
    final errors = <String, String>{};
    if (state.customerName.trim().isEmpty) {
      errors['customer_name'] = 'Customer name is required.';
    }
    if (state.customerPhone.trim().isEmpty) {
      errors['customer_phone'] = 'Customer phone is required.';
    }
    if (state.idCardFront == null) {
      errors['id_card_front'] = 'Front photo of the ID card is required.';
    }
    if (state.idCardBack == null) {
      errors['id_card_back'] = 'Back photo of the ID card is required.';
    }
    if (state.priceMode == 'custom_price' &&
        state.customPrice.trim().isEmpty) {
      errors['custom_price'] = 'Enter the custom price.';
    }
    if (errors.isNotEmpty) {
      state = state.copyWith(fieldErrors: errors);
      return null;
    }

    if (subBranchId == null) {
      state = state.copyWith(
        errorMessage: 'Select a sub-branch before submitting.',
      );
      return null;
    }

    state = state.copyWith(
      isSubmitting: true,
      errorMessage: null,
      fieldErrors: const {},
    );
    try {
      final result = await ref.read(createRequestRepositoryProvider).create(
        customerName: state.customerName.trim(),
        customerPhone: state.customerPhone.trim(),
        customerType: state.customerType,
        idCardFront: state.idCardFront!,
        idCardBack: state.idCardBack!,
        subBranchId: subBranchId,
        customerArea: _orNull(state.customerArea),
        customerAddress: _orNull(state.customerAddress),
        requestedPlanId: state.requestedPlanId,
        teamFlowId: state.teamFlowId,
        priceMode: state.priceMode,
        customPrice: _orNull(state.customPrice),
        discountType: _orNull(state.discountType),
        discountValue: _orNull(state.discountValue),
        utilityBill: state.utilityBill,
        connectionForm: state.connectionForm,
      );
      // The new request joins the survey queue — refresh it so going back
      // to the list shows it without a manual pull.
      ref.invalidate(connectionRequestsProvider);
      state = state.copyWith(isSubmitting: false, created: result);
      return result;
    } on IdCardTooLargeException catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
      return null;
    } on UnsupportedIdCardException catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
      return null;
    } on NetworkException {
      // No outbox exists in v1: the draft stays on screen and the user
      // retries from here. Say so plainly instead of claiming it queued.
      state = state.copyWith(
        isSubmitting: false,
        errorMessage:
            "Couldn't send — your entries are still here. Retry.",
      );
      return null;
    } on ApiException catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.message);
      return null;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
      return null;
    }
  }

  void clearError() => state = state.copyWith(errorMessage: null);

  static String? _orNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

final createRequestControllerProvider =
    NotifierProvider<CreateRequestController, CreateRequestState>(
      CreateRequestController.new,
    );
