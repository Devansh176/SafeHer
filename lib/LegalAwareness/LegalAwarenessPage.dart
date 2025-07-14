import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LegalAwarenessPage extends StatelessWidget {
  const LegalAwarenessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final laws = [
      {
        'title': '1. Protection of Women from Domestic Violence Act (2005)',
        'description':
        'Protects women from physical, sexual, emotional, verbal, and economic abuse. Offers protection orders, residence rights, custody, and maintenance.'
      },
      {
        'title': '2. Section 498A IPC (Cruelty by Husband/Relatives)',
        'description':
        'Punishes cruelty including dowry harassment. Cognizable and non-bailable offence with imprisonment up to 3 years and fine.'
      },
      {
        'title': '3. Supreme Court Order (2025) on Implementation of PWDVA',
        'description':
        'Directed all states to appoint Protection Officers and create awareness of women’s rights under the DV Act.'
      },
      {
        'title': '4. Maharashtra HC Orders ₹1 Crore Compensation (2025)',
        'description':
        'Court ordered high compensation to a domestic violence survivor citing long-term trauma and housing rights.'
      },
      {
        'title': '5. Tamil Nadu Law (2025): Good Conduct Year for Offenders',
        'description':
        'Men accused of domestic abuse to face jail and fine up to ₹1 lakh if they violate a one-year no-contact mandate.'
      },
      {
        'title': '6. The Dowry Prohibition Act (1961)',
        'description':
        'Prohibits giving, taking, or demanding dowry. Imprisonment up to 5 years and fine up to ₹15,000 or the dowry amount.'
      },
      {
        'title': '7. POCSO Act (2012)',
        'description':
        'Protects children under 18 from sexual abuse, trafficking, child porn. Also criminalizes possession/viewing of child porn (2024 SC ruling).'
      },
      {
        'title': '8. Workplace Sexual Harassment Act (2013)',
        'description':
        'Requires Internal Complaints Committees in all workplaces. Covers domestic workers and home-based jobs.'
      },
      {
        'title': '9. Right to Free Legal Aid – Article 39A',
        'description':
        'Women can access free legal services via Legal Services Authorities (DLSA, SLSA) in every district and state.'
      },
    ];

    final helplines = [
      '📞 Women Helpline (All India) – 1091',
      '👩 National Commission for Women – 011-26942369 / ncw@nic.in',
      '👶 Childline – 1098 (for children in distress)',
      '🚨 Police Emergency – 100 / 112',
      '⚖️ Legal Aid – Contact DLSA or call 15100 (Legal Services Authority)',
      '🌐 Cyber Crime – www.cybercrime.gov.in or 1930 (financial fraud)',
      '🏥 One-Stop Crisis Centres – For legal, medical & shelter help'
    ];

    final tips = [
      "✔️ Document abuse (photos, chats, recordings)",
      "✔️ Use SafeHer SOS & location share in danger",
      "✔️ Save 1091 & 112 in speed dial",
      "✔️ File FIR at nearest police station or Women’s Cell",
      "✔️ Contact Protection Officer for legal protection"
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Know Your Rights",
        ),
        backgroundColor: const Color(0xFF556B2F),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEFFBF1), Color(0xFFD5F5E3)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          children: [
            _sectionTitle("📚 Key Laws Protecting Women", Colors.green[900]),
            const SizedBox(height: 8),
            ...laws.map((law) => _lawCard(law)),

            const SizedBox(height: 25),
            _sectionTitle("📞 Helplines & Support", Colors.orange[900]),
            const SizedBox(height: 10),
            ...helplines.map((line) => ListTile(
              leading: const Icon(Icons.phone, color: Colors.deepOrange),
              title: Text(line, style: GoogleFonts.poppins(fontSize: 14)),
            )),

            const SizedBox(height: 25),
            _sectionTitle("🛡️ What You Can Do", Colors.blue[900]),
            const SizedBox(height: 10),
            ...tips.map((tip) => ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.teal),
              title: Text(tip, style: GoogleFonts.poppins(fontSize: 14)),
            )),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _lawCard(Map<String, String> law) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.shield, color: Colors.green, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    law['title']!,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              law['description']!,
              style: GoogleFonts.poppins(fontSize: 13.5, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, Color? color) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: color ?? Colors.black87,
      ),
    );
  }
}
