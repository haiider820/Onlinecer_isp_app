import 'dart:io';

import '../../../core/constants/app_constants.dart';
import '../../../models/complete_installation.dart';
import '../../survey/data/submit_survey_repository.dart'
    show UnsupportedVoiceNoteException, VoiceNoteTooLargeException;
import 'complete_installation_network.dart';

/// Thrown when an attached photo exceeds the backend's 2 MB per-image limit.
class InstallationPhotoTooLargeException implements Exception {
  const InstallationPhotoTooLargeException(this.sizeBytes);

  final int sizeBytes;

  @override
  String toString() => 'Installation photo exceeds 2 MB limit ($sizeBytes bytes).';
}

/// Thrown when a photo is provided whose MIME type the backend does not
/// accept (see [allowedInstallationPhotoMimeTypes]).
class UnsupportedInstallationPhotoException implements Exception {
  const UnsupportedInstallationPhotoException(this.mimeType);

  final String mimeType;

  @override
  String toString() => 'Unsupported installation photo type: $mimeType';
}

/// Submits completed installation work to `POST .../complete-installation`.
///
/// The endpoint takes two shapes (plain JSON vs multipart) depending on
/// whether photos or a voice note are attached; the branch lives here so the
/// UI only calls a single [submit] method.
class CompleteInstallationRepository {
  CompleteInstallationRepository({required this.network});

  final CompleteInstallationNetwork network;

  /// Completes the installation for [id].
  ///
  /// When [photos] or [voiceNotePath] is provided the payload is sent as
  /// `multipart/form-data`; otherwise plain JSON. Files are validated before
  /// upload: every photo must be within the 2 MB limit and use an accepted
  /// MIME type ([allowedInstallationPhotoMimeTypes]), and a voice note within
  /// the 10 MB limit and an accepted MIME type ([allowedVoiceNoteMimeTypes]).
  Future<CompleteInstallationResponse> submit({
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
    final hasPhotos = photos != null && photos.isNotEmpty;
    final hasVoice = voiceNotePath != null;

    if (!hasPhotos && !hasVoice) {
      final map = await network.completeInstallationJson(
        id,
        oltDeviceOwnership: oltDeviceOwnership,
        connectionFatNodeId: connectionFatNodeId,
        dpLatitude: dpLatitude,
        dpLongitude: dpLongitude,
        totalWireUsed: totalWireUsed,
        notes: notes,
        inventoryLines: inventoryLines,
      );
      return CompleteInstallationResponse.fromJson(map);
    }

    if (hasPhotos) {
      for (final photo in photos) {
        final size = await File(photo.path).length();
        if (size > maxInstallationPhotoBytes) {
          throw InstallationPhotoTooLargeException(size);
        }
        if (!allowedInstallationPhotoMimeTypes.contains(photo.mime)) {
          throw UnsupportedInstallationPhotoException(photo.mime);
        }
      }
    }

    if (hasVoice) {
      final size = await File(voiceNotePath).length();
      if (size > maxVoiceNoteBytes) {
        throw VoiceNoteTooLargeException(size);
      }
      final mime = voiceNoteMimeType ?? _mimeTypeForExtension(voiceNotePath);
      if (!allowedVoiceNoteMimeTypes.contains(mime)) {
        throw UnsupportedVoiceNoteException(mime);
      }
      voiceNoteMimeType = mime;
    }

    final map = await network.completeInstallationMultipart(
      id,
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
    return CompleteInstallationResponse.fromJson(map);
  }

  /// Maps a file extension to a backend-accepted MIME type, based on the
  /// formats the `record` package produces.
  static String _mimeTypeForExtension(String path) {
    final ext = path.toLowerCase().split('.').last;
    return switch (ext) {
      'm4a' || 'mp4' => 'audio/mp4',
      'webm' => 'audio/webm',
      'wav' => 'audio/x-wav',
      'ogg' || 'opus' => 'audio/ogg',
      'aac' => 'audio/mp4',
      _ => 'application/octet-stream',
    };
  }
}