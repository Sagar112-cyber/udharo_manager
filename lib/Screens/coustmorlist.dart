// lib/Screens/customer_list.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:udharo_manager/Screens/Detials.dart';
import 'package:udharo_manager/Screens/addudharo.dart';

class CustomerList extends StatefulWidget {
  const CustomerList({super.key});

  @override
  State<CustomerList> createState() => _CustomerListState();
}

class _CustomerListState extends State<CustomerList> {
  final DatabaseReference dbRef =
  FirebaseDatabase.instance.ref().child('customers');

  bool _isSearching = false;
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      // ************** AppBar with Search **************
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: !_isSearching
            ? const Text(
          "Customers",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
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
                _isSearching ? Icons.close : Icons.search,
                color: Colors.white),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                _searchQuery = "";
              });
            },
          )
        ],
      ),

      // ************** Body with Gradient Background **************
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6EA8FF), Color(0xFF8E87FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 110),
          child: StreamBuilder(
            stream: dbRef.onValue,
            builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.data!.snapshot.value == null) {
                return const Center(
                  child: Text(
                    'No customers added yet',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                );
              }

              Map<dynamic, dynamic> customerMap =
              snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

              List<Map<String, dynamic>> customers = [];

              customerMap.forEach((key, value) {
                Map<String, dynamic> data =
                Map<String, dynamic>.from(value ?? {});
                data['id'] = key;
                customers.add(data);
              });

              // 🔍 SEARCH FILTER
              if (_searchQuery.isNotEmpty) {
                customers = customers.where((customer) {
                  String name = (customer['name'] ?? '').toString().toLowerCase();
                  return name.contains(_searchQuery.toLowerCase());
                }).toList();
              }

              return ListView.builder(
                itemCount: customers.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  var customer = customers[index];
                  return _buildCustomerCard(customer);
                },
              );
            },
          ),
        ),
      ),

      // ************** Floating Button to Add Customer **************
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, size: 32, color: Colors.black87),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => const Addudharo()));
        },
      ),
    );
  }

  // ************** Customer Card UI **************
  Widget _buildCustomerCard(Map customer) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    CustomerDetailsPage(customerId: customer['id']?.toString() ?? '')));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.20),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Profile Icon Circle
            Container(
              height: 45,
              width: 45,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white24,
              ),
              child: const Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 14),
            // Customer info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer['name']?.toString() ?? 'No Name', // Null safe
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "📞 ${customer['phone']?.toString() ?? '-'}", // Null safe
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // Amount box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.85),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Rs. ${customer['amount']?.toString() ?? '0'}", // Null safe
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Payment + delete buttons
            Column(
              children: [
                InkWell(
                  onTap: () => _openPaymentDialog(customer),
                  child: const Icon(Icons.payment,
                      color: Colors.greenAccent, size: 28),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () =>
                      _confirmDelete(customer['id']?.toString() ?? ''), // Null safe
                  child:
                  const Icon(Icons.delete, color: Colors.redAccent, size: 28),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // ************** Payment Dialog **************
  void _openPaymentDialog(Map customer) {
    TextEditingController paymentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Payment for ${customer['name']?.toString() ?? ''}"),
          content: TextField(
            controller: paymentController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: "Enter amount paid",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text("Pay", style: TextStyle(color: Colors.green)),
              onPressed: () async {
                String paidText = paymentController.text.trim();
                if (paidText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Enter a valid amount")),
                  );
                  return;
                }

                double paidAmount = double.tryParse(paidText) ?? 0;
                double oldAmount =
                    double.tryParse(customer['amount']?.toString() ?? "0") ?? 0;
                double newAmount = oldAmount - paidAmount;

                if (newAmount < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Amount exceeds total udharo")),
                  );
                  return;
                }

                String id = customer['id']?.toString() ?? '';

                // Update customer's due amount
                await dbRef.child(id).update({"amount": newAmount.toString()});

                // Update total collection
                DatabaseReference totalRef =
                FirebaseDatabase.instance.ref().child("total_collection");

                DatabaseEvent event = await totalRef.once();
                double oldTotal = 0;
                if (event.snapshot.value != null) {
                  oldTotal = double.tryParse(event.snapshot.value.toString()) ?? 0;
                }
                double newTotal = oldTotal + paidAmount;
                await totalRef.set(newTotal);

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        "Payment Rs. $paidAmount received. Remaining: Rs. $newAmount"),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // ************** Delete Customer **************
  void _confirmDelete(String id) {
    if (id.isEmpty) return; // Safety check
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Customer"),
          content: const Text("Are you sure you want to delete this customer?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
              onPressed: () {
                dbRef.child(id).remove();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
