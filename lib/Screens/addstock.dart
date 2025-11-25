import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Addstock extends StatefulWidget {
  @override
  State<Addstock> createState() => _AddstockState();
}

class _AddstockState extends State<Addstock> {
  final iteamcontroller = TextEditingController();
  final purchasecontroller = TextEditingController();
  final sellcontroller = TextEditingController();
  final remainingcontroller = TextEditingController();

  bool _loading = false;

  final DatabaseReference totalstockRef =
  FirebaseDatabase.instance.ref('Total iteam stock');

  @override
  void dispose() {
    iteamcontroller.dispose();
    purchasecontroller.dispose();
    sellcontroller.dispose();
    remainingcontroller.dispose();
    super.dispose();
  }

  Future<void> addstock() async {
    String iteam = iteamcontroller.text.trim();
    String purchase = purchasecontroller.text.trim();
    String sell = sellcontroller.text.trim();
    String remaining = remainingcontroller.text.trim();

    if (iteam.isEmpty || purchase.isEmpty || sell.isEmpty || remaining.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Text('Please fill all fields'),
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final String id = totalstockRef.push().key ??
          DateTime.now().millisecondsSinceEpoch.toString();

      await totalstockRef.child(id).set({
        'id': id,
        'iteam': iteam,
        'purchase': purchase,
        'sell': sell,
        'remaining': remaining,
        'createdAt': ServerValue.timestamp,
      });

      Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding data: $e")),
      );
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff5f6fa),
      appBar: AppBar(
        title: Text("Add Stock"),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _inputCard(
              child: _buildTextField(
                lable: "Item Name",
                controller: iteamcontroller,

              ),
            ),
            _inputCard(
              child: _buildTextField(
                lable: "Purchase Rate",
                controller: purchasecontroller,
              ),
            ),
            _inputCard(
              child: _buildTextField(
                lable: "Sell Rate",
                controller: sellcontroller,
              ),
            ),
            _inputCard(
              child: _buildTextField(
                lable: "Total Stock",
                controller: remainingcontroller,
              ),
            ),

            SizedBox(height: 25),

            _loading
                ? CircularProgressIndicator()
                : _bigButton(
              lable: "Add Item",
              color: Colors.blueAccent,
              onTap: addstock,
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputCard({required Widget child}) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(1, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildTextField({
    required String lable,
    required TextEditingController controller,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: lable,
        labelStyle: TextStyle(fontSize: 16, color: Colors.black87),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  Widget _bigButton({
    required String lable,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 55,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.7), color, color.withOpacity(0.9)],
          ),
        ),
        child: Center(
          child: Text(
            lable,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
