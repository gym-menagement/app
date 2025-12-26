import 'package:flutter/material.dart';
import '../components/gym_components.dart';
import '../config/app_colors.dart';
import '../config/app_spacing.dart';
import '../config/app_text_styles.dart';

/// Design System Demo Screen
/// Showcases all Gym design system components
class DesignSystemDemoScreen extends StatefulWidget {
  const DesignSystemDemoScreen({super.key});

  @override
  State<DesignSystemDemoScreen> createState() => _DesignSystemDemoScreenState();
}

class _DesignSystemDemoScreenState extends State<DesignSystemDemoScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDimmed,
      appBar: AppBar(
        title: const Text('Gym Design System'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: 'Typography',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Display Large', style: AppTextStyles.displayLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Heading 1', style: AppTextStyles.h1),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Heading 2', style: AppTextStyles.h2),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Body Large', style: AppTextStyles.bodyLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Body Medium', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Caption', style: AppTextStyles.caption),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            _buildSection(
              title: 'Buttons',
              child: Column(
                children: [
                  const GymButton(
                    text: 'Primary Button',
                    purpose: GymButtonPurpose.primary,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const GymButton(
                    text: 'Secondary Button',
                    purpose: GymButtonPurpose.secondary,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const GymButton(
                    text: 'Outlined Button',
                    style: GymButtonStyle.outlined,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  GymButton(
                    text: 'Button with Icon',
                    icon: Icons.arrow_forward,
                    onPressed: () {},
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const GymButton(
                    text: 'Loading Button',
                    loading: true,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: GymButton(
                          text: 'Small',
                          size: GymButtonSize.small,
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: GymButton(
                          text: 'Large',
                          size: GymButtonSize.large,
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            _buildSection(
              title: 'Text Fields',
              child: Column(
                children: [
                  GymTextField(
                    controller: _emailController,
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    prefixIcon: Icons.email_outlined,
                    type: GymTextFieldType.email,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const GymTextField(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: Icons.lock_outlined,
                    obscureText: true,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const GymTextField(
                    labelText: 'With Error',
                    hintText: 'Invalid input',
                    errorText: 'This field is required',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            _buildSection(
              title: 'Cards',
              child: Column(
                children: [
                  GymCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: const Text('Simple Card'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  GymCardWithTitle(
                    title: 'Card with Title',
                    subtitle: 'This is a subtitle',
                    action: IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {},
                    ),
                    child: const Text('Card content goes here'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            _buildSection(
              title: 'Chips',
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  GymChip(
                    label: 'Default Chip',
                    onTap: () {},
                  ),
                  const GymChip(
                    label: 'Selected',
                    selected: true,
                  ),
                  GymChip(
                    label: 'With Icon',
                    icon: Icons.star,
                    onTap: () {},
                  ),
                  GymChip(
                    label: 'Deletable',
                    onDelete: () {},
                  ),
                  const GymChip(
                    label: 'Outlined',
                    style: GymChipStyle.outlined,
                  ),
                  const GymChip(
                    label: 'Small',
                    size: GymChipSize.small,
                  ),
                  const GymChip(
                    label: 'Large',
                    size: GymChipSize.large,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            _buildSection(
              title: 'Avatars',
              child: Row(
                children: [
                  GymAvatar(
                    name: 'John Doe',
                    size: GymAvatarSize.small,
                    onTap: () {},
                  ),
                  const SizedBox(width: AppSpacing.md),
                  const GymAvatar(
                    name: 'Jane Smith',
                    size: GymAvatarSize.medium,
                    showBadge: true,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  const GymAvatar(
                    name: 'Bob Wilson',
                    size: GymAvatarSize.large,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  GymAvatarGroup(
                    avatars: const [
                      GymAvatar(name: 'A'),
                      GymAvatar(name: 'B'),
                      GymAvatar(name: 'C'),
                      GymAvatar(name: 'D'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            _buildSection(
              title: 'Dividers',
              child: Column(
                children: [
                  const GymDivider(),
                  const SizedBox(height: AppSpacing.lg),
                  GymDividerWithText(
                    text: 'OR',
                    color: AppColors.grey400,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            _buildSection(
              title: 'Dialogs & Sheets',
              child: Column(
                children: [
                  GymButton(
                    text: 'Show Alert Dialog',
                    style: GymButtonStyle.outlined,
                    onPressed: () {
                      GymDialog.showAlert(
                        context: context,
                        title: 'Alert',
                        message: 'This is an alert dialog',
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  GymButton(
                    text: 'Show Confirm Dialog',
                    style: GymButtonStyle.outlined,
                    onPressed: () {
                      GymDialog.showConfirm(
                        context: context,
                        title: 'Confirm',
                        message: 'Are you sure you want to continue?',
                        onConfirm: () {
                          GymSnackbar.showSuccess(
                            context: context,
                            message: 'Confirmed!',
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  GymButton(
                    text: 'Show Bottom Sheet',
                    style: GymButtonStyle.outlined,
                    onPressed: () {
                      GymBottomSheet.show(
                        context: context,
                        title: 'Bottom Sheet',
                        child: const Padding(
                          padding: EdgeInsets.all(AppSpacing.lg),
                          child: Text('This is a bottom sheet'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  GymButton(
                    text: 'Show Options Sheet',
                    style: GymButtonStyle.outlined,
                    onPressed: () {
                      GymBottomSheet.showOptions(
                        context: context,
                        title: 'Select an option',
                        options: [
                          GymBottomSheetOption(
                            label: 'Option 1',
                            icon: Icons.check,
                            onTap: () {
                              GymSnackbar.showInfo(
                                context: context,
                                message: 'Option 1 selected',
                              );
                            },
                          ),
                          GymBottomSheetOption(
                            label: 'Option 2',
                            icon: Icons.star,
                            onTap: () {
                              GymSnackbar.showInfo(
                                context: context,
                                message: 'Option 2 selected',
                              );
                            },
                          ),
                          GymBottomSheetOption(
                            label: 'Delete',
                            icon: Icons.delete,
                            isDestructive: true,
                            onTap: () {
                              GymSnackbar.showError(
                                context: context,
                                message: 'Deleted!',
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            _buildSection(
              title: 'Snackbars',
              child: Column(
                children: [
                  GymButton(
                    text: 'Show Success',
                    purpose: GymButtonPurpose.success,
                    style: GymButtonStyle.outlined,
                    onPressed: () {
                      GymSnackbar.showSuccess(
                        context: context,
                        message: 'Operation successful!',
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  GymButton(
                    text: 'Show Error',
                    purpose: GymButtonPurpose.error,
                    style: GymButtonStyle.outlined,
                    onPressed: () {
                      GymSnackbar.showError(
                        context: context,
                        message: 'Something went wrong!',
                        actionLabel: 'Retry',
                        onAction: () {},
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  GymButton(
                    text: 'Show Warning',
                    purpose: GymButtonPurpose.warning,
                    style: GymButtonStyle.outlined,
                    onPressed: () {
                      GymSnackbar.showWarning(
                        context: context,
                        message: 'Please check your input',
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  GymButton(
                    text: 'Show Info',
                    style: GymButtonStyle.outlined,
                    onPressed: () {
                      GymSnackbar.showInfo(
                        context: context,
                        message: 'This is an informational message',
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            _buildSection(
              title: 'Loading',
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GymLoading(size: 24),
                      GymLoading(),
                      GymLoading(size: 60),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  GymButton(
                    text: 'Show Loading Dialog',
                    style: GymButtonStyle.outlined,
                    onPressed: () async {
                      showLoadingDialog(
                        context: context,
                        message: 'Processing...',
                      );
                      await Future.delayed(const Duration(seconds: 2));
                      if (mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.massive),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.h2,
        ),
        const SizedBox(height: AppSpacing.lg),
        GymCard(
          child: child,
        ),
      ],
    );
  }
}
