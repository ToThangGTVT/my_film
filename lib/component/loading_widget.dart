import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.primary,
      child: const Center(
          child: CircularProgressIndicator(
            valueColor:AlwaysStoppedAnimation<Color>(Colors.red),
          ),),
    );
  }
}
