import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JournalDetailPage extends StatelessWidget {
  final String date;
  final String entry;
  final String docId; // ✅ Required for deletion

  const JournalDetailPage({
    super.key,
    required this.date,
    required this.entry,
    required this.docId,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              width: screenWidth,
              height: screenHeight,
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * 0.03,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF5EEF8), Color(0xFFE8DAEF)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "📝 Journal Entry",
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.06,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple.shade700,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.deepPurple),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Date Info Card
                  _infoCard(context, date),

                  SizedBox(height: screenHeight * 0.025),

                  Text(
                    "Your Thoughts",
                    style: GoogleFonts.poppins(
                      fontSize: screenWidth * 0.048,
                      fontWeight: FontWeight.w600,
                      color: Colors.deepPurple.shade800,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.015),

                  // Entry Display
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.deepPurple[100]?.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 12,
                              offset: const Offset(2, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: SingleChildScrollView(
                            child: Text(
                              entry,
                              style: TextStyle(
                                fontSize: screenWidth * 0.038,
                                height: 1.6,
                                color: Colors.black87,
                                fontFamily: 'Roboto',
                              ),
                              textAlign: TextAlign.justify,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 70), // Bottom spacing for button
                ],
              ),
            ),

            // Elegant Delete Button
            Positioned(
              bottom: 20,
              right: 20,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 6,
                ),
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                label: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                onPressed: () async {
                  final shouldDelete = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Delete Entry"),
                      content: const Text("Are you sure you want to delete this journal entry?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            "Delete",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (shouldDelete == true) {
                    await FirebaseFirestore.instance
                        .collection('relationship_logs')
                        .doc(docId)
                        .delete();

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Entry deleted successfully!", style: TextStyle(color: Colors.deepPurple),),
                        backgroundColor: Colors.white,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(BuildContext context, String date) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.5,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.deepPurple.shade100),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_rounded, size: 20, color: Colors.deepPurple),
          const SizedBox(width: 10),
          Text(
            "Date: ",
            style: GoogleFonts.poppins(
              fontSize: screenWidth * 0.042,
              fontWeight: FontWeight.w500,
              color: Colors.deepPurple.shade800,
            ),
          ),
          Flexible(
            child: Text(
              date,
              style: GoogleFonts.poppins(
                fontSize: screenWidth * 0.041,
                fontWeight: FontWeight.w400,
                color: Colors.deepPurple.shade800,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
