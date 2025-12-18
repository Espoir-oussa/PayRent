const sdk = require('node-appwrite');

/**
 * Appwrite Function: create-contract
 * Expects JSON on stdin with { token, locataireId }
 * Requires environment variables:
 * - APPWRITE_ENDPOINT
 * - APPWRITE_PROJECT
 * - APPWRITE_API_KEY
 * - DATABASE_ID
 * - USERS_COLLECTION
 * - INVITATIONS_COLLECTION
 * - BIENS_COLLECTION
 * - CONTRATS_COLLECTION
 */

const fs = require('fs');

(async () => {
  try {
    const input = fs.readFileSync(0, 'utf8');
    const data = input ? JSON.parse(input) : {};

    const token = data.token;
    const locataireId = data.locataireId;

    if (!token || !locataireId) {
      console.error('Missing token or locataireId');
      console.log(JSON.stringify({ success: false, error: 'Missing token or locataireId' }));
      process.exit(1);
    }

    const client = new sdk.Client()
      .setEndpoint(process.env.APPWRITE_ENDPOINT)
      .setProject(process.env.APPWRITE_PROJECT)
      .setKey(process.env.APPWRITE_API_KEY);

    const databases = new sdk.Databases(client);

    const databaseId = process.env.DATABASE_ID;
    const usersCollection = process.env.USERS_COLLECTION;
    const invitationsCollection = process.env.INVITATIONS_COLLECTION;
    const biensCollection = process.env.BIENS_COLLECTION;
    const contratsCollection = process.env.CONTRATS_COLLECTION;

    // 1) Retrieve invitation by token
    const invitations = await databases.listDocuments(databaseId, invitationsCollection, [sdk.Query.equal('token', token)]);
    if (!invitations || !invitations.documents || invitations.documents.length === 0) {
      throw new Error('Invitation not found');
    }
    const invitation = invitations.documents[0];

    if (invitation.statut !== 'pending') {
      throw new Error('Invitation not pending');
    }

    if (invitation.dateExpiration) {
      const exp = new Date(invitation.dateExpiration);
      if (exp < new Date()) throw new Error('Invitation expired');
    }

    // 2) Verify locataire exists and email matches invitation
    const userDoc = await databases.getDocument(databaseId, usersCollection, locataireId);
    if (!userDoc) throw new Error('Locataire not found');

    if (userDoc.email !== invitation.emailLocataire) {
      throw new Error('User email does not match invitation');
    }

    // 3) Ensure locataire is not already contracted for the bien
    const contrats = await databases.listDocuments(databaseId, contratsCollection, [sdk.Query.equal('bienId', invitation.bienId), sdk.Query.equal('locataireId', locataireId)]);
    if (contrats.documents.length > 0) {
      throw new Error('Locataire already contracted for this bien');
    }

    // 4) Create contrat with strict permissions (server-side allowed)
    const contratData = {
      bienId: invitation.bienId,
      locataireId: locataireId,
      proprietaireId: invitation.proprietaireId,
      dateDebut: new Date().toISOString(),
      dateFin: null,
      loyerMensuel: invitation.loyerMensuel,
      charges: invitation.charges || 0,
      caution: 0,
      jourPaiement: 1,
      statut: 'actif',
      documentUrl: null,
      notes: invitation.message || null,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };

    const permissions = [
      `read("user:${locataireId}")`,
      `read("user:${invitation.proprietaireId}")`,
      `update("user:${invitation.proprietaireId}")`
    ];

    const createdContrat = await databases.createDocument(databaseId, contratsCollection, 'unique()', contratData, permissions);

    // 5) Update invitation (statut) and bien (locataireId)
    await databases.updateDocument(databaseId, invitationsCollection, invitation.$id, { statut: 'accepted', locataireId, updatedAt: new Date().toISOString() });

    await databases.updateDocument(databaseId, biensCollection, invitation.bienId, { locataireId, statut: 'occupe', updatedAt: new Date().toISOString() });

    console.log(JSON.stringify({ success: true, contrat: createdContrat }));
    process.exit(0);
  } catch (err) {
    console.error('Error in create-contract function', err);
    console.log(JSON.stringify({ success: false, error: err.message || String(err) }));
    process.exit(1);
  }
})();
