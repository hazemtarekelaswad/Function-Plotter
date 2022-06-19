// TODO: Constant function support i.e. y = 5
// TODO: Handle f(x) = 1/x domain
// TODO: sqrt support and handle its domain
// TODO: Trig functions support
// TODO: Refactor the code
// TODO: Add unit testing
// TODO: Add simple documentation with Readme file
// TODO: Release the app
// TODO: Modify the error messages

import 'package:fluent_ui/fluent_ui.dart';
import 'package:window_size/window_size.dart';

import 'home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setWindowTitle('Function Plotter');
  setWindowMaxSize(const Size(1400, 530));
  setWindowMinSize(const Size(1400, 530));
  runApp(FunctionPlotter());
}

class FunctionPlotter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FluentApp(
      debugShowCheckedModeBanner: false,
      title: 'Function Plotter',
      theme: ThemeData(brightness: Brightness.dark),
      home: Home(),
    );
  }
}
