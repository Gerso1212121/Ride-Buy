// Widget OverlappingProfileAvatar HORIZONTAL (corregido)
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class OverlappingProfileAvatar extends StatelessWidget {
  final String profileImageUrl;
  final String? businessName;
  final String? businessType;
  final double avatarSize;
  final double overlapAmount;
  final Color borderColor;
  final double borderWidth;
  final TextStyle? businessNameStyle;
  final TextStyle? businessTypeStyle;

  const OverlappingProfileAvatar({
    super.key,
    required this.profileImageUrl,
    this.businessName,
    this.businessType,
    this.avatarSize = 100,
    this.overlapAmount = 0,
    this.borderColor = Colors.white,
    this.borderWidth = 4.0,
    this.businessNameStyle,
    this.businessTypeStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultNameStyle = businessNameStyle ??
        theme.textTheme.titleLarge!.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 22,
        );
    final defaultTypeStyle = businessTypeStyle ??
        theme.textTheme.bodyMedium!.copyWith(
          color: theme.hintColor,
        );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: borderColor,
              width: borderWidth,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(avatarSize / 2),
            child: profileImageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: profileImageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => _buildPlaceholder(),
                    errorWidget: (context, url, error) => _buildPlaceholder(),
                  )
                : _buildPlaceholder(),
          ),
        ),
        const SizedBox(width: 12),

        // Texto a la derecha del avatar
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (businessName != null)
                Text(
                  businessName!,
                  style: defaultNameStyle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              if (businessType != null) ...<Widget>[
                const SizedBox(height: 4),
                Text(
                  businessType!,
                  style: defaultTypeStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: Icon(
        Icons.person,
        color: Colors.grey[600],
        size: avatarSize * 0.5,
      ),
    );
  }
}