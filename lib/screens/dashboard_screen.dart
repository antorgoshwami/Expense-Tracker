import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/transaction_model.dart';
import '../utils/constants.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_tile.dart';
import 'add_edit_transaction_screen.dart';
import 'transaction_details_screen.dart';
import 'transaction_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<TransactionModel> _transactions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await DatabaseHelper.instance.getAllTransactions();
    if (!mounted) return;
    setState(() {
      _transactions = data;
      _loading = false;
    });
  }

  double get _totalIncome => _transactions
      .where((t) => t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get _totalExpense => _transactions
      .where((t) => !t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get _balance => _totalIncome - _totalExpense;

  Future<void> _openAdd() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddEditTransactionScreen()),
    );
    if (changed == true) _loadData();
  }

  Future<void> _openDetails(TransactionModel t) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => TransactionDetailsScreen(id: t.id!)),
    );
    if (changed == true) _loadData();
  }

  Future<void> _openAll() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TransactionListScreen()),
    );
    _loadData(); // list screen may have changed data
  }

  @override
  Widget build(BuildContext context) {
    final recent = _transactions.take(5).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Expense Tracker',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAdd,
        tooltip: 'Add transaction',
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 90),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: SummaryCard(
                            label: 'Total Income',
                            value: formatMoney(_totalIncome),
                            icon: Icons.trending_up,
                            color: incomeColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SummaryCard(
                            label: 'Total Expense',
                            value: formatMoney(_totalExpense),
                            icon: Icons.trending_down,
                            color: expenseColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SummaryCard(
                            label: 'Current Balance',
                            value: formatMoney(_balance),
                            icon: Icons.account_balance_wallet,
                            color: balanceColor(_balance, _totalIncome),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Recent Transactions',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        TextButton(
                            onPressed: _openAll, child: const Text('View All')),
                      ],
                    ),
                  ),
                  if (recent.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child: Text(
                          'No transactions yet.\nTap + to add your first one.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recent.length,
                      itemBuilder: (context, i) => TransactionTile(
                        transaction: recent[i],
                        onTap: () => _openDetails(recent[i]),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
