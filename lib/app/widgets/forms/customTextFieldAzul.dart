import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFieldAzul extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;
  final bool isPassword;
  final bool isVisible;
  final VoidCallback? onVisibilityToggle;
  final IconData prefixIcon;

  const CustomTextFieldAzul({
    Key? key,
    required this.controller,
    required this.labelText,
    this.validator,
    this.isPassword = false,
    this.isVisible = false,
    this.onVisibilityToggle,
    this.prefixIcon = Icons.text_fields,
  }) : super(key: key);

  @override
  State<CustomTextFieldAzul> createState() => _CustomTextFieldAzulState();
}

class _CustomTextFieldAzulState extends State<CustomTextFieldAzul>
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
            decoration: InputDecoration(
              labelText: widget.labelText,
              labelStyle: TextStyle(
                color: Colors.blue.shade900,
                fontWeight: FontWeight.bold,
              ),
              prefixIcon: Icon(widget.prefixIcon, color: Colors.blue.shade900),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        widget.isVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.blue.shade900,
                      ),
                      onPressed: widget.onVisibilityToggle,
                    )
                  : null,
              filled: true,
              fillColor: Colors.blue.shade50,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue.shade200, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue.shade900, width: 2.0),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2.0),
              ),
            ),
            style: const TextStyle(fontSize: 18, color: Colors.black),
            validator: widget.validator,
            obscureText: widget.isPassword && !widget.isVisible,
            inputFormatters: widget.isPassword
                ? null
                : [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
          ),
        ),
      ),
    );
  }
}
