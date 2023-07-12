import 'package:extra_alignments/extra_alignments.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:focusable_control_builder/focusable_control_builder.dart';
import 'package:gap/gap.dart';
import 'package:next_gen_ui/assets.dart';
import 'package:next_gen_ui/common/shader_effect.dart';
import 'package:next_gen_ui/common/ticking_builder.dart';
import 'package:next_gen_ui/common/ui_scaler.dart';
import 'package:next_gen_ui/styles.dart';
import 'package:provider/provider.dart';

class TitleScreenUi extends StatelessWidget {
  const TitleScreenUi(
      {super.key,
      required this.difficulty,
      required this.onDifficultyPressed,
      required this.onDifficultyFocused,
      required this.onStartPressed});

  final int difficulty;
  final void Function(int difficulty) onDifficultyPressed;
  final void Function(int? difficulty) onDifficultyFocused;
  final VoidCallback onStartPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40, horizontal: 50),
      child: Stack(
        children: [
          TopLeft(
            child: UiScaler(child: _TitleText(), alignment: Alignment.topLeft),
          ),
          BottomLeft(
            child: UiScaler(
              child: _DifficultyBtns(
                difficulty: difficulty,
                onDifficultyFocused: onDifficultyFocused,
                onDifficultyPressed: onDifficultyPressed,
              ),
              alignment: Alignment.bottomLeft,
            ),
          ),
          BottomRight(
            child: UiScaler(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.only(bottom: 20, right: 40),
                child: _StartBtn(
                  onPressed: onStartPressed,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _StartBtn extends StatefulWidget {
  const _StartBtn({super.key, required this.onPressed});
  final VoidCallback onPressed;

  @override
  State<_StartBtn> createState() => __StartBtnState();
}

class __StartBtnState extends State<_StartBtn>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  bool _wasHovered = false;
  @override
  Widget build(BuildContext context) {
    return FocusableControlBuilder(
        cursor: SystemMouseCursors.click,
        onPressed: widget.onPressed,
        builder: (_, state) {
          if ((state.isHovered || state.isFocused) &&
              !_wasHovered &&
              _controller?.status != AnimationStatus.forward) {
            _controller?.forward(from: 0);
          }
          _wasHovered = (state.isHovered || state.isFocused);
          return SizedBox(
                  width: 520,
                  height: 100,
                  child: Stack(
                    children: [
                      Positioned.fill(
                          child: Image.asset(AssetPaths.titleStartBtn)),
                      if (state.isHovered || state.isFocused) ...[
                        Positioned.fill(
                            child: Image.asset(AssetPaths.titleStartBtnHover)),
                      ],
                      Center(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "START MISSION",
                                style: TextStyles.btn
                                    .copyWith(fontSize: 24, letterSpacing: 18),
                              )
                            ]),
                      )
                    ],
                  )
                      .animate(autoPlay: false, onInit: (c) => _controller = c)
                      .shimmer(duration: .1.seconds, color: Colors.black))
              .animate()
              .fadeIn(delay: 2.3.seconds)
              .slide(begin: Offset(0, .2));
        });
  }
}

class _TitleText extends StatelessWidget {
  const _TitleText({super.key});

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Gap(20),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.translate(
                offset: Offset(-(TextStyles.h1.letterSpacing! * .5), 0),
                child: Text(
                  "THE OUTPOST",
                  style: TextStyles.h1,
                )),
            Image.asset(
              AssetPaths.titleSelectedLeft,
              height: 65,
            ),
            Text(
              "57",
              style: TextStyles.h2,
            ),
            Image.asset(
              AssetPaths.titleSelectedRight,
              height: 65,
            ),
          ],
        ).animate().fadeIn(delay: .8.seconds, duration: .7.seconds),
        Text("INTO THE BADLANDS", style: TextStyles.h3)
            .animate()
            .fadeIn(delay: 1.seconds, duration: .7.seconds)
      ],
    );

    return Consumer<FragmentPrograms?>(builder: (context, fragmentPrograms, _) {
      if (fragmentPrograms == null) return content;
      return TickingBuilder(
        builder: (context, time) {
          return AnimatedSampler((image, size, canvas) {
            const double overdrawPx = 30;
            final shader = fragmentPrograms.ui.fragmentShader();
            shader
              ..setFloat(0, size.width)
              ..setFloat(1, size.height)
              ..setFloat(2, time)
              ..setImageSampler(0, image);
            Rect rect = Rect.fromLTWH(-overdrawPx, -overdrawPx,
                size.width + overdrawPx, size.height + overdrawPx);
            canvas.drawRect(rect, Paint()..shader = shader);
          }, child: content);
        },
      );
    });
  }
}

class _DifficultyBtns extends StatelessWidget {
  const _DifficultyBtns(
      {super.key,
      required this.difficulty,
      required this.onDifficultyPressed,
      required this.onDifficultyFocused});

  final int difficulty;
  final void Function(int difficulty) onDifficultyPressed;
  final void Function(int? difficulty) onDifficultyFocused;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _DifficultyBtn(
                label: "Casual",
                selected: difficulty == 0,
                onPressed: () => onDifficultyPressed(0),
                onHover: (over) => onDifficultyFocused(over ? 1 : null))
            .animate()
            .fadeIn(delay: 1.2.seconds, duration: 1.seconds)
            .slide(begin: Offset(0, .2)),
        _DifficultyBtn(
                label: "Normal",
                selected: difficulty == 1,
                onPressed: () => onDifficultyPressed(1),
                onHover: (over) => onDifficultyFocused(over ? 1 : null))
            .animate()
            .fadeIn(delay: 1.5.seconds, duration: 1.seconds)
            .slide(begin: const Offset(0, .2)),
        _DifficultyBtn(
                label: "Hardcore",
                selected: difficulty == 2,
                onPressed: () => onDifficultyPressed(2),
                onHover: (onHover) => onDifficultyFocused(onHover ? 2 : null))
            .animate()
            .fadeIn(delay: 1.7.seconds, duration: 1.seconds)
            .slide(begin: Offset(0, 0.2)),
        Gap(20)
      ],
    );
  }
}

class _DifficultyBtn extends StatelessWidget {
  const _DifficultyBtn(
      {super.key,
      required this.label,
      required this.selected,
      required this.onPressed,
      required this.onHover});

  final String label;
  final bool selected;
  final VoidCallback onPressed;
  final void Function(bool hasFocus) onHover;

  @override
  Widget build(BuildContext context) {
    return FocusableControlBuilder(
        onPressed: onPressed,
        onHoverChanged: (_, state) => onHover.call(state.isHovered),
        builder: (_, state) {
          return Padding(
            padding: EdgeInsets.all(10),
            child: SizedBox(
              width: 250,
              height: 60,
              child: Stack(children: [
                AnimatedOpacity(
                  opacity: (!selected && (state.isHovered || state.isFocused))
                      ? 1
                      : 0,
                  duration: .5.seconds,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Color(0xFF00D1FF).withOpacity(.1),
                        border: Border.all(color: Colors.white, width: 5)),
                  ),
                ),
                if (state.isHovered || state.isFocused) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF00D1FF).withOpacity(.1),
                    ),
                  )
                ],
                if (selected) ...[
                  CenterLeft(
                    child: Image.asset(AssetPaths.titleSelectedLeft),
                  ),
                  CenterRight(
                    child: Image.asset(AssetPaths.titleSelectedRight),
                  )
                ],
                Center(
                  child: Text(
                    label.toUpperCase(),
                    style: TextStyles.btn,
                  ),
                )
              ]),
            ),
          );
        });
  }
}
