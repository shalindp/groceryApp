import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';

class WithShimmer extends StatelessWidget {
  final bool condition;
  final bool? errorCondition;
  final double width;
  final double height;
  final Widget child;
  final Widget? errorChild;

  const WithShimmer({
    super.key,
    required this.condition,
    required this.width,
    required this.height,
    required this.child,
    this.errorCondition,
    this.errorChild,
  });

  @override
  Widget build(BuildContext context) {
    if (errorCondition == true && errorChild != null) {
      return errorChild!;
    }

    if (condition) {
      return Animate(child: child).fadeIn(duration: 300.milliseconds);
    }

    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        width: width,
        height: height,
      ),
    );
  }
}
