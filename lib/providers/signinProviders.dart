import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final emailControllerProvider =
    Provider<TextEditingController>((ref) => TextEditingController());
final passwordControllerProvider =
    Provider<TextEditingController>((ref) => TextEditingController());
