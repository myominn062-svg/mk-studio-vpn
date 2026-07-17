import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/model/constants.dart';
import 'package:hiddify/core/router/dialog/dialog_notifier.dart';
import 'package:hiddify/core/theme/mk_studio_colors.dart';
import 'package:hiddify/features/settings/notifier/config_option/config_option_notifier.dart';
import 'package:hiddify/features/settings/notifier/reset_tunnel/reset_tunnel_notifier.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

enum ConfigOptionSection {
  warp,
  fragment;

  static final _warpKey = GlobalKey(debugLabel: "warp-section-key");
  static final _fragmentKey = GlobalKey(debugLabel: "fragment-section-key");

  GlobalKey get key => switch (this) {
    ConfigOptionSection.warp => _warpKey,
    ConfigOptionSection.fragment => _fragmentKey,
  };
}

class SettingsPage extends HookConsumerWidget {
  SettingsPage({super.key, String? section})
    : section = section != null ? ConfigOptionSection.values.byName(section) : null;

  final ConfigOptionSection? section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider).requireValue;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final sections = <({String title, IconData icon, String? location, VoidCallback? onTap})>[
      (
        title: t.pages.settings.general.title,
        icon: Icons.layers_rounded,
        location: context.namedLocation('general'),
        onTap: null,
      ),
      (
        title: t.pages.settings.routing.title,
        icon: Icons.route_rounded,
        location: context.namedLocation('routeOptions'),
        onTap: null,
      ),
      (
        title: t.pages.settings.dns.title,
        icon: Icons.dns_rounded,
        location: context.namedLocation('dnsOptions'),
        onTap: null,
      ),
      (
        title: t.pages.settings.inbound.title,
        icon: Icons.input_rounded,
        location: context.namedLocation('inboundOptions'),
        onTap: null,
      ),
      (
        title: t.pages.settings.tlsTricks.title,
        icon: Icons.content_cut_rounded,
        location: context.namedLocation('tlsTricks'),
        onTap: null,
      ),
      (
        title: t.pages.settings.warp.title,
        icon: Icons.cloud_rounded,
        location: context.namedLocation('warpOptions'),
        onTap: null,
      ),
      // Community replaces Logs / About — opens MK Studio Telegram
      (
        title: 'Community',
        icon: Icons.forum_rounded,
        location: null,
        onTap: () => UriUtils.tryLaunch(Uri.parse(Constants.telegramChannelUrl)),
      ),
    ];

    return Scaffold(
      backgroundColor: isDark ? theme.scaffoldBackgroundColor : MkStudioColors.surface,
      appBar: AppBar(
        title: Text(t.pages.settings.title),
        actions: [
          MenuAnchor(
            menuChildren: <Widget>[
              SubmenuButton(
                menuChildren: <Widget>[
                  MenuItemButton(
                    onPressed: () async => await ref
                        .read(dialogNotifierProvider.notifier)
                        .showConfirmation(
                          title: t.common.msg.import.confirm,
                          message: t.dialogs.confirmation.settings.import.msg,
                        )
                        .then((shouldImport) async {
                          if (shouldImport) {
                            await ref.read(configOptionNotifierProvider.notifier).importFromClipboard();
                          }
                        }),
                    child: Text(t.pages.settings.options.import.clipboard),
                  ),
                  MenuItemButton(
                    onPressed: () async => await ref
                        .read(dialogNotifierProvider.notifier)
                        .showConfirmation(
                          title: t.common.msg.import.confirm,
                          message: t.dialogs.confirmation.settings.import.msg,
                        )
                        .then((shouldImport) async {
                          if (shouldImport) {
                            await ref.read(configOptionNotifierProvider.notifier).importFromJsonFile();
                          }
                        }),
                    child: Text(t.pages.settings.options.import.file),
                  ),
                ],
                child: Text(t.common.import),
              ),
              SubmenuButton(
                menuChildren: <Widget>[
                  MenuItemButton(
                    onPressed: () async => await ref.read(configOptionNotifierProvider.notifier).exportJsonClipboard(),
                    child: Text(t.pages.settings.options.export.anonymousToClipboard),
                  ),
                  MenuItemButton(
                    onPressed: () async => await ref.read(configOptionNotifierProvider.notifier).exportJsonFile(),
                    child: Text(t.pages.settings.options.export.anonymousToFile),
                  ),
                  const PopupMenuDivider(),
                  MenuItemButton(
                    onPressed: () async => await ref
                        .read(configOptionNotifierProvider.notifier)
                        .exportJsonClipboard(excludePrivate: false),
                    child: Text(t.pages.settings.options.export.allToClipboard),
                  ),
                  MenuItemButton(
                    onPressed: () async =>
                        await ref.read(configOptionNotifierProvider.notifier).exportJsonFile(excludePrivate: false),
                    child: Text(t.pages.settings.options.export.allToFile),
                  ),
                ],
                child: Text(t.common.export),
              ),
              const PopupMenuDivider(),
              MenuItemButton(
                child: Text(t.pages.settings.options.reset),
                onPressed: () async => await ref.read(configOptionNotifierProvider.notifier).resetOption(),
              ),
            ],
            builder: (context, controller, child) => IconButton(
              onPressed: () {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
              icon: const Icon(Icons.more_vert_rounded),
            ),
          ),
          const Gap(8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: [
          const _SettingsBrandHeader(),
          const Gap(20),
          ...sections.map((s) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SettingsSection(
                title: s.title,
                icon: s.icon,
                namedLocation: s.location,
                onTap: s.onTap,
              ),
            );
          }),
          if (PlatformUtils.isIOS)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Material(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
                child: ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  title: Text(t.pages.settings.resetTunnel),
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: MkStudioColors.softTealWash,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.autorenew_rounded, color: MkStudioColors.tealDeep),
                  ),
                  onTap: () async {
                    await ref.read(resetTunnelNotifierProvider.notifier).run();
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SettingsBrandHeader extends StatelessWidget {
  const _SettingsBrandHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: isDark
            ? LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  MkStudioColors.tealDeep.withValues(alpha: 0.55),
                  MkStudioColors.teal.withValues(alpha: 0.35),
                  theme.colorScheme.surfaceContainer,
                ],
              )
            : MkStudioColors.brandGradient,
        boxShadow: [
          BoxShadow(
            color: MkStudioColors.teal.withValues(alpha: isDark ? 0.18 : 0.22),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Icon(Icons.grid_view_rounded, color: MkStudioColors.tealDeep),
            ),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MK Studio VPN',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const Gap(4),
                Text(
                  'Tune performance, routing & privacy',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsSection extends HookConsumerWidget {
  const SettingsSection({
    super.key,
    required this.title,
    required this.icon,
    this.namedLocation,
    this.onTap,
  });

  final String title;
  final IconData icon;
  final String? namedLocation;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: isDark ? theme.colorScheme.surfaceContainer : MkStudioColors.surfaceElevated,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.28)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          if (onTap != null) {
            onTap!();
          } else if (namedLocation != null) {
            context.go(namedLocation!);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            MkStudioColors.teal.withValues(alpha: 0.35),
                            MkStudioColors.lime.withValues(alpha: 0.18),
                          ]
                        : const [MkStudioColors.softLimeWash, MkStudioColors.softTealWash],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: isDark ? MkStudioColors.lime : MkStudioColors.tealDeep),
              ),
              const Gap(14),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
