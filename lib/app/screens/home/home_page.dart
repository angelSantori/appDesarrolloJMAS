import 'dart:core';
import 'package:desarrollo_jmas/app/screens/ajustes_plus%20copy/add_ajuste_mas_page.dart';
import 'package:desarrollo_jmas/app/screens/ajustes_plus%20copy/list_ajuste_mas_page.dart';
import 'package:desarrollo_jmas/app/screens/ccontables/ccontables_reportes_page.dart';
import 'package:desarrollo_jmas/app/screens/ccontables/list_ccontables_page.dart';
import 'package:desarrollo_jmas/app/screens/compras/ordenCompras/add_orden_compra_page.dart';
import 'package:desarrollo_jmas/app/screens/compras/ordenCompras/list_orden_compra_page.dart';
import 'package:desarrollo_jmas/app/screens/compras/solicitudes/add_solicitud_compra.dart';
import 'package:desarrollo_jmas/app/screens/compras/solicitudes/list_solicitudes.dart';
import 'package:desarrollo_jmas/app/screens/conteoinicial/list_conteoinicial_page.dart';
import 'package:desarrollo_jmas/app/screens/descuentosSociales/add_descuento_soccial.dart';
import 'package:desarrollo_jmas/app/screens/descuentosSociales/descuentosMovils/list_descuento_social_movil.dart';
import 'package:desarrollo_jmas/app/screens/descuentosSociales/list_descuento_social.dart';
import 'package:desarrollo_jmas/app/screens/entradas/add_entrada_page.dart';
import 'package:desarrollo_jmas/app/screens/entradas/list_cancelados_page.dart';
import 'package:desarrollo_jmas/app/screens/entradas/list_entrada_page.dart';
import 'package:desarrollo_jmas/app/screens/herramientas/htaPrest/add_htaprest_page.dart';
import 'package:desarrollo_jmas/app/screens/herramientas/htaPrest/list_htaprest_page.dart';
import 'package:desarrollo_jmas/app/screens/herramientas/manage_hta/add_herramienta_page.dart';
import 'package:desarrollo_jmas/app/screens/herramientas/manage_hta/list_herramientas_page.dart';
import 'package:desarrollo_jmas/app/screens/home/inventory_dashboard_page.dart';
import 'package:desarrollo_jmas/app/screens/home/login2.dart';
import 'package:desarrollo_jmas/app/screens/home/widgets/excel_validar_captura.dart';
import 'package:desarrollo_jmas/app/screens/home/widgets/menus.dart';
import 'package:desarrollo_jmas/app/screens/lecturas/add_lecturas.dart';
import 'package:desarrollo_jmas/app/screens/lecturas/lista_lecturas.dart';
import 'package:desarrollo_jmas/app/screens/mantenimiento/almacenes/list_almacenes_page.dart';
import 'package:desarrollo_jmas/app/screens/mantenimiento/areas/list_areas_page.dart';
import 'package:desarrollo_jmas/app/screens/mantenimiento/calles/list_calles_page.dart';
import 'package:desarrollo_jmas/app/screens/mantenimiento/colonias/list_colonias_page.dart';
import 'package:desarrollo_jmas/app/screens/mantenimiento/contratistas/list_contratistas_page.dart';
import 'package:desarrollo_jmas/app/screens/mantenimiento/juntas/list_juntas_page.dart';
import 'package:desarrollo_jmas/app/screens/mantenimiento/medios/list_medios.dart';
import 'package:desarrollo_jmas/app/screens/mantenimiento/padron/list_padron_page.dart';
import 'package:desarrollo_jmas/app/screens/mantenimiento/proveedores/list_proveedor_page.dart';
import 'package:desarrollo_jmas/app/screens/mantenimiento/tipoProblemas/list_tipo_problema.dart';
import 'package:desarrollo_jmas/app/screens/ordenServicio/add_orden_servicio.dart';
import 'package:desarrollo_jmas/app/screens/ordenServicio/list_orden_servicio.dart';
import 'package:desarrollo_jmas/app/screens/presupuestos/add_presupuesto.dart';
import 'package:desarrollo_jmas/app/screens/presupuestos/list_presupuestos.dart';
import 'package:desarrollo_jmas/app/screens/productos/add_producto_page.dart';
import 'package:desarrollo_jmas/app/screens/productos/list_producto_page.dart';
import 'package:desarrollo_jmas/app/screens/salidas/add_salida_page.dart';
import 'package:desarrollo_jmas/app/screens/salidas/list_cancelacioens_salida_page.dart';
import 'package:desarrollo_jmas/app/screens/salidas/list_salida_page.dart';
import 'package:desarrollo_jmas/app/screens/universal/consulta_universal_page.dart';
import 'package:desarrollo_jmas/app/screens/universal/pdf_list_page.dart';
import 'package:desarrollo_jmas/app/screens/users/admin_role_page.dart';
import 'package:desarrollo_jmas/app/screens/users/list_user_page.dart';
import 'package:desarrollo_jmas/app/configs/auth/auth_service.dart';
import 'package:desarrollo_jmas/app/configs/auth/permission_widget.dart';
import 'package:desarrollo_jmas/app/configs/controllers/capturaInvIni_controller.dart';
import 'package:desarrollo_jmas/app/configs/controllers/productos_controller.dart';
import 'package:desarrollo_jmas/app/widgets/mensajes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

