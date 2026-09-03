USE [IBS_Extranet_Mobile];
GO

-- Insertion des permissions si elles n'existent pas déjà (Standard CRUD)

-- UTILISATEURS
IF NOT EXISTS (SELECT 1 FROM dbo.SitePermission WHERE Code = 'utilisateurs:lire') INSERT INTO dbo.SitePermission (Code, Description) VALUES ('utilisateurs:lire', 'Afficher la liste des utilisateurs');
IF NOT EXISTS (SELECT 1 FROM dbo.SitePermission WHERE Code = 'utilisateurs:creer') INSERT INTO dbo.SitePermission (Code, Description) VALUES ('utilisateurs:creer', 'Ajouter des utilisateurs');
IF NOT EXISTS (SELECT 1 FROM dbo.SitePermission WHERE Code = 'utilisateurs:modifier') INSERT INTO dbo.SitePermission (Code, Description) VALUES ('utilisateurs:modifier', 'Modifier des utilisateurs');
IF NOT EXISTS (SELECT 1 FROM dbo.SitePermission WHERE Code = 'utilisateurs:supprimer') INSERT INTO dbo.SitePermission (Code, Description) VALUES ('utilisateurs:supprimer', 'Supprimer des utilisateurs');
IF NOT EXISTS (SELECT 1 FROM dbo.SitePermission WHERE Code = 'utilisateurs:synchroniser') INSERT INTO dbo.SitePermission (Code, Description) VALUES ('utilisateurs:synchroniser', 'Synchroniser les comptes');
IF NOT EXISTS (SELECT 1 FROM dbo.SitePermission WHERE Code = 'utilisateurs:gerer_roles') INSERT INTO dbo.SitePermission (Code, Description) VALUES ('utilisateurs:gerer_roles', 'Gérer l''attribution des rôles');
IF NOT EXISTS (SELECT 1 FROM dbo.SitePermission WHERE Code = 'utilisateurs:gerer_sites') INSERT INTO dbo.SitePermission (Code, Description) VALUES ('utilisateurs:gerer_sites', 'Gérer l''accès aux sites');
IF NOT EXISTS (SELECT 1 FROM dbo.SitePermission WHERE Code = 'utilisateurs:gerer_permissions_sites') INSERT INTO dbo.SitePermission (Code, Description) VALUES ('utilisateurs:gerer_permissions_sites', 'Gérer les permissions par site');

-- SITES
IF NOT EXISTS (SELECT 1 FROM dbo.SitePermission WHERE Code = 'sites:lire') INSERT INTO dbo.SitePermission (Code, Description) VALUES ('sites:lire', 'Afficher la liste des sites');
IF NOT EXISTS (SELECT 1 FROM dbo.SitePermission WHERE Code = 'sites:creer') INSERT INTO dbo.SitePermission (Code, Description) VALUES ('sites:creer', 'Ajouter des sites');
IF NOT EXISTS (SELECT 1 FROM dbo.SitePermission WHERE Code = 'sites:modifier') INSERT INTO dbo.SitePermission (Code, Description) VALUES ('sites:modifier', 'Modifier des sites');
IF NOT EXISTS (SELECT 1 FROM dbo.SitePermission WHERE Code = 'sites:supprimer') INSERT INTO dbo.SitePermission (Code, Description) VALUES ('sites:supprimer', 'Supprimer des sites');

-- SIMULATIONS
IF NOT EXISTS (SELECT 1 FROM dbo.SitePermission WHERE Code = 'simulations:lire') INSERT INTO dbo.SitePermission (Code, Description) VALUES ('simulations:lire', 'Afficher la liste des simulations');
IF NOT EXISTS (SELECT 1 FROM dbo.SitePermission WHERE Code = 'simulations:creer') INSERT INTO dbo.SitePermission (Code, Description) VALUES ('simulations:creer', 'Ajouter des simulations');
IF NOT EXISTS (SELECT 1 FROM dbo.SitePermission WHERE Code = 'simulations:modifier') INSERT INTO dbo.SitePermission (Code, Description) VALUES ('simulations:modifier', 'Modifier des simulations');
IF NOT EXISTS (SELECT 1 FROM dbo.SitePermission WHERE Code = 'simulations:supprimer') INSERT INTO dbo.SitePermission (Code, Description) VALUES ('simulations:supprimer', 'Supprimer des simulations');

