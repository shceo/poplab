import 'package:flutter/material.dart';
import 'dart:math';

enum HazardType {
  jellyfish,  // Медуза
  blade,      // Лезвие
}

class Hazard {
  String id;
  HazardType type;
  Offset position;
  Offset velocity;
  double size;
  double rotation;
  double rotationSpeed;

  Hazard({
    required this.id,
    required this.type,
    required this.position,
    required this.velocity,
    this.size = 50.0,
    this.rotation = 0.0,
    this.rotationSpeed = 1.0,
  });

  void update(double dt, Size screenSize) {
    // Обновляем позицию
    position = Offset(
      position.dx + velocity.dx * dt,
      position.dy + velocity.dy * dt,
    );

    // Обновляем вращение
    rotation += rotationSpeed * dt;

    // Отскок от границ
    if (position.dx < 0 || position.dx > screenSize.width) {
      velocity = Offset(-velocity.dx, velocity.dy);
      position = Offset(
        position.dx.clamp(0, screenSize.width),
        position.dy,
      );
    }

    if (position.dy < 0 || position.dy > screenSize.height) {
      velocity = Offset(velocity.dx, -velocity.dy);
      position = Offset(
        position.dx,
        position.dy.clamp(0, screenSize.height),
      );
    }
  }

  bool intersects(Offset bubblePos, double bubbleRadius) {
    final distance = (position - bubblePos).distance;
    return distance < (size / 2 + bubbleRadius);
  }
}