// TODO: Agregar direccionamiento a medios
// TODO: Agregar direccionamiento a tipo de problema

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  String? userName;
  String? userRole;
  String? idUser;
  bool hasPendingCaptures = false;

  late AnimationController _animationController;
  late Animation<double> _animation;
  Widget _currentPage = const Center(
    child: Text(
      'Presiona \nCtrl + Shift + R \nUna o dos veces para cargar posibles actualizaciones en el sistema!',
      textAlign: TextAlign.center,
    ),
  );

  @override
  void initState() {
    super.initState();
    _loadUserData();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _animation = Tween<double>(begin: -250, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuart),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final decodeToken = await _authService.decodeToken();

    hasPendingCaptures = await _checkPendingCaptures();
    setState(() {
      userName = decodeToken?['User_Name'];
      userRole =
          decodeToken?['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'];
      idUser = decodeToken?['Id_User'];

      // Primero verificar si es admin (sin importar el nombre de usuario)
      if (userRole?.toLowerCase() == 'admin') {
        _currentPage = const InventoryDashboardPage();
      }
      // Luego verificar si es "Empleado 156" y tiene capturas pendientes
      // (esto se aplicará incluso si es admin)
      if (userName == "Angel" && hasPendingCaptures) {
        _currentPage = _buildCaptureValidationCard();
      }
      // Si no cumple ninguna condición especial, mostrar página de inicio normal
      // ignore: unnecessary_null_comparison
      else if (_currentPage == null) {
        _currentPage = const Center(
          child: Text(
            'Presiona \nCtrl + Shift + R \nUna o dos veces para posibles actualizaciones en el sistema!',
            textAlign: TextAlign.center,
          ),
        );
      }
    });
  }

  Future<bool> _checkPendingCaptures() async {
    try {
      final controller = CapturainviniController();
      final captures = await controller.listCapturaI();
      return captures.any((capture) => capture.invIniEstado == false);
    } catch (e) {
      print('Error checking pending captures: $e');
      return false;
    }
  }

  Widget _buildCaptureValidationCard() {
    return Center(
      child: Card(
        elevation: 8,
        margin: const EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Validar captura del mes: ${DateFormat.MMMM('es_ES').format(DateTime.now()).toUpperCase()}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    label: const Text('Descargar Excel'),
                    onPressed: _downloadExcelReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade800,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Aceptar Captura'),
                    onPressed: _showAcceptCaptureDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade900,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _downloadExcelReport() async {
    try {
      final controller = CapturainviniController();
      final productController = ProductosController();

      // Obtener capturas pendientes
      final captures = await controller.listCapturaI();
      final pendingCaptures = captures
          .where((c) => c.invIniEstado == false)
          .toList();

      // Obtener información de productos
      List<Map<String, dynamic>> excelData = [];

      for (var capture in pendingCaptures) {
        final product = await productController.getProductoById(
          capture.id_Producto!,
        );

        excelData.add({
          'IdProducto': capture.id_Producto,
          'Descripción': product?.prodDescripcion ?? 'N/A',
          'Existencia Sistema': product?.prodExistencia ?? 0,
          'Conteo Capturado': capture.invIniConteo,
          'Diferencia':
              (capture.invIniConteo ?? 0) - (product?.prodExistencia ?? 0),
          'Justificación': capture.invIniJustificacion ?? '',
        });
      }

      // Generar y descargar el Excel
      await excelValidarCaptura(data: excelData, context: context);

      // Mostrar mensaje de éxito
      showOk(context, 'Reporte generado exitosamente');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al generar reporte: $e')));
    }
  }

  void _showAcceptCaptureDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Desea aceptar la captura?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => _showConfirmationDialog(),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog() {
    Navigator.pop(context); // Cerrar el primer diálogo
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmación'),
        content: const Text(
          '¿Seguro que desea aceptar la captura? '
          'Esta acción editará las existencias actuales de los productos',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _acceptCapture();
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  Future<void> _acceptCapture() async {
    try {
      final captureController = CapturainviniController();
      final productController = ProductosController();

      // Obtener capturas pendientes
      final captures = await captureController.listCapturaI();
      final pendingCaptures = captures
          .where((c) => c.invIniEstado == false)
          .toList();

      // Procesar cada captura
      for (var capture in pendingCaptures) {
        // Actualizar estado de la captura
        final updatedCapture = capture.copyWith(invIniEstado: true);
        await captureController.editCapturaI(updatedCapture);

        // Actualizar existencia del producto
        final product = await productController.getProductoById(
          capture.id_Producto!,
        );
        if (product != null) {
          await productController.updateInventario(
            product.id_Producto!,
            capture.invIniConteo!,
            capture.id_Almacen!,
          );
        }
      }

      showOk(context, 'Captura aceptada exitosamente');
      // Actualizar la vista
      setState(() {
        _currentPage = const Center(
          child: Text(
            'Presiona \nCtrl + Shift + R \nUna o dos veces para cargar posibles actualizaciones en el sistema!',
            textAlign: TextAlign.center,
          ),
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al aceptar captura: $e')));
    }
  }

  // Método para obtener el Map de rutas
  Map<String, Widget Function()> _getRoutes() {
    return {
      //Productos
      'addProducto': () => const AddProductoPage(),
      'listProducto': () => const ListProductoPage(),
      'listConteo': () => const ListConteoinicialPage(),

      //Areas
      'listAreas': () => const ListAreasPage(),

      //  Descuentos Sociales
      'addDescuentoSocial': () => const DescuentosSocialesForm(),
      'listDescuentoSocial': () => const ListDescuentoSocial(),
      'listDescuentoSocialMovil': () => const ListDescuentoSocialMovil(),

      //Ajuste Mas
      'addAjusteMas': () =>
          AddAjusteMasPage(idUser: idUser, userName: userName),
      'listAjusteMas': () => ListAjusteMasPage(userRole: userRole),

      //Users
      'listUser': () => const ListUserPage(),
      'adminRole': () => const AdminRolePage(),

      //Entradas
      'addEntrada': () => AddEntradaPage(userName: userName, idUser: idUser),
      'listEntradas': () => ListEntradaPage(userRole: userRole),
      'listCancelados': () => const ListCanceladosPage(),

      //Proveedores
      'listProveedores': () => const ListProveedorPage(),

      //  Presupuestos
      'addPresupuesto': () =>
          AddPresupuesto(idUser: idUser, userName: userName),

      'listPresupuesto': () =>
          ListPresupuestosPage(userName: userName, userRole: userRole),

      //Salidas
      'addSalida': () => AddSalidaPage(userName: userName, idUser: idUser),
      'listSalidas': () =>
          ListSalidaPage(userRole: userRole, userName: userName),
      'listCanceladosSalida': () => const ListCancelacioensSalidaPage(),

      //Alamcen
      'listAlmacenes': () => const ListAlmacenesPage(),

      //Juntas
      'listJuntas': () => const ListJuntasPage(),

      //Colonias
      'listColonias': () => const ListColoniasPage(),

      //Calles
      'listCalles': () => const ListCallesPage(),

      //Contratistas
      'listContratistas': () => const ListContratistasPage(),

      //Medios
      'listMedios': () => const ListMedios(),

      //Tipo problemas
      'listTipoProblemas': () => const ListTipoProblema(),

      //Herramientas
      'listHerramientas': () => const ListHerramientasPage(),
      'addHerramienta': () => const AddHerramientaPage(),

      //HtaPrestamos
      'listHtaPrest': () => const ListHtaprestPage(),
      'addHtaPrest': () => AddHtaprestPage(idUser: idUser, userName: userName),

      //Consulta universal
      'ConsultaU': () => const ConsultaUniversalPage(),
      'listPDF': () => const PdfListPage(),

      //Orden de Compra
      'addOrdenCompra': () =>
          AddOrdenCompraPage(idUser: idUser, userName: userName),
      'listOrdenCompra': () => ListOrdenCompraPage(userRole: userRole),

      'addSolicitudCompra': () =>
          AddSolicitudCompra(idUser: idUser, userName: userName),
      'listSolicitudCompra': () => ListSolicitudesPage(
        userName: userName,
        userRole: userRole,
        idUser: idUser!,
      ),

      //Orden Servicio
      'addOrdenServicio': () =>
          AddOrdenServicio(idUser: idUser, userName: userName),
      'listOrdenServicio': () => const ListOrdenServicio(),

      //X
      'home': () => const Center(
        child: Text(
          'Presiona \nCtrl + Shift + R \nUna o dos veces para cargar posibles actualizaciones en el sistema!',
          textAlign: TextAlign.center,
        ),
      ),
      'dashboard': () => const InventoryDashboardPage(),
      'listPadron': () => const ListPadronPage(),

      //Cuentas contables
      'listCC': () => const ListCcontablesPage(),
      'generadorCC': () => const CcontablesReportesPage(),

      //Lecturas
      'listLecturas': () => const ListLecturasScreen(),
      'addLecturas': () => const AddLecturasEnviarScreen(),

      //'mapa': () => const MapaLecturasPage(),
      // 'addAjusteMenos': () => const AddAjusteMenosPage(),
    };
  }

  void _navigateTo(String routeName) {
    final routes = _getRoutes(); // Obtén el Map de rutas
    if (routes.containsKey(routeName)) {
      setState(() {
        _currentPage = routes[routeName]!();
      });
    } else {
      throw ArgumentError('Invalid route name: $routeName');
    }
  }

  void _logOut() {
    showDialog(
      context: context,
      builder: (BuildContext cotext) {
        return AlertDialog(
          title: const Text('Confirmación'),
          content: const Text('¿Estás seguro que deseas cerrar sesión?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                //1. Cerrar el diálogo
                Navigator.of(context).pop();

                //2. Limpiar datos de autenticación
                await _authService.clearAuthData();
                await _authService.deleteToken();

                //3. Navegar al login limpiando toda la pila
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginWidget()),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_animation.value, 0),
                child: child,
              );
            },
            child: Container(
              width: 250,
              decoration: BoxDecoration(
                color: Colors.green.shade900,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x40000000),
                    blurRadius: 4,
                    offset: Offset(12, 16),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Encabezado del menú
                  Container(
                    height: 170,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(26),
                        bottomRight: Radius.circular(26),
                      ),
                      color: Colors.white,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 100,
                          child: Image.asset('assets/images/logo_jmas_sf.png'),
                        ),
                        const SizedBox(height: 10),
                        if (userName != null)
                          Text(
                            userName!,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                          ),
                        const SizedBox(height: 10),
                        const Text(
                          'v. 07112025',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Contenido del menú con scroll
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          //  Dashboard
                          if (userRole?.toLowerCase() == 'admin') ...[
                            ListTile(
                              title: const Row(
                                children: [
                                  Icon(
                                    Icons.bar_chart_outlined,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Dashboard',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () => _navigateTo('dashboard'),
                            ),
                          ],
                          // Elementos del menú
                          ListTile(
                            title: const Row(
                              children: [
                                Icon(Icons.home, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Principal',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () => _navigateTo('home'),
                          ),

                          CustomExpansionTile(
                            title: 'Mantenimiento',
                            icon: SvgPicture.asset(
                              'assets/icons/mantenimiento.svg',
                              width: 20,
                              height: 20,
                              color: Colors.white,
                            ),
                            children: [
                              //Almacenes
                              CustomListTile(
                                title: 'Almacenes',
                                icon: SvgPicture.asset(
                                  'assets/icons/almacen.svg',
                                  height: 20,
                                  width: 20,
                                  color: Colors.white,
                                ),
                                onTap: () => _navigateTo('listAlmacenes'),
                              ),

                              CustomListTile(
                                title: 'Areas',
                                icon: const Icon(
                                  Icons.emoji_people_rounded,
                                  color: Colors.white,
                                ),
                                onTap: () => _navigateTo('listAreas'),
                              ),

                              //Calles
                              CustomListTile(
                                title: 'Calles',
                                icon: const Icon(
                                  Icons.stream,
                                  color: Colors.white,
                                ),
                                onTap: () => _navigateTo('listCalles'),
                              ),

                              //Colonias
                              CustomListTile(
                                title: 'Colonias',
                                icon: const Icon(
                                  Icons.map_rounded,
                                  color: Colors.white,
                                ),
                                onTap: () => _navigateTo('listColonias'),
                              ),

                              //Contratistas
                              CustomListTile(
                                title: 'Contratistas',
                                icon: const Icon(
                                  Icons.contact_page_sharp,
                                  color: Colors.white,
                                ),
                                onTap: () => _navigateTo('listContratistas'),
                              ),

                              //Juntas
                              CustomListTile(
                                title: 'Juntas',
                                icon: const Icon(
                                  Icons.location_city_outlined,
                                  color: Colors.white,
                                ),
                                onTap: () => _navigateTo('listJuntas'),
                              ),

                              CustomListTile(
                                title: 'Medios',
                                icon: const Icon(
                                  Icons.ac_unit,
                                  color: Colors.white,
                                ),
                                onTap: () => _navigateTo('listMedios'),
                              ),

                              CustomListTile(
                                title: 'Tipo Servicios',
                                icon: const Icon(
                                  Icons.accessibility_new,
                                  color: Colors.white,
                                ),
                                onTap: () => _navigateTo('listTipoProblemas'),
                              ),

                              //Padrones
                              CustomListTile(
                                title: 'Padrones',
                                icon: SvgPicture.asset(
                                  'assets/icons/social.svg',
                                  color: Colors.white,
                                  width: 20,
                                  height: 20,
                                ),
                                onTap: () => _navigateTo('listPadron'),
                              ),

                              //Proveedores
                              CustomListTile(
                                title: 'Proveedores',
                                icon: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                ),
                                onTap: () => _navigateTo('listProveedores'),
                              ),

                              //Productos
                              SubCustomExpansionTile(
                                title: 'Productos',
                                icon: SvgPicture.asset(
                                  'assets/icons/caja_abierta.svg',
                                  width: 20,
                                  height: 20,
                                  color: Colors.white,
                                ),
                                children: [
                                  CustomListTile(
                                    title: 'Conteo Inicial',
                                    icon: const Icon(
                                      Icons.abc_sharp,
                                      color: Colors.white,
                                    ),
                                    onTap: () => _navigateTo('listConteo'),
                                  ),
                                  CustomListTile(
                                    title: 'Lista productos',
                                    icon: SvgPicture.asset(
                                      'assets/icons/listprod.svg',
                                      width: 20,
                                      height: 20,
                                      color: Colors.white,
                                    ),
                                    onTap: () => _navigateTo('listProducto'),
                                  ),
                                  PermissionWidget(
                                    permission: 'add',
                                    child: CustomListTile(
                                      title: 'Agregar Producto',
                                      icon: SvgPicture.asset(
                                        'assets/icons/addprod.svg',
                                        width: 20,
                                        height: 20,
                                        color: Colors.white,
                                      ),
                                      onTap: () => _navigateTo('addProducto'),
                                    ),
                                  ),
                                ],
                              ),

                              //Herramientas
                              SubCustomExpansionTile(
                                title: 'Herraminetas',
                                icon: SvgPicture.asset(
                                  'assets/icons/worktools.svg',
                                  width: 20,
                                  height: 20,
                                  color: Colors.white,
                                ),
                                children: [
                                  CustomListTile(
                                    title: 'Lista Herramientas',
                                    icon: SvgPicture.asset(
                                      'assets/icons/worktools.svg',
                                      width: 20,
                                      height: 20,
                                      color: Colors.white,
                                    ),
                                    onTap: () =>
                                        _navigateTo('listHerramientas'),
                                  ),
                                  PermissionWidget(
                                    permission: 'add',
                                    child: CustomListTile(
                                      title: 'Agregar Herramienta',
                                      icon: SvgPicture.asset(
                                        'assets/icons/worktools.svg',
                                        width: 20,
                                        height: 20,
                                        color: Colors.white,
                                      ),
                                      onTap: () =>
                                          _navigateTo('addHerramienta'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // Movimientos
                          CustomExpansionTile(
                            title: 'Movimientos',
                            icon: const Icon(Icons.compare_arrows_sharp),
                            children: [
                              SubCustomExpansionTile(
                                title: 'Entradas',
                                icon: const Icon(
                                  Icons.arrow_circle_right_outlined,
                                ),
                                children: [
                                  PermissionWidget(
                                    permission: 'add',
                                    child: CustomListTile(
                                      title: 'Agregar entrada',
                                      icon: const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                      ),
                                      onTap: () => _navigateTo('addEntrada'),
                                    ),
                                  ),
                                  CustomListTile(
                                    title: 'Lista de entradas',
                                    icon: const Icon(
                                      Icons.list,
                                      color: Colors.white,
                                    ),
                                    onTap: () => _navigateTo('listEntradas'),
                                  ),
                                  CustomListTile(
                                    title: 'Cancelados',
                                    icon: const Icon(
                                      Icons.cancel_outlined,
                                      color: Colors.white,
                                    ),
                                    onTap: () => _navigateTo('listCancelados'),
                                  ),
                                ],
                              ),
                              SubCustomExpansionTile(
                                title: 'Salidas',
                                icon: const Icon(
                                  Icons.arrow_circle_left_outlined,
                                ),
                                children: [
                                  PermissionWidget(
                                    permission: 'add',
                                    child: CustomListTile(
                                      title: 'Agregar salida',
                                      icon: const Icon(
                                        Icons.add_box_outlined,
                                        color: Colors.white,
                                      ),
                                      onTap: () => _navigateTo('addSalida'),
                                    ),
                                  ),
                                  CustomListTile(
                                    title: 'Lista de salidas',
                                    icon: const Icon(
                                      Icons.line_style,
                                      color: Colors.white,
                                    ),
                                    onTap: () => _navigateTo('listSalidas'),
                                  ),
                                  CustomListTile(
                                    title: 'Cancelados',
                                    icon: const Icon(
                                      Icons.cancel_outlined,
                                      color: Colors.white,
                                    ),
                                    onTap: () =>
                                        _navigateTo('listCanceladosSalida'),
                                  ),
                                ],
                              ),

                              //Presupuesto
                              SubCustomExpansionTile(
                                title: 'Presupuestos',
                                icon: const Icon(
                                  Icons.wallet,
                                  color: Colors.white,
                                ),
                                children: [
                                  PermissionWidget(
                                    permission: 'add',
                                    child: CustomListTile(
                                      title: 'Agregar Presupuesto',
                                      icon: const Icon(
                                        Icons.wallet_rounded,
                                        color: Colors.white,
                                      ),
                                      onTap: () =>
                                          _navigateTo('addPresupuesto'),
                                    ),
                                  ),
                                  CustomListTile(
                                    title: 'Lista Presupuestos',
                                    icon: const Icon(
                                      Icons.wallet_membership_outlined,
                                      color: Colors.white,
                                    ),
                                    onTap: () => _navigateTo('listPresupuesto'),
                                  ),
                                ],
                              ),

                              //HtaPrestamo
                              SubCustomExpansionTile(
                                title: 'Prestamos',
                                icon: SvgPicture.asset(
                                  'assets/icons/worktools.svg',
                                  width: 20,
                                  height: 20,
                                  color: Colors.white,
                                ),
                                children: [
                                  CustomListTile(
                                    title: 'Lista Prestamos',
                                    icon: SvgPicture.asset(
                                      'assets/icons/worktools.svg',
                                      width: 20,
                                      height: 20,
                                      color: Colors.white,
                                    ),
                                    onTap: () => _navigateTo('listHtaPrest'),
                                  ),
                                  PermissionWidget(
                                    permission: 'add',
                                    child: CustomListTile(
                                      title: 'Add Prestamos',
                                      icon: SvgPicture.asset(
                                        'assets/icons/worktools.svg',
                                        width: 20,
                                        height: 20,
                                        color: Colors.white,
                                      ),
                                      onTap: () => _navigateTo('addHtaPrest'),
                                    ),
                                  ),
                                ],
                              ),

                              PermissionWidget(
                                permission: 'add',
                                child: SubCustomExpansionTile(
                                  title: 'Ajustes',
                                  icon: const Icon(Icons.abc_outlined),
                                  children: [
                                    CustomListTile(
                                      title: 'Ajuste +',
                                      icon: const Icon(
                                        Icons.list_alt_rounded,
                                        color: Colors.white,
                                      ),
                                      onTap: () => _navigateTo('addAjusteMas'),
                                    ),
                                    CustomListTile(
                                      title: 'Lista Ajuste +',
                                      icon: const Icon(
                                        Icons.list_alt_rounded,
                                        color: Colors.white,
                                      ),
                                      onTap: () => _navigateTo('listAjusteMas'),
                                    ),
                                    // CustomListTile(
                                    //   title: 'Ajuste -',
                                    //   icon: Icon(Icons.list_alt_rounded),
                                    //   onTap: () {},
                                    // ),
                                  ],
                                ),
                              ),

                              CustomListTile(
                                title: 'Consulta Universal',
                                icon: const Icon(
                                  Icons.webhook_rounded,
                                  color: Colors.white,
                                ),
                                onTap: () => _navigateTo('ConsultaU'),
                              ),
                            ],
                          ),

                          CustomExpansionTile(
                            title: 'Orden Servicio',
                            icon: Icon(Icons.sell_rounded, color: Colors.white),
                            children: [
                              CustomListTile(
                                title: 'Add Orden Servicios',
                                icon: const Icon(
                                  Icons.sell_rounded,
                                  color: Colors.white,
                                ),
                                onTap: () => _navigateTo('addOrdenServicio'),
                              ),
                              CustomListTile(
                                title: 'List Orden Servicios',
                                icon: const Icon(
                                  Icons.sell_rounded,
                                  color: Colors.white,
                                ),
                                onTap: () => _navigateTo('listOrdenServicio'),
                              ),
                            ],
                          ),

                          //REportes
                          PermissionWidget(
                            permission: 'canCContable',
                            child: CustomExpansionTile(
                              title: 'Contabilidad',
                              icon: const Icon(Icons.paste_rounded),
                              children: [
                                CustomListTile(
                                  title: 'CContables',
                                  icon: const Icon(
                                    Icons.list,
                                    color: Colors.white,
                                  ),
                                  onTap: () => _navigateTo('listCC'),
                                ),
                                CustomListTile(
                                  title: 'Reportes',
                                  icon: const Icon(
                                    Icons.add_chart,
                                    color: Colors.white,
                                  ),
                                  onTap: () => _navigateTo('generadorCC'),
                                ),
                                CustomListTile(
                                  title: 'PDF',
                                  icon: const Icon(
                                    Icons.picture_as_pdf,
                                    color: Colors.white,
                                  ),
                                  onTap: () => _navigateTo('listPDF'),
                                ),
                              ],
                            ),
                          ),

                          CustomExpansionTile(
                            title: 'Compras',
                            icon: const Icon(Icons.monetization_on),
                            children: [
                              SubCustomExpansionTile(
                                title: 'Solicitud',
                                icon: const Icon(Icons.pause_presentation),
                                children: [
                                  CustomListTile(
                                    title: '1) Solicitud',
                                    icon: const Icon(
                                      Icons.numbers,
                                      color: Colors.white,
                                    ),
                                    onTap: () =>
                                        _navigateTo('addSolicitudCompra'),
                                  ),
                                  CustomListTile(
                                    title: '2) Lista Solicitudes',
                                    icon: const Icon(
                                      Icons.numbers,
                                      color: Colors.white,
                                    ),
                                    onTap: () =>
                                        _navigateTo('listSolicitudCompra'),
                                  ),
                                ],
                              ),
                              PermissionWidget(
                                permission: 'seeDesarrollo',
                                child: SubCustomExpansionTile(
                                  title: 'Compras',
                                  icon: const Icon(Icons.bedroom_baby_rounded),
                                  children: [
                                    CustomListTile(
                                      title: 'Orden Compra',
                                      icon: const Icon(
                                        Icons.stroller_rounded,
                                        color: Colors.white,
                                      ),
                                      onTap: () =>
                                          _navigateTo('addOrdenCompra'),
                                    ),
                                    CustomListTile(
                                      title: 'Lista Compras',
                                      icon: const Icon(
                                        Icons.stroller,
                                        color: Colors.white,
                                      ),
                                      onTap: () =>
                                          _navigateTo('listOrdenCompra'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          CustomExpansionTile(
                            title: 'Lecturas',
                            icon: Icon(Icons.coffee_rounded),
                            children: [
                              CustomListTile(
                                title: 'Agregar Lecturas',
                                icon: const Icon(
                                  Icons.coffee_rounded,
                                  color: Colors.white,
                                ),
                                onTap: () => _navigateTo('addLecturas'),
                              ),
                              CustomListTile(
                                title: 'Lecturas',
                                icon: const Icon(
                                  Icons.coffee_rounded,
                                  color: Colors.white,
                                ),
                                onTap: () => _navigateTo('listLecturas'),
                              ),
                            ],
                          ),

                          CustomExpansionTile(
                            title: 'Descuentos',
                            icon: const Icon(Icons.portrait_sharp),
                            children: [
                              CustomListTile(
                                title: 'Add Descuento',
                                icon: const Icon(
                                  Icons.portrait_sharp,
                                  color: Colors.white,
                                ),
                                onTap: () => _navigateTo('addDescuentoSocial'),
                              ),
                              CustomListTile(
                                title: 'List Descuentos',
                                icon: const Icon(
                                  Icons.portrait_sharp,
                                  color: Colors.white,
                                ),
                                onTap: () => _navigateTo('listDescuentoSocial'),
                              ),
                              CustomListTile(
                                title: 'List Descuentos Movil',
                                icon: const Icon(
                                  Icons.portrait_sharp,
                                  color: Colors.white,
                                ),
                                onTap: () =>
                                    _navigateTo('listDescuentoSocialMovil'),
                              ),
                            ],
                          ),

                          PermissionWidget(
                            permission: 'manage_users',
                            child: CustomExpansionTile(
                              title: 'Configuración',
                              icon: const Icon(Icons.settings),
                              children: [
                                //Usuarios
                                SubCustomExpansionTile(
                                  title: 'Usuarios',
                                  icon: const Icon(
                                    Icons.person_pin,
                                    color: Colors.white,
                                  ),
                                  children: [
                                    CustomListTile(
                                      title: 'Lista Usuarios',
                                      icon: const Icon(
                                        Icons.format_list_numbered_outlined,
                                        color: Colors.white,
                                      ),
                                      onTap: () => _navigateTo('listUser'),
                                    ),
                                    PermissionWidget(
                                      permission: 'manage_roles',
                                      child: CustomListTile(
                                        title: 'Admin Roles',
                                        icon: const Icon(
                                          Icons.rocket_launch_sharp,
                                          color: Colors.white,
                                        ),
                                        onTap: () => _navigateTo('adminRole'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Logout
                  ListTile(
                    title: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.redAccent.shade400),
                        const SizedBox(width: 8),
                        Text(
                          'Salir',
                          style: TextStyle(
                            color: Colors.redAccent.shade400,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    onTap: _logOut,
                  ),
                ],
              ),
            ),
          ),

          // Contenido principal
          Expanded(
            child: Container(
              color: Colors.grey.shade100,
              child: Center(child: _currentPage),
            ),
          ),
        ],
      ),
    );
  }
}
