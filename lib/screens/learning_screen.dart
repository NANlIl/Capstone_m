import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../widgets/fade_page_route.dart';
import './character_learning_screen.dart';
import './quiz_screen.dart';

class LearningScreen extends StatelessWidget {
  const LearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: <Widget>[
        _buildMenuButton(context, '문자 학습', Icons.translate, () => Navigator.push(context, FadePageRoute(child: const CharacterLearningScreen()))),
        _buildMenuButton(context, '한자 학습', Icons.font_download, () { /* TODO */ }),
        _buildMenuButton(context, '단어 학습', Icons.style, () { /* TODO */ }),
        _buildMenuButton(context, '단어 퀴즈', Icons.quiz, () => Navigator.push(context, FadePageRoute(child: const QuizScreen()))),
        _buildMenuButton(context, '문법/예문 학습', Icons.short_text, () { /* TODO */ }),
        const Divider(height: 32, thickness: 1, indent: 16, endIndent: 16),
        _buildMenuButton(context, '실력평가', Icons.leaderboard, () { /* TODO */ }, isPrimary: true),
      ],
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, IconData icon, VoidCallback onPressed, {bool isPrimary = false}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: isPrimary ? AppColors.primary : AppColors.border, width: 1.5),
      ),
      color: isPrimary ? AppColors.primary.withAlpha(13) : AppColors.card,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Row(
            children: [
              Icon(icon, color: isPrimary ? AppColors.primary : AppColors.textGrey, size: 28),
              const SizedBox(width: 16),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.headline)),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, color: AppColors.textGrey, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
