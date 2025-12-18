class Environment {
  // Configuration Appwrite
  static const String appwriteProjectId = '69393f23001c2e93607c';
  static const String appwriteProjectName = 'Payrent-Backend';
  static const String appwritePublicEndpoint = 'https://fra.cloud.appwrite.io/v1';
  
  // IDs des bases de données et collections Appwrite
  // ⚠️ À configurer après création dans la console Appwrite
  static const String databaseId = 'payrent_db'; // ID de votre base de données
  
  // Collections
  static const String usersCollectionId = 'users';
  static const String biensCollectionId = 'biens';
  static const String contratsCollectionId = 'contrats';
  static const String paiementsCollectionId = 'paiements';
  static const String plaintesCollectionId = 'plaintes';
  static const String facturesCollectionId = 'factures';
  static const String invitationsCollectionId = 'invitations';
  static const String notificationsCollectionId = 'notifications';

  // Function IDs
  // Remplacez par l'ID réel de la fonction Appwrite après déploiement
  static const String createContractFunctionId = '69438e9600100260ed7e';
  
  // Storage Buckets
  static const String imagesBucketId = 'images';
  static const String documentsBucketId = 'documents';
}