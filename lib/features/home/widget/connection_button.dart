import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/router/bottom_sheets/bottom_sheets_notifier.dart';
import 'package:hiddify/core/router/dialog/dialog_notifier.dart';
import 'package:hiddify/core/theme/mk_studio_colors.dart';
import 'package:hiddify/core/theme/theme_extensions.dart';
import 'package:hiddify/features/connection/model/connection_status.dart';
import 'package:hiddify/features/connection/notifier/connection_notifier.dart';
import 'package:hiddify/features/profile/notifier/active_profile_notifier.dart';
import 'package:hiddify/features/proxy/active/active_proxy_notifier.dart';
import 'package:hiddify/features/settings/data/config_option_repository.dart';
import 'package:hiddify/features/settings/notifier/config_option/config_option_notifier.dart';
import 'package:hiddify/gen/assets.gen.dart';
import 'package:hiddify/singbox/model/singbox_config_enum.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ConnectionButton extends HookConsumerWidget {
  const ConnectionButton({super.key, this.compact = false});

  /// Slightly smaller CTA for single-viewport home layout.
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider).requireValue;
    final connectionStatus = ref.watch(connectionNotifierProvider);
    final activeProxy = ref.watch(activeProxyNotifierProvider);
    final delay = activeProxy.valueOrNull?.urlTestDelay ?? 0;
    final requiresReconnect = ref.watch(configOptionNotifierProvider).valueOrNull;
    final pendingAction = useState(false);
    const buttonTheme = ConnectionButtonTheme.mkStudio;

    var secureLabel =
        (ref.watch(ConfigOptions.enableWarp) && ref.watch(ConfigOptions.warpDetourMode) == WarpDetourMode.warpOverProxy)
        ? t.connection.secure
        : "";
    if (delay <= 0 || delay > 65000 || connectionStatus.value != const Connected()) {
      secureLabel = "";
    }

    final isConnected = switch (connectionStatus) {
      AsyncData(value: Connected()) => true,
      _ => false,
    };
    final isSwitching = switch (connectionStatus) {
      AsyncData(value: Connecting()) || AsyncData(value: Disconnecting()) => true,
      _ => false,
    };
    final isBusy = pendingAction.value || isSwitching;

    Future<void> handleTap() async {
      if (pendingAction.value) return;
      pendingAction.value = true;
      try {
        if (ref.read(activeProfileProvider).valueOrNull == null &&
            connectionStatus.valueOrNull is! Connected) {
          await ref.read(dialogNotifierProvider.notifier).showNoActiveProfile();
          ref.read(bottomSheetsNotifierProvider.notifier).showAddProfile();
          return;
        }
        if (connectionStatus case AsyncData(value: Connected()) when requiresReconnect == true) {
          final activeProfile = await ref.read(activeProfileProvider.future);
          await ref.read(connectionNotifierProvider.notifier).reconnect(activeProfile);
          return;
        }
        await ref.read(connectionNotifierProvider.notifier).toggleConnection();
      } finally {
        pendingAction.value = false;
      }
    }

    return _ConnectionButton(
      onTap: handleTap,
      enabled: true,
      label: switch (connectionStatus) {
        AsyncData(value: Connected()) when requiresReconnect == true => t.connection.reconnect,
        AsyncData(value: Connecting()) => t.connection.connecting,
        AsyncData(value: Disconnecting()) => t.connection.disconnecting,
        AsyncData(value: final status) => status.present(t),
        _ => pendingAction.value ? t.connection.connecting : t.connection.tapToConnect,
      },
      buttonColor: switch (connectionStatus) {
        AsyncData(value: Connected()) when requiresReconnect == true => MkStudioColors.ocean,
        AsyncData(value: Connected()) => buttonTheme.connectedColor!,
        AsyncData(value: Connecting()) || AsyncData(value: Disconnecting()) => MkStudioColors.teal,
        AsyncData(value: _) => buttonTheme.idleColor!,
        _ => MkStudioColors.teal,
      },
      image: switch (connectionStatus) {
        AsyncData(value: Connected()) when requiresReconnect == true => Assets.images.disconnectNorouz,
        AsyncData(value: Connected()) => Assets.images.connectNorouz,
        AsyncData(value: _) => Assets.images.disconnectNorouz,
        _ => Assets.images.disconnectNorouz,
      },
      useImage: false,
      secureLabel: secureLabel,
      isConnected: isConnected,
      isBusy: isBusy,
      compact: compact,
    );
  }
}

