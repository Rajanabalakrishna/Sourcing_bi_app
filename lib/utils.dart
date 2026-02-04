//
//
// import 'package:flutter/material.dart';
// import 'package:path/path.dart';
//
// Future<void> _selectFreeFromDate() async {
//   DateTime? picked = await showDatePicker(
//     context: context,
//     initialDate: DateTime.now(),
//     firstDate: DateTime(2000),
//     lastDate: DateTime(2101),
//   );
//   if (picked != null) {
//     setState(() {
//       _freeFromDateController.text = picked.toIso8601String().split('T')[0];
//     });
//   }
// }
