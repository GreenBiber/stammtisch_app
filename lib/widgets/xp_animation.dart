import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class XPGainAnimation extends StatefulWidget {
  final String text;
  final VoidCallback? onComplete;

  const XPGainAnimation({
    super.key,
    required this.text,
    this.onComplete,
  });

  @override
  State<XPGainAnimation> createState() => _XPGainAnimationState();
}

class _XPGainAnimationState extends State<XPGainAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -1),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
    ));

    _controller.forward().then((_) {
      if (widget.onComplete != null) {
        widget.onComplete!();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  widget.text, // Text wird bereits lokalisiert übergeben
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class LevelUpAnimation extends StatefulWidget {
  final int newLevel;
  final String levelTitle;
  final VoidCallback? onComplete;

  const LevelUpAnimation({
    super.key,
    required this.newLevel,
    required this.levelTitle,
    this.onComplete,
  });

  @override
  State<LevelUpAnimation> createState() => _LevelUpAnimationState();
}

class _LevelUpAnimationState extends State<LevelUpAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.7, curve: Curves.easeInOut),
    ));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.8, 1.0, curve: Curves.easeIn),
    ));

    _controller.forward().then((_) {
      if (widget.onComplete != null) {
        widget.onComplete!();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n; // Lokalisierung hinzugefügt

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: RotationTransition(
              turns: _rotationAnimation,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.orange, Colors.yellow],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.locale.languageCode == 'de'
                          ? '🎉 LEVEL UP! 🎉'
                          : '🎉 LEVEL UP! 🎉', // Englisch bleibt gleich
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${l10n.level} ${widget.newLevel}', // LOKALISIERT
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.levelTitle, // Level-Titel wird bereits lokalisiert übergeben
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AchievementUnlockedAnimation extends StatefulWidget {
  final String achievementName;
  final String achievementIcon;
  final String achievementDescription;
  final VoidCallback? onComplete;

  const AchievementUnlockedAnimation({
    super.key,
    required this.achievementName,
    required this.achievementIcon,
    required this.achievementDescription,
    this.onComplete,
  });

  @override
  State<AchievementUnlockedAnimation> createState() => _AchievementUnlockedAnimationState();
}

class _AchievementUnlockedAnimationState extends State<AchievementUnlockedAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.bounceOut),
    ));

    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 0.6, curve: Curves.elasticOut),
    ));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.8, 1.0, curve: Curves.easeIn),
    ));

    _controller.forward().then((_) {
      if (widget.onComplete != null) {
        widget.onComplete!();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n; // Lokalisierung hinzugefügt

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Transform.translate(
            offset: Offset(_slideAnimation.value * MediaQuery.of(context).size.width, 0),
            child: ScaleTransition(
              scale: _bounceAnimation,
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.purple, Colors.blue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.achievementIcon,
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.locale.languageCode == 'de'
                                ? 'Achievement freigeschaltet!'
                                : 'Achievement unlocked!', // LOKALISIERT
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            widget.achievementName, // Achievement-Name wird bereits lokalisiert übergeben
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.achievementDescription, // Beschreibung wird bereits lokalisiert übergeben
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// XP Animation Overlay Widget
class XPAnimationOverlay extends StatefulWidget {
  final Widget child;

  const XPAnimationOverlay({
    super.key,
    required this.child,
  });

  @override
  State<XPAnimationOverlay> createState() => XPAnimationOverlayState();
}

class XPAnimationOverlayState extends State<XPAnimationOverlay> {
  final List<Widget> _activeAnimations = [];

  void showXPGain(String text) {
    final animation = XPGainAnimation(
      text: text, // Text wird bereits lokalisiert übergeben
      onComplete: () {
        setState(() {
          _activeAnimations.removeWhere((w) => w is XPGainAnimation);
        });
      },
    );

    setState(() {
      _activeAnimations.add(animation);
    });
  }

  void showLevelUp(int newLevel, String levelTitle) {
    final animation = LevelUpAnimation(
      newLevel: newLevel,
      levelTitle: levelTitle, // Titel wird bereits lokalisiert übergeben
      onComplete: () {
        setState(() {
          _activeAnimations.removeWhere((w) => w is LevelUpAnimation);
        });
      },
    );

    setState(() {
      _activeAnimations.add(animation);
    });
  }

  void showAchievementUnlock(String name, String icon, String description) {
    final animation = AchievementUnlockedAnimation(
      achievementName: name, // Name wird bereits lokalisiert übergeben
      achievementIcon: icon,
      achievementDescription: description, // Beschreibung wird bereits lokalisiert übergeben
      onComplete: () {
        setState(() {
          _activeAnimations.removeWhere((w) => w is AchievementUnlockedAnimation);
        });
      },
    );

    setState(() {
      _activeAnimations.add(animation);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // Animation Overlay
        if (_activeAnimations.isNotEmpty)
          Positioned.fill(
            child: IgnorePointer(
              child: Stack(
                children: [
                  // XP Gains (top center)
                  ..._activeAnimations
                      .where((w) => w is XPGainAnimation)
                      .map((w) => Positioned(
                            top: 100,
                            left: 0,
                            right: 0,
                            child: Center(child: w),
                          )),
                  
                  // Level Ups (center)
                  ..._activeAnimations
                      .where((w) => w is LevelUpAnimation)
                      .map((w) => Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Center(child: w),
                          )),
                  
                  // Achievements (top right)
                  ..._activeAnimations
                      .where((w) => w is AchievementUnlockedAnimation)
                      .map((w) => Positioned(
                            top: 50,
                            right: 0,
                            child: w,
                          )),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// Confetti Animation für besondere Momente
class ConfettiAnimation extends StatefulWidget {
  final Widget child;
  final bool trigger;

  const ConfettiAnimation({
    super.key,
    required this.child,
    this.trigger = false,
  });

  @override
  State<ConfettiAnimation> createState() => _ConfettiAnimationState();
}

class _ConfettiAnimationState extends State<ConfettiAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Offset> _confettiPositions;
  late List<Color> _confettiColors;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _generateConfetti();

    if (widget.trigger) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(ConfettiAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _generateConfetti();
      _controller.reset();
      _controller.forward();
    }
  }

  void _generateConfetti() {
    _confettiPositions = List.generate(20, (index) {
      return Offset(
        (index % 4) * 0.25 + 0.125,
        -0.1,
      );
    });

    _confettiColors = List.generate(20, (index) {
      final colors = [Colors.red, Colors.blue, Colors.green, Colors.yellow, Colors.purple];
      return colors[index % colors.length];
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.trigger)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: ConfettiPainter(
                  animation: _controller,
                  positions: _confettiPositions,
                  colors: _confettiColors,
                ),
                size: Size.infinite,
              );
            },
          ),
      ],
    );
  }
}

class ConfettiPainter extends CustomPainter {
  final Animation<double> animation;
  final List<Offset> positions;
  final List<Color> colors;

  ConfettiPainter({
    required this.animation,
    required this.positions,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (int i = 0; i < positions.length; i++) {
      final progress = animation.value;
      final x = positions[i].dx * size.width;
      final y = positions[i].dy * size.height + (progress * size.height * 1.2);
      
      paint.color = colors[i].withOpacity(1.0 - progress);
      
      canvas.drawCircle(
        Offset(x, y),
        4.0,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}