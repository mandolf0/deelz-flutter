import 'package:flutter/material.dart';

// Our design contains Neumorphism design and i made a extention for it
// We can apply it on any  widget

extension Mitchify on Widget {
  addNeoMitch({
    double borderRadius = 15.0,
    Offset offset = const Offset(4, 4),
    double blurRadius = 15,
    Color topShadowColor = Colors.white60,
    Color bottomShadowColor = const Color(0x26234395),
    bool elevated = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        // color: Colors.grey[300],
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: Colors.white60,
                  offset: offset,
                  blurRadius: blurRadius,
                  spreadRadius: 1.0,
                ),
                BoxShadow(
                  color: Colors.grey[500]!,
                  offset: const Offset(-5.0, -5.0),
                  blurRadius: blurRadius,
                  spreadRadius: 1.0,
                ),
              ]
            : [],
      ),
      child: this,
    );
  }
}

extension Neumorphism on Widget {
  addNeumorphism({
    double borderRadius = 10.0,
    Offset offset = const Offset(5, 5),
    double blurRadius = 10,
    Color topShadowColor = Colors.white30,
    Color bottomShadowColor = const Color(0x26234395),
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        boxShadow: [
          BoxShadow(
            offset: offset,
            blurRadius: blurRadius,
            color: bottomShadowColor,
          ),
          BoxShadow(
            offset: Offset(-offset.dx, -offset.dx),
            blurRadius: blurRadius,
            color: topShadowColor,
          ),
        ],
      ),
      child: this,
    );
  }
}
