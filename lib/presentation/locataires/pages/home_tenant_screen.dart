// ===============================
// 🏠 Écran : Accueil Locataire
//
// Ce fichier définit l'interface utilisateur principale pour le locataire.
//
// Dossier : lib/presentation/locataires/pages/
// Rôle : Tableau de bord du locataire
// Utilisé par : Locataires
// ===============================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/colors.dart';
import '../../../core/di/providers.dart';
import '../../../data/models/contrat_location_model.dart';
import '../../../data/models/paiement_model.dart';
import './locations/tenant_locations_controller.dart';
import './payments/tenant_payments_controller.dart';
import 'complaint_screens/complaint_detail_screen.dart';

class HomeTenantScreen extends ConsumerStatefulWidget {
  const HomeTenantScreen({super.key});

  @override
  ConsumerState<HomeTenantScreen> createState() => _HomeTenantScreenState();
}

class _HomeTenantScreenState extends ConsumerState<HomeTenantScreen> {
  int _currentIndex = 0;
  String? _userName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final appwriteService = ref.read(appwriteServiceProvider);
      final user = await appwriteService.getCurrentUser();
      if (user != null && mounted) {
        setState(() {
          _userName = user.name;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Déconnecter'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final appwriteService = ref.read(appwriteServiceProvider);
        await appwriteService.logout();
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login_owner',
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PayRent'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppColors.primaryDark,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'Paiements',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_problem),
            label: 'Plaintes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildPaymentsTab();
      case 2:
        return _buildComplaintsTab();
      case 3:
        return _buildProfileTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return Consumer(
      builder: (context, ref, child) {
        final locationsState = ref.watch(tenantLocationsControllerProvider);

        // Charger les locations si nécessaire
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (locationsState.locations.isEmpty &&
              locationsState.status == LocationLoadingStatus.idle) {
            // Charger les locations (besoin d'obtenir l'ID du locataire)
            _loadLocations(ref);
          }
        });

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête de bienvenue
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryDark,
                      AppColors.primaryDark.withOpacity(0.8)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person,
                          size: 35, color: AppColors.primaryDark),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bienvenue,',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            _userName ?? 'Locataire',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Titre: Mes Locations
              Text(
                'Mes Locations',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),

              // Afficher les locations
              _buildLocationsSection(context, locationsState),

              const SizedBox(height: 24),

              // Actions rapides
              Text(
                'Actions rapides',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.payment,
                      label: 'Payer\nle loyer',
                      color: Colors.green,
                      onTap: () => setState(() => _currentIndex = 1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.report_problem,
                      label: 'Signaler\nun problème',
                      color: Colors.orange,
                      onTap: () => setState(() => _currentIndex = 2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.receipt_long,
                      label: 'Mes\nquittances',
                      color: Colors.blue,
                      onTap: () => setState(() => _currentIndex = 1),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _loadLocations(WidgetRef ref) async {
    try {
      final appwriteService = ref.read(appwriteServiceProvider);
      final user = await appwriteService.getCurrentUser();
      if (user != null && mounted) {
        final controller = ref.read(tenantLocationsControllerProvider.notifier);
        await controller.loadLocations(user.$id);
      }
    } catch (e) {
      print('Erreur lors du chargement des locations: $e');
    }
  }

  Widget _buildLocationsSection(
      BuildContext context, TenantLocationsState state) {
    if (state.status == LocationLoadingStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == LocationLoadingStatus.error) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text('Erreur: ${state.errorMessage}'),
          ],
        ),
      );
    }

    if (state.locations.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.home_outlined, color: Colors.grey, size: 48),
            const SizedBox(height: 16),
            const Text('Aucune location trouvée'),
          ],
        ),
      );
    }

    return Column(
      children: List.generate(
        state.locations.length,
        (index) => _buildLocationCard(context, state.locations[index]),
      ),
    );
  }

  Widget _buildLocationCard(
      BuildContext context, ContratLocationModel location) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // TODO: Naviguer vers DetailLocationScreen avec le bien
          // Pour cela, il faudrait charger le bien associé
          Navigator.of(context).pushNamed(
            '/detail-location',
            arguments: location,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.home, color: AppColors.primaryDark),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Location #${location.idBien}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Montant: ${location.montantTotalMensuel.toStringAsFixed(2)} €/mois',
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(location.statut)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getStatusLabel(location.statut ?? 'actif'),
                            style: TextStyle(
                              color: _getStatusColor(location.statut),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward, color: AppColors.primaryDark),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String? statut) {
    switch (statut?.toLowerCase()) {
      case 'actif':
        return Colors.green;
      case 'termine':
        return Colors.grey;
      case 'suspendu':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  String _getStatusLabel(String statut) {
    switch (statut.toLowerCase()) {
      case 'actif':
        return '✅ Actif';
      case 'termine':
        return '✓ Terminé';
      case 'suspendu':
        return '⚠️ Suspendu';
      default:
        return statut;
    }
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentsTab() {
    return Consumer(
      builder: (context, ref, child) {
        final paymentsState = ref.watch(tenantPaymentsControllerProvider);

        // Charger les paiements si nécessaire
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (paymentsState.payments.isEmpty &&
              paymentsState.status == PaymentLoadingStatus.idle) {
            _loadPayments(ref);
          }
        });

        if (paymentsState.status == PaymentLoadingStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (paymentsState.status == PaymentLoadingStatus.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text('Erreur: ${paymentsState.errorMessage}'),
              ],
            ),
          );
        }

        if (paymentsState.payments.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.payment, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Historique des paiements',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Aucun paiement trouvé',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Résumé des paiements en attente
              if (paymentsState.pendingPayments.isNotEmpty)
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.warning, color: Colors.orange),
                              const SizedBox(width: 8),
                              Text(
                                '${paymentsState.pendingPayments.length} paiement(s) en attente',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Total dû: ${paymentsState.pendingPayments.fold<double>(0.0, (sum, p) => sum + p.montantPaye).toStringAsFixed(2)} €',
                            style: const TextStyle(color: Colors.orange),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),

              Text(
                'Historique des paiements',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              // Liste des paiements
              Column(
                children: List.generate(
                  paymentsState.payments.length,
                  (index) =>
                      _buildPaymentCard(context, paymentsState.payments[index]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _loadPayments(WidgetRef ref) async {
    try {
      final appwriteService = ref.read(appwriteServiceProvider);
      final user = await appwriteService.getCurrentUser();
      if (user != null && mounted) {
        final controller = ref.read(tenantPaymentsControllerProvider.notifier);
        await controller.loadPayments(user.$id);
      }
    } catch (e) {
      print('Erreur lors du chargement des paiements: $e');
    }
  }

  Widget _buildPaymentCard(BuildContext context, PaiementModel payment) {
    final statusColor = _getPaymentStatusColor(payment.statut);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.check_circle, color: statusColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Paiement ${payment.montantPaye.toStringAsFixed(2)} €',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Le ${payment.datePaiement.day}/${payment.datePaiement.month}/${payment.datePaiement.year}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                payment.statut,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'payé':
      case 'paye':
        return Colors.green;
      case 'en attente':
      case 'en_attente':
        return Colors.orange;
      case 'retard':
      case 'en_retard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildComplaintsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mes plaintes',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildComplaintCard(
            id: 1,
            title: 'Chauffage defaillant',
            status: 'Ouverte',
            date: '15/11/2024',
          ),
          const SizedBox(height: 12),
          _buildComplaintCard(
            id: 2,
            title: 'Fuite d\'eau resolue',
            status: 'Resolue',
            date: '10/11/2024',
          ),
          const SizedBox(height: 12),
          _buildComplaintCard(
            id: 3,
            title: 'Lumiere cassee',
            status: 'Fermee',
            date: '28/10/2024',
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintCard({
    required int id,
    required String title,
    required String status,
    required String date,
  }) {
    final statusColor = _getStatusColor(status);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ComplaintDetailScreen(
              complaintId: id,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.report_problem, color: statusColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 11,
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Mon profil',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Gérez vos informations personnelles',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
