import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../models/connection_request.dart';
import '../../../models/splicing.dart';
import '../../auth/presentation/providers.dart';
import '../../survey/presentation/connection_request_providers.dart';
import '../data/splicing_network.dart';
import '../data/splicing_repository.dart';

final splicingRequestsProvider = FutureProvider.family<ConnectionRequestPage, int>((ref, page) {
  return ref.watch(connectionRequestRepositoryProvider).fetchPage(
        page: page,
        status: ConnectionStatus.splicingAssigned,
      );
});

final splicingNetworkProvider = Provider<SplicingNetwork>((ref) =>
    DioSplicingNetwork(ref.watch(apiClientProvider)));
final splicingRepositoryProvider = Provider<SplicingRepository>((ref) =>
    SplicingRepository(network: ref.watch(splicingNetworkProvider)));
final splicingDetailProvider = FutureProvider.family<SplicingDetail, String>((ref, id) =>
    ref.watch(splicingRepositoryProvider).fetchDetail(id));

class CompleteSplicingState {
  const CompleteSplicingState({this.isSubmitting = false, this.errorMessage, this.done});
  final bool isSubmitting;
  final String? errorMessage;
  final CompleteSplicingResponse? done;
  bool get hasError => errorMessage != null;
}

class CompleteSplicingController extends Notifier<CompleteSplicingState> {
  @override
  CompleteSplicingState build() => const CompleteSplicingState();

  Future<CompleteSplicingResponse?> submit({
    required String id,
    String? voiceNotePath,
    String? voiceNoteMimeType,
  }) async {
    state = const CompleteSplicingState(isSubmitting: true);
    try {
      final result = await ref.read(splicingRepositoryProvider).complete(
            id: id, voiceNotePath: voiceNotePath, voiceNoteMimeType: voiceNoteMimeType);
      state = CompleteSplicingState(done: result);
      return result;
    } on ApiException catch (e) {
      state = CompleteSplicingState(errorMessage: e.message);
    } catch (e) {
      state = CompleteSplicingState(errorMessage: e.toString());
    }
    return null;
  }
}

final completeSplicingControllerProvider =
    NotifierProvider<CompleteSplicingController, CompleteSplicingState>(CompleteSplicingController.new);
