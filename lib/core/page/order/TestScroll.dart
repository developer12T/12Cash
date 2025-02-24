import 'package:flutter/material.dart';

class NestedScrollViewExample extends StatefulWidget {
  const NestedScrollViewExample({super.key});

  @override
  State<NestedScrollViewExample> createState() =>
      _NestedScrollViewExampleState();
}

class _NestedScrollViewExampleState extends State<NestedScrollViewExample> {
  ScrollController _outerController = ScrollController();

  ScrollController _innerController = ScrollController();

  bool _isInnerAtTop = true;
  bool _isInnerAtBottom = false;

  @override
  void initState() {
    super.initState();
    _innerController.addListener(_handleInnerScroll);
  }

  void _handleInnerScroll() {
    if (_innerController.position.atEdge) {
      bool isTop = _innerController.position.pixels == 0;
      bool isBottom = _innerController.position.pixels ==
          _innerController.position.maxScrollExtent;

      setState(() {
        _isInnerAtTop = isTop;
        _isInnerAtBottom = isBottom;
      });
    }
  }

  @override
  void dispose() {
    _innerController.removeListener(_handleInnerScroll);
    _innerController.dispose();
    _outerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          if (notification is OverscrollNotification) {
            if (_isInnerAtTop && notification.overscroll < 0) {
              _outerController
                  .jumpTo(_outerController.offset + notification.overscroll);
            } else if (_isInnerAtBottom && notification.overscroll > 0) {
              _outerController
                  .jumpTo(_outerController.offset + notification.overscroll);
            }
          }
          return false;
        },
        child: ListView(
          controller: _outerController,
          children: [
            Container(
              height: 200,
              color: Colors.blue,
              child: Center(
                  child: Text("Header Content",
                      style: TextStyle(color: Colors.white, fontSize: 20))),
            ),
            Container(
              height: 500, // Ensures enough space to scroll
              child: ListView.builder(
                controller: _innerController,
                physics: ClampingScrollPhysics(), // Allows controlled scrolling
                itemCount: 20,
                itemBuilder: (context, index) {
                  return ListTile(title: Text("Item $index"));
                },
              ),
            ),
            Container(
              height: 200,
              color: Colors.green,
              child: Center(
                  child: Text("Footer Content",
                      style: TextStyle(color: Colors.white, fontSize: 20))),
            ),
          ],
        ),
      ),
    );
  }
}
