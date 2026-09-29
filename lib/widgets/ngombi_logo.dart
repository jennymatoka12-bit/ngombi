import 'package:flutter/material.dart';

import '../theme/ngombi_colors.dart';
import '../theme/ngombi_typography.dart';

enum NgombiLogoVariant {
  full,
  compact,
  icon,
}

class NgombiLogo extends StatelessWidget {
  final NgombiLogoVariant variant;
  final double? height;

  const NgombiLogo({
    super.key,
    this.variant = NgombiLogoVariant.full,
    this.height,
  });

  const NgombiLogo.full({
    super.key,
    this.height,
  }) : variant = NgombiLogoVariant.full;

  const NgombiLogo.compact({
    super.key,
    this.height,
  }) : variant = NgombiLogoVariant.compact;

  const NgombiLogo.icon({
    super.key,
    this.height,
  }) : variant = NgombiLogoVariant.icon;

  @override
  Widget build(BuildContext context) {
    final logoHeight = height ?? _defaultHeight;

    switch (variant) {
      case NgombiLogoVariant.full:
        return _buildFullLogo(logoHeight);

      case NgombiLogoVariant.compact:
        return _buildCompactLogo(logoHeight);

      case NgombiLogoVariant.icon:
        return _buildIcon(logoHeight);
    }
  }

  double get _defaultHeight {
    switch (variant) {
      case NgombiLogoVariant.full:
        return 42;

      case NgombiLogoVariant.compact:
        return 36;

      case NgombiLogoVariant.icon:
        return 36;
    }
  }

  Widget _buildFullLogo(double height) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIcon(height),

        const SizedBox(width: 10),

        Text(
          'NGOMBI',
          style: NgombiTypography.title.copyWith(
            color: NgombiColors.textPrimary,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactLogo(double height) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIcon(height),

        const SizedBox(width: 8),

        Text(
          'NGOMBI',
          style: NgombiTypography.subtitle.copyWith(
            color: NgombiColors.textPrimary,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildIcon(double size) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: NgombiColors.orange,
          borderRadius: BorderRadius.circular(
            size * 0.28,
          ),
          boxShadow: [
            BoxShadow(
              color: NgombiColors.orange.withOpacity(0.25),
              blurRadius: 14,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.play_arrow_rounded,
              color: Colors.black,
              size: size * 0.58,
            ),

            Positioned(
              bottom: size * 0.12,
              left: size * 0.20,
              right: size * 0.20,
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  _waveBar(
                    size * 0.10,
                    size * 0.20,
                  ),

                  SizedBox(
                    width: size * 0.045,
                  ),

                  _waveBar(
                    size * 0.10,
                    size * 0.30,
                  ),

                  SizedBox(
                    width: size * 0.045,
                  ),

                  _waveBar(
                    size * 0.10,
                    size * 0.22,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _waveBar(
    double width,
    double height,
  ) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.75),
        borderRadius: BorderRadius.circular(width),
      ),
    );
  }
}
