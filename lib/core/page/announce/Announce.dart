import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:flutter/material.dart';

class Announce extends StatefulWidget {
  const Announce({super.key});

  @override
  State<Announce> createState() => _AnnounceState();
}

class _AnnounceState extends State<Announce> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppbarCustom(
          title: ' Announce',
          icon: Icons.campaign,
        ),
      ),
      body: AnimatedContainer(
        duration: Duration(seconds: 1),
      ),
    );
  }
}
