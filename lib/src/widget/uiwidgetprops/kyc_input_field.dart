/*
  @author   : Gayathri
  @created  : 08/11/2025
  @desc     : Reusable KYC input field widget for form integration
*/

import 'package:sysmo_verification/kyc_validation.dart';

/// Custom TextInputFormatter for Aadhaar masking
/// Masks first 8 digits and shows only last 4 digits
class AadhaarMaskFormatter extends TextInputFormatter {
  final int visibleDigits;
  final String maskChar;

  AadhaarMaskFormatter({this.visibleDigits = 4, this.maskChar = '*'});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Allow only digits
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Limit to 12 digits for Aadhaar
    final limitedDigits = digitsOnly.length > 12
        ? digitsOnly.substring(0, 12)
        : digitsOnly;

    return TextEditingValue(
      text: limitedDigits,
      selection: TextSelection.collapsed(offset: limitedDigits.length),
    );
  }
}

/// KYC input field widget with reactive form integration
class KYCInputField extends StatefulWidget {
  final FormProps formProps;
  final StyleProps styleProps;
  final InputValidationManager validationManager;
  final String? validationPatternErrorMessage;
  final bool disabled;
  final TextInputType keyboardType;
  final ReactiveFormFieldCallback<String>? onChange;
  final RegExp? validationPattern;
  final bool obscureText;
  final bool maskAadhaar;

  const KYCInputField({
    super.key,
    required this.formProps,
    required this.styleProps,
    required this.validationManager,
    this.validationPatternErrorMessage,
    this.disabled = false,
    this.keyboardType = TextInputType.text,
    this.onChange,
    this.validationPattern,
    this.obscureText = false,
    this.maskAadhaar = false,
  });

  @override
  State<KYCInputField> createState() => _KYCInputFieldState();
}

class _KYCInputFieldState extends State<KYCInputField> {
  late bool _isObscured;
  final TextEditingController _maskedController = TextEditingController();
  bool _isFocused = false;
  final FocusNode _aadhaarFocusNode = FocusNode();


  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  void dispose() {
      _aadhaarFocusNode.dispose();

    _maskedController.dispose();
    
    super.dispose();
  }

  void _toggleObscure() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IgnorePointer(
            ignoring: widget.disabled,
            child: widget.maskAadhaar
                ? _buildMaskedAadhaarField()
                : _buildRegularTextField(),
          ),
          ReactiveFormConsumer(
            builder: (context, form, child) {
              final control = form.control(widget.formProps.formControlName);
              final currentValue = control.value ?? '';
              final isPatternInvalid =
                  widget.validationPattern != null &&
                  currentValue.isNotEmpty &&
                  !widget.validationPattern!.hasMatch(currentValue);

              if (isPatternInvalid &&
                  widget.validationPatternErrorMessage != null) {
                return Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4),
                  child: Text(
                    widget.validationPatternErrorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  /// Builds the regular text field without masking
  Widget _buildRegularTextField() {
    return ReactiveTextField<String>(
      focusNode: _aadhaarFocusNode,
      autofocus: false,
      keyboardType: widget.keyboardType,
      formControlName: widget.formProps.formControlName,
      onChanged: widget.onChange,
      maxLength: widget.formProps.maxLength,
      obscureText: _isObscured,
      style: widget.styleProps.textStyle ?? const TextStyle(fontSize: 14),
      decoration:
          widget.styleProps.inputDecoration ??
          InputDecoration(
            label: RichText(
              text: TextSpan(
                text: widget.formProps.label,
                style:
                    widget.styleProps.textStyle ??
                    const TextStyle(color: Colors.black, fontSize: 18),
                children: [
                  TextSpan(
                    text: widget.formProps.mandatory ? ' *' : '',
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
            errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _isObscured ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: _toggleObscure,
                  )
                : null,
          ),
      validationMessages: widget.formProps.validator != null
          ? {
              '': (control) {
                final abstractControl = control as AbstractControl<dynamic>;
                return widget.formProps.validator!(abstractControl);
              },
            }
          : null,
    );
  }

  /// Builds masked Aadhaar text field
  /// Shows first 8 digits as * and last 4 digits visible when not focused
  Widget _buildMaskedAadhaarField() {
    return ReactiveFormConsumer(
      builder: (context, form, child) {
        final control = form.control(widget.formProps.formControlName);
        final actualValue = control.value ?? '';
        final displayValue = _isFocused
            ? actualValue
            : _getMaskedAadhaar(actualValue);

        return GestureDetector(
          onTap: () {
            setState(() {
              _isFocused = true;
            });
             _aadhaarFocusNode.requestFocus();
          },
          child: Stack(
            children: [
              // Actual input field (visible when focused/editing)
              Opacity(
                opacity: _isFocused ? 1.0 : 0.0,
                child: Focus(
                  onFocusChange: (hasFocus) {
                    if (!hasFocus) {
                      setState(() {
                        _isFocused = false;
                      });
                    }
                  },
                  child: ReactiveTextField<String>(
                    focusNode: _aadhaarFocusNode,
                    autofocus: false,
                    keyboardType: TextInputType.number,
                    formControlName: widget.formProps.formControlName,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(12),
                    ],
                    onChanged: (ctrl) {
                      widget.onChange?.call(ctrl);
                    },
                    maxLength: widget.formProps.maxLength,
                    style:
                        widget.styleProps.textStyle ??
                        const TextStyle(fontSize: 14),
                    decoration:
                        widget.styleProps.inputDecoration ??
                        InputDecoration(
                          label: RichText(
                            text: TextSpan(
                              text: widget.formProps.label,
                              style:
                                  widget.styleProps.textStyle ??
                                  const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                  ),
                              children: [
                                TextSpan(
                                  text: widget.formProps.mandatory ? ' *' : '',
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                          errorStyle: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                    validationMessages: widget.formProps.validator != null
                        ? {
                            '': (control) {
                              final abstractControl =
                                  control as AbstractControl<dynamic>;
                              return widget.formProps.validator!(
                                abstractControl,
                              );
                            },
                          }
                        : null,
                  ),
                ),
              ),
              // Masked display field (visible when not focused)
              if (!_isFocused)
                MouseRegion(
                  cursor: SystemMouseCursors.text,
                  child: TextField(
                    controller: TextEditingController(text: displayValue),
                    readOnly: true,
                    showCursor: true,
                    cursorColor: Colors.black,
                    style:
                        widget.styleProps.textStyle ??
                        const TextStyle(fontSize: 14),
                    decoration:
                        widget.styleProps.inputDecoration ??
                        InputDecoration(
                          label: RichText(
                            text: TextSpan(
                              text: widget.formProps.label,
                              style:
                                  widget.styleProps.textStyle ??
                                  const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                  ),
                              children: [
                                TextSpan(
                                  text: widget.formProps.mandatory ? ' *' : '',
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                          errorStyle: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                    onTap: () {
                      setState(() {
                        _isFocused = true;
                      });
                      _aadhaarFocusNode.requestFocus();
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Returns masked Aadhaar number - first digits as *, last 4 visible
  String _getMaskedAadhaar(String value) {
    if (value.isEmpty) return '';
    if (value.length <= 4) return value;

    final visiblePart = value.substring(value.length - 4);
    final maskedLength = value.length - 4;
    return '${'*' * maskedLength}$visiblePart';
  }
}
