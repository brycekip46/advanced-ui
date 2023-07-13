import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:particle_field/particle_field.dart';
import 'dart:math';

import 'package:rnd/rnd.dart';

class ParticalOverlay extends StatelessWidget {
  const ParticalOverlay({super.key, required this.color, required this.energy});
  final Color color;
  final double energy;

  @override
  Widget build(BuildContext context) {
    return ParticleField(
      spriteSheet:
          SpriteSheet(image: AssetImage("assets/images/particle-wave.png")),
      onTick: (controller, _, size) {
        List<Particle> particles = controller.particles;

        double a = rnd(pi * 2);
        double dist = rnd(1, 4) * 35 + 150 * energy;
        double velocity = rnd(1, 2) * (1 + energy * 1.8);
        particles.add(Particle(
          lifespan: rnd(1, 2) * 20 + energy * 15,
          x: cos(a) * dist,
          y: sin(a) * dist,
          vx: cos(a) * velocity,
          vy: sin(a) * velocity,
          rotation: a,
          scale: rnd(1, 2) * 0.6 + energy * 0.5,
        ));
        for (int i = particles.length - 1; i >= 0; i--) {
          Particle p = particles[i];
          if (p.lifespan <= 0) {
            particles.removeAt(i);
            continue;
          }
          p.update(
              scale: p.scale * 1.025,
              vx: p.vx * 1.025,
              vy: p.vy * 1.025,
              color: color.withOpacity(p.lifespan * 0.001 + 0.01),
              lifespan: p.lifespan - 1);
        }
      },
      blendMode: BlendMode.dstIn,
    );
  }
}
