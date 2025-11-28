import 'package:flutter/material.dart';
import '../app_colors.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('달력 화면', style: TextStyle(fontSize: 24, color: AppColors.textGrey)));
  }
}
