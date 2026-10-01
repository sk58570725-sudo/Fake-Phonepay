import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const kPhonePePurple = Color(0xFF5F259F);

class PinScreen extends StatefulWidget {
  final bool isSettingPin;
  const PinScreen({super.key, this.isSettingPin = false});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  String _entered = '';
  String? _firstPin;
  String _title = '';

  @override
  void initState() {
    super.initState();
    _title = widget.isSettingPin ? 'Set your UPI PIN' : 'Enter UPI PIN';
  }

  Future<void> _savePin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('upi_pin', pin);
  }

  Future<String?> _getPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('upi_pin');
  }

  void _onDigit(String d) {
    if (_entered.length >= 4) return;
    setState(() => _entered += d);
    if (_entered.length == 4) _submit();
  }

  void _onBack() {
    if (_entered.isEmpty) return;
    setState(() => _entered = _entered.substring(0, _entered.length - 1));
  }

  Future<void> _submit() async {
    if (widget.isSettingPin) {
      if (_firstPin == null) {
        _firstPin = _entered;
        setState(() {
          _entered = '';
          _title = 'Confirm your UPI PIN';
        });
        return;
      }
      if (_firstPin == _entered) {
        await _savePin(_entered);
        if (mounted) Navigator.pop(context, true);
      } else {
        setState(() {
          _firstPin = null;
          _entered = '';
          _title = 'Set your UPI PIN';
        });
        _snack('PINs did not match. Try again.');
      }
      return;
    }

    final saved = await _getPin();
    if (saved == _entered) {
      if (mounted) Navigator.pop(context, true);
    } else {
      setState(() => _entered = '');
      _snack('Incorrect PIN');
    }
  }

  void _snack(String s) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: kPhonePePurple,
        foregroundColor: Colors.white,
        title: const Text('PhonePe'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Text(_title,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final filled = i < _entered.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled ? kPhonePePurple : Colors.transparent,
                    border: Border.all(color: kPhonePePurple, width: 2),
                  ),
                );
              }),
            ),
            const Spacer(),
            _keypad(),
          ],
        ),
      ),
    );
  }

  Widget _keypad() {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '⌫'],
    ];
    return Column(
      children: keys.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: row.map((k) {
            if (k.isEmpty) return const SizedBox(width: 70, height: 70);
            return InkWell(
              onTap: () => k == '⌫' ? _onBack() : _onDigit(k),
              borderRadius: BorderRadius.circular(50),
              child: Container(
                width: 70,
                height: 70,
                alignment: Alignment.center,
                child: Text(k,
                    style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.w500)),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
