import 'package:flutter_bloc/flutter_bloc.dart';

enum AppTab { today, transactions, budget, analysis, settings }

class AppTabCubit extends Cubit<AppTab> {
  AppTabCubit() : super(AppTab.today);

  void select(AppTab tab) => emit(tab);
}
