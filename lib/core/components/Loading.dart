import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class LoadingSkeletonizer extends StatefulWidget {
  final Widget child;
  bool loading = true;
  LoadingSkeletonizer({required this.child, this.loading = true, super.key});

  @override
  State<LoadingSkeletonizer> createState() => _LoadingSkeletonizerState();
}

class _LoadingSkeletonizerState extends State<LoadingSkeletonizer> {
  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
        effect: const PulseEffect(
            from: Colors.grey,
            to: Color.fromARGB(255, 241, 241, 241),
            duration: Duration(seconds: 3)),
        enabled: widget.loading,
        enableSwitchAnimation: true,
        child: widget.child);
  }
}
