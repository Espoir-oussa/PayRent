// Fichier : lib/presentation/proprietaires/pages/auth_screens/owner_register_screen.dart

import 'package:flutter/material.dart';
import '../../../../config/colors.dart';
import 'owner_login_screen.dart';

class OwnerRegisterScreen extends StatefulWidget {
  const OwnerRegisterScreen({super.key});

  @override
  State<OwnerRegisterScreen> createState() => _OwnerRegisterScreenState();
}

class _OwnerRegisterScreenState extends State<OwnerRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate() && _acceptTerms) {
      setState(() => _isLoading = true);

      // Simuler un appel API
      await Future.delayed(const Duration(seconds: 2));

      setState(() => _isLoading = false);

      // TODO: Implémenter la logique d'inscription réelle
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inscription réussie ! Redirection...'),
          backgroundColor: AppColors.accentRed,
        ),
      );

      // Redirection vers login après succès
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const OwnerLoginScreen(),
        ),
      );
    } else if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez accepter les conditions'),
          backgroundColor: AppColors.accentRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 40.0, vertical: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo et retour
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primaryDark.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.primaryDark,
                          size: 20,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Logo PayRent (optionnel)
                    Image.asset(
                      'assets/images/payrent_blanc.png',
                      height: 100,
                      color: AppColors.primaryDark,
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Titre principal - Style cohérent avec login
                Text(
                  'Créer un compte',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: AppColors.primaryDark,
                        fontSize: 32,
                        letterSpacing: 1.5,
                      ),
                ),

                const SizedBox(height: 8),

                // Sous-titre
                Text(
                  'Rejoignez PayRent pour gérer vos biens facilement',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primaryDark.withOpacity(0.6),
                      ),
                ),

                const SizedBox(height: 50),

                // Formulaire
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Nom et Prénom
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _firstNameController,
                              decoration: InputDecoration(
                                labelText: 'Prénom',
                                prefixIcon: const Icon(Icons.person_outline),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez entrer votre prénom';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _lastNameController,
                              decoration: const InputDecoration(
                                labelText: 'Nom',
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez entrer votre nom';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Adresse Email',
                          prefixIcon: Icon(Icons.email_outlined),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre email';
                          }
                          if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                              .hasMatch(value)) {
                            return 'Email invalide';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Téléphone
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Numéro de téléphone',
                          prefixIcon: Icon(Icons.phone_outlined),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre téléphone';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Mot de passe
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.primaryDark.withOpacity(0.5),
                            ),
                            onPressed: () {
                              setState(
                                  () => _obscurePassword = !_obscurePassword);
                            },
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un mot de passe';
                          }
                          if (value.length < 6) {
                            return 'Minimum 6 caractères';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Confirmation mot de passe
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Confirmer le mot de passe',
                          prefixIcon: const Icon(Icons.lock_reset_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.primaryDark.withOpacity(0.5),
                            ),
                            onPressed: () {
                              setState(() => _obscureConfirmPassword =
                                  !_obscureConfirmPassword);
                            },
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez confirmer votre mot de passe';
                          }
                          if (value != _passwordController.text) {
                            return 'Les mots de passe ne correspondent pas';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Indicateur visuel de force du mot de passe (optionnel)
                      if (_passwordController.text.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LinearProgressIndicator(
                              value: _passwordController.text.isEmpty
                                  ? 0
                                  : _passwordController.text.length / 12,
                              backgroundColor:
                                  AppColors.primaryDark.withOpacity(0.1),
                              color: _passwordController.text.length >= 8
                                  ? Colors.green
                                  : _passwordController.text.length >= 6
                                      ? Colors.orange
                                      : AppColors.accentRed,
                              minHeight: 3,
                              borderRadius: BorderRadius.circular(1.5),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _passwordController.text.isEmpty
                                  ? ''
                                  : _passwordController.text.length >= 8
                                      ? 'Mot de passe fort'
                                      : _passwordController.text.length >= 6
                                          ? 'Mot de passe moyen'
                                          : 'Mot de passe faible',
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'MuseoModerno',
                                color: _passwordController.text.isEmpty
                                    ? Colors.transparent
                                    : _passwordController.text.length >= 8
                                        ? Colors.green
                                        : _passwordController.text.length >= 6
                                            ? Colors.orange
                                            : AppColors.accentRed,
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 30),

                      // Checkbox Conditions
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _acceptTerms,
                            onChanged: (value) {
                              setState(() => _acceptTerms = value ?? false);
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            activeColor: AppColors.accentRed,
                            checkColor: AppColors.textLight,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: "J'accepte les ",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'MuseoModerno',
                                      ),
                                    ),
                                    WidgetSpan(
                                      child: GestureDetector(
                                        onTap: () {
                                          // TODO: Ouvrir les conditions
                                        },
                                        child: Text(
                                          'conditions d\'utilisation',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'MuseoModerno',
                                            color: AppColors.accentRed,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const TextSpan(
                                      text: ' et la ',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'MuseoModerno',
                                      ),
                                    ),
                                    WidgetSpan(
                                      child: GestureDetector(
                                        onTap: () {
                                          // TODO: Ouvrir la politique
                                        },
                                        child: Text(
                                          'politique de confidentialité',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'MuseoModerno',
                                            color: AppColors.accentRed,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // Bouton d'inscription
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegister,
                        style: Theme.of(context).elevatedButtonTheme.style,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: AppColors.textLight,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                "S'INSCRIRE",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: AppColors.textLight,
                                    ),
                              ),
                      ),

                      const SizedBox(height: 30),

                      // Lien vers login
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const OwnerLoginScreen(),
                            ),
                          );
                        },
                        child: Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Déjà un compte ? ',
                                style: TextStyle(
                                  fontFamily: 'MuseoModerno',
                                ),
                              ),
                              TextSpan(
                                text: 'Se connecter',
                                style: TextStyle(
                                  fontFamily: 'MuseoModerno',
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
