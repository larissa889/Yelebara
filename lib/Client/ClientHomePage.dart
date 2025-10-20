import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:yelebara_mobile/Screens/LoginPage.dart';
import 'package:collection/collection.dart';
import 'dart:async';

class ClientHomePage extends StatefulWidget {
  const ClientHomePage({Key? key}) : super(key: key);

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  bool _showLocationDialog = false;
  String _selectedPrecision = 'exacte'; // 'exacte' ou 'approximative'
  bool _gpsDisabled = false;
  StreamSubscription<ServiceStatus>? _serviceStatusSub;
  String? _headerName;
  String? _headerPhone;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
    _listenGpsServiceStatus();
    _loadHeaderInfo();
  }

  Future<void> _checkFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasShownLocationDialog = prefs.getBool('hasShownLocationDialog') ?? false;
    
    if (!hasShownLocationDialog) {
      // Petite pause pour laisser la page se charger
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _showLocationDialog = true;
      });
    }
  }

  Future<void> _loadHeaderInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final emailKey = prefs.getString('current_user_email');
    if (emailKey == null) return;
    setState(() {
      _headerName = prefs.getString('profile:'+emailKey+':name');
      _headerPhone = prefs.getString('profile:'+emailKey+':phone');
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user_email');
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Future<void> _listenGpsServiceStatus() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    setState(() { _gpsDisabled = !enabled; });
    _serviceStatusSub = Geolocator.getServiceStatusStream().listen((status) {
      setState(() { _gpsDisabled = status == ServiceStatus.disabled; });
    });
  }

  @override
  void dispose() {
    _serviceStatusSub?.cancel();
    super.dispose();
  }

  Future<void> _handleLocationPermission(String choice) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasShownLocationDialog', true);
    
    // TODO: Implémenter la logique de permission de localisation
    if (choice == 'allow_while_using' || choice == 'allow_once') {
      // Demander la permission de localisation
      // Utiliser le package geolocator ou location
      print('Permission demandée: $choice avec précision: $_selectedPrecision');
    }
    
    setState(() {
      _showLocationDialog = false;
    });

    // Afficher un message de confirmation
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            choice == 'deny' 
              ? 'Vous pourrez activer la localisation plus tard dans les paramètres'
              : 'Localisation activée',
          ),
          backgroundColor: choice == 'deny' ? Colors.orange : Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          // Contenu principal
          CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                backgroundColor: Colors.orange.shade600,
                floating: true,
                pinned: true,
                elevation: 2,
                leading: Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                ),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'YELEBARA',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () {
                      // TODO: Ouvrir la page de recherche
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ),

              // Bannière principale
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  height: 180,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade400, Colors.orange.shade700],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -20,
                        top: -20,
                        child: Icon(
                          Icons.local_laundry_service,
                          size: 150,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Pour tous vos besoins\nde pressing',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '8H - 22H',
                                style: TextStyle(
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Section "Nos spécialités"
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Nos spécialités',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Voir tous les services
                        },
                        child: Text(
                          'Voir plus',
                          style: TextStyle(
                            color: Colors.orange.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Grille des services
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildListDelegate([
                    _buildServiceCard(
                      'Nettoyage à sec',
                      Icons.dry_cleaning,
                      Colors.blue,
                    ),
                    _buildServiceCard(
                      'Repassage',
                      Icons.iron,
                      Colors.purple,
                    ),
                    _buildServiceCard(
                      'Lavage express',
                      Icons.local_laundry_service,
                      Colors.green,
                    ),
                    _buildServiceCard(
                      'Livraison',
                      Icons.delivery_dining,
                      Colors.orange,
                    ),
                  ]),
                ),
              ),
            ],
          ),

          // Popup de permission de localisation
          if (_showLocationDialog)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2E),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icône de localisation
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade400,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Titre
                      const Text(
                        'Autoriser Yelebara Pressing à accéder à la position de cet appareil ?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Options de précision
                      Row(
                        children: [
                          Expanded(
                            child: _buildPrecisionOption(
                              'Exacte',
                              Icons.my_location,
                              'exacte',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildPrecisionOption(
                              'Approximative',
                              Icons.location_searching,
                              'approximative',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Boutons d'action
                      _buildActionButton(
                        "Lorsque vous utilisez l'appli",
                        () => _handleLocationPermission('allow_while_using'),
                      ),
                      const SizedBox(height: 12),
                      _buildActionButton(
                        'Uniquement cette fois-ci',
                        () => _handleLocationPermission('allow_once'),
                      ),
                      const SizedBox(height: 12),
                      _buildActionButton(
                        'Ne pas autoriser',
                        () => _handleLocationPermission('deny'),
                        isDestructive: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // Popup GPS désactivé
          if (_gpsDisabled)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4E8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Localisation',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Votre position GPS est désactivée.\nVeuillez l\'activer dans les paramètres.',
                        style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () { setState(() { _gpsDisabled = false; }); },
                            child: const Text('J\'ai compris'),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () async { await Geolocator.openLocationSettings(); },
                            child: const Text('Activer'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0, // Accueil actif sur cette page
        selectedItemColor: Colors.orange.shade700,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) return; // Rester sur Accueil
          Widget page;
          switch (index) {
            case 1:
              page = const _ClientPressingPage();
              break;
            case 2:
              page = const _ClientOrdersPage();
              break;
            case 3:
              page = const _ClientProfilePage();
              break;
            default:
              return;
          }
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => page),
          );
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.local_laundry_service), label: 'Pressing'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Commandes'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
      drawer: _buildDrawer(),
    );
  }

  Widget _buildPrecisionOption(String label, IconData icon, String value) {
    final isSelected = _selectedPrecision == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPrecision = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade400.withOpacity(0.2) : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue.shade400 : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.shade400 : Colors.grey.shade700,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed, {bool isDestructive = false}) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.grey.shade800,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isDestructive ? Colors.red.shade400 : Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(String title, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: Navigation vers le détail du service
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 40,
                    color: color,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade400, Colors.orange.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 44, color: Colors.orange),
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        _headerName ?? 'Invité',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Flexible(
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        _headerPhone ?? '',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ),
            ListTile(
            leading: const Icon(Icons.local_laundry_service),
            title: const Text('Nos services'),
            onTap: () {
              Navigator.pop(context);
            },
            ),
            ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('Commande'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const _ClientOrdersPage()),
              );
            },
            ),
            const Divider(),
            const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(alignment: Alignment.centerLeft, child: Text('Communication', style: TextStyle(fontWeight: FontWeight.w700))),
            ),
            ListTile(
            leading: const Icon(Icons.phone_in_talk, color: Colors.green),
            title: const Text('Contactez-nous'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () { Navigator.pop(context); },
            ),
            ListTile(
            leading: const Icon(Icons.star_rate_rounded, color: Colors.orange),
            title: const Text('Notez-nous'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () { Navigator.pop(context); },
            ),
            ListTile(
            leading: const Icon(Icons.share, color: Colors.lightBlue),
            title: const Text('Partagez cette application'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () { Navigator.pop(context); },
            ),
            const Divider(),
            ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Se déconnecter', style: TextStyle(color: Colors.red)),
            onTap: _logout,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// Pages accessibles via la barre de navigation inférieure

class _ClientPressingPage extends StatelessWidget {
  const _ClientPressingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const _BeneficiaryDirectoryPage();
  }
}

class _BeneficiaryDirectoryPage extends StatefulWidget {
  const _BeneficiaryDirectoryPage({Key? key}) : super(key: key);

  @override
  State<_BeneficiaryDirectoryPage> createState() => _BeneficiaryDirectoryPageState();
}

class _BeneficiaryDirectoryPageState extends State<_BeneficiaryDirectoryPage> {
  List<_Beneficiary> _all = [];
  String _query = '';
  String _selectedQuartier = 'Tous';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getStringList('beneficiaries_index') ?? <String>[];
    final List<_Beneficiary> users = [];
    for (final email in index) {
      final name = prefs.getString('profile:'+email+':name') ?? '';
      final phone = prefs.getString('profile:'+email+':phone') ?? '';
      final addr = prefs.getString('profile:'+email+':address1') ?? '';
      users.add(_Beneficiary(name: name, email: email, phone: phone, quartier: addr));
    }
    setState(() { _all = users; });
  }

  @override
  Widget build(BuildContext context) {
    final quartiers = ['Tous', ..._all.map((e) => e.quartier.trim()).where((e) => e.isNotEmpty).toSet().toList()];
    final filtered = _all.where((b) {
      final matchQuery = _query.isEmpty || b.name.toLowerCase().contains(_query.toLowerCase()) || b.phone.contains(_query) || b.email.contains(_query);
      final matchQuartier = _selectedQuartier == 'Tous' || b.quartier.trim() == _selectedQuartier;
      return matchQuery && matchQuartier;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.orange.shade700,
        title: Text('Pressing', style: TextStyle(color: Colors.orange.shade700, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: LayoutBuilder(
              builder: (ctx, constraints) {
                final isNarrow = constraints.maxWidth < 360;
                return isNarrow
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            onChanged: (v) => setState(() => _query = v),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search),
                              hintText: 'Rechercher un bénéficiaire...',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedQuartier,
                            decoration: const InputDecoration(border: OutlineInputBorder(borderSide: BorderSide.none), filled: true),
                            items: quartiers.map((q) => DropdownMenuItem(value: q, child: Text(q))).toList(),
                            onChanged: (v) => setState(() => _selectedQuartier = v ?? 'Tous'),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onChanged: (v) => setState(() => _query = v),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.search),
                                hintText: 'Rechercher un bénéficiaire...',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 160,
                            child: DropdownButtonFormField<String>(
                              value: _selectedQuartier,
                              decoration: const InputDecoration(border: OutlineInputBorder(borderSide: BorderSide.none), filled: true),
                              items: quartiers.map((q) => DropdownMenuItem(value: q, child: Text(q, overflow: TextOverflow.ellipsis))).toList(),
                              onChanged: (v) => setState(() => _selectedQuartier = v ?? 'Tous'),
                            ),
                          ),
                        ],
                      );
              },
            ),
          ),
          Expanded(
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, i) {
                final b = filtered[i];
                return ListTile(
                  leading: CircleAvatar(child: Text(b.initials)),
                  title: Text(
                    b.name.isEmpty ? b.email : b.name,
                    style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    b.quartier.isEmpty ? '—' : b.quartier,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: SizedBox(
                    width: 110,
                    child: Text(
                      b.phone,
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const _ClientBottomNav(activeIndex: 1),
    );
  }
}

class _Beneficiary {
  final String name;
  final String email;
  final String phone;
  final String quartier;
  _Beneficiary({required this.name, required this.email, required this.phone, required this.quartier});
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }
}

class _GpsDisabledLayer extends StatefulWidget {
  const _GpsDisabledLayer({Key? key}) : super(key: key);

  @override
  State<_GpsDisabledLayer> createState() => _GpsDisabledLayerState();
}

class _GpsDisabledLayerState extends State<_GpsDisabledLayer> {
  bool _gpsDisabled = false;
  bool _hiddenOnce = false;
  StreamSubscription<ServiceStatus>? _sub;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    setState(() {
      _gpsDisabled = !enabled;
      _hiddenOnce = false;
    });
    _sub = Geolocator.getServiceStatusStream().listen((status) {
      setState(() {
        _gpsDisabled = status == ServiceStatus.disabled;
        if (!_gpsDisabled) _hiddenOnce = false; // reset hide when re-enabled
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_gpsDisabled || _hiddenOnce) return const SizedBox.shrink();
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4E8),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Localisation',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              const Text(
                'Votre position GPS est désactivée.\nVeuillez l\'activer dans les paramètres.',
                style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () { setState(() { _hiddenOnce = true; }); },
                    child: const Text('J\'ai compris'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () async { await Geolocator.openLocationSettings(); },
                    child: const Text('Activer'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _ClientOrdersPage extends StatelessWidget {
  const _ClientOrdersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.orange.shade700,
        title: Text('Commandes', style: TextStyle(color: Colors.orange.shade700, fontWeight: FontWeight.w700)),
      ),
      body: const Center(child: Text('Liste de vos commandes')),
      bottomNavigationBar: _ClientBottomNav(activeIndex: 2),
    );
  }
}

class _ClientProfilePage extends StatefulWidget {
  const _ClientProfilePage({Key? key}) : super(key: key);

  @override
  State<_ClientProfilePage> createState() => _ClientProfilePageState();
}

class _ClientProfilePageState extends State<_ClientProfilePage> {
  String? _name;
  String? _email;
  String? _phone;
  String? _address1;
  String? _address2;
  String? _phone2;
  Uint8List? _photoBytes;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final emailKey = prefs.getString('current_user_email');
    if (emailKey == null) return;
    final b64 = prefs.getString('profile:'+emailKey+':photo_b64');
    setState(() {
      _name = prefs.getString('profile:'+emailKey+':name');
      _email = prefs.getString('profile:'+emailKey+':email');
      _phone = prefs.getString('profile:'+emailKey+':phone');
      _address1 = prefs.getString('profile:'+emailKey+':address1');
      _address2 = prefs.getString('profile:'+emailKey+':address2');
      _phone2 = prefs.getString('profile:'+emailKey+':phone2');
      _photoBytes = (b64 != null && b64.isNotEmpty) ? base64Decode(b64) : null;
    });
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1200);
    if (image == null) return;
    final prefs = await SharedPreferences.getInstance();
    final emailKey = prefs.getString('current_user_email');
    if (emailKey == null) return;
    final bytes = await image.readAsBytes();
    final b64 = base64Encode(bytes);
    await prefs.setString('profile:'+emailKey+':photo_b64', b64);
    setState(() {
      _photoBytes = bytes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.orange.shade700,
        title: Text('Mon profil', style: TextStyle(color: Colors.orange.shade700, fontWeight: FontWeight.w700)),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
          const SizedBox(height: 8),
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickPhoto,
                  child: CircleAvatar(
                    radius: 54,
                    backgroundColor: Colors.orange.shade100,
                    backgroundImage: (_photoBytes != null) ? MemoryImage(_photoBytes!) : null,
                    child: (_photoBytes == null)
                        ? const Icon(Icons.person, size: 64, color: Colors.white70)
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _name ?? 'Utilisateur',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _ProfileField(title: 'Mon numéro de téléphone', value: _phone ?? ''),
          _EditableProfileField(
            title: 'Mon 2nd numéro de téléphone',
            value: _phone2 ?? '',
            keyboardType: TextInputType.phone,
            onSaved: (val) async {
              final prefs = await SharedPreferences.getInstance();
              final emailKey = prefs.getString('current_user_email');
              if (emailKey != null) {
                await prefs.setString('profile:'+emailKey+':phone2', val);
                setState(() => _phone2 = val);
              }
            },
          ),
          _ProfileField(title: 'Mon email', value: _email ?? ''),
          _ProfileField(title: 'Mon adresse', value: _address1 ?? ''),
          _EditableProfileField(
            title: 'Ma 2nde adresse',
            value: _address2 ?? '',
            keyboardType: TextInputType.streetAddress,
            onSaved: (val) async {
              final prefs = await SharedPreferences.getInstance();
              final emailKey = prefs.getString('current_user_email');
              if (emailKey != null) {
                await prefs.setString('profile:'+emailKey+':address2', val);
                setState(() => _address2 = val);
              }
            },
          ),

          const SizedBox(height: 24),
          const Text('Options', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87)),
          const SizedBox(height: 8),
          _OptionItem(
            icon: Icons.edit_note,
            iconColor: Colors.orange,
            title: 'Changer mes informations',
            onTap: _editMainInfo,
          ),
          _OptionItem(
            icon: Icons.phone_in_talk,
            iconColor: Colors.green,
            title: 'Contactez-nous',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Contact: support@yelebara.app | +226 xx xx xx xx')),
              );
            },
          ),
          _OptionItem(
            icon: Icons.star_rate_rounded,
            iconColor: Colors.amber,
            title: 'Notez-nous',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bientôt disponible sur le store.')),
              );
            },
          ),
          _OptionItem(
            icon: Icons.share,
            iconColor: Colors.lightBlue,
            title: 'Partagez cette application',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Lien de partage bientôt disponible.')),
              );
            },
          ),
          _OptionItem(
            icon: Icons.logout,
            iconColor: Colors.red,
            title: 'Se déconnecter',
            onTap: _logout,
            trailingColor: Colors.red,
          ),

          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1E6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Supprimer mon compte', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                const Text(
                  'Vous pouvez supprimer votre compte à tout moment. Vos informations personnelles seront supprimées de cet appareil.',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                    onPressed: _confirmDeleteAccount,
                    child: const Text('Supprimer mon compte'),
                  ),
                ),
              ],
            ),
          ),
            ],
          ),
          const _GpsDisabledLayer(),
        ],
      ),
      bottomNavigationBar: const _ClientBottomNav(activeIndex: 3),
    );
  }

  Future<void> _editMainInfo() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => _EditProfilePage(
          initialName: _name ?? '',
          initialPhone: _phone ?? '',
          initialPhone2: _phone2 ?? '',
          initialEmail: _email ?? '',
          initialAddress1: _address1 ?? '',
          initialAddress2: _address2 ?? '',
        ),
      ),
    );
    if (saved == true) {
      await _loadProfile();
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user_email');
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Future<void> _confirmDeleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Supprimer mon compte'),
          content: const Text('Cette action supprimera vos données locales sur cet appareil. Continuer ?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Annuler')),
            TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Supprimer', style: TextStyle(color: Colors.red))),
          ],
        );
      },
    );
    if (confirm != true) return;
    final prefs = await SharedPreferences.getInstance();
    final emailKey = prefs.getString('current_user_email');
    if (emailKey != null) {
      await prefs.remove('user_role:'+emailKey);
      await prefs.remove('profile:'+emailKey+':name');
      await prefs.remove('profile:'+emailKey+':email');
      await prefs.remove('profile:'+emailKey+':phone');
      await prefs.remove('profile:'+emailKey+':phone2');
      await prefs.remove('profile:'+emailKey+':address1');
      await prefs.remove('profile:'+emailKey+':address2');
      await prefs.remove('profile:'+emailKey+':photo_b64');
    }
    await prefs.remove('current_user_email');
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String title;
  final String value;
  const _ProfileField({Key? key, required this.title, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value.isEmpty ? '-' : value,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditableProfileField extends StatelessWidget {
  final String title;
  final String value;
  final TextInputType keyboardType;
  final Future<void> Function(String value) onSaved;

  const _EditableProfileField({
    Key? key,
    required this.title,
    required this.value,
    required this.keyboardType,
    required this.onSaved,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final controller = TextEditingController(text: value);
        final newValue = await showModalBottomSheet<String>(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (ctx) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Saisir ici...'
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
                      child: const Text('Enregistrer'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
        if (newValue != null) {
          await onSaved(newValue);
        }
      },
      child: _ProfileField(title: title, value: value),
    );
  }
}

class _OptionItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;
  final Color? trailingColor;

  const _OptionItem({
    Key? key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
    this.trailingColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container
    (
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        trailing: Icon(Icons.chevron_right, color: trailingColor ?? Colors.grey.shade600),
      ),
    );
  }
}

class _EditProfilePage extends StatefulWidget {
  final String initialName;
  final String initialPhone;
  final String initialPhone2;
  final String initialEmail;
  final String initialAddress1;
  final String initialAddress2;

  const _EditProfilePage({
    Key? key,
    required this.initialName,
    required this.initialPhone,
    required this.initialPhone2,
    required this.initialEmail,
    required this.initialAddress1,
    required this.initialAddress2,
  }) : super(key: key);

  @override
  State<_EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<_EditProfilePage> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _phone2Ctrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _addr1Ctrl;
  late final TextEditingController _addr2Ctrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName);
    _phoneCtrl = TextEditingController(text: widget.initialPhone);
    _phone2Ctrl = TextEditingController(text: widget.initialPhone2);
    _emailCtrl = TextEditingController(text: widget.initialEmail);
    _addr1Ctrl = TextEditingController(text: widget.initialAddress1);
    _addr2Ctrl = TextEditingController(text: widget.initialAddress2);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _phone2Ctrl.dispose();
    _emailCtrl.dispose();
    _addr1Ctrl.dispose();
    _addr2Ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon profil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _LabeledField(
            label: 'Nom & Prénom',
            icon: Icons.person_outline,
            controller: _nameCtrl,
          ),
          _LabeledField(
            label: 'Numéro de téléphone',
            icon: Icons.phone,
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
          ),
          _LabeledField(
            label: '2nd numéro de téléphone',
            icon: Icons.phone,
            controller: _phone2Ctrl,
            keyboardType: TextInputType.phone,
          ),
          _LabeledField(
            label: 'Email',
            icon: Icons.mail_outline,
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          _LabeledField(
            label: 'Adresse de livraison',
            icon: Icons.home_outlined,
            controller: _addr1Ctrl,
            keyboardType: TextInputType.streetAddress,
            maxLines: 2,
          ),
          _LabeledField(
            label: '2nde Adresse de livraison',
            icon: Icons.home_outlined,
            controller: _addr2Ctrl,
            keyboardType: TextInputType.streetAddress,
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              child: const Text('Enregistrer'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final emailKey = prefs.getString('current_user_email');
    if (emailKey != null) {
      await prefs.setString('profile:'+emailKey+':name', _nameCtrl.text.trim());
      await prefs.setString('profile:'+emailKey+':phone', _phoneCtrl.text.trim());
      await prefs.setString('profile:'+emailKey+':phone2', _phone2Ctrl.text.trim());
      await prefs.setString('profile:'+emailKey+':email', _emailCtrl.text.trim());
      await prefs.setString('profile:'+emailKey+':address1', _addr1Ctrl.text.trim());
      await prefs.setString('profile:'+emailKey+':address2', _addr2Ctrl.text.trim());
    }
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;

  const _LabeledField({
    Key? key,
    required this.label,
    required this.icon,
    required this.controller,
    this.keyboardType,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              maxLines: maxLines,
              decoration: InputDecoration(
                labelText: label,
                border: InputBorder.none,
              ),
            ),
          ),
          Icon(icon, color: Colors.orange.shade400),
        ],
      ),
    );
  }
}

// Gender UI removed as requested

class _ClientBottomNav extends StatelessWidget {
  final int activeIndex;
  const _ClientBottomNav({Key? key, required this.activeIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: activeIndex,
      selectedItemColor: Colors.orange.shade700,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        if (index == activeIndex) return;
        if (index == 0) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const ClientHomePage()),
            (route) => false,
          );
          return;
        }
        Widget page;
        switch (index) {
          case 1:
            page = const _ClientPressingPage();
            break;
          case 2:
            page = const _ClientOrdersPage();
            break;
          case 3:
            page = const _ClientProfilePage();
            break;
          default:
            return;
        }
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => page),
        );
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
        BottomNavigationBarItem(icon: Icon(Icons.local_laundry_service), label: 'Pressing'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Commandes'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ],
    );
  }
}