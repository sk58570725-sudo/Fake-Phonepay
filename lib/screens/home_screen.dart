import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/bank_data.dart';
import '../services/sound_box.dart';
import '../services/sms_service.dart';
import 'send_money.dart';
import 'pin_screen.dart';

const kPhonePePurple = Color(0xFF5F259F);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _fmt =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
  int _selectedAccount = 0;

  @override
  void initState() {
    super.initState();
    SoundBox.init();
    FakeSms.init();
  }

  @override
  Widget build(BuildContext context) {
    final acc = BankStore.accounts[_selectedAccount];
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: kPhonePePurple,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      const Text('Hello,',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 13)),
                      const Spacer(),
                      IconButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const PinScreen(isSettingPin: true)),
                          );
                        },
                        icon: const Icon(Icons.settings,
                            color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(_fmt.format(BankStore.totalBalance),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold)),
                  const Text('Total balance across all accounts',
                      style:
                          TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: PageView.builder(
                controller: PageController(
                    viewportFraction: 0.9, initialPage: 0),
                itemCount: BankStore.accounts.length,
                onPageChanged: (i) =>
                    setState(() => _selectedAccount = i),
                itemBuilder: (_, i) {
                  final a = BankStore.accounts[i];
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: i == _selectedAccount
                            ? kPhonePePurple
                            : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: a.brandColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              a.bankName.substring(0, 2).toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(a.bankName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15)),
                              const SizedBox(height: 4),
                              Text(a.accountNumber,
                                  style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12)),
                              const SizedBox(height: 6),
                              Text(_fmt.format(a.balance),
                                  style: const TextStyle(
                                      color: kPhonePePurple,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _actionBtn(
                      icon: Icons.send,
                      label: 'Send',
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                SendMoneyScreen(fromAccount: acc),
                          ),
                        );
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _actionBtn(
                      icon: Icons.qr_code_scanner,
                      label: 'Scan QR',
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Recent Transactions',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(height: 10),
                    Expanded(
                      child: TransactionStore.history.isEmpty
                          ? const Center(
                              child: Text('No transactions yet',
                                  style:
                                      TextStyle(color: Colors.black45)))
                          : ListView.builder(
                              itemCount:
                                  TransactionStore.history.length,
                              itemBuilder: (_, i) {
                                final t =
                                    TransactionStore.history[i];
                                final debit = t.type == 'debit';
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: CircleAvatar(
                                    backgroundColor: debit
                                        ? Colors.red.shade50
                                        : Colors.green.shade50,
                                    child: Icon(
                                      debit
                                          ? Icons.arrow_upward
                                          : Icons.arrow_downward,
                                      color: debit
                                          ? Colors.red
                                          : Colors.green,
                                    ),
                                  ),
                                  title: Text(t.name),
                                  subtitle: Text(
                                      '${t.bank} · ${DateFormat('dd MMM, hh:mm a').format(t.time)}'),
                                  trailing: Text(
                                    '${debit ? '-' : '+'}${_fmt.format(t.amount)}',
                                    style: TextStyle(
                                      color: debit
                                          ? Colors.red
                                          : Colors.green,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: kPhonePePurple,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 6),
            Text(label,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
