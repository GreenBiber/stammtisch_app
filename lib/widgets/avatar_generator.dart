import 'package:flutter/material.dart';

class AvatarGenerator extends StatelessWidget {
  final String name;
  final double radius;

  const AvatarGenerator({
    super.key,
    required this.name,
    this.radius = 24,
  });

  /// Ermittelt Initialen aus einem Gruppennamen
  String _initials(String input) {
    final cleaned = input.trim();
    if (cleaned.isEmpty) return "?";

    final words = cleaned.split(RegExp(r'\s+'));
    if (words.length >= 2) {
      return (words[0][0] + words[1][0]).toUpperCase();
    } else if (words[0].length >= 2) {
      return words[0].substring(0, 2).toUpperCase();
    } else {
      return words[0].substring(0, 1).toUpperCase();
    }
  }

  /// Erzeugt eine stabile Farbe aus dem Gruppennamen
  Color _colorFromName(String input) {
    if (input.isEmpty) return Colors.grey;
    final hash = input.codeUnits.fold<int>(0, (int p, int c) => p + c);
    const colors = Colors.primaries;
    return colors[hash % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: _colorFromName(name),
      child: Text(
        _initials(name),
        style:
            const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}
