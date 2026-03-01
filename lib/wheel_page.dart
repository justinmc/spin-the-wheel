import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'section_config_page.dart';
import 'wheel_painter.dart';

class WheelPage extends StatefulWidget {
  const WheelPage({super.key});

  @override
  State<WheelPage> createState() => _WheelPageState();
}

class _WheelPageState extends State<WheelPage>
    with SingleTickerProviderStateMixin {
  List<String> _sections = [
    'Pizza',
    'Tacos',
    'Sushi',
    'Burgers',
    'Pasta',
    'Salad',
  ];

  late AnimationController _controller;
  double _currentAngle = 0.0;
  double _previousAngle = 0.0;
  Offset? _panCenter;
  double? _lastPanAngle;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this);
    _controller.addListener(() {
      setState(() => _currentAngle = _controller.value);
    });
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _showWinner();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _angleTo(Offset position) {
    final delta = position - _panCenter!;
    return atan2(delta.dy, delta.dx);
  }

  void _onPanStart(DragStartDetails details) {
    _controller.stop();
    final box = context.findRenderObject() as RenderBox;
    _panCenter = box.size.center(Offset.zero);
    _lastPanAngle = _angleTo(details.localPosition);
    _previousAngle = _currentAngle;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final angle = _angleTo(details.localPosition);
    var delta = angle - _lastPanAngle!;

    // Correct wrapping at ±pi boundary
    if (delta > pi) {
      delta -= 2 * pi;
    } else if (delta < -pi) {
      delta += 2 * pi;
    }

    setState(() {
      _currentAngle += delta;
    });
    _lastPanAngle = angle;
  }

  void _onPanEnd(DragEndDetails details) {
    final angularVelocity = (_currentAngle - _previousAngle) * 20;

    if (angularVelocity.abs() < 0.5) {
      // Too slow, no spin
      return;
    }

    final simulation = FrictionSimulation(
      0.15,
      _currentAngle,
      angularVelocity,
    );

    _controller.animateWith(simulation);
  }

  void _showWinner() {
    final sectionAngle = 2 * pi / _sections.length;
    // Pointer is at top center (-pi/2). Normalize to find which section is there.
    final normalized = ((-pi / 2 - _currentAngle) % (2 * pi) + 2 * pi) % (2 * pi);
    final index = (normalized / sectionAngle).floor() % _sections.length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Winner!'),
        content: Text(
          _sections[index],
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _openSettings() async {
    final result = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(
        builder: (context) => SectionConfigPage(sections: _sections),
      ),
    );
    if (result != null && mounted) {
      setState(() => _sections = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Spin the Wheel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wheelSize =
              min(constraints.maxWidth, constraints.maxHeight - 40) * 0.85;
          return Center(
            child: SizedBox(
              width: wheelSize,
              height: wheelSize + 30,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Wheel
                  Positioned(
                    top: 30,
                    child: GestureDetector(
                      onPanStart: _onPanStart,
                      onPanUpdate: _onPanUpdate,
                      onPanEnd: _onPanEnd,
                      child: SizedBox(
                        width: wheelSize,
                        height: wheelSize,
                        child: CustomPaint(
                          painter: WheelPainter(
                            sections: _sections,
                            rotationAngle: _currentAngle,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Pointer arrow at top center
                  Positioned(
                    top: 0,
                    child: CustomPaint(
                      size: const Size(30, 30),
                      painter: _PointerPainter(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);

    // Border
    final borderPaint = Paint()
      ..color = Colors.red.shade900
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
