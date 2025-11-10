import 'package:ezride/Feature/Home/Favoritos/widgets/FavoritosCard_widget.dart';
import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FavCards extends StatefulWidget {
  const FavCards({Key? key}) : super(key: key);

  @override
  State<FavCards> createState() => _FavCardsState();
}

class _FavCardsState extends State<FavCards> {
  // Lista de vehículos favoritos de ejemplo
  final List<VehicleItem> _favoriteVehicles = [
    VehicleItem(
      id: '1',
      imageUrl:
          'https://images.unsplash.com/photo-1704146705694-6bab0ffb8cf9?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTk3Mjk3Nzd8&ixlib=rb-4.1.0&q=80&w=1080',
      title: 'BMW Serie 3',
      subtitle: '2023 • Sedán • Automático',
      description: 'Motor 2.0L Turbo • 255 HP',
      price: '\$45,990',
      isFavorite: true,
    ),
    VehicleItem(
      id: '2',
      imageUrl:
          'https://images.unsplash.com/photo-1555215695-3004980ad54e?ixlib=rb-4.0.0&auto=format&fit=crop&w=1080&q=80',
      title: 'Audi A4',
      subtitle: '2023 • Sedán • Automático',
      description: 'Motor 2.0L TFSI • 201 HP',
      price: '\$42,500',
      isFavorite: true,
    ),
    VehicleItem(
      id: '3',
      imageUrl:
          'https://images.unsplash.com/photo-1544636331-e26879cd4d9b?ixlib=rb-4.0.0&auto=format&fit=crop&w=1080&q=80',
      title: 'Mercedes Clase C',
      subtitle: '2023 • Sedán • Automático',
      description: 'Motor 2.0L • 255 HP',
      price: '\$48,200',
      isFavorite: true,
    ),
    VehicleItem(
      id: '4',
      imageUrl:
          'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?ixlib=rb-4.0.0&auto=format&fit=crop&w=1080&q=80',
      title: 'Tesla Model 3',
      subtitle: '2023 • Eléctrico • Automático',
      description: 'Autonomía 438km • 283 HP',
      price: '\$52,990',
      isFavorite: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }

PreferredSizeWidget _buildAppBar(BuildContext context) {
  return AppBar(
    title: Text(
      'Mis Favoritos',
      style: GoogleFonts.figtree(
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1A1A1A),
      ),
    ),
    backgroundColor: Colors.white, // Fondo blanco fijo
    elevation: 0, // Sin sombra inicial
    scrolledUnderElevation: 0, // ← ELIMINA la elevación al scrollear
    surfaceTintColor: Colors.transparent, // ← ELIMINA el tinte automático
    foregroundColor: Colors.transparent, // ← Sin efectos de overlay
    shadowColor: Colors.transparent, // ← Sin sombras
    actions: [
      IconButton(
        icon: Icon(Icons.search, color: const Color(0xFF1A1A1A)),
        onPressed: _handleSearch,
      ),
      IconButton(
        icon: Icon(Icons.filter_list, color: const Color(0xFF1A1A1A)),
        onPressed: _handleFilter,
      ),
    ],
  );
}

  Widget _buildBody(BuildContext context) {
    if (_favoriteVehicles.isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          Expanded(
            child: _buildVehiclesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${_favoriteVehicles.length} vehículos guardados',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        if (_favoriteVehicles.isNotEmpty)
          TextButton.icon(
            onPressed: _handleClearAll,
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('Limpiar todo'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
          ),
      ],
    );
  }

  Widget _buildVehiclesList() {
    return ListView.separated(
      itemCount: _favoriteVehicles.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final vehicle = _favoriteVehicles[index];
        return VehicleFavCard(
          imageUrl: vehicle.imageUrl,
          title: vehicle.title,
          subtitle: vehicle.subtitle,
          description: vehicle.description,
          price: vehicle.price,
          isFavorite: vehicle.isFavorite,
          onFavoritePressed: () => _handleFavoriteToggle(vehicle.id),
          onDetailsPressed: () => _handleViewDetails(vehicle.id),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes favoritos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Los vehículos que marques como favoritos\naparecerán aquí',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _handleExploreVehicles,
            child: const Text('Explorar Vehículos'),
          ),
        ],
      ),
    );
  }

  // Handlers para las acciones
  void _handleSearch() {
    // Navegar a pantalla de búsqueda
    print('Buscar en favoritos');
  }

  void _handleFilter() {
    // Mostrar opciones de filtro
    print('Filtrar favoritos');
    _showFilterDialog();
  }

  void _handleFavoriteToggle(String vehicleId) {
    setState(() {
      final vehicle = _favoriteVehicles.firstWhere((v) => v.id == vehicleId);
      vehicle.isFavorite = !vehicle.isFavorite;

      // Si se desmarca como favorito, remover de la lista
      if (!vehicle.isFavorite) {
        _favoriteVehicles.removeWhere((v) => v.id == vehicleId);

        // Mostrar snackbar de confirmación
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${vehicle.title} removido de favoritos'),
            action: SnackBarAction(
              label: 'Deshacer',
              onPressed: () {
                setState(() {
                  vehicle.isFavorite = true;
                  _favoriteVehicles.add(vehicle);
                });
              },
            ),
          ),
        );
      }
    });
  }

  void _handleViewDetails(String vehicleId) {
    // Navegar a pantalla de detalles del vehículo
    final vehicle = _favoriteVehicles.firstWhere((v) => v.id == vehicleId);
    print('Ver detalles de: ${vehicle.title}');

    // Ejemplo de navegación:
    // Navigator.push(context, MaterialPageRoute(
    //   builder: (_) => VehicleDetailPage(vehicleId: vehicleId),
    // ));
  }

  void _handleClearAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar favoritos'),
        content: const Text(
            '¿Estás seguro de que quieres eliminar todos tus vehículos favoritos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _favoriteVehicles.clear();
              });
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Todos los favoritos han sido eliminados')),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _handleExploreVehicles() {
    // Navegar a la pantalla principal de vehículos
    print('Explorar vehículos');
    // Navigator.pushAndRemoveUntil(context,
    //   MaterialPageRoute(builder: (_) => HomePage()),
    //   (route) => false
    // );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtrar Favoritos',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            // Aquí puedes agregar opciones de filtro
            ListTile(
              leading: const Icon(Icons.sort),
              title: const Text('Ordenar por precio'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                _sortByPrice();
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Ordenar por año'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                _sortByYear();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _sortByPrice() {
    setState(() {
      _favoriteVehicles.sort((a, b) {
        final priceA = double.parse(a.price.replaceAll(RegExp(r'[^\d.]'), ''));
        final priceB = double.parse(b.price.replaceAll(RegExp(r'[^\d.]'), ''));
        return priceA.compareTo(priceB);
      });
    });
  }

  void _sortByYear() {
    setState(() {
      _favoriteVehicles.sort((a, b) {
        final yearA = int.parse(a.subtitle.split('•').first.trim());
        final yearB = int.parse(b.subtitle.split('•').first.trim());
        return yearB.compareTo(yearA); // Más reciente primero
      });
    });
  }
}

// Clase auxiliar para manejar los datos del vehículo
class VehicleItem {
  final String id;
  final String imageUrl;
  final String title;
  final String subtitle;
  final String description;
  final String price;
  bool isFavorite;

  VehicleItem({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.price,
    this.isFavorite = false,
  });
}
