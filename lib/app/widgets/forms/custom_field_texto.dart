import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFielTexto extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;
  final IconData prefixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final int? maxLength;
  final bool? obscureText;
  final bool autoUppercase;
  final bool noSpaces;
  final bool onlyAlphanumeric;

  const CustomTextFielTexto({
    super.key,
    required this.controller,
    required this.labelText,
    this.validator,
    this.prefixIcon = Icons.text_fields,
    this.inputFormatters,
    this.enabled = true,
    this.onChanged,
    this.onFieldSubmitted,
    this.maxLength,
    this.autoUppercase = false,
    this.noSpaces = false,
    this.obscureText = false,
    this.onlyAlphanumeric = false,
  });

  @override
  State<CustomTextFielTexto> createState() => _CustomTextFielTextoState();
}

class _CustomTextFielTextoState extends State<CustomTextFielTexto>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    // Inicializa el AnimationController
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000), // Duración de la animación
    );

    // Define la animación de desplazamiento
    _animation =
        Tween<Offset>(
          begin: Offset(0, -1), // Comienza fuera de la pantalla (arriba)
          end: Offset.zero, // Termina en su posición original
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutQuart, // Curva suave
          ),
        );
    // Inicia la animación cuando el widget se construye
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose(); // Limpia el AnimationController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<TextInputFormatter> formatters = [];

    // Agregar formateadores basados en las propiedades
    if (widget.noSpaces) {
      formatters.add(FilteringTextInputFormatter.deny(RegExp(r'\s')));
    }

    if (widget.onlyAlphanumeric) {
      formatters.add(FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')));
    }

    if (widget.autoUppercase) {
      formatters.add(
        TextInputFormatter.withFunction(
          (oldValue, newValue) =>
              newValue.copyWith(text: newValue.text.toUpperCase()),
        ),
      );
    }

    // Agregar formateadores personalizados si existen
    if (widget.inputFormatters != null) {
      formatters.addAll(widget.inputFormatters!);
    }

    return SlideTransition(
      position: _animation,
      child: SizedBox(
        width: 500,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade900, // Color de la sombra
                blurRadius: 8, // Difuminado de la sombra
                offset: Offset(0, 4), // Desplazamiento de la sombra
              ),
            ],
          ),
          child: TextFormField(
            controller: widget.controller,
            enabled: widget.enabled,
            inputFormatters: formatters,
            maxLength: widget.maxLength,
            obscureText: widget.obscureText ?? false,
            buildCounter:
                (
                  BuildContext context, {
                  int? currentLength,
                  int? maxLength,
                  bool? isFocused,
                }) => null,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onFieldSubmitted,
            decoration: InputDecoration(
              labelText: widget.labelText,
              labelStyle: TextStyle(
                color: widget.enabled
                    ? Colors.blue.shade900
                    : Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
              prefixIcon: Icon(widget.prefixIcon, color: Colors.blue.shade900),
              filled: true,
              fillColor: widget.enabled
                  ? Colors.blue.shade50
                  : Colors.grey.shade200,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: widget.enabled
                      ? Colors.blue.shade200
                      : Colors.grey.shade400,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue.shade900, width: 2.0),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: widget.enabled
                      ? Colors.blue.shade900
                      : Colors.grey.shade600,
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2.0),
              ),
            ),
            style: TextStyle(
              fontSize: 18,
              color: widget.enabled ? Colors.black : Colors.grey.shade600,
            ),
            validator: widget.validator,
          ),
        ),
      ),
    );
  }
}
