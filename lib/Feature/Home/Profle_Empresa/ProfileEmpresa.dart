import 'package:ezride/Feature/Home/Profle_Empresa/widget/GestionEmpresa.dart';
import 'package:ezride/Feature/Home/Profle_Empresa/widget/ProfileButton.dart';
import 'package:ezride/Feature/Home/Profle_Empresa/widget/ProfileEmpresaAppBar_widget.dart';
import 'package:ezride/Feature/Home/Profle_Empresa/widget/ProfileEmpresaGanancias_widget.dart';
import 'package:ezride/Feature/Home/Profle_Empresa/widget/ProfileEmpresaHeader_widget.dart';
import 'package:ezride/Feature/Home/Profle_Empresa/widget/ProfileEstadistics.dart';
import 'package:ezride/Feature/Home/Profle_Empresa/widget/ProfleActions.dart';
import 'package:ezride/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

class PerfilEmpresaWidget extends StatefulWidget {
  const PerfilEmpresaWidget({super.key});

  @override
  State<PerfilEmpresaWidget> createState() => _PerfilEmpresaWidgetState();
}

class _PerfilEmpresaWidgetState extends State<PerfilEmpresaWidget> {
  // Agregando las variables que faltan
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Si necesitas inicializar algún modelo aquí
  }

  @override
  void dispose() {
    // Si necesitas limpiar algún modelo aquí
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xFFF0F5F9),
        appBar: EmpresaAppBar(), // Asumiendo que este widget existe
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                PerfilHeader(
                  nombreEmpresa: 'AutoRent Premium',
                  descripcion: 'Empresa de Renta de Vehículos',
                  imagenUrl: 'https://images.unsplash.com/photo-1604172497384-6fea2a1e7092',
                  calificacion: 4.2,
                  totalResenas: 156,
                  ubicacion: 'Av. Principal 123, Ciudad de México',
                ),
                GananciasCard(
                  gananciasTotales: 45280,
                  gananciasMes: 12450,
                  tendenciaPositiva: true,
                ),
                EstadisticasRapidas(
                  totalVehiculos: 24,
                  porcentajeOcupacion: 89,
                ),
                AccionesGrid(
                  solicitudesPendientes: 12,
                  carrosRentados: 8,
                  carrosDisponibles: 15,
                  onAgregarCarro: () => print('Agregar carro'),
                  onVerSolicitudes: () => print('Ver solicitudes'),
                  onVerRentados: () => print('Ver rentados'),
                  onVerInventario: () => print('Ver inventario'),
                ),
                GestionEmpresa(
                  representante: 'Carlos Mendoza',
                  cargoRepresentante: 'CEO',
                  usuarioEmail: 'autorent.premium@email.com',
                  onPerfilEmpresa: () => print('Perfil empresa'),
                  onRepresentante: () => print('Representante'),
                  onUsuario: () => print('Usuario'),
                ),
                BotonCerrarSesion(
                  onCerrarSesion: () => print('Cerrar sesión'),
                ),
              ]
                  .divide(SizedBox(height: 16))
                  .addToStart(SizedBox(height: 12))
                  .addToEnd(SizedBox(height: 24)),
            ),
          ),
        ),
      ),
    );
  }
}