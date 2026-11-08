import 'package:flutter/material.dart';

import '../models/transaction_model.dart';
import '../utils/constants.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback onTap;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = transaction.isIncome ? incomeColor : expenseColor;
    final sign = transaction.isIncome ? '+' : '-';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      color: Color.alphaBlend(color.withOpacity(0.12), navyCard),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.18),
          child: Icon(
            transaction.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: color,
          ),
        ),
        title: Text(transaction.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600, color: textPrimary)),
        subtitle: Text('${transaction.category} • ${formatDate(transaction.date)}',
            style: const TextStyle(color: textSecondary)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('$sign${formatMoney(transaction.amount)}',
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 15)),
            Text(transaction.type,
                style: const TextStyle(color: textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
