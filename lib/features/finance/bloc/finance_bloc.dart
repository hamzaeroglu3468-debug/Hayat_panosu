import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/database/hive_service.dart';
import 'finance_event.dart';
import 'finance_state.dart';

class FinanceBloc extends Bloc<FinanceEvent, FinanceState> {
  FinanceBloc() : super(FinanceInitialState()) {
    on<LoadFinanceEvent>(_onLoadFinance);
    on<AddTransactionEvent>(_onAddTransaction);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
  }

  void _onLoadFinance(LoadFinanceEvent event, Emitter<FinanceState> emit) {
    try {
      emit(FinanceLoadingState());
      final transactions = HiveService.getTransactions();
      emit(FinanceLoadedState(transactions));
    } catch (e) {
      emit(FinanceErrorState(e.toString()));
    }
  }

  Future<void> _onAddTransaction(
      AddTransactionEvent event, Emitter<FinanceState> emit) async {
    try {
      await HiveService.saveTransaction(event.transaction);
      emit(FinanceLoadedState(HiveService.getTransactions()));
    } catch (e) {
      emit(FinanceErrorState(e.toString()));
    }
  }

  Future<void> _onDeleteTransaction(
      DeleteTransactionEvent event, Emitter<FinanceState> emit) async {
    try {
      await HiveService.deleteTransaction(event.transactionId);
      emit(FinanceLoadedState(HiveService.getTransactions()));
    } catch (e) {
      emit(FinanceErrorState(e.toString()));
    }
  }
}
