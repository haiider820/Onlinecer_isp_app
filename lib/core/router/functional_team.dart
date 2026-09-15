/// The five functional teams an employee can belong to.
///
/// This is the single team identity used everywhere in the app. The API talks
/// in wire strings (`employee.functional_team_type`); this enum is the mapping
/// from those strings to a compile-time-checked identity. Never branch on the
/// wire string directly — always parse into this enum first and exhaustively
/// `switch` on it, so the compiler forces every team to be handled and an
/// unrecognised value can never silently fall through to a wrong screen.
enum FunctionalTeamType {
  survey('survey'),
  installation('installation'),
  fiberSplicing('fiber_splicing'),
  connectionVerification('connection_verification'),
  closing('closing');

  const FunctionalTeamType(this.wireValue);

  /// The value the backend sends under `employee.functional_team_type`.
  final String wireValue;

  /// Parses a backend wire value. Returns `null` for anything not one of the
  /// five known teams — callers must handle `null` explicitly (a user with no
  /// team yet should get an explicit "no team assigned" screen, never a silent
  /// wrong-team or "coming soon" fallback).
  static FunctionalTeamType? fromWire(String? value) {
    if (value == null) return null;
    for (final team in FunctionalTeamType.values) {
      if (team.wireValue == value) return team;
    }
    return null;
  }
}