-- CLIENTS
IF NOT EXISTS (SELECT 1 FROM dbo.SitePermission WHERE Code = 'clients:lire') INSERT INTO dbo.SitePermission (Code, Description) VALUES ('clients:lire', 'Afficher la liste des clients');
IF NOT EXISTS (SELECT 1 FROM dbo.SitePermission WHERE Code = 'clients:creer') INSERT INTO dbo.SitePermission (Code, Description) VALUES ('clients:creer', 'Ajouter des clients');
IF NOT EXISTS (SELECT 1 FROM dbo.SitePermission WHERE Code = 'clients:modifier') INSERT INTO dbo.SitePermission (Code, Description) VALUES ('clients:modifier', 'Modifier des clients');
IF NOT EXISTS (SELECT 1 FROM dbo.SitePermission WHERE Code = 'clients:supprimer') INSERT INTO dbo.SitePermission (Code, Description) VALUES ('clients:supprimer', 'Supprimer des clients');
IF NOT EXISTS (SELECT 1 FROM dbo.SitePermission WHERE Code = 'clients:creer_utilisateur') INSERT INTO dbo.SitePermission (Code, Description) VALUES ('clients:creer_utilisateur', 'Créer un compte pour un client');
IF NOT EXISTS (SELECT 1 FROM dbo.SitePermission WHERE Code = 'clients:lier') INSERT INTO dbo.SitePermission (Code, Description) VALUES ('clients:lier', 'Associer un client à un profil');
IF NOT EXISTS (SELECT 1 FROM dbo.SitePermission WHERE Code = 'clients:delier') INSERT INTO dbo.SitePermission (Code, Description) VALUES ('clients:delier', 'Délier un client d''un utilisateur');
IF NOT EXISTS (SELECT 1 FROM dbo.SitePermission WHERE Code = 'clients:modifier_parent') INSERT INTO dbo.SitePermission (Code, Description) VALUES ('clients:modifier_parent', 'Modifier le parent d''un client');
IF NOT EXISTS (SELECT 1 FROM dbo.SitePermission WHERE Code = 'clients:gerer_emails') INSERT INTO dbo.SitePermission (Code, Description) VALUES ('clients:gerer_emails', 'Gérer les adresses emails');
IF NOT EXISTS (SELECT 1 FROM dbo.SitePermission WHERE Code = 'clients:gerer_options') INSERT INTO dbo.SitePermission (Code, Description) VALUES ('clients:gerer_options', 'Gérer les options du client');

-- ADHERENTS
IF NOT EXISTS (SELECT 1 FROM dbo.SitePermission WHERE Code = 'adherents:lire') INSERT INTO dbo.SitePermission (Code, Description) VALUES ('adherents:lire', 'Afficher la liste des adhérents');
IF NOT EXISTS (SELECT 1 FROM dbo.SitePermission WHERE Code = 'adherents:creer') INSERT INTO dbo.SitePermission (Code, Description) VALUES ('adherents:creer', 'Ajouter des adhérents');
IF NOT EXISTS (SELECT 1 FROM dbo.SitePermission WHERE Code = 'adherents:modifier') INSERT INTO dbo.SitePermission (Code, Description) VALUES ('adherents:modifier', 'Modifier des adhérents');
IF NOT EXISTS (SELECT 1 FROM dbo.SitePermission WHERE Code = 'adherents:supprimer') INSERT INTO dbo.SitePermission (Code, Description) VALUES ('adherents:supprimer', 'Supprimer des adhérents');
IF NOT EXISTS (SELECT 1 FROM dbo.SitePermission WHERE Code = 'adherents:creer_utilisateur') INSERT INTO dbo.SitePermission (Code, Description) VALUES ('adherents:creer_utilisateur', 'Créer un compte pour un adhérent');
IF NOT EXISTS (SELECT 1 FROM dbo.SitePermission WHERE Code = 'adherents:lier') INSERT INTO dbo.SitePermission (Code, Description) VALUES ('adherents:lier', 'Associer un adhérent à un profil');
IF NOT EXISTS (SELECT 1 FROM dbo.SitePermission WHERE Code = 'adherents:delier') INSERT INTO dbo.SitePermission (Code, Description) VALUES ('adherents:delier', 'Délier un adhérent');

