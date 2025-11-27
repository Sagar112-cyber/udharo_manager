// lib/Screens/stockdetials.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class Stockdetials extends StatefulWidget {
  final String stockId; // Stock ID passed from StockScreen
  const Stockdetials({super.key, required this.stockId});

  @override
  State<Stockdetials> createState() => _StockdetialsState();
}

class _StockdetialsState extends State<Stockdetials> {
  late DatabaseReference stockRef;
  DatabaseReference?
  historyRef; // Make it nullable to prevent LateInitializationError

  @override
  void initState() {
    super.initState();
    stockRef = FirebaseDatabase.instance
        .ref()
        .child('Total iteam stock')
        .child(widget.stockId);

    // Initialize historyRef safely
    historyRef = stockRef.child('history');
  }

  @override
  Widget build(BuildContext context) {
    if (historyRef == null) {
      // Show loading if references are not ready
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Stock Details"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: stockRef.onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("Stock not found"));
          }

          Map stock = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

          String name = stock['iteam']?.toString() ?? 'No Name';
          String purchase = stock['purchase']?.toString() ?? '0';
          String sell = stock['sell']?.toString() ?? '0';
          int remaining =
              int.tryParse(stock['remaining']?.toString() ?? '0') ?? 0;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stock Info Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.blueAccent, Colors.lightBlue],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Purchase Rate: $purchase",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Sell Rate: $sell",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Remaining Stock: $remaining",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Stock History",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),

                // Stock History List
                Expanded(
                  child: StreamBuilder<DatabaseEvent>(
                    stream: historyRef!.onValue,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      var raw = snapshot.data!.snapshot.value;

                      if (raw == null || raw is! Map) {
                        return const Center(
                          child: Text(
                            "No history yet",
                            style: TextStyle(color: Colors.black54),
                          ),
                        );
                      }

                      Map<dynamic, dynamic> historyMap =
                          Map<dynamic, dynamic>.from(raw);

                      List historyList = historyMap.values.toList();

                      // Sort newest first
                      historyList.sort(
                        (a, b) => b['timestamp'].compareTo(a['timestamp']),
                      );

                      return ListView.builder(
                        itemCount: historyList.length,
                        itemBuilder: (context, index) {
                          var item = historyList[index];
                          bool isAdd = item['type'] == "Added";

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 4,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isAdd
                                    ? Colors.green
                                    : Colors.red,
                                child: Icon(
                                  isAdd ? Icons.add : Icons.remove,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                "${item['type']} ${item['amount']}",
                                style: TextStyle(
                                  color: isAdd ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                "${item['date']}  |  ${item['time']}",
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton(
              heroTag: "minusStock",
              backgroundColor: Colors.redAccent,
              onPressed: () => _updateStock(isAdd: false),
              child: const Icon(Icons.remove, size: 28),
            ),
            FloatingActionButton(
              heroTag: "addStock",
              backgroundColor: Colors.green,
              onPressed: () => _updateStock(isAdd: true),
              child: const Icon(Icons.add, size: 28),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // ********** Update Stock with History safely **********
  void _updateStock({required bool isAdd}) {
    if (historyRef == null) return; // safety check

    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isAdd ? "Add Stock" : "Subtract Stock"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: isAdd
                  ? "Enter amount to add"
                  : "Enter amount to subtract",
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                int value = int.tryParse(controller.text.trim()) ?? 0;
                if (value <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Enter a valid number")),
                  );
                  return;
                }

                DatabaseEvent event = await stockRef.once();
                int current =
                    int.tryParse(
                      event.snapshot.child("remaining").value.toString(),
                    ) ??
                    0;

                int newRemaining = isAdd ? current + value : current - value;

                if (newRemaining < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Stock cannot be negative")),
                  );
                  return;
                }

                await stockRef.update({"remaining": newRemaining.toString()});

                // Add history entry
                String date =
                    "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}";
                String time =
                    "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}";
                int timestamp = DateTime.now().millisecondsSinceEpoch;

                await historyRef!.push().set({
                  "type": isAdd ? "Added" : "Subtracted",
                  "amount": value.toString(),
                  "date": date,
                  "time": time,
                  "timestamp": timestamp,
                });

                Navigator.pop(context);
              },
              child: Text(
                isAdd ? "Add" : "Subtract",
                style: TextStyle(color: isAdd ? Colors.green : Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
