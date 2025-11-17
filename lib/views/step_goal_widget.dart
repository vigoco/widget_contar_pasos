import 'package:flutter/material.dart';
import '../viewmodels/step_goal_viewmodel.dart';

/// A widget that displays step count and progress toward a daily goal.
/// Optimized for Wear OS smartwatches with compact and expanded views.
class StepGoalWidget extends StatefulWidget {
  final StepGoalViewModel viewModel;
  final Color? progressColor;
  final Color? backgroundColor;
  final TextStyle? stepTextStyle;
  final TextStyle? goalTextStyle;

  const StepGoalWidget({
    super.key,
    required this.viewModel,
    this.progressColor,
    this.backgroundColor,
    this.stepTextStyle,
    this.goalTextStyle,
  });

  @override
  State<StepGoalWidget> createState() => _StepGoalWidgetState();
}

class _StepGoalWidgetState extends State<StepGoalWidget> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() {
    setState(() {});
  }

  void _handleTap() {
    widget.viewModel.toggleExpanded();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    final progressColor = widget.progressColor ?? Colors.blue;
    final backgroundColor = widget.backgroundColor ?? Colors.transparent;
    final stepTextStyle = widget.stepTextStyle ??
        const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        );
    final goalTextStyle = widget.goalTextStyle ??
        const TextStyle(
          fontSize: 16,
          color: Colors.white70,
        );

    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: backgroundColor,
        child: viewModel.isExpanded
            ? _buildExpandedView(viewModel, progressColor, stepTextStyle, goalTextStyle)
            : _buildCompactView(viewModel, progressColor, stepTextStyle, goalTextStyle),
      ),
    );
  }

  Widget _buildCompactView(
    StepGoalViewModel viewModel,
    Color progressColor,
    TextStyle stepTextStyle,
    TextStyle goalTextStyle,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: viewModel.progressPercent,
                  strokeWidth: 8,
                  backgroundColor: Colors.grey[800],
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
                Text(
                  '${viewModel.steps}',
                  style: stepTextStyle.copyWith(fontSize: 24),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Goal: ${viewModel.dailyGoal}',
            style: goalTextStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedView(
    StepGoalViewModel viewModel,
    Color progressColor,
    TextStyle stepTextStyle,
    TextStyle goalTextStyle,
  ) {
    final progressPercent = (viewModel.progressPercent * 100).toStringAsFixed(1);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 150,
            height: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: viewModel.progressPercent,
                  strokeWidth: 10,
                  backgroundColor: Colors.grey[800],
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${viewModel.steps}',
                      style: stepTextStyle.copyWith(fontSize: 36),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'steps',
                      style: goalTextStyle.copyWith(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Daily Goal: ${viewModel.dailyGoal}',
            style: goalTextStyle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            '$progressPercent%',
            style: goalTextStyle.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap to minimize',
            style: goalTextStyle.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

