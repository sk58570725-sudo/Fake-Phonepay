import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/bank_data.dart';
import '../services/sound_box.dart';
import '../services/sms_service.dart';
import 'pin_screen.dart';

const kPhonePePurple = Color(0xFF5F259F);

class SendMoneyScreen extends StatefulWidget {
  final BankAccount fromAccount;
  const SendMoneyScreen({super.key, required this.fromAccount});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  final _amtCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _loading = false;

  final _fmt = NumberFormat.currency(
      locale: 'en_IN', symbol: '₹', decimalDigits: 2);

  Future<void> _send() async {
    final amt = double.tryParse(_amtCtrl.text);
    if (amt == null || amt <= 0) {
      _snack('Enter a valid amount');
      return;
    }
    if (_nameCtrl.text.trim().isEmpty) {
      _snack('Enter receiver name');
      return;
    }

    final pinOk = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const PinScreen()),
    );
    if (pinOk != true) return;

    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));

    widget.fromAccount.balance -= amt;

    final name = _nameCtrl.text.trim();
    TransactionStore.add(Transaction(
      type: 'debit',
      amount: amt,
      name: name,
      time: DateTime.now(),
      bank: widget.fromAccount.bankName,
    ));

    await SoundBox.paymentSuccess(
      amount: amt,
      receiver: name,
      isDebit: true,
    );

    await FakeSms.send(
      bankShort: BankStore.shortCode(widget.fromAccount.bankName),
      accountLast4: BankStore.last4(widget.fromAccount.accountNumber),
      amount: amt,
      name: name,
      debit: true,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => _SuccessScreen(amount: amt, name: name, fmt: _fmt),
      ),
    );
  }

  void _snack(String s) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: kPhonePePurple,
        foregroundColor: Colors.white,
        title: const Text('Send Money'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('From: ${widget.fromAccount.bankName}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('Balance: ${_fmt.format(widget.fromAccount.balance)}',
                style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 24),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Receiver name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amtCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount (₹)',
                border: OutlineInputBorder(),
                prefixText: '₹ ',
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _send,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPhonePePurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Pay', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessScreen extends StatelessWidget {
  final double amount;
  final String name;
  final NumberFormat fmt;
  const _SuccessScreen(
      {required this.amount, required this.name, required this.fmt});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPhonePePurple,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 100),
            const SizedBox(height: 20),
            Text('${fmt.format(amount)} sent',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('to $name',
                style: const TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 40),
            TextButton(
              onPressed: () =>
                  Navigator.popUntil(context, (r) => r.isFirst),
              child: const Text('Done',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
