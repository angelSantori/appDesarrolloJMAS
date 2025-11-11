import 'package:flutter/material.dart';

class CustomAutocomplete<T extends Object> extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final List<T> options;
  final String Function(T) displayStringForOption;
  final void Function(T?) onSelected;
  final String? Function(String?)? validator;
  final bool enabled;
  final VoidCallback? onSelectionConfirmed;
  final bool clearOnSelect;

  const CustomAutocomplete({
    super.key,
    required this.controller,
    required this.labelText,
    required this.options,
    required this.displayStringForOption,
    required this.onSelected,
    this.validator,
    this.enabled = true,
    this.onSelectionConfirmed,
    this.clearOnSelect = true,
  });

  @override
  Widget build(BuildContext context) {
    return Autocomplete<T>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return Iterable<T>.empty();
        }
        return options.where((T option) {
          return displayStringForOption(option)
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (T selection) {
        // Notificar la selección primero
        onSelected(selection);

        // Limpiar el campo si es necesario
        if (clearOnSelect) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            controller.clear();
          });
        } else {
          controller.text = displayStringForOption(selection);
        }

        // Ejecutar callback de confirmación
        onSelectionConfirmed?.call();
      },
      fieldViewBuilder: (BuildContext context,
          TextEditingController fieldTextEditingController,
          FocusNode focusNode,
          VoidCallback onFieldSubmitted) {
        // Sincronizar nuestro controlador con el interno de Autocomplete
        controller.addListener(() {
          if (controller.text != fieldTextEditingController.text) {
            fieldTextEditingController.text = controller.text;
          }
        });

        return TextFormField(
          controller:
              fieldTextEditingController, // Usamos el controlador interno
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: labelText,
            border: const OutlineInputBorder(),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      controller.clear();
                      fieldTextEditingController.clear();
                      onSelected(null);
                    },
                  )
                : null,
          ),
          validator: validator,
          enabled: enabled,
          onChanged: (value) {
            // Sincronizar ambos controladores
            if (controller.text != value) {
              controller.text = value;
            }
            if (value.isEmpty) {
              onSelected(null);
            }
          },
        );
      },
      optionsViewBuilder: (BuildContext context,
          AutocompleteOnSelected<T> onSelected, Iterable<T> options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final T option = options.elementAt(index);
                  return InkWell(
                    onTap: () {
                      onSelected(option);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(displayStringForOption(option)),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}