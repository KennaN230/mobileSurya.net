import 'package:flutter/material.dart';

class TransaksiPage extends StatefulWidget {
  final String wifiName; // Nama WiFi yang dipilih dari DashboardPage
  final int wifiPrice; // Harga WiFi yang dipilih dari DashboardPage

  const TransaksiPage(
      {Key? key, required this.wifiName, required this.wifiPrice})
      : super(key: key);

  @override
  State<TransaksiPage> createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  String _selectedPaymentMethod = ''; // Metode pembayaran yang dipilih

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Transaksi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('WiFi yang dipesan: ${widget.wifiName}'),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedPaymentMethod.isEmpty
                  ? null
                  : _selectedPaymentMethod,
              onChanged: (newValue) {
                setState(() {
                  _selectedPaymentMethod = newValue!;
                });
              },
              items: <String>[
                'Bank BCA - No Rekening 125478 5874',
                'Dana - Fairozi Rohainun Najih 021478541365',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: const InputDecoration(
                labelText: 'Metode Pembayaran',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Pembayaran: Rp ${widget.wifiPrice}',
                  style: const TextStyle(fontSize: 16),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Handle submit form here
                  },
                  child: const Text('Pesan Sekarang'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
