import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AdminPanelScreen extends StatefulWidget {
  // ... (existing code)
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    // ... (existing code)
  }

  @override
  Widget build(BuildContext context) {
    // ... (existing code)
  }
} 