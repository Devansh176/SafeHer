import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'JournalDetailPage.dart';
import 'add_entry_page.dart';

class FamilyTrackerPage extends StatefulWidget {
  const FamilyTrackerPage({super.key});

  @override
  State<FamilyTrackerPage> createState() => _FamilyTrackerPageState();
}

class _FamilyTrackerPageState extends State<FamilyTrackerPage>
    with SingleTickerProviderStateMixin {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  String _searchText = "";
  DateTime? _selectedDate;
  final FocusNode _searchFocusNode = FocusNode();
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    _selectedDate = DateTime.now();
  }


  @override
  void dispose() {
    _controller.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _refresh() async => setState(() {});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1C1C1E), Color(0xFF3E1E68)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              RefreshIndicator(
                onRefresh: _refresh,
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: FadeTransition(
                    opacity: _controller,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 25),
                        _sectionTitle("\ud83d\udcd8 Private Journal"),
                        const SizedBox(height: 18),
                        _calendarTimeline(),
                        const SizedBox(height: 12),
                        _searchBar(),
                        const SizedBox(height: 20),
                        Expanded(child: _entryList()),
                        const SizedBox(height: 70),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                right: 20,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: FloatingActionButton.extended(
                      backgroundColor: Colors.deepPurpleAccent,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text("New Entry",
                          style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () async {
                        _searchFocusNode.unfocus();
                        final shouldReset = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AddEntryPage()),
                        );

                        if (shouldReset == true) {
                          setState(() {
                            _selectedDate = DateTime.now();
                            _searchText = '';
                          });
                        }
                      },
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black45, blurRadius: 12, offset: Offset(0, 6))
        ],
      ),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _searchBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
      ),
      padding: const EdgeInsets.all(6),
      child: TextField(
        focusNode: _searchFocusNode,
        style: TextStyle(color: Colors.white),
        onChanged: (val) => setState(() => _searchText = val.toLowerCase()),
        decoration: InputDecoration(
          hintText: "Search entries...",
          hintStyle: TextStyle(color: Colors.white54),
          prefixIcon: const Icon(Icons.search, color: Colors.white),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _calendarTimeline() {
    final now = DateTime.now();
    final days = List.generate(10, (i) => now.subtract(Duration(days: i)));

    return Container(
      padding: const EdgeInsets.all(8),
      child: SizedBox(
        height: 65,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: days.length + 1,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            if (index == days.length) {
              return GestureDetector(
                onTap: () async {
                  _searchFocusNode.unfocus();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? now,
                    firstDate: DateTime(2022),
                    lastDate: now,
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child:
                  const Icon(Icons.calendar_month_rounded, color: Colors.white),
                ),
              );
            }

            final day = days[index];
            final isSelected = _selectedDate != null &&
                DateFormat('yyyy-MM-dd').format(day) ==
                    DateFormat('yyyy-MM-dd').format(_selectedDate!);

            return GestureDetector(
              onTap: () => setState(() => _selectedDate = day),
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.deepPurple
                      : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('E').format(day),
                      style: GoogleFonts.poppins(
                        color:
                        isSelected ? Colors.white : Colors.white70,
                      ),
                    ),
                    Text(
                      DateFormat('d').format(day),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.white,
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _entryList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('relationship_logs')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
              child: Text("Something went wrong",
                  style: TextStyle(color: Colors.white)));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs.where((doc) {
          final entry = doc['entry'].toString().toLowerCase();
          final date = doc['date'].toString().toLowerCase();
          final matchSearch = entry.contains(_searchText) || date.contains(_searchText);

          bool matchDate;
          if (_selectedDate == null) {
            matchDate = true;
          } else {
            final selected = DateFormat('yyyy-MM-dd').format(_selectedDate!);
            matchDate = selected == doc['date'];
          }

          return matchSearch && matchDate;
        }).toList();


        if (docs.isEmpty) {
          return const Center(
              child:
              Text("No entries found.", style: TextStyle(color: Colors.white)));
        }

        return ListView.separated(
          physics: const BouncingScrollPhysics(),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final log = docs[index];
            return Dismissible(
              key: Key(log.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (_) async {
                _searchFocusNode.unfocus();
                return await showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Delete Entry?"),
                    content: const Text("This action cannot be undone."),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Cancel")),
                      TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Delete")),
                    ],
                  ),
                );
              },
              onDismissed: (_) async {
                await FirebaseFirestore.instance
                    .collection('relationship_logs')
                    .doc(log.id)
                    .delete();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Entry deleted successfully")),
                );
              },
              child: GestureDetector(
                onTap: () {
                  _searchFocusNode.unfocus();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => JournalDetailPage(
                        date: log['date'],
                        entry: log['entry'],
                        docId: log.id,
                      ),
                    ),
                  );
                },
                child:
                _logCard(date: log['date'], entry: log['entry']),
              ),
            );
          },
        );
      },
    );
  }

  Widget _logCard({required String date, required String entry}) {
    final preview = entry.split('\n').first.trim();

    return Stack(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: [
                Colors.deepPurple.withOpacity(0.23),
                Colors.deepPurpleAccent.withOpacity(0.15)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withOpacity(0.07),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 7.5, sigmaY: 7.5),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.deepPurpleAccent,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    preview,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}