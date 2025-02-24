import 'dart:async';
import 'dart:ui';

class Throttle {
  Duration delay;
  Timer? _timer;
  bool _isReady = true;

  Throttle(this.delay);

  void run(VoidCallback action) {
    if (_isReady) {
      _isReady = false;
      action();
      _timer = Timer(delay, () {
        _isReady = true;
      });
    }
  }
}
