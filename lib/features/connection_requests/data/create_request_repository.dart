import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../../../core/constants/app_constants.dart';
import '../../../models/create_data.dart';
import 'create_request_network.dart';

/// One attached image on the create form: a local file path plus its
/// reported MIME type (used for the multipart content-type and for the
/// size/type guards). Mirrors [InstallationPhoto].
typedef CreateRequestFile = ({String path, String mime});

/// File slots on the create form. Front/back ID are required; the utility
/// bill and the connection form are optional supporting images.
enum CreateRequestFileSlot {
  idCardFront,
  idCardBack,
  utilityBill,
  connectionForm,
}

/// Wire field name for each file slot (guide §4, exact).
extension CreateRequestFileSlotField on CreateRequestFileSlot {
  String get fieldName => switch (this) {
        CreateRequestFileSlot.idCardFront => 'id_card_front',
        CreateRequestFileSlot.idCardBack => 'id_card_back',
        CreateRequestFileSlot.utilityBill => 'utility_bill',
        CreateRequestFileSlot.connectionForm => 'connection_form',
      };
}

/// Thrown when an ID-card / supporting image exceeds the backend's 10 MB
/// limit ([maxIdCardBytes]).
class IdCardTooLargeException implements Exception {
  const IdCardTooLargeException(this.sizeBytes);

  final int sizeBytes;

  @override
  String toString() => 'ID card image exceeds 10 MB limit ($sizeBytes bytes).';
}

/// Thrown when an image is provided whose MIME type the backend does not
/// accept (see [allowedIdCardMimeTypes]). Images only — no PDF (Haider's
/// call, 2026-11-23).
class UnsupportedIdCardException implements Exception {
  const UnsupportedIdCardException(this.mimeType);

  final String mimeType;

  @override
  String toString() => 'Unsupported ID card image type: $mimeType';
}

/// The created request inside the 201 response: `{ "data": { "id",
/// "request_number", "status", "customer_name", "sub_branch",
/// "requested_plan" } }`.
///
/// `sub_branch` / `requested_plan` are parsed as generic maps on purpose:
/// the guide does not pin their shapes down, so a typed model would throw
/// on any unexpected field. Callers read the keys they need.
class CreatedConnectionRequest {
  const CreatedConnectionRequest({
    required this.id,
    required this.requestNumber,
    required this.status,
    this.customerName,
    this.subBranch,
    this.requestedPlan,
  });

  final String id;
  final String requestNumber;
  final String status;
  final String? customerName;
  final Map<String, Object?>? subBranch;
  final Map<String, Object?>? requestedPlan;

  factory CreatedConnectionRequest.fromJson(Map<String, Object?> json) {
    return CreatedConnectionRequest(
      id: json['id']?.toString() ?? '',
      requestNumber: json['request_number']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      customerName: json['customer_name']?.toString(),
      subBranch: json['sub_branch'] is Map
          ? Map<String, Object?>.from(json['sub_branch'] as Map)
          : null,
      requestedPlan: json['requested_plan'] is Map
          ? Map<String, Object?>.from(json['requested_plan'] as Map)
          : null,
    );
  }
}

/// The 201 response of `POST /connection-requests`: `{ "message", "data",
/// "allowed_action", "allowed_actions" }`. The plural `allowed_actions` is
/// the current shape; the singular `allowed_action` is kept for old
/// backend payloads.
class CreateConnectionRequestResponse {
  const CreateConnectionRequestResponse({
    this.message,
    this.data,
    this.allowedAction,
    this.allowedActions,
  });

  final String? message;
  final CreatedConnectionRequest? data;
  final String? allowedAction;
  final List<String>? allowedActions;

  factory CreateConnectionRequestResponse.fromJson(
    Map<String, Object?> json,
  ) {
    final data = json['data'];
    return CreateConnectionRequestResponse(
      message: json['message']?.toString(),
      data: data is Map
          ? CreatedConnectionRequest.fromJson(
              Map<String, Object?>.from(data),
            )
          : null,
      allowedAction: json['allowed_action']?.toString(),
      allowedActions: json['allowed_actions'] is List
          ? (json['allowed_actions'] as List)
                .map((value) => value.toString())
                .toList()
          : null,
    );
  }
}

