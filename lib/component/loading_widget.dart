import 'package:flutter/material.dart';

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
