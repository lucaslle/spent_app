import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Theme/app_button.dart';
import '../Theme/app_colors.dart';
import '../Theme/app_text.dart';
import '../Theme/ecu_logo.dart';
import 'app_lock_cubit.dart';

class AppLockGate extends StatefulWidget {
  const AppLockGate({super.key, required this.child});

  final Widget child;

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cubit = context.read<AppLockCubit>();
    switch (state) {
      case AppLifecycleState.paused || AppLifecycleState.hidden:
        cubit.onBackgrounded();
      case AppLifecycleState.resumed:
        cubit.onResumed();
      case AppLifecycleState.inactive || AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lock = context.watch<AppLockCubit>().state;
    final covered = !lock.ready || lock.locked;
    return Stack(children: [
      widget.child,
      if (covered)
        Positioned.fill(
          child: Container(
            color: AppColors.bg,
            alignment: Alignment.center,
            child: !lock.ready
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const EcuLogo(size: 72),
                      const SizedBox(height: 16),
                      const AppText('écu', size: 26, mono: true),
                      const SizedBox(height: 6),
                      const AppText('Application verrouillée', size: 13, weight: FontWeight.w500, color: AppColors.muted),
                      const SizedBox(height: 28),
                      AppButton(label: 'Déverrouiller', onPressed: lock.busy ? null : context.read<AppLockCubit>().unlock),
                    ]),
                  ),
          ),
        ),
    ]);
  }
}
