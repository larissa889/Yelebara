import 'package:flutter/material.dart';
import 'package:yelebara_mobile/widgets/YelebaraLogo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _addressController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String _selectedUserType = 'client'; // 'client' ou 'presseur'
  String? _selectedZone; // Zone pour les presseurs

  // Liste des zones disponibles (à remplacer par un appel API plus tard)
  final List<String> _zones = [
    'Ouagadougou – Zone du 1200 logements',
    'Ouagadougou – Tampouy',
    'Ouagadougou – Ouaga 2000',
    'Ouagadougou – Zone du Bois',
    'Ouagadougou – Gounghin',
    'Ouagadougou – Cissin',
    'Bobo-Dioulasso – Accart-ville',
    'Bobo-Dioulasso – Belle-ville',
    'Koudougou – Secteur 5',
    'Koudougou – Centre-ville',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _handleSignup() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simuler une inscription
      Future.delayed(const Duration(seconds: 2), () async {
        setState(() {
          _isLoading = false;
        });
        // Sauvegarde du rôle sélectionné et des infos de profil pour l'étape de connexion
        final prefs = await SharedPreferences.getInstance();
        final emailKey = _emailController.text.trim().toLowerCase();
        if (emailKey.isNotEmpty) {
          await prefs.setString('user_role:$emailKey', _selectedUserType);
          await prefs.setString('profile:$emailKey:name', _nameController.text.trim());
          await prefs.setString('profile:$emailKey:email', _emailController.text.trim());
          await prefs.setString('profile:$emailKey:phone', _phoneController.text.trim());
          await prefs.setString('profile:$emailKey:address1', _addressController.text.trim());
          await prefs.setString('profile:$emailKey:address2', '');
          await prefs.setString('profile:$emailKey:phone2', '');
          
          // Sauvegarder la zone si c'est un presseur
          if (_selectedUserType == 'presseur' && _selectedZone != null) {
            await prefs.setString('profile:$emailKey:zone', _selectedZone!);
          }
          
          // Indexer les presseurs
          if (_selectedUserType == 'presseur') {
            final List<String> index = prefs.getStringList('presseurs_index') ?? <String>[];
            if (!index.contains(emailKey)) {
              index.add(emailKey);
              await prefs.setStringList('presseurs_index', index);
            }
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Inscription réussie en tant que $_selectedUserType !',
            ),
            backgroundColor: Colors.green,
          ),
        );
        // Retour à la page de connexion (le routage par rôle se fait à la connexion)
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.08,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: isSmallScreen ? 10 : 20),

                  // Logo
                  const Center(child: YelebaraLogo(size: 120)),

                  SizedBox(height: isSmallScreen ? 20 : 30),

                  // Titre
                  Text(
                    'Créer un compte',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 28 : 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  Text(
                    'Rejoignez Yelebara Pressing',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 15 : 16,
                      color: Colors.grey[600],
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 20 : 30),

                  // Sélection du type d'utilisateur
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedUserType = 'client';
                                _selectedZone = null; // Réinitialiser la zone
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: isSmallScreen ? 12 : 14,
                              ),
                              decoration: BoxDecoration(
                                color: _selectedUserType == 'client'
                                    ? Colors.orange.shade600
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.person_outline,
                                    color: _selectedUserType == 'client'
                                        ? Colors.white
                                        : Colors.grey.shade600,
                                    size: isSmallScreen ? 28 : 32,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Client',
                                    style: TextStyle(
                                      color: _selectedUserType == 'client'
                                          ? Colors.white
                                          : Colors.grey.shade600,
                                      fontWeight: FontWeight.bold,
                                      fontSize: isSmallScreen ? 14 : 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedUserType = 'presseur';
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: isSmallScreen ? 12 : 14,
                              ),
                              decoration: BoxDecoration(
                                color: _selectedUserType == 'presseur'
                                    ? Colors.orange.shade600
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.business_center_outlined,
                                    color: _selectedUserType == 'presseur'
                                        ? Colors.white
                                        : Colors.grey.shade600,
                                    size: isSmallScreen ? 28 : 32,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Presseur',
                                    style: TextStyle(
                                      color: _selectedUserType == 'presseur'
                                          ? Colors.white
                                          : Colors.grey.shade600,
                                      fontWeight: FontWeight.bold,
                                      fontSize: isSmallScreen ? 14 : 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 20 : 30),

                  // Formulaire
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Champ Nom complet
                        TextFormField(
                          controller: _nameController,
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                            labelText: _selectedUserType == 'presseur' 
                                ? 'Nom du pressing' 
                                : 'Nom complet',
                            hintText: _selectedUserType == 'presseur'
                                ? 'Ex: Pressing Excellence'
                                : 'Votre nom et prénom',
                            prefixIcon: Icon(
                              _selectedUserType == 'presseur'
                                  ? Icons.business
                                  : Icons.person_outline,
                              color: Colors.orange.shade600,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.orange.shade600,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return _selectedUserType == 'presseur'
                                  ? 'Veuillez entrer le nom du pressing'
                                  : 'Veuillez entrer votre nom';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: isSmallScreen ? 14 : 18),

                        // Champ Email
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'votreemail@exemple.com',
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: Colors.orange.shade600,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.orange.shade600,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre email';
                            }
                            if (!value.contains('@')) {
                              return 'Email invalide';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: isSmallScreen ? 14 : 18),

                        // Champ Téléphone
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Téléphone',
                            hintText: '+226 XX XX XX XX',
                            prefixIcon: Icon(
                              Icons.phone_outlined,
                              color: Colors.orange.shade600,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.orange.shade600,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre numéro';
                            }
                            return null;
                          },
                        ),

                        // Zone de couverture (affichée uniquement si type "presseur")
                        if (_selectedUserType == 'presseur') ...[
                          SizedBox(height: isSmallScreen ? 14 : 18),
                          DropdownButtonFormField<String>(
                            value: _selectedZone,
                            decoration: InputDecoration(
                              labelText: 'Zone de couverture',
                              hintText: 'Sélectionnez votre zone',
                              prefixIcon: Icon(
                                Icons.location_on_outlined,
                                color: Colors.orange.shade600,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.orange.shade600,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            items: _zones.map((String zone) {
                              return DropdownMenuItem<String>(
                                value: zone,
                                child: Text(
                                  zone,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedZone = newValue;
                              });
                            },
                            validator: (value) {
                              if (_selectedUserType == 'presseur' && value == null) {
                                return 'Veuillez sélectionner une zone';
                              }
                              return null;
                            },
                          ),
                        ],

                        // Adresse (affichée uniquement si type "client")
                        if (_selectedUserType == 'client') ...[
                          SizedBox(height: isSmallScreen ? 14 : 18),
                          TextFormField(
                            controller: _addressController,
                            keyboardType: TextInputType.streetAddress,
                            decoration: InputDecoration(
                              labelText: 'Adresse',
                              hintText: 'Rue, quartier, ville',
                              prefixIcon: Icon(
                                Icons.home_outlined,
                                color: Colors.orange.shade600,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.orange.shade600,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            validator: (value) {
                              if (_selectedUserType == 'client') {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez entrer votre adresse';
                                }
                              }
                              return null;
                            },
                          ),
                        ],

                        SizedBox(height: isSmallScreen ? 14 : 18),

                        // Champ Mot de passe
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Mot de passe',
                            hintText: '••••••••',
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: Colors.orange.shade600,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.grey.shade600,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.orange.shade600,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer un mot de passe';
                            }
                            if (value.length < 6) {
                              return 'Au moins 6 caractères requis';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: isSmallScreen ? 14 : 18),

                        // Champ Confirmer mot de passe
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            labelText: 'Confirmer le mot de passe',
                            hintText: '••••••••',
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: Colors.orange.shade600,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.grey.shade600,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.orange.shade600,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez confirmer le mot de passe';
                            }
                            if (value != _passwordController.text) {
                              return 'Les mots de passe ne correspondent pas';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: isSmallScreen ? 20 : 30),

                        // Bouton d'inscription
                        SizedBox(
                          width: double.infinity,
                          height: isSmallScreen ? 50 : 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSignup,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade600,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Text(
                                    'S\'inscrire',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 16 : 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 20 : 30),

                  SizedBox(height: isSmallScreen ? 12 : 16),

                  // Lien connexion
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Vous avez déjà un compte ? ',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: isSmallScreen ? 14 : 15,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Se connecter',
                            style: TextStyle(
                              color: Colors.orange.shade600,
                              fontWeight: FontWeight.bold,
                              fontSize: isSmallScreen ? 14 : 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 10 : 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}