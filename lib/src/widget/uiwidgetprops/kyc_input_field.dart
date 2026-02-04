/*
  @author   : Gayathri
  @created  : 08/11/2025
  @desc     : Reusable KYC input field widget for form integration
*/

import 'package:sysmo_verification/kyc_validation.dart';

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
  });

  @override
  State<KYCInputField> createState() => _KYCInputFieldState();
}

class _KYCInputFieldState extends State<KYCInputField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
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
            child: ReactiveTextField<String>(
              autofocus: false,
              keyboardType: widget.keyboardType,
              formControlName: widget.formProps.formControlName,
              onChanged: widget.onChange,
              maxLength: widget.formProps.maxLength,
              obscureText: _isObscured,
              style:
                  widget.styleProps.textStyle ?? const TextStyle(fontSize: 14),
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
                    errorStyle: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                    suffixIcon: widget.obscureText
                        ? IconButton(
                            icon: Icon(
                              _isObscured
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: _toggleObscure,
                          )
                        : null,
                  ),
              validationMessages: widget.formProps.validator != null
                  ? {
                      '': (control) {
                        final abstractControl =
                            control as AbstractControl<dynamic>;
                        return widget.formProps.validator!(abstractControl);
                      },
                    }
                  : null,
            ),
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
}
