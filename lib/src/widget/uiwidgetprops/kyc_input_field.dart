/*
  @author   : Gayathri
  @created  : 08/11/2025
  @desc     : Reusable KYC input field widget for form integration
*/

import 'package:sysmo_verification/kyc_validation.dart';

/// KYC input field widget with reactive form integration
class KYCInputField extends StatelessWidget {
  final FormProps formProps;
  final StyleProps styleProps;
  final InputValidationManager validationManager;
  final String? validationPatternErrorMessage;
  final bool disabled;
  final TextInputType keyboardType;
  final ReactiveFormFieldCallback<String>? onChange;
  final RegExp? validationPattern;

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
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IgnorePointer(
          ignoring: disabled,
          child: ReactiveTextField<String>(
            autofocus: false,
            keyboardType: keyboardType,
            formControlName: formProps.formControlName,
            onChanged: onChange,
            maxLength: formProps.maxLength,
            style: styleProps.textStyle ?? const TextStyle(fontSize: 14),
            decoration: styleProps.inputDecoration ??
                InputDecoration(
                  label: RichText(
                    text: TextSpan(
                      text: formProps.label,
                      style: styleProps.textStyle ??
                          const TextStyle(color: Colors.black, fontSize: 18),
                      children: [
                        TextSpan(
                          text: formProps.mandatory ? ' *' : '',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
                ),
            validationMessages: formProps.validator != null
                ? {
                    '': (control) {
                      final abstractControl = control as AbstractControl<dynamic>;
                      return formProps.validator!(abstractControl);
                    },
                  }
                : null,
          ),
        ),
        ReactiveFormConsumer(
          builder: (context, form, child) {
            final control = form.control(formProps.formControlName);
            final currentValue = control.value ?? '';
            final isPatternInvalid = validationPattern != null &&
                currentValue.isNotEmpty &&
                !validationPattern!.hasMatch(currentValue);

            if (isPatternInvalid && validationPatternErrorMessage != null) {
              return Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Text(
                  validationPatternErrorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
