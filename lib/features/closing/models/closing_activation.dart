/// Activation credentials returned by `POST
/// /connection-requests/{id}/complete-closing` at
/// `response.data.data.activation` (mobile-dev spec, D24).
///
/// Hand-written lenient parse (no codegen): every field is optional and any
/// missing / null / wrong-typed value parses to `null` — an older backend
/// response with no `activation` block must never crash the success screen,
/// it simply shows no activation card.
class ClosingActivation {
  const ClosingActivation({
    this.pppoeUsername,
    this.pppoePassword,
    this.portalEmail,
    this.portalPassword,
    this.radiusSynced,
  });

  /// `activation.pppoe_username` — PPPoE login for the customer router.
  final String? pppoeUsername;

  /// `activation.pppoe_password`.
  final String? pppoePassword;

  /// `activation.portal_email` — customer portal login.
  final String? portalEmail;

  /// `activation.portal_password`.
  final String? portalPassword;

  /// `activation.radius_synced` — `false` means the RADIUS sync failed and
  /// the success screen must warn. `null` = the backend did not report it
  /// (older response): no warning, no assumption.
  final bool? radiusSynced;

  factory ClosingActivation.fromJson(Map<String, dynamic> json) {
    return ClosingActivation(
      pppoeUsername: _string(json['pppoe_username']),
      pppoePassword: _string(json['pppoe_password']),
      portalEmail: _string(json['portal_email']),
      portalPassword: _string(json['portal_password']),
      radiusSynced: json['radius_synced'] is bool
          ? json['radius_synced'] as bool
          : null,
    );
  }

  /// True when at least one credential value is present — the card is only
  /// worth showing then; an all-null activation renders nothing.
  bool get hasAnyValue =>
      pppoeUsername != null ||
      pppoePassword != null ||
      portalEmail != null ||
      portalPassword != null;

  static String? _string(Object? value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}