class _ConnectionButton extends StatefulWidget {
  const _ConnectionButton({
    required this.onTap,
    required this.enabled,
    required this.label,
    required this.buttonColor,
    required this.image,
    required this.useImage,
    required this.secureLabel,
    required this.isConnected,
    required this.isBusy,
    required this.compact,
  });

  final Future<void> Function() onTap;
  final bool enabled;
  final String label;
  final Color buttonColor;
  final AssetGenImage image;
  final bool useImage;
  final String secureLabel;
  final bool isConnected;
  final bool isBusy;
  final bool compact;

  @override
  State<_ConnectionButton> createState() => _ConnectionButtonState();
}

class _ConnectionButtonState extends State<_ConnectionButton> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _syncAnimations();
  }

  @override
  void didUpdateWidget(_ConnectionButton old) {
    super.didUpdateWidget(old);
    if (old.isBusy != widget.isBusy || old.isConnected != widget.isConnected) {
      _syncAnimations();
    }
  }

  void _syncAnimations() {
    if (widget.isBusy) {
      _pulseController.repeat(reverse: true);
      _rotateController.repeat();
    } else {
      _pulseController.stop();
      _pulseController.animateTo(0, duration: const Duration(milliseconds: 300));
      _rotateController.stop();
      _rotateController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final diameter = widget.compact ? 120.0 : 148.0;
    final iconSize = widget.compact ? 48.0 : 56.0;

    final gradientColors = widget.isConnected
        ? const [MkStudioColors.lime, MkStudioColors.teal, MkStudioColors.tealDeep]
        : widget.isBusy
        ? const [MkStudioColors.teal, MkStudioColors.ocean, MkStudioColors.tealDeep]
        : const [MkStudioColors.teal, MkStudioColors.tealDeep, Color(0xFF115E59)];

    final targetIcon = widget.isConnected
        ? Icons.shield_rounded
        : Icons.power_settings_new_rounded;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Semantics(
          button: true,
          enabled: widget.enabled,
          label: widget.label,
          child: ScaleTransition(
            scale: _pulseAnimation,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
                width: diameter,
                height: diameter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: gradientColors,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.buttonColor.withValues(alpha: 0.32),
                      blurRadius: 18,
                      spreadRadius: 1,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    key: const ValueKey("home_connection_button"),
                    customBorder: const CircleBorder(),
                    onTap: () => widget.onTap(),
                    child: Center(
                      child: widget.useImage
                          ? Padding(
                              padding: EdgeInsets.all(diameter * 0.19),
                              child: widget.image.image(),
                            )
                          : widget.isBusy
                          ? RotationTransition(
                              turns: _rotateController,
                              child: Icon(
                                Icons.sync_rounded,
                                size: iconSize,
                                color: Colors.white,
                              ),
                            )
                          : AnimatedSwitcher(
                              duration: const Duration(milliseconds: 350),
                              transitionBuilder: (child, anim) => ScaleTransition(
                                scale: anim,
                                child: FadeTransition(opacity: anim, child: child),
                              ),
                              child: Icon(
                                targetIcon,
                                key: ValueKey(targetIcon),
                                size: iconSize,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        Gap(widget.compact ? 12 : 18),
        ExcludeSemantics(
          child: Column(
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: widget.isConnected
                          ? MkStudioColors.tealDeep
                          : Theme.of(context).colorScheme.onSurface,
                    ) ??
                    const TextStyle(),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.15),
                        end: Offset.zero,
                      ).animate(anim),
                      child: child,
                    ),
                  ),
                  child: Text(
                    widget.label,
                    key: ValueKey(widget.label),
                  ),
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: widget.secureLabel.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(FontAwesomeIcons.shieldHalved, size: 14, color: MkStudioColors.teal),
                            const Gap(6),
                            Text(
                              widget.secureLabel,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: MkStudioColors.teal,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
