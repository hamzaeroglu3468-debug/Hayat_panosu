import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../bloc/finance_bloc.dart';
import '../bloc/finance_event.dart';
import '../bloc/finance_state.dart';
import 'add_transaction_dialog.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Row(
            children: [
              Icon(Icons.account_balance_wallet_rounded, color: AppColors.success),
              SizedBox(width: 8),
              Text('Finansal Durum Kontrolü'),
            ],
          ),
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.textPrimary,
            unselectedLabelColor: AppColors.textMuted,
            tabs: [
              Tab(text: 'Özet ve Akış'),
              Tab(text: 'Planlı Ödemeler'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add_rounded),
          onPressed: () => AddTransactionDialog.show(context),
        ),
        body: BlocBuilder<FinanceBloc, FinanceState>(
          builder: (context, state) {
            if (state is FinanceLoadedState) {
              return TabBarView(
                children: [
                  // Tab 1: Summary Table & List
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Balance Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: AppColors.financeGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.success.withOpacity(0.2),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Net Bakiye',
                              style: TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              currencyFormat.format(state.netBalance),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 14,
                                      backgroundColor: Colors.white24,
                                      child: Icon(Icons.arrow_downward_rounded,
                                          size: 16, color: Colors.white),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Toplam Gelir',
                                            style: TextStyle(
                                                color: Colors.white70, fontSize: 11)),
                                        Text(
                                          currencyFormat.format(state.totalIncome),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 14,
                                      backgroundColor: Colors.white24,
                                      child: Icon(Icons.arrow_upward_rounded,
                                          size: 16, color: Colors.white),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Toplam Gider',
                                            style: TextStyle(
                                                color: Colors.white70, fontSize: 11)),
                                        Text(
                                          currencyFormat.format(state.totalExpense),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Section Title
                      const Text(
                        'Son İşlemler & Hareket Tablosu',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (state.transactions.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Text('Kayıtlı finansal hareket yok.',
                                style: TextStyle(color: AppColors.textMuted)),
                          ),
                        )
                      else
                        ...state.transactions.map((tx) {
                          final dateStr = DateFormat('dd.MM.yyyy').format(tx.date);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: tx.isIncome
                                    ? AppColors.success.withOpacity(0.15)
                                    : AppColors.danger.withOpacity(0.15),
                                child: Icon(
                                  tx.isIncome
                                      ? Icons.arrow_downward_rounded
                                      : Icons.arrow_upward_rounded,
                                  color: tx.isIncome ? AppColors.success : AppColors.danger,
                                  size: 18,
                                ),
                              ),
                              title: Text(
                                tx.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              subtitle: Text(
                                '${tx.category} • $dateStr',
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.textMuted),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${tx.isIncome ? '+' : '-'}${currencyFormat.format(tx.amount)}',
                                    style: TextStyle(
                                      color: tx.isIncome
                                          ? AppColors.success
                                          : AppColors.danger,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        size: 18, color: AppColors.textMuted),
                                    onPressed: () {
                                      context
                                          .read<FinanceBloc>()
                                          .add(DeleteTransactionEvent(tx.id));
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                    ],
                  ),

                  // Tab 2: Planned / Recurring Payments
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.event_repeat_rounded,
                                color: AppColors.primary, size: 28),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Aylık ve haftalık düzenli planlanan ödemelerinizi bu listeden takip edebilirsiniz.',
                                style: TextStyle(
                                    color: AppColors.textSecondary, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (state.recurringPayments.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text(
                              'Planlı ödeme kaydı bulunmuyor.',
                              style: TextStyle(color: AppColors.textMuted),
                            ),
                          ),
                        )
                      else
                        ...state.recurringPayments.map((tx) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  tx.recurringType ?? 'Planlı',
                                  style: const TextStyle(
                                    color: AppColors.primaryLight,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(tx.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary)),
                              subtitle: Text('Kategori: ${tx.category}'),
                              trailing: Text(
                                currencyFormat.format(tx.amount),
                                style: const TextStyle(
                                  color: AppColors.danger,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ],
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
