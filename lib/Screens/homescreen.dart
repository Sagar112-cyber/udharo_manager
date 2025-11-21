// lib/Screens/homescreen.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:udharo_manager/Screens/addudharo.dart';
import 'package:udharo_manager/Screens/coustmorlist.dart';
import 'package:udharo_manager/Screens/loginscreen.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  final DatabaseReference customersRef = FirebaseDatabase.instance.ref('customers');
  final DatabaseReference totalCollectionRef = FirebaseDatabase.instance.ref('total_collection');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF3FF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          "Udharo Manager",
          style: TextStyle(
            fontSize: 22,
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: "Logout",
            icon: const Icon(Icons.logout, color: Colors.black87),
            onPressed: _logout,
          )
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // 🔹 Dashboard Cards
              SingleChildScrollView(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _dashboardCard("Total Udharo", _totalUdharoCard()),
                    _dashboardCard("Customers", _totalCustomersCard()),
                    _dashboardCard("Collection", _totalCollectionCard()),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // 🔹 Add Udharo Button
              _bigButton(
                label: "➕ Add Udharo",
                color: Colors.blueAccent,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const Addudharo()));
                },
              ),

              const SizedBox(height: 20),

              // 🔹 Customer List Button
              _bigButton(
                label: "👤 Customer List",
                color: Colors.deepPurpleAccent,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerList()));
                },
              ),

              const SizedBox(height: 30),

              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  "📜 App History",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              _historyCard(),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================================
  // 🔹 BEAUTIFUL HISTORY CARD UI
  Widget _historyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "• App Created: 2025\n"
                "• Version: 1.0.0\n"
                "• Developer: Your Name\n"
                "• Purpose: Manage Udharo, Collections & Customers\n"
                "• Status: Stable\n"
                "• Last Update: Today",
            style: TextStyle(fontSize: 15, height: 1.6, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  // =====================================================================
  // 🔹 DASHBOARD CARD WRAPPER
  Widget _dashboardCard(String title, Widget valueWidget) {
    return Container(
      width: 110,
      height: 130,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              )),
          const SizedBox(height: 8),
          valueWidget,
        ],
      ),
    );
  }

  // =====================================================================
  // 🔹 BIG BUTTON UI
  Widget _bigButton({required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 55,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.8),
              color,
              color.withOpacity(0.9),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // =====================================================================
  // 🔹 FETCH VALUES
  Widget _totalCustomersCard() {
    return StreamBuilder<DatabaseEvent>(
      stream: customersRef.onValue,
      builder: (context, snapshot) {
        int count = 0;
        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          final val = snapshot.data!.snapshot.value;
          if (val is Map) count = val.length;
        }
        return Text(
          count.toString(),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        );
      },
    );
  }

  Widget _totalUdharoCard() {
    return StreamBuilder<DatabaseEvent>(
      stream: customersRef.onValue,
      builder: (context, snapshot) {
        double total = 0;
        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          final data = snapshot.data!.snapshot.value as Map;
          data.forEach((key, value) {
            if (value is Map && value['amount'] != null) {
              total += double.tryParse(value['amount'].toString()) ?? 0.0;
            }
          });
        }
        return Text(
          total.toString(),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        );
      },
    );
  }

  Widget _totalCollectionCard() {
    return StreamBuilder(
      stream: totalCollectionRef.onValue,
      builder: (context, snapshot) {
        double total = 0;
        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          total = double.tryParse(snapshot.data!.snapshot.value.toString()) ?? 0.0;
        }
        return Text(
          total.toString(),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        );
      },
    );
  }
  // 🔹 LOGOUT FUNCTION
  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Loginscreen()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Logout error: $e")),
      );
    }
  }
}
