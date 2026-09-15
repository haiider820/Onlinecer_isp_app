import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../models/complete_installation.dart';
import '../../../models/connection_request.dart';
import '../../../models/inventory_item.dart';
import '../../auth/presentation/providers.dart';
import '../../survey/presentation/connection_request_providers.dart';
import '../data/complete_installation_network.dart';
import '../data/complete_installation_repository.dart';
import '../data/inventory_network.dart';
import '../data/inventory_repository.dart';

/// Page of installation-assigned requests. The status filter is sent to the
/// server, which returns only the requests the installation team owns.
///
/// The shared list screen watches pages of this provider; the status constant
/// is what distinguishes this queue from the survey queue.
final installationRequestsProvider =
    FutureProvider.family<ConnectionRequestPage, int>((ref, page) {
  return ref
      .watch(connectionRequestRepositoryProvider)
      .fetchPage(page: page, status: ConnectionStatus.installationAssigned);
});

/// Real HTTP-backed inventory network.
final inventoryNetworkProvider = Provider<InventoryNetwork>((ref) {
  return DioInventoryNetwork(ref.watch(apiClientProvider));
});

/// Inventory repository wiring the network layer.
final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepository(network: ref.watch(inventoryNetworkProvider));
});

/// The installation inventory catalog (`GET /lookups/inventory-items`).
///
/// The completion form watches this on entry and populates the inventory-item
/// dropdowns/ranges from it. FAT-node lookups are reused unchanged from the
/// survey flow (`fatNodesProvider(connectionRequestId)`).
final inventoryItemsProvider = FutureProvider<InventoryItemList>((ref) {
  return ref.watch(inventoryRepositoryProvider).fetch();
});

/// Real HTTP-backed complete-installation network.
final completeInstallationNetworkProvider = Provider<CompleteInstallationNetwork>((ref) {
  return DioCompleteInstallationNetwork(ref.watch(apiClientProvider));
});

/// Complete-installation repository wiring the network layer.
final completeInstallationRepositoryProvider =
    Provider<CompleteInstallationRepository>((ref) {
  return CompleteInstallationRepository(
    network: ref.watch(completeInstallationNetworkProvider),
  );
});

/// Immutable submission state exposed to the completion screen.
class CompleteInstallationState {
  const CompleteInstallationState({
    this.isSubmitting = false,
    this.errorMessage,
    this.done,
  });

  final bool isSubmitting;
  final String? errorMessage;
  final CompleteInstallationResponse? done;

  bool get hasError => errorMessage != null;
}

/// Drives the complete-installation submission. Populates
/// [CompleteInstallationState.done] on success so the screen can show the new
/// status and navigate away (mirrors the submit-survey controller).
class CompleteInstallationController extends Notifier<CompleteInstallationState> {
  @override
  CompleteInstallationState build() => const CompleteInstallationState();

  Future<CompleteInstallationResponse?> submit({
    required String id,
    required String oltDeviceOwnership,
    required String connectionFatNodeId,
    required double dpLatitude,
    required double dpLongitude,
    num? totalWireUsed,
    String? notes,
    List<InventoryLine>? inventoryLines,
    List<InstallationPhoto>? photos,
    String? voiceNotePath,
    String? voiceNoteMimeType,
  }) async {
    state = const CompleteInstallationState(isSubmitting: true);
    try {
      final repo = ref.read(completeInstallationRepositoryProvider);
      final result = await repo.submit(
        id: id,
        oltDeviceOwnership: oltDeviceOwnership,
        connectionFatNodeId: connectionFatNodeId,
        dpLatitude: dpLatitude,
        dpLongitude: dpLongitude,
        totalWireUsed: totalWireUsed,
        notes: notes,
        inventoryLines: inventoryLines,
        photos: photos,
        voiceNotePath: voiceNotePath,
        voiceNoteMimeType: voiceNoteMimeType,
      );
      state = CompleteInstallationState(done: result);
      return result;
    } on ApiException catch (e) {
      state = CompleteInstallationState(errorMessage: e.message);
      return null;
    } catch (e) {
      state = CompleteInstallationState(errorMessage: e.toString());
      return null;
    }
  }

  void clearError() {
    state = const CompleteInstallationState();
  }
}

final completeInstallationControllerProvider =
    NotifierProvider<CompleteInstallationController, CompleteInstallationState>(
  CompleteInstallationController.new,
);