import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../technical/Theme/app_card.dart';
import '../../../../technical/Theme/app_colors.dart';
import '../../../../technical/Theme/app_text.dart';
import '../../domain/spending_stats.dart';

class DailyBarsCard extends StatelessWidget {
  const DailyBarsCard({super.key, required this.stats});

  final SpendingStats stats;

  @override
  Widget build(BuildContext context) {
    final max = stats.dailyVariable.fold<double>(1, math.max);
    return AppCard(
      radius: 20,
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const AppText('Dépenses variables', size: 15),
        const SizedBox(height: 12),
        SizedBox(
          height: 96,
          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            for (var i = 0; i < stats.dailyVariable.length; i++)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i == stats.dailyVariable.length - 1 ? 0 : 3),
                  child: FractionallySizedBox(
                    heightFactor: i < stats.day ? math.max(stats.dailyVariable[i] / max, stats.dailyVariable[i] > 0 ? 0.04 : 0.02) : 0.02,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: i == stats.day - 1 ? AppColors.accent : (i < stats.day ? AppColors.bar : AppColors.barFuture),
                      ),
                    ),
                  ),
                ),
              ),
          ]),
        ),
        const SizedBox(height: 6),
        Row(children: [
          for (var i = 0; i < stats.dailyVariable.length; i++)
            Expanded(child: SizedBox(height: 12, child: OverflowBox(maxWidth: 24, child: AppText(i == 0 || (i + 1) % 5 == 0 ? '${i + 1}' : '', size: 9, weight: FontWeight.w600, color: AppColors.muted, align: TextAlign.center)))),
        ]),
      ]),
    );
  }
}
