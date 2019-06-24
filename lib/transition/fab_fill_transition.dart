import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:reply/styling.dart';

class FabFillTransition extends StatelessWidget {
  const FabFillTransition({
    Key key,
    @required this.source,
    @required this.child,
    @required this.icon,
  })  : assert(source != null),
        assert(child != null),
        assert(icon != null),
        super(key: key);

  final Rect source;
  final Widget child;
  final String icon;

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = ModalRoute.of(context).animation;
    final Animation<double> secondary = ModalRoute.of(context).secondaryAnimation;

    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      final Animation<double> positionAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutQuad,
      );

      final Animation<RelativeRect> itemPosition = RelativeRectTween(
        begin: RelativeRect.fromLTRB(source.left, source.top, constraints.biggest.width - source.right,
            constraints.biggest.height - source.bottom),
        end: RelativeRect.fill,
      ).animate(positionAnimation);

      final size = MediaQuery.of(context).size;

      final Animation<double> revealScale = CurvedAnimation(
        parent: animation,
        curve: const Interval(0.0, 0.8, curve: Curves.fastOutSlowIn),
      );

      final Animation<double> revealOpacity = ReverseAnimation(CurvedAnimation(
        parent: animation,
        curve: const Interval(0.5, 1, curve: Curves.ease),
      ));

      final Animation<double> iconScaleAnimation = CurvedAnimation(
        parent: animation,
        curve: const Interval(0.0, 0.7, curve: Curves.fastOutSlowIn),
      );

      final Animation<double> pageFade = CurvedAnimation(
        parent: animation,
        curve: const Interval(0.5, 0.5, curve: Curves.easeOutExpo),
      );

      final Tween<double> fabIconTween = Tween<double>(begin: 1.0, end: 3.0);

      return Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          FadeTransition(
            opacity: pageFade,
            child: child,
          ),
          PositionedTransition(
            rect: itemPosition,
            child: AnimatedBuilder(
                animation: animation,
                builder: (context, _) {
                  return OverflowBox(
                    alignment: Alignment.center,
                    minWidth: constraints.minWidth * 2,
                    maxWidth: constraints.maxWidth * 2,
                    minHeight: constraints.maxHeight * math.pi,
                    maxHeight: constraints.maxHeight * math.pi,
                    child: ClipPath(
                      clipper: _RevealClipper(
                        minRadius: source.size.longestSide / 2,
                        progress: revealScale.value,
                      ),
                      child: FadeTransition(
                        opacity: revealOpacity,
                        child: Stack(
                          overflow: Overflow.visible,
                          fit: StackFit.passthrough,
                          children: <Widget>[
                            ConstrainedBox(
                              constraints: BoxConstraints.loose(size),
                              child: Container(
                                color: AppTheme.orange,
                                child: GestureDetector(
                                  onTap: () => Navigator.of(context).pop(),
                                ),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              height: double.infinity,
                              alignment: Alignment.center,
                              child: ScaleTransition(
                                alignment: Alignment.topCenter,
                                scale: fabIconTween.animate(iconScaleAnimation),
                                child: Image.asset(
                                  icon,
                                  width: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
          ),
        ],
      );
    });
  }
}

class _RevealClipper extends CustomClipper<Path> {
  const _RevealClipper({
    this.minRadius = 0,
    @required this.progress,
  })  : assert(minRadius != null),
        assert(minRadius >= 0),
        assert(progress != null),
        super();

  final double minRadius;

  final double progress;

  @override
  Path getClip(Size size) {
    final radius = minRadius + (progress * size.longestSide / 2 * math.sqrt2);
    return Path()
      ..addOval(Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: radius,
      ));
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    if (oldClipper.runtimeType != _RevealClipper) return true;
    final _RevealClipper other = oldClipper;
    return other.progress != progress || other.minRadius != minRadius;
  }
}
