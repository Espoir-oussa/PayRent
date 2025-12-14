
// ===============================
// 💰 Écran : Historique des Paiements (Propriétaire)
//
// Ce fichier définit l'interface utilisateur pour la consultation de l'historique des paiements par le propriétaire.
//
// Dossier : lib/presentation/proprietaires/pages/
// Rôle : UI pour affichage des paiements reçus
// Utilisé par : Propriétaires
// ===============================


import 'package:flutter/material.dart';

class PaymentHistoryScreen extends StatelessWidget {
	const PaymentHistoryScreen({super.key});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: const Center(child: Text('Écran Historique des Paiements')),
		);
	}
}
