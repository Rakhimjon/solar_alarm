import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_alarm/core/theme/app_theme.dart';

/// App-wide button. Default style is the tinted primary pill
/// (primary tint background, primary text, thin primary border).
/// Pass [backgroundColor] / [foregroundColor] for a filled variant.
class CustomButton extends StatelessWidget {
  final String title;
  final Widget? icon;
  final VoidCallback? onTap;
  final bool enabled;
  final bool isLoading;
  final bool isFullWidth;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final EdgeInsets? padding;
  final TextStyle? textStyle;

  const CustomButton({
    super.key,
    required this.title,
    this.icon,
    this.onTap,
    this.enabled = true,
    this.isLoading = false,
    this.isFullWidth = false,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderRadius,
    this.padding,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final foreground = foregroundColor ?? colors.primary;
    final background =
        backgroundColor ??
        colors.primary.withValues(alpha: context.isDark ? 0.16 : 0.10);
    final border =
        borderColor ??
        (backgroundColor == null
            ? colors.primary.withValues(alpha: 0.45)
            : Colors.transparent);
    final radius = BorderRadius.circular(borderRadius ?? 14.r);

    final button = Opacity(
      opacity: enabled ? 1 : 0.5,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: radius,
          border: Border.all(color: border),
        ),
        child: CupertinoButton(
          onPressed: enabled && !isLoading ? onTap : null,
          padding:
              padding ?? EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
          borderRadius: radius,
          pressedOpacity: 0.6,
          child: isLoading
              ? CupertinoActivityIndicator(color: foreground)
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      IconTheme(
                        data: IconThemeData(color: foreground, size: 20.r),
                        child: icon!,
                      ),
                      SizedBox(width: 8.w),
                    ],
                    Flexible(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style:
                            textStyle ??
                            TextStyle(
                              color: foreground,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );

    return isFullWidth
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}
