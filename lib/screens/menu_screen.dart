import 'package:flutter/material.dart';
import '../app_colors.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('메뉴 화면', style: TextStyle(fontSize: 24, color: AppColors.textGrey)));
  }
}
