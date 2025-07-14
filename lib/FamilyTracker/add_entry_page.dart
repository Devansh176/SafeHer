import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AddEntryPage extends StatefulWidget {
  const AddEntryPage({super.key});

  @override
  State<AddEntryPage> createState() => _AddEntryPageState();
}

class _AddEntryPageState extends State<AddEntryPage> {
  final TextEditingController _controller = TextEditingController();
  bool isSaving = false;

  Future<void> _saveEntry() async {
    final entry = _controller.text.trim();
    if (entry.isEmpty) return;

    setState(() => isSaving = true);

    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(now);

    try {
      await FirebaseFirestore.instance.collection('relationship_logs').add({
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'entry': entry,
        'date': formattedDate,
        'timestamp': now,
      });

      if (mounted) {
        setState(() => isSaving = false);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Entry saved successfully!", style: GoogleFonts.poppins()),
            backgroundColor: Colors.purple,
          ),
        );
      }
    } catch (e) {
      setState(() => isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to save entry: $e", style: GoogleFonts.poppins()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Entry", style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xFF6D597A), // Matching purple
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5EEF8), Color(0xFFE8DAEF)], // Soft pastel purple background
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: "Describe the situation, concern, or relationship abuse...",
                hintStyle: GoogleFonts.poppins(fontSize: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: isSaving ? null : _saveEntry,
              icon: const Icon(Icons.save, color: Colors.white,),
              label: isSaving
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
                  : Text(
                  "Save",
                  style: GoogleFonts.poppins(
                    color: Colors.white
                  ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6D597A),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