-- RECLAMATIONS
IF NOT EXISTS (SELECT 1 FROM dbo.SitePermission WHERE Code = 'reclamations:lire') INSERT INTO dbo.SitePermission (Code, Description) VALUES ('reclamations:lire', 'Afficher la liste des réclamations');
IF NOT EXISTS (SELECT 1 FROM dbo.SitePermission WHERE Code = 'reclamations:creer') INSERT INTO dbo.SitePermission (Code, Description) VALUES ('reclamations:creer', 'Créer des réclamations');
IF NOT EXISTS (SELECT 1 FROM dbo.SitePermission WHERE Code = 'reclamations:modifier') INSERT INTO dbo.SitePermission (Code, Description) VALUES ('reclamations:modifier', 'Modifier les réclamations');
IF NOT EXISTS (SELECT 1 FROM dbo.SitePermission WHERE Code = 'reclamations:supprimer') INSERT INTO dbo.SitePermission (Code, Description) VALUES ('reclamations:supprimer', 'Supprimer des réclamations');

-- DOCUMENTS
IF NOT EXISTS (SELECT 1 FROM dbo.SitePermission WHERE Code = 'documents:lire') INSERT INTO dbo.SitePermission (Code, Description) VALUES ('documents:lire', 'Afficher la liste des documents');
IF NOT EXISTS (SELECT 1 FROM dbo.SitePermission WHERE Code = 'documents:creer') INSERT INTO dbo.SitePermission (Code, Description) VALUES ('documents:creer', 'Ajouter des documents');
IF NOT EXISTS (SELECT 1 FROM dbo.SitePermission WHERE Code = 'documents:modifier') INSERT INTO dbo.SitePermission (Code, Description) VALUES ('documents:modifier', 'Modifier des documents');
IF NOT EXISTS (SELECT 1 FROM dbo.SitePermission WHERE Code = 'documents:supprimer') INSERT INTO dbo.SitePermission (Code, Description) VALUES ('documents:supprimer', 'Supprimer des documents');

-- ROLES
IF NOT EXISTS (SELECT 1 FROM dbo.SitePermission WHERE Code = 'roles:lire') INSERT INTO dbo.SitePermission (Code, Description) VALUES ('roles:lire', 'Afficher la liste des rôles');
IF NOT EXISTS (SELECT 1 FROM dbo.SitePermission WHERE Code = 'roles:creer') INSERT INTO dbo.SitePermission (Code, Description) VALUES ('roles:creer', 'Créer des rôles');
IF NOT EXISTS (SELECT 1 FROM dbo.SitePermission WHERE Code = 'roles:modifier') INSERT INTO dbo.SitePermission (Code, Description) VALUES ('roles:modifier', 'Modifier des rôles');
IF NOT EXISTS (SELECT 1 FROM dbo.SitePermission WHERE Code = 'roles:supprimer') INSERT INTO dbo.SitePermission (Code, Description) VALUES ('roles:supprimer', 'Supprimer des rôles');
IF NOT EXISTS (SELECT 1 FROM dbo.SitePermission WHERE Code = 'roles:gerer_permissions') INSERT INTO dbo.SitePermission (Code, Description) VALUES ('roles:gerer_permissions', 'Paramétrer les autorisations');

GO
