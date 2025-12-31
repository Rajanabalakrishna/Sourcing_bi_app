


import 'package:flutter/material.dart';


class VisitTrackingScreen extends StatefulWidget {
  const VisitTrackingScreen({super.key});

  @override
  State<VisitTrackingScreen> createState() => _VisitTrackingScreenState();
}

class _VisitTrackingScreenState extends State<VisitTrackingScreen> {
  final List<Map<String, dynamic>> villages = [
    {'name': 'Rampur', 'block': 'Block A', 'selected': true},
    {'name': 'Sitapur', 'block': 'Block B', 'selected': false},
    {'name': 'Lakhanpur', 'block': 'Block A', 'selected': true},
    {'name': 'Chandni Chowk', 'block': 'Block C', 'selected': true},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F8F6),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
        title: const Text(
          'Visit Tracking',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A)),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Save',
              style: TextStyle(
                color: Color(0xFF15803D),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        shape: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Select Villages', trailing: '3 Selected'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  children: villages.map((village) {
                    return Column(
                      children: [
                        CheckboxListTile(
                          value: village['selected'],
                          onChanged: (val) => setState(() => village['selected'] = val),
                          activeColor: const Color(0xFF46EC13),
                          checkColor: Colors.white,
                          title: Text(village['name'],
                              style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                          subtitle: Text(village['block'],
                              style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                          secondary: const Icon(Icons.location_on, color: Color(0xFFCBD5E1)),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        ),
                        if (village != villages.last) const Divider(height: 1, indent: 64),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 32),
            _buildSectionHeader('Visit Metrics'),
            _buildInputField(
              label: 'Number of villages visited',
              hint: '0',
              icon: Icons.holiday_village,
              keyboardType: TextInputType.number,
              initialValue: '3',
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: _buildInputField(
                      label: 'Mukadams met',
                      hint: '0',
                      keyboardType: TextInputType.number,
                      isCompact: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInputField(
                      label: 'Interested Mukadams',
                      hint: '0',
                      keyboardType: TextInputType.number,
                      isCompact: true,
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '* Ensure interested count does not exceed total met.',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ),

            const SizedBox(height: 32),
            _buildSectionHeader("Tomorrow's Plan"),
            _buildInputField(
              label: 'Villages to visit tomorrow',
              hint: 'Enter village names',
              icon: Icons.next_plan,
            ),
            _buildInputField(
              label: 'Number of mukadams to meet tomorrow',
              hint: '0',
              icon: Icons.group_add,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 32),
            _buildSectionHeader('Additional Notes'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                maxLines: 5,
                style: const TextStyle(color: Color(0xFF0F172A)),
                decoration: _inputDecoration('Enter details about the visit...'),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF15803D).withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.save),
                  label: const Text('Submit Report', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF46EC13),
                    foregroundColor: const Color(0xFF142210),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {String? trailing}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
          ),
          if (trailing != null)
            Text(trailing, style: const TextStyle(color: Color(0xFF64748B), fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    bool isCompact = false,
    String? initialValue,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 0 : 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF475569), fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: initialValue,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 16, color: Color(0xFF0F172A)),
            decoration: _inputDecoration(hint, icon: icon),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, {IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
      filled: true,
      fillColor: Colors.white,
      suffixIcon: icon != null ? Icon(icon, color: const Color(0xFFCBD5E1)) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF46EC13), width: 2),
      ),
    );
  }
}