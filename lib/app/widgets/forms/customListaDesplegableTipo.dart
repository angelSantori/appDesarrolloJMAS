import 'package:flutter/material.dart';

class CustomListaDesplegableTipo<T> extends StatefulWidget {
  final T? value;
  final String labelText;
  final List<T> items;
  final void Function(T?) onChanged;
  final String? Function(T?)? validator;
  final IconData icon;
  final String Function(T) itemLabelBuilder;
  final Widget? trailingIcon;

  const CustomListaDesplegableTipo({
    super.key,
    required this.value,
    required this.labelText,
    required this.items,
    required this.onChanged,
    this.validator,
    this.icon = Icons.arrow_drop_down,
    required this.itemLabelBuilder,
    this.trailingIcon,
  });

  @override
  State<CustomListaDesplegableTipo<T>> createState() =>
      _CustomListaDesplegableTipoState<T>();
}

class _CustomListaDesplegableTipoState<T>
    extends State<CustomListaDesplegableTipo<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    // Inicializa el AnimationController
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Duración de la animación
    );

    // Define la animación de desplazamiento
    _animation =
        Tween<Offset>(
          begin: const Offset(0, -1), // Comienza fuera de la pantalla (arriba)
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
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: IntrinsicWidth(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade900, // Color de la sombra
                  blurRadius: 8, // Difuminado de la sombra
                  offset: const Offset(0, 4), // Desplazamiento de la sombra
                ),
              ],
            ),
            child: DropdownButtonFormField<T>(
              isExpanded: true,
              value: widget.value,
              decoration: InputDecoration(
                labelText: widget.labelText,
                labelStyle: TextStyle(
                  color: Colors.blue.shade900,
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis,
                ),
                filled: true,
                fillColor: Colors.blue.shade50,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 12,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.blue.shade200,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.blue.shade900,
                    width: 2.0,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 1.5),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 2.0),
                ),
                suffixIcon: widget.trailingIcon,
              ),
              items: widget.items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                    ),
                    child: Text(
                      widget.itemLabelBuilder(item),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                );
              }).toList(),
              onChanged: widget.onChanged,
              validator: widget.validator,
            ),
          ),
        ),
      ),
    );
  }
}
