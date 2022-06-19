import 'package:fluent_ui/fluent_ui.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:math_expressions/math_expressions.dart' as math;

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final _functionController = TextEditingController();
  final _minXController = TextEditingController();
  final _maxXController = TextEditingController();

  math.Expression? yVal;
  math.Expression? xMinVal;
  math.Expression? xMaxVal;
  double? step;

  List<List<double>> values = [];

  Map<String, dynamic> _parseAll(String function, String xmin, String xmax) {
    if (function.isEmpty || xmin.isEmpty || xmax.isEmpty) {
      print('ERROR: Empty string');
      return {
        'status': false,
        'msgTitle': 'Empty fields!',
        'msg': 'Please fill any empty box to start plotting.'
      };
    }

    math.Parser parser = math.Parser();
    if (function.contains('/') ||
        function.contains('*') ||
        function.contains('-') ||
        function.contains('+') ||
        function.contains('^') ||
        function.contains('x') ||
        function.contains('(') ||
        function.contains(')') ||
        function.contains(RegExp(r'([0-9]*[.])?[0-9]+'))) {
      try {
        yVal = parser.parse(_functionController.text.toLowerCase());
      } catch (msg) {
        print('ERROR in y: $msg');
        return {
          'status': false,
          'msgTitle': 'Error in y expression.',
          'msg': msg.toString()
        };
      }

      try {
        xMinVal = parser.parse(_minXController.text);
      } catch (msg) {
        print('ERROR in Xmin: $msg');
        return {
          'status': false,
          'msgTitle': 'Error in Xmin Value.',
          'msg': msg.toString(),
        };
      }

      try {
        xMaxVal = parser.parse(_maxXController.text);
      } catch (msg) {
        print('ERROR in Xmax: $msg');
        return {
          'status': false,
          'msgTitle': 'Error in Xmax Value.',
          'msg': msg.toString(),
        };
      }

      return {
        'status': true,
        'msgTitle': '',
        'msg': '',
      };
    }
    print('ERROR: Unsupported symbol');
    return {
      'status': false,
      'msgTitle': 'Unsupported operator',
      'msg': 'Please enter a valid y expression with only supported operators.'
    };
  }

  _plot() {
    xMinVal = xMaxVal = yVal = null;
    values.clear();

    Map<String, dynamic> isValid = _parseAll(
      _functionController.text.toLowerCase(),
      _minXController.text,
      _maxXController.text,
    );

    if (!isValid['status']) {
      showDialog(
        context: context,
        builder: (context) {
          return Warning(isValid['msgTitle'], isValid['msg']);
        },
      );
      return;
    }

    math.ContextModel cntxt = math.ContextModel();
    math.Variable x = math.Variable('x');

    double minX = 0, maxX = 0;
    try {
      minX = xMinVal!.evaluate(math.EvaluationType.REAL, cntxt);
      maxX = xMaxVal!.evaluate(math.EvaluationType.REAL, cntxt);
    } catch (msg) {
      print('ERROR in evaluating Xmin or Xmax: $msg');
      showDialog(
        context: context,
        builder: (context) {
          return Warning('Error in Xmin or Xmax values', msg.toString());
        },
      );
      return;
    }

    if (minX >= maxX) {
      print('ERROR: Xmin should be less than Xmax');
      showDialog(
        context: context,
        builder: (context) {
          return Warning('Error in Xmin and Xmax values',
              'Error: Xmin should be less than Xmax');
        },
      );
      return;
    }
    step = (maxX - minX) / 200.0;
    // setState(() => _isPoint = step == 0);
    // if (step == 0) step = 1;
    for (double i = minX; i <= maxX; i += step ?? 0.1) {
      cntxt.bindVariable(x, math.Number(i));
      double y = 0;
      try {
        y = yVal!.evaluate(math.EvaluationType.REAL, cntxt);
      } catch (msg) {
        print('ERROR in evaluating y: $msg');
        showDialog(
          context: context,
          builder: (context) {
            return Warning('Error in y expression.', msg.toString());
          },
        );
        return;
      }
      setState(() {
        values.add([i, y]);
      });
    }
  }

  // @override
  // void initState() {
  //   super.initState();
  //   values.clear();
  // }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      // header: PageHeader(title: Text('Function Plotter'),),
      content: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: TextBox(
                        outsidePrefix: const Text(
                          'y =  ',
                          style: TextStyle(fontSize: 20),
                        ),
                        controller: _functionController,
                      ),
                    ),
                  ),
                  const Expanded(child: SizedBox(height: 20)),
                  Expanded(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width / 10,
                      child: TextBox(
                        outsidePrefix: const Text(
                          'x ₘᵢₙ =  ',
                          style: TextStyle(fontSize: 20),
                        ),
                        controller: _minXController,
                      ),
                    ),
                  ),
                  const Expanded(child: SizedBox(height: 20)),
                  Expanded(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width / 10,
                      child: TextBox(
                        outsidePrefix: const Text(
                          'x ₘₐₓ =  ',
                          style: TextStyle(fontSize: 20),
                        ),
                        controller: _maxXController,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: SizedBox(height: 20),
                  ),
                  Expanded(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: FilledButton(
                        child: const Text(
                          'Plot',
                          style: TextStyle(fontSize: 20),
                        ),
                        onPressed: _plot,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(
              direction: Axis.vertical,
              style: DividerThemeData(thickness: 0.5)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              child: values.isNotEmpty
                  ? LineChart(
                      LineChartData(
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipItems: (spots) {
                              return spots.map((LineBarSpot touchedSpot) {
                                const textStyle = TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                );
                                return LineTooltipItem(
                                    '(${touchedSpot.x.toStringAsFixed(2)}, ${touchedSpot.y.toStringAsFixed(2)})',
                                    textStyle);
                              }).toList();
                            },
                          ),
                        ),
                        baselineX: 0.0,
                        baselineY: 0.0,
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true)),
                          leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                  reservedSize: 40, showTitles: true)),
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            dotData: FlDotData(show: false),
                            isCurved: false,
                            spots: values
                                .map(((point) => FlSpot(point[0], point[1])))
                                .toList(),
                          )
                        ],
                      ),
                      swapAnimationDuration: const Duration(milliseconds: 200),
                      swapAnimationCurve: Curves.ease,
                    )
                  : SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class Warning extends StatelessWidget {
  String _msgTitle;
  String _msg;
  Warning(this._msgTitle, this._msg);

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text(_msgTitle),
      content: Text(_msg),
      actions: [
        Button(
          child: const Text('Ok'),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    );
  }
}
