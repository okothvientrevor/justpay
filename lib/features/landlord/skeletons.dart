import 'package:flutter/material.dart';

class StatsSkeleton extends StatelessWidget {
  const StatsSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: SkeletonBox(height: 100)),
            const SizedBox(width: 16),
            Expanded(child: SkeletonBox(height: 100)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: SkeletonBox(height: 80)),
            const SizedBox(width: 16),
            Expanded(child: SkeletonBox(height: 80)),
          ],
        ),
      ],
    );
  }
}

class GraphSkeleton extends StatelessWidget {
  const GraphSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(height: 180);
  }
}

class SkeletonBox extends StatelessWidget {
  final double height;

  const SkeletonBox({required this.height, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[800]?.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