/// Creates connection requests (`POST /connection-requests`, ISPFINAL §4)
/// and loads the create form's dropdown data (`GET .../create-data`, §3).
///
/// The create call is always multipart: the two ID-card images are
/// required, so there is no plain-JSON branch (unlike submit-survey).
/// Every file is validated client-side before upload — MIME in
/// [allowedIdCardMimeTypes], each file at most [maxIdCardBytes] — mirroring
/// the voice-note / installation-photo guards.
class CreateRequestRepository {
  CreateRequestRepository({required this.network});

  final CreateRequestNetwork network;

  /// Loads the create form's dropdown data for [subBranchId] (from Phase B
  /// only — never an invented id). The backend scopes plans / FAT nodes /
  /// team flows to that sub-branch.
  Future<CreateDataResponse> fetchCreateData({String? subBranchId}) async {
    final map = await network.fetchCreateData(subBranchId: subBranchId);
    return CreateDataResponse.fromJson(map);
  }

  /// Creates a connection request (guide §4, exact field names).
  ///
  /// Required: [customerName], [customerPhone], [idCardFront],
  /// [idCardBack]. [customerType] defaults to `'home'`. [subBranchId] comes
  /// from Phase B only and is omitted when `null`. All other fields are
  /// optional and are omitted when empty so the backend sees exactly what
  /// the user entered.
  Future<CreateConnectionRequestResponse> create({
    required String customerName,
    required String customerPhone,
    String customerType = 'home',
    required CreateRequestFile idCardFront,
    required CreateRequestFile idCardBack,
    String? subBranchId,
    String? customerArea,
    String? customerAddress,
    String? requestedPlanId,
    String? teamFlowId,
    String? priceMode,
    String? customPrice,
    String? discountType,
    String? discountValue,
    CreateRequestFile? utilityBill,
    CreateRequestFile? connectionForm,
  }) async {
    _validateFile(idCardFront);
    _validateFile(idCardBack);
    if (utilityBill != null) _validateFile(utilityBill);
    if (connectionForm != null) _validateFile(connectionForm);

    final form = FormData.fromMap({
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_type': customerType,
      if (subBranchId != null) 'sub_branch_id': subBranchId,
      if (customerArea != null && customerArea.isNotEmpty)
        'customer_area': customerArea,
      if (customerAddress != null && customerAddress.isNotEmpty)
        'customer_address': customerAddress,
      if (requestedPlanId != null) 'requested_plan_id': requestedPlanId,
      if (teamFlowId != null) 'team_flow_id': teamFlowId,
      if (priceMode != null) 'price_mode': priceMode,
      if (customPrice != null && customPrice.isNotEmpty)
        'custom_price': customPrice,
      if (discountType != null && discountType.isNotEmpty)
        'discount_type': discountType,
      if (discountValue != null && discountValue.isNotEmpty)
        'discount_value': discountValue,
      'id_card_front': MultipartFile.fromFileSync(
        idCardFront.path,
        contentType: MediaType.parse(idCardFront.mime),
      ),
      'id_card_back': MultipartFile.fromFileSync(
        idCardBack.path,
        contentType: MediaType.parse(idCardBack.mime),
      ),
      if (utilityBill != null)
        'utility_bill': MultipartFile.fromFileSync(
          utilityBill.path,
          contentType: MediaType.parse(utilityBill.mime),
        ),
      if (connectionForm != null)
        'connection_form': MultipartFile.fromFileSync(
          connectionForm.path,
          contentType: MediaType.parse(connectionForm.mime),
        ),
    });

    final map = await network.createConnectionRequest(form);
    return CreateConnectionRequestResponse.fromJson(map);
  }

  /// Size + MIME guard for one attached image. Runs before any network
  /// call, so a rejected file never leaves the phone.
  ///
  /// Synchronous on purpose ([File.lengthSync]): async dart:io never
  /// returns inside flutter_tester on this VM (see AGENTS.md, 2026-11-15),
  /// and the same sync read is what the field uses in production.
  static void _validateFile(CreateRequestFile file) {
    final size = File(file.path).lengthSync();
    if (size > maxIdCardBytes) {
      throw IdCardTooLargeException(size);
    }
    if (!allowedIdCardMimeTypes.contains(file.mime)) {
      throw UnsupportedIdCardException(file.mime);
    }
  }

  /// Maps a picked file's extension to a backend-accepted MIME type, based
  /// on the formats `image_picker` produces. Anything else maps to
  /// `application/octet-stream`, which the MIME guard then rejects.
  static String mimeTypeForExtension(String path) {
    final ext = path.toLowerCase().split('.').last;
    return switch (ext) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'application/octet-stream',
    };
  }
}
