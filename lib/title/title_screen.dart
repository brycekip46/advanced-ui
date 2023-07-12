import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:next_gen_ui/assets.dart';
import 'package:next_gen_ui/styles.dart';
import 'package:next_gen_ui/title/title_ui.dart';
import 'package:next_gen_ui/orb_shader/orb_shader_widget.dart';

import '../orb_shader/orb_shader_config.dart';

class Title_screen extends StatefulWidget {
  const Title_screen({super.key});

  @override
  State<Title_screen> createState() => _Title_screenState();
}

class _Title_screenState extends State<Title_screen>
    with SingleTickerProviderStateMixin {
  final _orbKey = GlobalKey<OrbShaderWidgetState>();
  final _minRecieveAmt = .35;
  final _maxReceiveAmt = .7;

  final _minEmitAmt = .5;
  final _maxEmitAmt = 1;

  var _mousePos = Offset.zero;

  Color get _emitColor =>
      AppColors.emitColors[_difficultyOverride ?? _difficulty];
  Color get _orbColor =>
      AppColors.orbColors[_difficultyOverride ?? _difficulty];

  int _difficulty = 0;

  int? _difficultyOverride;
  double _orbEngery = 0;
  double _minOrbEngery = 0;

  double get _finalReceiveLightAmt {
    final light = lerpDouble(_minRecieveAmt, _maxReceiveAmt, _orbEngery) ?? 0;
    return light + _pulseEffect.value * .05 * _orbEngery;
  }

  double get _finalEmitAmt {
    return lerpDouble(_minEmitAmt, _maxEmitAmt, _orbEngery) ?? 0;
  }

  late final _pulseEffect = AnimationController(
    vsync: this,
    duration: _getRndPulseDuration(),
    lowerBound: -1,
    upperBound: 1,
  );

  Duration _getRndPulseDuration() => 300.ms * Random().nextDouble();

  double _getMinEnergyForDiff(int difficulty) {
    if (difficulty == 1) {
      return .3;
    } else if (difficulty == 2) {
      return .6;
    }
    return 0;
  }

  void _handleDifficultyPressed(int value) {
    setState(() => _difficulty = value);
    _bumpMinEnergy();
  }

  void _handleDifficultyFocused(int? value) {
    setState(() {
      _difficultyOverride = value;
      if (value == null) {
        _minOrbEngery = _getMinEnergyForDiff(_difficulty);
      } else {
        _minOrbEngery = _getMinEnergyForDiff(value);
      }
    });
  }

  void _handleMouseMove(PointerHoverEvent e) {
    setState(() {
      _mousePos = e.localPosition;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pulseEffect.forward();
    _pulseEffect.addListener(_handlePulseEffectUpdate);
  }

  void _handlePulseEffectUpdate() {
    if (_pulseEffect.status == AnimationStatus.completed) {
      _pulseEffect.reverse();
      _pulseEffect.duration = _getRndPulseDuration();
    } else if (_pulseEffect.status == AnimationStatus.dismissed) {
      _pulseEffect.duration = _getRndPulseDuration();
      _pulseEffect.forward();
    }
  }

  Future<void> _bumpMinEnergy([double amt = 0.1]) async {
    setState(() {
      _minOrbEngery = _getMinEnergyForDiff(_difficulty) + amt;
    });
    await Future<void>.delayed(.2.seconds);
    setState(() {
      _minOrbEngery = _getMinEnergyForDiff(_difficulty);
    });
  }

  void _handleStartPressed() => _bumpMinEnergy(0.3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: MouseRegion(
            onHover: _handleMouseMove,
            child: _AnimatedColors(
                orbColor: _orbColor,
                emitColor: _emitColor,
                builder: (_, orbColor, emitColor) {
                  return Stack(
                    children: [
                      // Background pictures
                      Image.asset(AssetPaths.titleBgBase),

                      _Litimage(
                        color: _orbColor,
                        imgSrc: AssetPaths.titleBgReceive,
                        lightAmt: _finalReceiveLightAmt,
                        pulseEffect: _pulseEffect,
                      ),

                      Positioned.fill(
                          child: Stack(children: [
                        OrbShaderWidget(
                            key: _orbKey,
                            config: OrbShaderConfig(
                                ambientLightColor: orbColor,
                                materialColor: orbColor,
                                lightColor: orbColor),
                            onUpdate: (energy) => setState(() {
                                  _orbEngery = energy;
                                }),
                            mousePos: _mousePos,
                            minEnergy: _minOrbEngery)
                      ])),

                      //Middle ground
                      _Litimage(
                        imgSrc: AssetPaths.titleMgBase,
                        color: _orbColor,
                        lightAmt: _finalReceiveLightAmt,
                        pulseEffect: _pulseEffect,
                      ),

                      _Litimage(
                        color: _orbColor,
                        lightAmt: _finalReceiveLightAmt,
                        imgSrc: AssetPaths.titleMgReceive,
                        pulseEffect: _pulseEffect,
                      ),

                      _Litimage(
                        imgSrc: AssetPaths.titleMgEmit,
                        color: _emitColor,
                        lightAmt: _finalReceiveLightAmt,
                        pulseEffect: _pulseEffect,
                      ),

                      //fore ground

                      Image.asset(AssetPaths.titleFgBase),

                      _Litimage(
                        imgSrc: AssetPaths.titleFgReceive,
                        color: _orbColor,
                        lightAmt: _finalReceiveLightAmt,
                        pulseEffect: _pulseEffect,
                      ),

                      _Litimage(
                        imgSrc: AssetPaths.titleFgEmit,
                        lightAmt: _finalEmitAmt,
                        color: _emitColor,
                        pulseEffect: _pulseEffect,
                      ),

                      Positioned.fill(
                          child: TitleScreenUi(
                              difficulty: _difficulty,
                              onDifficultyPressed: _handleDifficultyPressed,
                              onDifficultyFocused: _handleDifficultyFocused,
                              onStartPressed: _handleStartPressed))
                    ],
                  ).animate().fade(duration: 1.seconds, delay: .3.seconds);
                })),
      ),
    );
  }
}

class _Litimage extends StatelessWidget {
  final Color color;
  final String imgSrc;
  final double lightAmt;
  final AnimationController pulseEffect;

  const _Litimage(
      {required this.color,
      required this.imgSrc,
      required this.lightAmt,
      required this.pulseEffect});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final hsl = HSLColor.fromColor(color);
    return ListenableBuilder(
      listenable: pulseEffect,
      builder: (context, child) {
        return Image.asset(
          imgSrc,
          color: hsl.withLightness(hsl.lightness * lightAmt).toColor(),
          colorBlendMode: BlendMode.modulate,
        );
      },
    );
  }
}

class _AnimatedColors extends StatelessWidget {
  const _AnimatedColors({
    required this.emitColor,
    required this.orbColor,
    required this.builder,
  });

  final Color emitColor;
  final Color orbColor;

  final Widget Function(BuildContext context, Color orbColor, Color emitColor)
      builder;

  @override
  Widget build(BuildContext context) {
    final duration = .5.seconds;
    return TweenAnimationBuilder(
      tween: ColorTween(begin: emitColor, end: emitColor),
      duration: duration,
      builder: (_, emitColor, __) {
        return TweenAnimationBuilder(
          tween: ColorTween(begin: orbColor, end: orbColor),
          duration: duration,
          builder: (context, orbColor, __) {
            return builder(context, orbColor!, emitColor!);
          },
        );
      },
    );
  }
}
