import 'package:flutter/material.dart';

class AlertModel {
  final String type;
  final String title;
  final String body;
  final double thresholdMeters;
  final double currentDistance;
  final String style;
  final Map<String, dynamic> payload;

  AlertModel({
    required this.type,
    required this.title,
    required this.body,
    required this.thresholdMeters,
    required this.currentDistance,
    required this.style,
    required this.payload,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      type: json['type'],
      title: json['title'],
      body: json['body'],
      thresholdMeters: (json['threshold_meters'] as num).toDouble(),
      currentDistance: (json['current_distance'] as num).toDouble(),
      style: json['style'],
      payload: json['payload'],
    );
  }

  String get uuid => payload['uuid'] ?? 'N/A';
  String get action => payload['action'] ?? '';
}
