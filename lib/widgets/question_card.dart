import 'package:flutter/material.dart';
import '../models/speaker_question_model.dart';
import '../theme/app_theme.dart';

/// Speaker Q&A Question Card with realtime upvoting
class QuestionCard extends StatelessWidget {
  final SpeakerQuestionModel question;
  final VoidCallback onUpvote;

  const QuestionCard({
    super.key,
    required this.question,
    required this.onUpvote,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(AppTheme.spacingCardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppTheme.surfaceContainer,
            child: Text(
              question.studentName.isNotEmpty ? question.studentName[0] : 'S',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.studentName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  question.question,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.onSurface,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Upvote Column
          InkWell(
            onTap: onUpvote,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(Icons.thumb_up_alt_outlined, size: 16, color: AppTheme.primary),
                  const SizedBox(height: 2),
                  Text(
                    '${question.upvotes}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
