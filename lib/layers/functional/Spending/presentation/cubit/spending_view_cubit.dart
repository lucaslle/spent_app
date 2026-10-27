import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/spend_category.dart';

class SpendingViewState extends Equatable {
  const SpendingViewState({this.filter = 'all', this.search = '', this.donutSelection, this.monthsRange = 12});

  final String filter;
  final String search;
  final SpendCategory? donutSelection;
  final int monthsRange;

  SpendingViewState copyWith({String? filter, String? search, SpendCategory? donutSelection, bool clearDonut = false, int? monthsRange}) => SpendingViewState(
        filter: filter ?? this.filter,
        search: search ?? this.search,
        donutSelection: clearDonut ? null : (donutSelection ?? this.donutSelection),
        monthsRange: monthsRange ?? this.monthsRange,
      );

  @override
  List<Object?> get props => [filter, search, donutSelection, monthsRange];
}

class SpendingViewCubit extends Cubit<SpendingViewState> {
  SpendingViewCubit() : super(const SpendingViewState());

  void setFilter(String filter) => emit(state.copyWith(filter: filter, search: ''));
  void setSearch(String search) => emit(state.copyWith(search: search));
  void toggleDonut(SpendCategory c) => emit(state.donutSelection == c ? state.copyWith(clearDonut: true) : state.copyWith(donutSelection: c));
  void setMonthsRange(int months) => emit(state.copyWith(monthsRange: months));
  void clearDonut() => emit(state.copyWith(clearDonut: true));
}
