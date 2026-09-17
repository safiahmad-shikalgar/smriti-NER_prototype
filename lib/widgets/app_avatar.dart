import 'dart:io';

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class AppAvatar extends StatelessWidget {
  final String? imagePath;
  final double size;
  final VoidCallback? onTap;
  final Color borderColor;
  final double borderWidth;

  const AppAvatar({
    super.key,
    this.imagePath,
    this.size = 48.0,
    this.onTap,
    this.borderColor = AppColors.sageGreen,
    this.borderWidth = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider? provider;
    if (imagePath != null && imagePath!.isNotEmpty) {
      if (imagePath!.startsWith('assets/')) {
        provider = AssetImage(imagePath!);
      } else if (File(imagePath!).existsSync()) {
        provider = FileImage(File(imagePath!));
      }
    }

    Widget avatarWidget = Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: AppColors.warmPaleCoral,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: borderWidth, color: borderColor),
          borderRadius: BorderRadius.circular(size / 2),
        ),
      ),
      child: provider != null
          ? Image(image: provider, fit: BoxFit.cover)
          : Icon(Icons.person, size: size * 0.55, color: AppColors.sageGreen),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: Semantics(
          label: 'User profile avatar',
          button: true,
          child: avatarWidget,
        ),
      );
    }

    return avatarWidget;
  }
}
