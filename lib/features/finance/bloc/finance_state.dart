import 'package:equatable/equatable.dart';
import '../models/transaction_model.dart';

abstract class FinanceState extends Equatable {
  const FinanceState();

  @override
  List<Object?> get props => [];
}

class FinanceInitialState extends FinanceState {}

class FinanceLoadingState extends FinanceState {}

class FinanceLoadedState extends FinanceState {
  final List<TransactionModel> transactions;

  const FinanceLoadedState(this.transactions);

  double get totalIncome => transactions
      .where((t) => t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense => transactions
      .where((t) => !t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get netBalance => totalIncome - totalExpense;

  List<TransactionModel> get recurringPayments =>
      transactions.where((t) => t.isRecurring).toList();

  @override
  List<Object?> get props => [transactions];
}

class FinanceErrorState extends FinanceState {
  final String message;
  const FinanceErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
