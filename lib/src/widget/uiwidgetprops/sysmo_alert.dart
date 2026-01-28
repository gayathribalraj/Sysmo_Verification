import 'package:flutter/material.dart';

/*
  @author     : akshayaa.p
  @date       : 16/05/2025
  @desc       : Reusable stateless widget to show an alert box with customizable:
                - Icon, text, colors and action button.
                - Used to display messages like success, failure, warning or error.
                - The button executes the provided onButtonPressed callback.
*/

class SysmoAlert extends StatelessWidget {
  final String message;
  final Color textColor;
  final Color backgroundColor;
  final Color iconColor;
  final IconData icon;
  final String buttonText;
  final VoidCallback onButtonPressed;
  final String? detailMessage;
  final String? viewButtonText;

  const SysmoAlert({
    super.key,
    required this.message,
    this.textColor = Colors.black,
    this.backgroundColor = Colors.white,
    this.iconColor = Colors.black,
    this.icon = Icons.info_outline,
    this.buttonText = 'OK',
    required this.onButtonPressed,
    this.detailMessage,
    this.viewButtonText,
  });

  factory SysmoAlert.success({
    Key? key,
    required String message,
    VoidCallback? onButtonPressed,
    Color? textColor,
    Color? backgroundColor,
    Color? iconColor,
    IconData? icon,
    String? buttonText,
    String? detailMessage,
    String? viewButtonText,
  }) {
    return SysmoAlert(
      key: key,
      message: message,
      textColor: textColor ?? Colors.black,
      backgroundColor: backgroundColor ?? Colors.green.shade50,
      iconColor: iconColor ?? Colors.green,
      icon: icon ?? Icons.check_circle_outline,
      buttonText: buttonText ?? 'OK',
      onButtonPressed: onButtonPressed ?? () {},
      detailMessage: detailMessage,
      viewButtonText: viewButtonText,
    );
  }

  factory SysmoAlert.failure({
    Key? key,
    required String message,
    VoidCallback? onButtonPressed,
    Color? textColor,
    Color? backgroundColor,
    Color? iconColor,
    IconData? icon,
    String? buttonText,
    String? detailMessage,
    String? viewButtonText,
  }) {
    return SysmoAlert(
      key: key,
      message: message,
      textColor: textColor ?? Colors.black,
      backgroundColor: backgroundColor ?? Colors.red.shade50,
      iconColor: iconColor ?? Colors.red,
      icon: icon ?? Icons.error_outline,
      buttonText: buttonText ?? 'OK',
      onButtonPressed: onButtonPressed ?? () {},
      detailMessage: detailMessage,
      viewButtonText: viewButtonText,
    );
  }

  factory SysmoAlert.warning({
    Key? key,
    required String message,
    VoidCallback? onButtonPressed,
    Color? textColor,
    Color? backgroundColor,
    Color? iconColor,
    IconData? icon,
    String? buttonText,
    String? detailMessage,
    String? viewButtonText,
  }) {
    return SysmoAlert(
      key: key,
      message: message,
      textColor: textColor ?? Colors.black,
      backgroundColor: backgroundColor ?? Colors.orange.shade50,
      iconColor: iconColor ?? Colors.orange,
      icon: icon ?? Icons.warning_amber_rounded,
      buttonText: buttonText ?? 'OK',
      onButtonPressed: onButtonPressed ?? () {},
      detailMessage: detailMessage,
      viewButtonText: viewButtonText,
    );
  }

  factory SysmoAlert.info({
    Key? key,
    required String message,
    VoidCallback? onButtonPressed,
    Color? textColor,
    Color? backgroundColor,
    Color? iconColor,
    IconData? icon,
    String? buttonText,
    String? detailMessage,
    String? viewButtonText,
  }) {
    return SysmoAlert(
      key: key,
      message: message,
      textColor: textColor ?? Colors.black,
      backgroundColor: backgroundColor ?? Colors.blue.shade50,
      iconColor: iconColor ?? Colors.blue,
      icon: icon ?? Icons.info_outline,
      buttonText: buttonText ?? 'OK',
      onButtonPressed: onButtonPressed ?? () {},
      detailMessage: detailMessage,
      viewButtonText: viewButtonText,
    );
  }

  void _showDetailBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(icon, color: iconColor, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Error Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    if (detailMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: SelectableText(
                          detailMessage!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade800,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Close button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: iconColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: iconColor, size: 40),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textColor, fontSize: 22),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (detailMessage != null) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _showDetailBottomSheet(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black,
                            side: BorderSide(color:Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(viewButtonText ?? 'View'),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onButtonPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: iconColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(buttonText),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// sysmoalert(message:'') -> icon default to info icon , ok button
