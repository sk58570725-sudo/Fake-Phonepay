import 'package:flutter/material.dart';

class BankAccount {
  final String bankName;
  final String accountNumber;
  final String ifsc;
  double balance;
  final Color brandColor;

  BankAccount({
    required this.bankName,
    required this.accountNumber,
    required this.ifsc,
    required this.balance,
    required this.brandColor,
  });
}

class BankStore {
  static List<BankAccount> accounts = [
    BankAccount(
      bankName: 'State Bank of India',
      accountNumber: 'XXXX XXXX 4821',
      ifsc: 'SBIN0001234',
      balance: 1248500.75,
      brandColor: const Color(0xFF22409A),
    ),
    BankAccount(
      bankName: 'HDFC Bank',
      accountNumber: 'XXXX XXXX 9037',
      ifsc: 'HDFC0000567',
      balance: 862340.20,
      brandColor: const Color(0xFF004C8F),
    ),
    BankAccount(
      bankName: 'ICICI Bank',
      accountNumber: 'XXXX XXXX 2210',
      ifsc: 'ICIC0000789',
      balance: 2145780.50,
      brandColor: const Color(0xFFF58220),
    ),
    BankAccount(
      bankName: 'Axis Bank',
      accountNumber: 'XXXX XXXX 6642',
      ifsc: 'UTIB0000234',
      balance: 945120.00,
      brandColor: const Color(0xFF97144D),
    ),
    BankAccount(
      bankName: 'Punjab National Bank',
      accountNumber: 'XXXX XXXX 1189',
      ifsc: 'PUNB0000456',
      balance: 432890.30,
      brandColor: const Color(0xFFA11E22),
    ),
    BankAccount(
      bankName: 'Kotak Mahindra Bank',
      accountNumber: 'XXXX XXXX 5573',
      ifsc: 'KKBK0000789',
      balance: 1589200.00,
      brandColor: const Color(0xFFED1C24),
    ),
    BankAccount(
      bankName: 'Bank of Baroda',
      accountNumber: 'XXXX XXXX 8826',
      ifsc: 'BARB0KOTHAR',
      balance: 678450.90,
      brandColor: const Color(0xFFF15A22),
    ),
    BankAccount(
      bankName: 'Yes Bank',
      accountNumber: 'XXXX XXXX 3394',
      ifsc: 'YESB0000123',
      balance: 1103750.45,
      brandColor: const Color(0xFF00518F),
    ),
  ];

  static double get totalBalance =>
      accounts.fold(0.0, (sum, a) => sum + a.balance);

  static String shortCode(String bankName) {
    if (bankName.contains('State Bank')) return 'SBI';
    if (bankName.contains('HDFC')) return 'HDFC';
    if (bankName.contains('ICICI')) return 'ICICI';
    if (bankName.contains('Axis')) return 'AXIS';
    if (bankName.contains('Punjab')) return 'PNB';
    if (bankName.contains('Kotak')) return 'KOTAK';
    if (bankName.contains('Baroda')) return 'BOB';
    if (bankName.contains('Yes')) return 'YES';
    return 'BANK';
  }

  static String last4(String accNum) {
    final digits = accNum.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.length >= 4 ? digits.substring(digits.length - 4) : digits;
  }
}

class Transaction {
  final String type;
  final double amount;
  final String name;
  final DateTime time;
  final String bank;

  Transaction({
    required this.type,
    required this.amount,
    required this.name,
    required this.time,
    required this.bank,
  });
}

class TransactionStore {
  static List<Transaction> history = [];
  static void add(Transaction t) => history.insert(0, t);
}
