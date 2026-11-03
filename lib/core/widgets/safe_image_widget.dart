import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SafeImageWidget extends StatelessWidget {
  final String? path;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;

  const SafeImageWidget({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    if (path == null || path!.isEmpty) {
      return _buildPlaceholder();
    }

    if (kIsWeb) {
      if (path!.startsWith('http://') ||
          path!.startsWith('https://') ||
          path!.startsWith('blob:') ||
          path!.startsWith('data:')) {
        return Image.network(
          path!,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (_, __, ___) => _buildPlaceholder(),
        );
      }
      return _buildPlaceholder();
    }

    try {
      final file = File(path!);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (_, __, ___) => _buildPlaceholder(),
        );
      }
    } catch (_) {}

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return placeholder ??
        Container(
          width: width,
          height: height,
          color: Colors.grey.withValues(alpha: 0.1),
          child: const Icon(Icons.image, color: Colors.grey, size: 28),
        );
  }
}
