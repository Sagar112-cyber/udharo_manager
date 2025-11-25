// lib/Screens/addudharo.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class Addudharo extends StatefulWidget {
  const Addudharo({super.key});

  @override
  State<Addudharo> createState() => _AddudharoState();
}

class _AddudharoState extends State<Addudharo> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  final DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('customers');

  bool _isSaving = false;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    amountController.dispose();
    super.dispose();
  }

  Future<void> addUdharo() async {
    String name = nameController.text.trim();
    String phone = phoneController.text.trim();
    String amountText = amountController.text.trim();

    if (name.isEmpty || phone.isEmpty || amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final parsedAmount = num.tryParse(amountText.replaceAll(',', ''));

    if (parsedAmount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid number for amount')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final String id = dbRef.push().key ?? DateTime.now().millisecondsSinceEpoch.toString();

      await dbRef.child(id).set({
        'name': name,
        'phone': phone,
        'amount': parsedAmount,
        'createdAt': ServerValue.timestamp,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Udharo Added Successfully')),
      );

      nameController.clear();
      phoneController.clear();
      amountController.clear();

    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding data: $error')),
      );
    }

    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      // 🔵 TRANSPARENT APP BAR
      appBar: AppBar(
        title: const Text(
          'Add Udharo',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: Container(
        width: double.infinity,
        height: double.infinity,

        // 🔹 BEAUTIFUL BLUE–PURPLE GRADIENT
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF6EA8FF),
              Color(0xFF8E87FF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 22,
            right: 22,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 120,
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Enter Details",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 25),

              // 🔵 GLASS CARD INPUT FIELD
              _glassInput(
                controller: nameController,
                hint: "Customer Name",
                icon: Icons.person,
              ),

              const SizedBox(height: 16),

              _glassInput(
                controller: amountController,
                hint: "Amount (e.g. 1500)",
                icon: Icons.currency_rupee,
                inputType: TextInputType.numberWithOptions(decimal: true),
              ),

              const SizedBox(height: 16),

              _glassInput(
                controller: phoneController,
                hint: "Phone Number",
                icon: Icons.phone,
                inputType: TextInputType.phone,
              ),

              const SizedBox(height: 35),

              // 🔥 BIG BEAUTIFUL BUTTON
              _mainButton(
                label: "Add Udharo",
                loading: _isSaving,
                onTap: _isSaving ? null : addUdharo,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ************************************************************
  // 🔵 INPUT FIELD STYLING (GLASS EFFECT)
  Widget _glassInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.09),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        style: const TextStyle(color: Colors.white, fontSize: 17),
        decoration: InputDecoration(
          icon: Icon(icon, color: Colors.white),
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.6),
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  // ************************************************************
  // 🔥 MAIN ACTION BUTTON
  Widget _mainButton({
    required String label,
    required bool loading,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 55,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF3C7BFF),
              Color(0xFF635BFF),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),

        child: Center(
          child: loading
              ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : Text(
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
}