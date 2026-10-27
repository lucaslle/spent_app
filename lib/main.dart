import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app_shell.dart';
import 'app/app_tab_cubit.dart';
import 'layers/functional/Savings/data/shared_prefs_accounts_gateway.dart';
import 'layers/functional/Savings/presentation/cubit/accounts_cubit.dart';
import 'layers/functional/Spending/data/shared_prefs_spending_gateway.dart';
import 'layers/functional/Spending/presentation/cubit/spending_cubit.dart';
import 'layers/functional/Spending/presentation/cubit/spending_view_cubit.dart';
import 'layers/technical/Formatting/amount_privacy_cubit.dart';
import 'layers/technical/Security/app_lock_cubit.dart';
import 'layers/technical/Security/app_lock_gate.dart';
import 'layers/technical/Security/device_authenticator.dart';
import 'layers/technical/Theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarBrightness: Brightness.dark, statusBarIconBrightness: Brightness.light, statusBarColor: Colors.transparent));
  final prefs = await SharedPreferences.getInstance();
  runApp(EcuApp(prefs: prefs, authenticator: LocalAuthDeviceAuthenticator()));
}

class EcuApp extends StatelessWidget {
  const EcuApp({super.key, required this.prefs, required this.authenticator});

  final SharedPreferences prefs;
  final DeviceAuthenticator authenticator;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AmountPrivacyCubit(prefs)),
        BlocProvider(create: (_) => SpendingCubit(SharedPrefsSpendingGateway(prefs))..load()),
        BlocProvider(create: (_) => AccountsCubit(SharedPrefsAccountsGateway(prefs))..load()),
        BlocProvider(create: (_) => SpendingViewCubit()),
        BlocProvider(create: (_) => AppTabCubit()),
        BlocProvider(create: (_) => AppLockCubit(prefs, authenticator)..init()),
      ],
      child: MaterialApp(
        title: 'écu',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        builder: (context, child) => AppLockGate(child: child ?? const SizedBox.shrink()),
        home: const AppShell(),
      ),
    );
  }
}
