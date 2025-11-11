import 'package:flutter/material.dart';

//ListTitle
class CustomListTile extends StatefulWidget {
  final String title;
  final Widget icon;
  final VoidCallback onTap;

  const CustomListTile({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  _CustomListTileState createState() => _CustomListTileState();
}

class _CustomListTileState extends State<CustomListTile> {
  bool _isHovered = false; // Estado para controlar el hover

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click, // Cambia el cursor al pasar el mouse
      onEnter: (_) =>
          setState(() => _isHovered = true), // Detecta cuando el cursor entra
      onExit: (_) =>
          setState(() => _isHovered = false), // Detecta cuando el cursor sale
      child: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 200,
          ), // Duración de la animación
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: _isHovered
                ? Colors.green.shade600
                : Colors.transparent, // Color de fondo al hacer hover
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(
                        0.3,
                      ), // Color de la sombra
                      blurRadius: 10, // Difuminado de la sombra
                      offset: const Offset(0, 5), // Desplazamiento de la sombra
                    ),
                  ]
                : [], // Sin sombra cuando no hay hover
          ),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(8),
            hoverColor:
                Colors.transparent, // Desactiva el hoverColor de InkWell
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  widget.icon,
                  const SizedBox(width: 8),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

//ExpansionTitle
class CustomExpansionTile extends StatefulWidget {
  final String title;
  final Widget icon;
  final List<Widget> children;

  const CustomExpansionTile({
    Key? key,
    required this.title,
    required this.icon,
    required this.children,
  }) : super(key: key);

  @override
  _CustomExpansionTileState createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile> {
  bool _isHovered = false; // Estado para controlar el hover

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) =>
          setState(() => _isHovered = true), // Detecta cuando el cursor entra
      onExit: (_) =>
          setState(() => _isHovered = false), // Detecta cuando el cursor sale
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200), // Duración de la animación
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: _isHovered
              ? Colors.green.shade800
              : Colors.transparent, // Color de fondo al hacer hover
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3), // Color de la sombra
                    blurRadius: 10, // Difuminado de la sombra
                    offset: const Offset(0, 5), // Desplazamiento de la sombra
                  ),
                ]
              : [], // Sin sombra cuando no hay hover
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            expansionTileTheme: const ExpansionTileThemeData(
              iconColor: Colors.white,
              textColor: Colors.white,
              collapsedIconColor: Colors.white,
            ),
          ),
          child: ExpansionTile(
            title: Row(
              children: [
                widget.icon,
                const SizedBox(width: 8),
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            children: widget.children,
          ),
        ),
      ),
    );
  }
}

//SubExpansionTitle
class SubCustomExpansionTile extends StatefulWidget {
  final String title;
  final Widget icon;
  final List<Widget> children;

  const SubCustomExpansionTile({
    Key? key,
    required this.title,
    required this.icon,
    required this.children,
  }) : super(key: key);

  @override
  _SubCustomExpansionTileState createState() => _SubCustomExpansionTileState();
}

class _SubCustomExpansionTileState extends State<SubCustomExpansionTile> {
  bool _isHovered = false; // Estado para controlar el hover

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) =>
          setState(() => _isHovered = true), // Detecta cuando el cursor entra
      onExit: (_) =>
          setState(() => _isHovered = false), // Detecta cuando el cursor sale
      child: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 200,
          ), // Duración de la animación
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: _isHovered
                ? Colors.green.shade700
                : Colors.transparent, // Color de fondo al hacer hover
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(
                        0.3,
                      ), // Color de la sombra
                      blurRadius: 10, // Difuminado de la sombra
                      offset: const Offset(0, 5), // Desplazamiento de la sombra
                    ),
                  ]
                : [], // Sin sombra cuando no hay hover
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              expansionTileTheme: const ExpansionTileThemeData(
                iconColor: Colors.white,
                textColor: Colors.white,
                collapsedIconColor: Colors.white,
              ),
            ),
            child: ExpansionTile(
              title: Row(
                children: [
                  widget.icon,
                  const SizedBox(width: 8),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              children: widget.children,
            ),
          ),
        ),
      ),
    );
  }
}
