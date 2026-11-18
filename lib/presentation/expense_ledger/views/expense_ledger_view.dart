import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../currency/views/currency_cheat_sheet_view.dart';
import '../../itinerary/controllers/itinerary_controller.dart';
import '../controllers/expense_ledger_controller.dart';
import 'widgets/add_expense_sheet.dart';
import 'widgets/expense_charts.dart';

class ExpenseLedgerView extends StatelessWidget {
  const ExpenseLedgerView({super.key});

  void _showAddExpense(BuildContext context, String tripId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddExpenseSheet(tripId: tripId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expenseCtrl = Get.find<ExpenseLedgerController>();
    final itineraryCtrl = Get.find<ItineraryController>();
    final colorScheme = Theme.of(context).colorScheme;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    if (itineraryCtrl.activeTrip.value != null &&
        expenseCtrl.activeTrip.value?.id !=
            itineraryCtrl.activeTrip.value!.id) {
      expenseCtrl.setActiveTrip(itineraryCtrl.activeTrip.value!);
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_expense_log',
        onPressed: () {
          final tripId = itineraryCtrl.activeTrip.value?.id ?? 'trip_hunza_7d';
          _showAddExpense(context, tripId);
        },
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        icon: const Icon(Icons.add, size: 20),
        label: const Text(
          'Log Expense',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Obx(() {
        if (expenseCtrl.isLoading.value && expenseCtrl.expenses.isEmpty) {
          return Center(
            child: CircularProgressIndicator(color: colorScheme.primary),
          );
        }

        final currency = expenseCtrl.selectedCurrency.value;
        final symbol = CurrencyFormatter.getSymbol(currency);
        final totalBudget = expenseCtrl.totalBudgetSelectedCurrency;
        final totalSpent = expenseCtrl.totalSpentSelectedCurrency;
        final remaining = expenseCtrl.remainingBudgetSelectedCurrency;
        final dailyAllowance = expenseCtrl.dailyAllowanceSelectedCurrency;

        final cockpitWidget = _buildBudgetCockpit(
          context,
          expenseCtrl,
          colorScheme,
          currency,
          symbol,
          totalBudget,
          totalSpent,
          remaining,
          dailyAllowance,
        );

        final chartsWidget = ExpenseCharts(
          categoryBreakdown: expenseCtrl.categoryBreakdown,
          currencySymbol: symbol,
        );

        final transactionsWidget = _buildTransactionsList(
          expenseCtrl,
          colorScheme,
          symbol,
        );

        if (isLandscape) {
          return Row(
            children: [
              SizedBox(
                width: 340,
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Column(
                    children: [
                      cockpitWidget,
                      const SizedBox(height: 12),
                      chartsWidget,
                    ],
                  ),
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EXPEDITION TRANSACTIONS (${expenseCtrl.expenses.length})',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      transactionsWidget,
                      const SizedBox(height: 72),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              cockpitWidget,
              const SizedBox(height: 16),
              chartsWidget,
              const SizedBox(height: 16),
              Text(
                'TRANSACTION HISTORY',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 10),
              transactionsWidget,
              const SizedBox(height: 80),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildBudgetCockpit(
    BuildContext context,
    ExpenseLedgerController ctrl,
    ColorScheme colorScheme,
    String currency,
    String symbol,
    double totalBudget,
    double totalSpent,
    double remaining,
    double dailyAllowance,
  ) {
    final burnPercent = totalBudget > 0
        ? (totalSpent / totalBudget).clamp(0.0, 1.0)
        : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'EXPEDITION FINANCIAL COCKPIT',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.currency_exchange,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  tooltip: 'Currency & Tip Cheat-Sheet',
                  onPressed: () => Get.to(() => const CurrencyCheatSheetView()),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: currency,
                    dropdownColor: colorScheme.surfaceContainerHighest,
                    items: AppConstants.supportedCurrencies.map((c) {
                      return DropdownMenuItem(
                        value: c,
                        child: Text(
                          c,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.primary,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) ctrl.setCurrency(val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildCockpitStat(
                    'TOTAL BUDGET',
                    '$symbol${totalBudget.toStringAsFixed(0)}',
                    colorScheme.onSurface,
                  ),
                ),
                Expanded(
                  child: _buildCockpitStat(
                    'TOTAL SPENT',
                    '$symbol${totalSpent.toStringAsFixed(0)}',
                    colorScheme.secondary,
                  ),
                ),
                Expanded(
                  child: _buildCockpitStat(
                    'REMAINING',
                    '$symbol${remaining.toStringAsFixed(0)}',
                    remaining >= 0 ? colorScheme.primary : colorScheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: burnPercent,
                minHeight: 8,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(
                  burnPercent > 0.9 ? colorScheme.error : colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Daily Allowance: $symbol${dailyAllowance.toStringAsFixed(0)} / day',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCockpitStat(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 8.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsList(
    ExpenseLedgerController ctrl,
    ColorScheme colorScheme,
    String symbol,
  ) {
    if (ctrl.expenses.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36),
        child: Column(
          children: [
            Icon(Icons.receipt_long, size: 36, color: colorScheme.outline),
            const SizedBox(height: 8),
            Text(
              'No expenses logged for this expedition.',
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: ctrl.expenses.map((expense) {
        final amountInSelected = CurrencyFormatter.convert(
          amount: expense.amountUsd,
          fromCurrency: 'USD',
          toCurrency: ctrl.selectedCurrency.value,
        );

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 4,
            ),
            leading: CircleAvatar(
              backgroundColor: colorScheme.surfaceContainerHighest,
              child: Icon(
                _getCategoryIcon(expense.category),
                size: 18,
                color: colorScheme.primary,
              ),
            ),
            title: Text(
              expense.title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            subtitle: Text(
              '${expense.category} • ${expense.splitCount > 1 ? "Split with ${expense.splitCount}" : "Solo"} • Orig: ${expense.currencyCode} ${expense.originalAmount.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$symbol${amountInSelected.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.secondary,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: colorScheme.outline,
                  ),
                  onPressed: () => ctrl.deleteExpense(expense.id),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Flights':
        return Icons.flight;
      case 'Stays':
        return Icons.hotel;
      case 'Food':
        return Icons.restaurant;
      case 'Transport':
        return Icons.directions_car;
      case 'Gear':
        return Icons.backpack;
      default:
        return Icons.shopping_bag;
    }
  }
}
