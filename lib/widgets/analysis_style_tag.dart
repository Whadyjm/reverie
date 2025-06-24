import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../provider/dream_provider.dart';

class AnalysisStyleTag extends StatelessWidget {
  AnalysisStyleTag({super.key, required this.analysisStyle});

  String analysisStyle = '';
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            offset: Offset(1, 2),
            spreadRadius: 2,
            blurRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child:
          analysisStyle == 'psicologico'
              ? Center(child: Text('🧠', style: TextStyle(fontSize: 20)))
              : analysisStyle == 'mistico'
              ? Center(child: Text('🔮', style: TextStyle(fontSize: 18)))
              : Center(child: Text('🌀', style: TextStyle(fontSize: 18))),
    );
  }
}
