import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/app_info/app_info_provider.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/router/bottom_sheets/bottom_sheets_notifier.dart';
import 'package:hiddify/core/theme/mk_studio_colors.dart';
import 'package:hiddify/features/home/widget/connection_button.dart';
import 'package:hiddify/features/profile/notifier/active_profile_notifier.dart';
import 'package:hiddify/features/profile/widget/profile_tile.dart';
import 'package:hiddify/features/proxy/active/active_proxy_card.dart';
import 'package:hiddify/features/proxy/active/active_proxy_delay_indicator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Static single-viewport home: logo, title, profile, connect, status — no motion.
class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final t = ref.watch(translationsProvider).requireValue;
    final activeProfile = ref.watch(activeProfileProvider);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? theme.scaffoldBackgroundColor : MkStudioColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 8,
        title: const SizedBox.shrink(),
        actions: [
          Semantics(
            key: const ValueKey("profile_quick_settings"),
            label: t.pages.home.quickSettings,
            child: IconButton(
              icon: Icon(Icons.tune_rounded, color: theme.colorScheme.primary),
              onPressed: () => ref.read(bottomSheetsNotifierProvider.notifier).showQuickSettings(),
            ),
          ),
          Semantics(
            key: const ValueKey("profile_add_button"),
            label: t.pages.profiles.add,
            child: IconButton(
              icon: Icon(Icons.add_rounded, color: theme.colorScheme.primary),
              onPressed: () => ref.read(bottomSheetsNotifierProvider.notifier).showAddProfile(),
            ),
          ),
          const Gap(8),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.scaffoldBackgroundColor,
                    MkStudioColors.tealDeep.withValues(alpha: 0.18),
                    theme.scaffoldBackgroundColor,
                  ],
                )
              : MkStudioColors.heroBackground,
        ),
        child: SafeArea(
          top: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final short = constraints.maxHeight < 640;
                  final logoSize = short ? 64.0 : 80.0;

                  return Padding(
                    padding: EdgeInsets.fromLTRB(16, short ? 0 : 4, 16, 8),
                    child: Column(
                      children: [
                        // Brand
                        ClipRRect(
                          borderRadius: BorderRadius.circular(logoSize * 0.24),
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: logoSize,
                            height: logoSize,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              width: logoSize,
                              height: logoSize,
                              color: MkStudioColors.softTealWash,
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.grid_view_rounded,
                                size: logoSize * 0.42,
                                color: MkStudioColors.tealDeep,
                              ),
                            ),
                          ),
                        ),
                        Gap(short ? 8 : 12),
                        Text(
                          t.common.appTitle,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                            height: 1.1,
                            color: isDark ? theme.colorScheme.onSurface : MkStudioColors.tealDeep,
                          ),
                        ),
                        const Gap(4),
                        const AppVersionLabel(),
                        Gap(short ? 8 : 12),

                        // Profile selector
                        switch (activeProfile) {
                          AsyncData(value: final profile?) => ProfileTile(
                            profile: profile,
                            isMain: true,
                            margin: EdgeInsets.zero,
                            color: theme.colorScheme.surface,
                          ),
                          _ => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              t.dialogs.noActiveProfile.title,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(color: MkStudioColors.muted),
                            ),
                          ),
                        },

                        // Connect + delay — fills remaining space without scrolling
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ConnectionButton(compact: short),
                              const Gap(4),
                              const ActiveProxyDelayIndicator(staticPlaceholder: true),
                            ],
                          ),
                        ),

                        // Status footer (shrinks away when disconnected)
                        const ActiveProxyFooter(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppVersionLabel extends HookConsumerWidget {
  const AppVersionLabel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider).requireValue;
    final theme = Theme.of(context);

    final version = ref.watch(appInfoProvider).requireValue.presentVersion;
    if (version.isBlank) return const SizedBox();

    return Semantics(
      label: t.common.version,
      button: false,
      child: Text(
        version,
        textDirection: TextDirection.ltr,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
