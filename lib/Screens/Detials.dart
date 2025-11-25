// lib/Screens/customer_details_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class CustomerDetailsPage extends StatefulWidget {
  final String customerId;

  const CustomerDetailsPage({super.key, required this.customerId});

  @override
  _CustomerDetailsPageState createState() => _CustomerDetailsPageState();
}

class _CustomerDetailsPageState extends State<CustomerDetailsPage> {
  late DatabaseReference customerRef;
  late DatabaseReference historyRef;

  @override
  void initState() {
    super.initState();
    customerRef = FirebaseDatabase.instance
        .ref()
        .child('customers')
        .child(widget.customerId);

    historyRef = customerRef.child('history');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Customer Details"),
        elevation: 0,
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: customerRef.onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("Customer not found"));
          }

          Map customer =
          snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

          return Column(
            children: [
              // 🌟 Customer Summary Card
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.deepPurple, Colors.purpleAccent],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer['name']?.toString() ?? 'No Name',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.phone, color: Colors.white70),
                        const SizedBox(width: 6),
                        Text(
                          customer['phone']?.toString() ?? '-',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      "Remaining Udharo: Rs. ${customer['amount']?.toString() ?? '0'}",
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Transaction History",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // 🌟 Transaction History List
              Expanded(
                child: StreamBuilder<DatabaseEvent>(
                  stream: historyRef.onValue,
                  builder: (context, snapshot2) {
                    if (!snapshot2.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    var raw = snapshot2.data!.snapshot.value;

                    if (raw == null || raw is! Map) {
                      return const Center(child: Text("No history yet"));
                    }

                    Map<dynamic, dynamic> historyMap =
                    Map<dynamic, dynamic>.from(raw);

                    List historyList = historyMap.values.toList();

                    // Sort newest first
                    historyList.sort((a, b) {
                      final dateA = a['date']?.toString() ?? '';
                      final dateB = b['date']?.toString() ?? '';
                      return dateB.compareTo(dateA);
                    });

                    return ListView.builder(
                      itemCount: historyList.length,
                      itemBuilder: (context, index) {
                        var item = historyList[index];
                        bool isPayment =
                            (item['type']?.toString() ?? '') == "Payment Received";

                        return Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 5,
                              )
                            ],
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                              isPayment ? Colors.green : Colors.red,
                              child: Icon(
                                isPayment
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              item['type']?.toString() ?? '-',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isPayment ? Colors.green : Colors.red,
                              ),
                            ),
                            subtitle: Text(
                              "Rs. ${item['amount']?.toString() ?? '0'}\n${item['date']?.toString() ?? '-'} - ${item['time']?.toString() ?? '-'}",
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),

      // 🌟 Floating Action Buttons
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "addUdharo",
            backgroundColor: Colors.redAccent,
            child: const Icon(Icons.add),
            onPressed: () {
              _addUdharoDialog(context);
            },
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "payIn",
            backgroundColor: Colors.green,
            child: const Icon(Icons.payment),
            onPressed: () {
              _payInDialog(context);
            },
          ),
        ],
      ),
    );
  }

  // 🌟 Add Udharo
  void _addUdharoDialog(BuildContext context) {
    TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Udharo"),
          content: TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: "Enter amount",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
                child: const Text("Cancel"),
                onPressed: () => Navigator.pop(context)),
            TextButton(
              child: const Text("Add", style: TextStyle(color: Colors.blue)),
              onPressed: () async {
                double amount =
                    double.tryParse(amountController.text.trim()) ?? 0;

                DatabaseEvent event = await customerRef.once();
                final oldAmountStr =
                    event.snapshot.child("amount").value?.toString() ?? "0";
                double oldAmount = double.tryParse(oldAmountStr) ?? 0;
                double newAmount = oldAmount + amount;

                await customerRef.update({"amount": newAmount.toString()});

                String date =
                    "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}";
                String time =
                    "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}";

                await historyRef.push().set({
                  "type": "Udharo Added",
                  "amount": amount.toString(),
                  "date": date,
                  "time": time,
                });

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // 🌟 Pay In
  void _payInDialog(BuildContext context) {
    TextEditingController payController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Pay In"),
          content: TextField(
            controller: payController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: "Enter Pay Amount",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
                child: const Text("Cancel"),
                onPressed: () => Navigator.pop(context)),
            TextButton(
              child: const Text("Pay", style: TextStyle(color: Colors.green)),
              onPressed: () async {
                double payAmount =
                    double.tryParse(payController.text.trim()) ?? 0;

                DatabaseEvent event = await customerRef.once();
                final oldAmountStr =
                    event.snapshot.child("amount").value?.toString() ?? "0";
                double oldAmount = double.tryParse(oldAmountStr) ?? 0;

                if (payAmount > oldAmount) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Amount exceeds udharo")),
                  );
                  return;
                }

                double newAmount = oldAmount - payAmount;

                await customerRef.update({"amount": newAmount.toString()});

                String date =
                    "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}";
                String time =
                    "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}";

                await historyRef.push().set({
                  "type": "Payment Received",
                  "amount": payAmount.toString(),
                  "date": date,
                  "time": time,
                });

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
