import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_spacing.dart';

class GymLayout extends StatelessWidget {
  const GymLayout({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.scrollable = true,
    this.backgroundImage,
    this.backgroundColor,
    this.showAppBar = true,
    this.centerTitle = true,
    this.leading,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.padding,
  });

  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final bool scrollable;
  final String? backgroundImage;
  final Color? backgroundColor;
  final bool showAppBar;
  final bool centerTitle;
  final Widget? leading;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    Widget content = body;

    // Add padding if specified
    if (padding != null) {
      content = Padding(
        padding: padding!,
        child: content,
      );
    }

    // Make scrollable if needed
    if (scrollable) {
      content = SingleChildScrollView(
        child: content,
      );
    }

    // Add background image if specified
    Widget scaffold = Scaffold(
      backgroundColor: backgroundColor ?? AppColors.background,
      appBar: showAppBar
          ? AppBar(
              title: title != null ? Text(title!) : null,
              centerTitle: centerTitle,
              actions: actions,
              leading: leading,
              backgroundColor: backgroundImage != null
                  ? Colors.transparent
                  : null,
              elevation: backgroundImage != null ? 0 : null,
              foregroundColor: backgroundImage != null
                  ? Colors.white
                  : AppColors.onSurface,
            )
          : null,
      body: SafeArea(
        child: content,
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );

    if (backgroundImage != null) {
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(backgroundImage!),
            fit: BoxFit.cover,
          ),
        ),
        child: scaffold,
      );
    }

    return scaffold;
  }
}
