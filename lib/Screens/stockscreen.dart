// lib/Screens/stockscreen.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:udharo_manager/Screens/addstock.dart';
import 'package:udharo_manager/Screens/stockdetials.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  bool _issearching=false;
  String _searchQuery='';
  final searchcontroller=TextEditingController();
  final DatabaseReference stockRef =
  FirebaseDatabase.instance.ref('Total iteam stock');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      appBar:  AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: !_issearching
            ? const Text(
          "Stock List",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        )
            : TextField(
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Search customer...",
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value.trim();
            });
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
                _issearching ? Icons.close : Icons.search,
                color: Colors.white),
            onPressed: () {
              setState(() {
                _issearching = !_issearching;
                _searchQuery = "";
              });
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: StreamBuilder<DatabaseEvent>(
          stream: stockRef.onValue,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                  child: Text('Error loading data: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
              return const Center(
                  child: Text(
                    'No stock added yet',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ));
            }

            final data =
            snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
            final stockList = data.entries.toList();

            return ListView.builder(
              itemCount: stockList.length,
              itemBuilder: (context, index) {
                final key = stockList[index].key;
                final value = stockList[index].value as Map<dynamic, dynamic>;

                return InkWell(
                  onTap: () {
                    // Pass the stock ID to the details screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            Stockdetials(stockId: key.toString()),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      title: Text(
                        value['iteam'] ?? 'No Name',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Purchase Rate: ${value['purchase'] ?? '-'}'),
                            Text('Sell Rate: ${value['sell'] ?? '-'}'),
                            Text('Remaining Stock: ${value['remaining'] ?? '-'}'),
                          ],
                        ),
                      ),
                      trailing: const Icon(
                        Icons.inventory_2_outlined,
                        color: Colors.blueAccent,
                        size: 30,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Text(
          '+',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        ),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Addstock()));
        },
      ),
    );
  }
}
