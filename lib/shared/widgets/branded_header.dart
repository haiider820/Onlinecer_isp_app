import 'package:flutter/material.dart';

import '../../core/theme/field_ops_design_tokens.dart';

/// Reusable top header matching the stitch mockup pattern (screens 2–10).
///
/// Fixed-height bar on a frosted surface: an optional back button, a small
/// brand mark + feature [title] on the left, and an arbitrary [actions] slot
/// on the right (avatar circle, notification bell, share, …).
///
/// Drop-in `appBar:` for any screen that should visually match the branded
/// headers in the DESIGN.md mockups rather than a plain Material [AppBar].
class BrandedHeader extends StatelessWidget implements PreferredSizeWidget {
  const BrandedHeader({
    super.key,
    required this.title,
    this.onBack,
    this.actions = const [],
    this.centerTitle = false,
    this.height = 64,
    this.onLogout,
  });

  /// Feature title in the header, e.g. 'Tickets', 'Work Order Execution'.
  final String title;

  /// When non-null, renders a 48dp round back button that calls [onBack].
  final VoidCallback? onBack;

  /// Right-side slot; children are laid out in [Row] with 8dp gaps.
  final List<Widget> actions;

  final bool centerTitle;

  /// Header bar height (mockups use a 64dp tall bar).
  final double height;

  /// Optional logout callback for dashboard screens. When provided, renders
  /// a red logout icon button in the header's trailing area. Dashboards should
  /// NOT pass [onBack] since they're top-level screens with nowhere to go back to.
  final VoidCallback? onLogout;

  /// Brand mark shown left of the title — the Malik Fiber logo mark.
  Widget buildBrandMark(BuildContext context) {
    return Image.asset(
      'assets/images/malik_fiber_logo.png',
      width: 36,
      height: 36,
      fit: BoxFit.contain,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PreferredSize(
      preferredSize: Size.fromHeight(height),
      child: SafeArea(
        top: true,
        bottom: false,
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: FieldOpsDesignTokens.pageMargin),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F9FD).withValues(alpha: 0.86),
            border: const Border(
              bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 8,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              if (onBack != null) ...[
                // 48dp round back target, −8dp left so the glyph sits off-gutter.
                SizedBox(
                  width: 48,
                  height: 48,
                  child: IconButton(
                    tooltip: 'Back',
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back, size: 24),
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: FieldOpsDesignTokens.spaceXs),
              ],
              buildBrandMark(context),
              const SizedBox(width: FieldOpsDesignTokens.spaceSm),
              Expanded(
                child: centerTitle
                    ? Text(
                        title,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              if (actions.isNotEmpty) ...[
                const SizedBox(width: FieldOpsDesignTokens.spaceSm),
                for (final action in actions)
                  Padding(
                    padding: const EdgeInsets.only(left: FieldOpsDesignTokens.spaceXs),
                    child: action,
                  ),
              ],
              if (onLogout != null) ...[
                const SizedBox(width: FieldOpsDesignTokens.spaceSm),
                Padding(
                  padding: const EdgeInsets.only(left: FieldOpsDesignTokens.spaceXs),
                  child: IconButton(
                    tooltip: 'Log out',
                    onPressed: onLogout,
                    icon: const Icon(Icons.logout, size: 24),
                    color: const Color(0xFFDC2626), // Material red / error color
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626).withValues(alpha: 0.1),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}

/// Compact 32dp avatar circle used in the header's right slot (mockup shows a
/// plain person glyph on a primary disc).
class HeaderAvatar extends StatelessWidget {
  const HeaderAvatar({super.key, this.initials, this.size = 32});

  /// Optional initials; when null the person glyph is shown instead.
  final String? initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: initials == null
          ? Icon(
              Icons.person,
              size: size * 0.56,
              color: Theme.of(context).colorScheme.onPrimary,
            )
          : Text(
              initials!,
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.36,
                fontWeight: FontWeight.w800,
              ),
            ),
    );
  }
}