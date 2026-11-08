import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const String currencySymbol = '\$'; // change to any symbol you like

const String typeIncome = 'Income';
const String typeExpense = 'Expense';

const List<String> categories = [
  'Food',
  'Transport',
  'Shopping',
  'Bills',
  'Health',
  'Entertainment',
  'Salary',
  'Freelance',
  'Gift',
  'Other',
];

const Color incomeColor = Color(0xFF4ADE80);
const Color expenseColor = Color(0xFFF87171);
const Color warningColor = Color(0xFFFBBF24);
const Color primaryColor = Color(0xFF38BDF8);
const Color navyBackground = Color(0xFF002942);
const Color navyCard = Color(0xFF0A3552);
const Color inputFill = Color(0xFF0F3E5E);
const Color navyBorder = Color(0xFF1E5075);
const Color textPrimary = Color(0xFFF1F5F9);
const Color textSecondary = Color(0xFF8FB0C7);

Color balanceColor(double balance, double income) {
  if (balance < 0) return expenseColor;
  if (income > 0 && balance < income * 0.2) return warningColor;
  return incomeColor;
}

String formatMoney(double value) =>
    '$currencySymbol${NumberFormat('#,##0.00').format(value)}';

String formatDate(DateTime date) => DateFormat('dd MMM yyyy').format(date);
