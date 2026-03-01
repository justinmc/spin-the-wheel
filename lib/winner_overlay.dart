import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class WinnerOverlay extends StatefulWidget {
  const WinnerOverlay({super.key, required this.name, required this.onDismiss});

  final String name;
  final VoidCallback onDismiss;

  @override
  State<WinnerOverlay> createState() => _WinnerOverlayState();
}

class _WinnerOverlayState extends State<WinnerOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _flyIn;
  late final AnimationController _bounce;
  late final AnimationController _winnerLabel;
  late final AnimationController _dismissCtrl;

  late final Animation<double> _bgOpacity;
  late final Animation<double> _nameOffsetY;
  late final Animation<double> _nameRotation;
  late final Animation<double> _nameScale;
  late final Animation<double> _bounceScale;
  late final Animation<double> _labelOffsetY;
  late final Animation<double> _labelOpacity;
  late final Animation<double> _dismissOpacity;

  bool _dismissing = false;

  @override
  void initState() {
    super.initState();

    _flyIn = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _bounce = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _winnerLabel = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _dismissCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Background fades in during the first half of the fly-in
    _bgOpacity = Tween<double>(begin: 0, end: 0.82).animate(
      CurvedAnimation(
        parent: _flyIn,
        curve: const Interval(0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Name translates down from the top of the screen (where the wheel pointer is)
    _nameOffsetY = Tween<double>(
      begin: -320,
      end: 0,
    ).animate(CurvedAnimation(parent: _flyIn, curve: Curves.easeOutCubic));

    // Name rotates from sideways (as it appears on the wheel) to upright
    _nameRotation = Tween<double>(
      begin: -pi / 2,
      end: 0,
    ).animate(CurvedAnimation(parent: _flyIn, curve: Curves.easeOutCubic));

    // Name grows with an elastic spring overshoot
    _nameScale = Tween<double>(
      begin: 0.2,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _flyIn, curve: Curves.elasticOut));

    // Continuous gentle pulse after landing
    _bounceScale = Tween<double>(
      begin: 1.0,
      end: 1.07,
    ).animate(CurvedAnimation(parent: _bounce, curve: Curves.easeInOut));

    // "Winner!" slides up from off-screen below
    _labelOffsetY = Tween<double>(
      begin: 360,
      end: 0,
    ).animate(CurvedAnimation(parent: _winnerLabel, curve: Curves.easeOutBack));
    _labelOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _winnerLabel,
        curve: const Interval(0, 0.4, curve: Curves.easeOut),
      ),
    );

    _dismissOpacity = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(CurvedAnimation(parent: _dismissCtrl, curve: Curves.easeIn));

    _start();
  }

  Future<void> _start() async {
    await _flyIn.forward();
    _bounce.repeat(reverse: true);
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) _winnerLabel.forward();
  }

  Future<void> _dismiss() async {
    if (_dismissing) return;
    _dismissing = true;
    _bounce.stop();
    _winnerLabel.stop();
    await _dismissCtrl.forward();
    if (mounted) widget.onDismiss();
  }

  @override
  void dispose() {
    _flyIn.dispose();
    _bounce.dispose();
    _winnerLabel.dispose();
    _dismissCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
    color: Colors.transparent,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _flyIn,
          _bounce,
          _winnerLabel,
          _dismissCtrl,
        ]),
        builder: (context, _) {
          return Opacity(
            opacity: _dismissOpacity.value,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _dismiss,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Blurred + darkened backdrop
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child: ColoredBox(
                      color: Color.fromRGBO(0, 0, 0, _bgOpacity.value),
                    ),
                  ),
                  // Content
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Winning name: flies from top, rotates upright, springs into size
                        Transform.translate(
                          offset: Offset(0, _nameOffsetY.value),
                          child: Transform.rotate(
                            angle: _nameRotation.value,
                            child: Transform.scale(
                              scale: _nameScale.value * _bounceScale.value,
                              child: Text(
                                widget.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 80,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -1,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 30,
                                      color: Colors.amber,
                                      offset: Offset(0, 0),
                                    ),
                                    Shadow(
                                      blurRadius: 70,
                                      color: Colors.orange,
                                      offset: Offset(0, 0),
                                    ),
                                    Shadow(
                                      blurRadius: 4,
                                      color: Colors.black54,
                                      offset: Offset(2, 4),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),
                        // "Winner!" slides up from off-screen below
                        Transform.translate(
                          offset: Offset(0, _labelOffsetY.value),
                          child: Opacity(
                            opacity: _labelOpacity.value,
                            child: const Text(
                              'Winner!',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                                letterSpacing: 3,
                                shadows: [
                                  Shadow(
                                    blurRadius: 24,
                                    color: Colors.deepOrange,
                                    offset: Offset(0, 0),
                                  ),
                                  Shadow(
                                    blurRadius: 4,
                                    color: Colors.black54,
                                    offset: Offset(1, 3),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
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
