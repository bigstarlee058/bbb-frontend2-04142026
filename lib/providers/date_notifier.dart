import 'dart:async';

class DateStreamNotifier {
  final _controller = StreamController<DateTime>.broadcast();

  DateStreamNotifier() {
    Timer.periodic(Duration(minutes: 1), (timer) {
      _controller.add(DateTime.now());
    });
  }

  Stream<DateTime> get stream => _controller.stream;
}
