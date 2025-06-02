import 'package:flutter/material.dart';

class ServiceCategory {
  final String name;
  final IconData icon;
  final String? parentCategory;

  ServiceCategory(this.name, this.icon, [this.parentCategory]);
}
