import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/transaction_model.dart';
import '../utils/constants.dart';
import 'add_edit_transaction_screen.dart';

class TransactionDetailsScreen extends StatefulWidget {
  final int id;

  const TransactionDetailsScreen({super.key, required this.id});

  @override
  State<TransactionDetailsScreen> createState() =>
      _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  TransactionModel? _transaction;
  bool _loading = true;
  bool _changed = false; // tells previous screen to refresh

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final t = await DatabaseHelper.instance.getTransactionById(widget.id);
    if (!mounted) return;
    setState(() {
      _transaction = t;
      _loading = false;
    });
  }

  Future<void> _edit() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditTransactionScreen(transaction: _transaction),
      ),
    );
    if (updated == true) {
      _changed = true;
      _load();
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text(
            'Are you sure you want to delete this transaction? '
            'This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: expenseColor),
              child: const Text('Delete')),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deleteTransaction(widget.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction deleted')),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = _transaction;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) Navigator.pop(context, _changed);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Transaction Details'),
          actions: [
            if (t != null) ...[
              IconButton(
                  onPressed: _edit,
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit'),
              IconButton(
                  onPressed: _delete,
                  icon: const Icon(Icons.delete),
                  tooltip: 'Delete'),
            ],
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : t == null
                ? const Center(child: Text('Transaction not found'))
                : _buildBody(t),
      ),
    );
  }

  Widget _buildBody(TransactionModel t) {
    final color = t.isIncome ? incomeColor : expenseColor;
    final sign = t.isIncome ? '+' : '-';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: Color.alphaBlend(color.withOpacity(0.12), navyCard),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: color.withOpacity(0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 28),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: color.withOpacity(0.2),
                  child: Icon(
                    t.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                    color: color,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 14),
                Text('$sign${formatMoney(t.amount)}',
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: color)),
                const SizedBox(height: 4),
                Text(t.type, style: TextStyle(color: color, fontSize: 16)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              _row(Icons.title, 'Title', t.title),
              const Divider(height: 1),
              _row(Icons.category, 'Category', t.category),
              const Divider(height: 1),
              _row(Icons.swap_vert, 'Type', t.type),
              const Divider(height: 1),
              _row(Icons.calendar_today, 'Date', formatDate(t.date)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _edit,
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: const BorderSide(color: primaryColor),
                ),
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: _delete,
                style: FilledButton.styleFrom(backgroundColor: expenseColor),
                icon: const Icon(Icons.delete),
                label: const Text('Delete'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label,
          style: const TextStyle(fontSize: 12, color: textSecondary)),
      subtitle: Text(value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
    );
  }
}
