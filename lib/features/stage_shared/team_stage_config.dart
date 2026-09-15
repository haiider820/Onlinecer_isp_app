import '../../core/constants/app_constants.dart';
import '../../core/router/functional_team.dart';

/// Immutable differences between the otherwise identical Verification and
/// Closing stages. Feature wiring can consume these configs without adding
/// another copy of list/detail/completion behavior.
///
/// The identity is a typed [FunctionalTeamType], and the human labels it feeds
/// to the UI are all derived from that same value here — no caller may supply
/// or hardcode a stage label.
class TeamStageConfig {
  const TeamStageConfig({
    required this.team,
    required this.statusFilter,
    required this.allowedAction,
    required this.completionPathFor,
    required this.notesField,
    required this.isTerminal,
  });

  final FunctionalTeamType team;
  final String statusFilter;
  final String allowedAction;
  final String Function(String requestId) completionPathFor;
  final String notesField;
  final bool isTerminal;

  /// Human feature name for success messages, e.g. 'Verification'.
  ///
  /// Exhaustive switch with **no default arm and no `_` fallback**: adding a
  /// team forces this to be revisited at compile time rather than silently
  /// labelling the stage as the wrong team.
  String get featureName => switch (team) {
        FunctionalTeamType.connectionVerification => 'Verification',
        FunctionalTeamType.closing => 'Closing',
        FunctionalTeamType.survey ||
        FunctionalTeamType.installation ||
        FunctionalTeamType.fiberSplicing =>
          // Staged config is only ever constructed for Verification/Closing;
          // the other teams have no completion stage of their own.
          'Request',
      };

  /// Label of the confirmation button, e.g. 'Complete Verification'.
  String get actionLabel => switch (team) {
        FunctionalTeamType.connectionVerification => 'Complete Verification',
        FunctionalTeamType.closing => 'Complete Closing',
        FunctionalTeamType.survey ||
        FunctionalTeamType.installation ||
        FunctionalTeamType.fiberSplicing =>
          'Complete',
      };

  /// Label of the notes input, e.g. 'Verification notes'.
  String get notesLabel => switch (team) {
        FunctionalTeamType.connectionVerification => 'Verification notes',
        FunctionalTeamType.closing => 'Closing notes',
        FunctionalTeamType.survey ||
        FunctionalTeamType.installation ||
        FunctionalTeamType.fiberSplicing =>
          'Notes',
      };

  static const verification = TeamStageConfig(
    team: FunctionalTeamType.connectionVerification,
    statusFilter: 'verification_assigned',
    allowedAction: 'complete_verification',
    completionPathFor: Endpoints.completeVerification,
    notesField: 'verification_notes',
    isTerminal: false,
  );

  static const closing = TeamStageConfig(
    team: FunctionalTeamType.closing,
    statusFilter: 'closing_assigned',
    allowedAction: 'complete_closing',
    completionPathFor: Endpoints.completeClosing,
    notesField: 'closing_notes',
    isTerminal: true,
  );
}