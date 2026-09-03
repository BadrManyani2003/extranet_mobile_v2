USE [IBS_Extranet_Mobile];
GO

DELETE FROM dbo.SiteRolePermission;
DELETE FROM dbo.UserSiteRole;
DELETE FROM dbo.SiteRole;
DELETE FROM dbo.SitePermission;
DELETE FROM dbo.ReclamationsDet;
DELETE FROM dbo.ReclamationsIdt;
DELETE FROM dbo.StdDocument;
DELETE FROM dbo.PolDocument;
DELETE FROM dbo.Garanties;
DELETE FROM dbo.sinComplement;
DELETE FROM dbo.Sinistres;
DELETE FROM dbo.Quittances;
DELETE FROM dbo.PersACharge;
DELETE FROM dbo.Adherents;
DELETE FROM dbo.Risques;
DELETE FROM dbo.Polices;
DELETE FROM dbo.UserSimulationClients;
DELETE FROM dbo.UsersXClients;
DELETE FROM dbo.Clients;
DELETE FROM dbo.userConnection;
DELETE FROM dbo.Postes_Autorises;
DELETE FROM dbo.Nature;
UPDATE dbo.sysUser SET CreatedBy = NULL;
DELETE FROM dbo.sysUser;
DELETE FROM dbo.UserSites;
DELETE FROM dbo.Sites;
DELETE FROM dbo.Compagnies;
GO

-- Réinitialisation des colonnes d'identité
IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.Compagnies') AND last_value IS NOT NULL)
    DBCC CHECKIDENT ('dbo.Compagnies', RESEED, 0);
IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.Risques') AND last_value IS NOT NULL)
    DBCC CHECKIDENT ('dbo.Risques', RESEED, 0);
IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.Garanties') AND last_value IS NOT NULL)
    DBCC CHECKIDENT ('dbo.Garanties', RESEED, 0);
IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.ReclamationsIdt') AND last_value IS NOT NULL)
    DBCC CHECKIDENT ('dbo.ReclamationsIdt', RESEED, 0);
IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.Postes_Autorises') AND last_value IS NOT NULL)
    DBCC CHECKIDENT ('dbo.Postes_Autorises', RESEED, 0);
GO

-- 1. COMPAGNIES D'ASSURANCE
INSERT INTO dbo.Compagnies (RaisonSociale, CreatedAt) VALUES
('Wafa Assurance', '20260101'),
('Sanlam Maroc', '20260101'),
('RMA Watanya', '20260101'),
('AtlantaSanad', '20260101'),
('AXA Assurance Maroc', '20260101');

DECLARE @Comp1Id INT = (SELECT Id FROM dbo.Compagnies WHERE RaisonSociale = 'Wafa Assurance');
DECLARE @Comp2Id INT = (SELECT Id FROM dbo.Compagnies WHERE RaisonSociale = 'Sanlam Maroc');
DECLARE @Comp3Id INT = (SELECT Id FROM dbo.Compagnies WHERE RaisonSociale = 'RMA Watanya');
DECLARE @Comp4Id INT = (SELECT Id FROM dbo.Compagnies WHERE RaisonSociale = 'AtlantaSanad');
DECLARE @Comp5Id INT = (SELECT Id FROM dbo.Compagnies WHERE RaisonSociale = 'AXA Assurance Maroc');

SET IDENTITY_INSERT dbo.Sites ON;
INSERT INTO dbo.Sites (Id, Code, RaisonSociale, Ville, Actif) VALUES
(1, 'CASA', 'MyASK Casablanca', 'Casablanca', 'O'),
(2, 'RBA', 'MyASK Rabat', 'Rabat', 'O');
SET IDENTITY_INSERT dbo.Sites OFF;

-- 3. UTILISATEURS (id_auth conserves)
SET IDENTITY_INSERT dbo.sysUser ON;
INSERT INTO dbo.sysUser (Id, Id_Auth, Nom, Telephone, Email, Nature, Extranet, Mobile, CreatedAt, token, CreatedBy) VALUES
(1, 'cc7011b8-e421-48c8-a6a1-f832e17da059', 'Badr MANYANI (Admin)', '0661223344', 'admin@ibs.ma', 'A', 'O', 'N', '20260101', 'token_admin_001', NULL),
(2, '', 'Meryem Ouazzani (Com Casa)', '0661556677', 'com1@ibs.ma', 'C', 'O', 'N', '20260101', 'token_com_001', 1),
(8, '', 'Youssef Filali (Com Rabat)', '0661998877', 'com2@ibs.ma', 'C', 'O', 'N', '20260101', 'token_com_002', 1),
(3, '', 'Sanae (Energies Sud)', '0661889900', 'sanae@enersud.ma', 'C', 'O', 'N', '20260101', 'token_societe1', 2),
(4, '', 'Hamza (Digital Sol)', '0661112233', 'hamza@digitalsol.ma', 'C', 'O', 'N', '20260101', 'token_societe2', 1),
(5, '', 'Amine QAMCH (Adh DSM)', '0661445566', 'amine.qamch@test.ma', 'C', 'O', 'O', '20260101', 'token_adherent1', 2),
(6, '', 'Nadia Slaoui (Adh ASL)', '0661778899', 'adherent2@test.ma', 'C', 'O', 'O', '20260101', 'token_adherent2', 1),
(7, '', 'Imad (Auto Particulier)', '0661999999', 'imad@test.ma', 'E', 'O', 'N', '20260101', 'token_Client3_001', 1);
SET IDENTITY_INSERT dbo.sysUser OFF;

DECLARE @AdminId INT = 1;
DECLARE @ComCasaId INT = 2;
DECLARE @ComRabatId INT = 8;
DECLARE @UserClient1 INT = 3;
DECLARE @UserClient2 INT = 4;
DECLARE @UserAdherent1 INT = 5;
DECLARE @UserAdherent2 INT = 6;
DECLARE @UserClient3 INT = 7;

-- Roles
INSERT INTO dbo.Nature (FK_User_Id, Nature) VALUES 
(@AdminId, 'admin_cabinet'),
(@ComCasaId, 'commercial_cabinet'),
(@ComRabatId, 'commercial_cabinet'),
(@UserClient1, 'CLIENT'),
(@UserClient2, 'CLIENT');

-- Postes autorises
INSERT INTO dbo.Postes_Autorises (FK_User_Id, Libelle, Identifiant, Actif, CreatedAt) VALUES
(@AdminId, 'Siège Social Casablanca', 'IDENT_CASA_001', 'O', '20260101'),
(@AdminId, 'Succursale Rabat', 'IDENT_RBA_001', 'O', '20260101'),
(@ComCasaId, 'Agence Maarif Casablanca', 'IDENT_CASA_002', 'O', '20260101'),
(@ComRabatId, 'Agence Agdal Rabat', 'IDENT_RBA_002', 'O', '20260101');

-- Connexions utilisateurs
INSERT INTO dbo.userConnection (FK_User_Id, FK_Poste_Id, DateConnection, DateSortie) VALUES
(@AdminId, 1, '20260102 08:00:00', '20260102 18:00:00'),
(@ComCasaId, 3, '20260102 08:30:00', '20260102 17:30:00'),
(@AdminId, 2, '20260103 08:15:00', NULL);

-- 4. USER SITES (Multi-site)
INSERT INTO dbo.UserSites (fk_user_id, fk_site_id) VALUES
(@AdminId, 1), (@AdminId, 2), -- Admin access to both
(@ComCasaId, 1), -- Com 1 Casa only
(@ComRabatId, 2), -- Com 2 Rabat only
(@UserClient1, 1), -- Energies Sud (Casa)
(@UserClient2, 1), -- Digital Sol (Casa)
(@UserAdherent1, 1), -- Adh Casa
(@UserAdherent2, 1), -- Adh Casa
(@UserClient3, 2); -- Imad Auto (Rabat)

INSERT INTO dbo.Clients (fk_site_id, Id, RaisonSociale, Particulier, Email, Adresse, Telephone, recClt, recAdh, CreatedAt) VALUES
-- Site 1 (CASA)
(1, 1001, 'Energies Renouvelables du Sud S.A.', 'N', 'achats@enersud.ma', 'Lotissement La Colline, Sidi Maarouf, Casa', '0522334455', 'O', 'O', '20260101'),
(1, 1002, 'Digital Solutions Maroc S.A.', 'N', 'direction.achats@digitalsol.ma', 'CasaNearshore Park, Casa', '0522719000', 'O', 'O', '20260101'),
(1, 1003, 'Aero Services Logistiques', 'N', 'assurances@aeroserv.ma', 'Aéroport Mohammed V, Nouaceur', '0522434343', 'O', 'N', '20260101'),
(1, 2001, 'Omar Tazi', 'O', 'omar.tazi@email.ma', 'Quartier Racine, Maarif, Casablanca', '0661223345', 'O', 'O', '20260101'),
(1, 2002, 'Fatima El Fassi', 'O', 'fatima.elfassi@email.ma', 'Avenue Hassan II, Casablanca', '0667889900', 'O', 'O', '20260101'),

-- Site 2 (RABAT)
(2, 3001, 'Banque du Commerce Moderne', 'N', 'assurances@banquecom.ma', 'Avenue Mohammed V, Rabat', '0537494000', 'O', 'O', '20260101'),
(2, 3002, 'Grande Distribution Alimentation', 'N', 'direction@gda.ma', 'Hay Riad, Rabat', '0537033445', 'N', 'O', '20260101'),
(2, 4001, 'Rachid Belkadi', 'O', 'rachid.belkadi@email.ma', 'Hay El Wifaq, Témara', '0665112233', 'O', 'O', '20260101'),
(2, 4002, 'Souad Alaoui', 'O', 'souad.alaoui@email.ma', 'Agdal, Rabat', '0662445566', 'O', 'O', '20260101'),
(2, 4003, 'Imad Auto', 'O', 'imad@test.ma', 'Salé, Centre ville', '0661999999', 'O', 'O', '20260101');

DECLARE @ClientId1 INT = 1001; -- Energies Renouvelables du Sud (CASA)
DECLARE @ClientId2 INT = 1002; -- Digital Solutions Maroc (CASA)
DECLARE @ClientId3 INT = 1003; -- Aero Services Logistiques (CASA)
DECLARE @ClientId4 INT = 3001; -- Banque du Commerce Moderne (RABAT)
DECLARE @ClientId5 INT = 3002; -- Grande Distribution Alimentation (RABAT)

-- Liaison Users <-> Clients
INSERT INTO dbo.UsersXClients (FK_User_Id, FK_Client_Id, Actif, CreatedAt) VALUES
(@UserClient1, 1001, 'O', '20260101'),  -- Sanae -> Energies Sud (Casa)
(@UserClient2, 1002, 'O', '20260101'),  -- Hamza -> Digital Sol (Casa)
(@UserClient3, 4003, 'O', '20260101'),  -- Imad -> Imad Auto (Rabat)
(@UserAdherent1, 2001, 'O', '20260101'), -- Amine -> Omar Tazi
(@UserAdherent2, 2002, 'O', '20260101'); -- Nadia -> Fatima

-- 6. POLICES D'ASSURANCE
INSERT INTO dbo.Polices (fk_site_id, Id, Fk_Client_Id, FK_Compagnie_Id, Branche, Police, DateEcheance, Statut, Module, DateEffet, CreatedAt) VALUES
-- === SITE 1: CASA ===
(1, 101, @ClientId2, @Comp1Id, 'Automobile', 'POL-AUTO-2026-DSM-01', '20261231', 'E', 'FLOTTE', '20260101', '20260101'),
(1, 102, @ClientId1, @Comp2Id, 'Automobile', 'POL-AUTO-2026-ERS-01', '20261231', 'E', 'FLOTTE', '20260101', '20260101'),
(1, 201, @ClientId2, @Comp1Id, 'Santé', 'POL-SANTE-2026-DSM-01', '20261231', 'E', 'GROUPE', '20260101', '20260101'),
(1, 202, @ClientId1, @Comp2Id, 'Santé', 'POL-SANTE-2026-ERS-01', '20261231', 'E', 'GROUPE', '20260101', '20260101'),
(1, 301, @ClientId2, @Comp1Id, 'AT', 'POL-AT-2026-DSM-01', '20261231', 'E', 'GROUPE', '20260101', '20260101'),
(1, 401, @ClientId1, @Comp2Id, 'IARD', 'POL-IARD-2026-ERS-01', '20261231', 'E', 'MR_INDUSTRIELLE', '20260101', '20260101'),
(1, 402, @ClientId2, @Comp1Id, 'IARD', 'POL-IARD-2026-DSM-01', '20261231', 'E', 'MR_INDUSTRIELLE', '20260101', '20260101'),
(1, 108, 2001, @Comp4Id, 'Automobile', 'POL-AUTO-2026-OMAR-01', '20260630', 'E', 'INDIV', '20260101', '20260101'),
(1, 205, 2001, @Comp4Id, 'Santé', 'POL-SANTE-2026-OMAR-01', '20261231', 'E', 'INDIV', '20260101', '20260101'),

-- === SITE 2: RABAT ===
(2, 106, @ClientId5, @Comp4Id, 'Automobile', 'POL-AUTO-2026-GDA-01', '20261231', 'E', 'FLOTTE', '20260101', '20260101'),
(2, 107, @ClientId4, @Comp1Id, 'Automobile', 'POL-AUTO-2026-BCM-01', '20261231', 'E', 'FLOTTE', '20260101', '20260101'),
(2, 204, @ClientId4, @Comp1Id, 'Santé', 'POL-SANTE-2026-BCM-01', '20261231', 'E', 'GROUPE', '20260101', '20260101'),
(2, 403, @ClientId5, @Comp4Id, 'IARD', 'POL-IARD-2026-GDA-01', '20261231', 'E', 'MR_INDUSTRIELLE', '20260101', '20260101'),
(2, 109, 4001, @Comp4Id, 'Automobile', 'POL-AUTO-2026-RACHID-01', '20261231', 'E', 'INDIV', '20260101', '20260101'),
(2, 110, 4002, @Comp5Id, 'Automobile', 'POL-AUTO-2026-SOUAD-01', '20261231', 'E', 'INDIV', '20260101', '20260101'),
(2, 111, 4003, @Comp5Id, 'Automobile', 'POL-AUTO-2026-IMAD-01', '20260930', 'E', 'INDIV', '20260101', '20260101');

-- Variables Polices
DECLARE @PolAutoDSM INT = 101, @PolAutoERS INT = 102;
DECLARE @PolSanteDSM INT = 201, @PolSanteERS INT = 202;
DECLARE @PolATDSM INT = 301;
DECLARE @PolIARD_ERS INT = 401, @PolIARD_DSM INT = 402;
DECLARE @PolAutoOmar INT = 108, @PolSanteOmar INT = 205;

DECLARE @PolAutoGDA INT = 106, @PolAutoBCM INT = 107;
DECLARE @PolSanteBCM INT = 204, @PolIARD_GDA INT = 403;
DECLARE @PolAutoRachid INT = 109, @PolAutoSouad INT = 110, @PolAutoImad INT = 111;

-- 7. ADHERENTS (Maladie)
INSERT INTO dbo.Adherents (fk_site_id, Id, FK_Police_Id, FK_User_Id, NomComplet, Email, NumAdhesion, Matricule, DateNaissance, DateAdhesion, Actif, Telephone, CreatedAt) VALUES
-- SITE 1 (CASA) - DSM
(1, 5001, @PolSanteDSM, NULL, 'Jawad El Hariri', 'jawad.hariri@digitalsol.ma', 10001, 2020001, '19750412', '20260101', 'O', '0661234567', '20260101'),
(1, 5005, @PolSanteDSM, @UserAdherent1, 'Amine QAMCH', 'amine.qamch@test.ma', 10005, 2020005, '19920707', '20260101', 'O', '0661445566', '20260101'),
-- SITE 1 (CASA) - ERS
(1, 5007, @PolSanteERS, NULL, 'Abdelghani Benali', 'abdelghani.benali@enersud.ma', 10011, 2020011, '19801215', '20260101', 'O', '0661234571', '20260101'),
-- SITE 1 (CASA) - Particulier
(1, 5015, @PolSanteOmar, NULL, 'Omar Tazi', 'omar.tazi@email.ma', 10040, 9999001, '19850403', '20260101', 'O', '0661223345', '20260101'),

-- SITE 2 (RABAT) - BCM
(2, 5013, @PolSanteBCM, NULL, 'Redouane Taibi', 'redouane.taibi@banquecom.ma', 10030, 2020030, '19820318', '20260101', 'O', '0661234577', '20260101'),
(2, 5014, @PolSanteBCM, @UserAdherent2, 'Nadia Slaoui', 'adherent2@test.ma', 10020, 2020020, '19801010', '20260601', 'O', '0661778899', '20260101');

-- Personnes à charge
INSERT INTO dbo.PersACharge (fk_site_id, Id, FK_Adherent_Id, Nom, Lien, DateNaissance, DateAdhesion, CreatedAt) VALUES
(1, 6001, 5005, 'Yassine QAMCH', 'Enfant', '20150515', '20260101', '20260101'),
(1, 6002, 5005, 'Salma QAMCH', 'Conjoint', '19940820', '20260101', '20260101'),
(2, 6003, 5014, 'Omar Slaoui', 'Enfant', '20120805', '20260601', '20260101');

-- 8. RISQUES (Vehicules + IARD)
INSERT INTO dbo.Risques (fk_site_id, FK_Police_Id, Libelle, Identifiant, Description, Assure, DateDu, DateEcheance, NumeroIBS, Statut, CreatedAt) VALUES
-- SITE 1 (CASA)
(1, @PolAutoDSM, 'Dacia Duster Essence', '12345-A-1', 'Vehicule Direction', 'Amine Bouhaddou', '20260101', '20261231', 9001, 'O', '20260101'),
(1, @PolAutoERS, 'Toyota Land Cruiser', '44556-C-1', 'Vehicule Chantier', 'Younes Ait Taleb', '20260101', '20261231', 9007, 'O', '20260101'),
(1, @PolATDSM, 'Ahmed El Mansouri', '3030001', 'Assuré Accident Travail', 'Ahmed El Mansouri', '20260101', '20261231', 9501, 'O', '20260101'),
(1, @PolIARD_ERS, 'Batiment Administratif', 'BAT-ADM-001', 'Batiment R+2', 'Energies Sud', '20260101', '20261231', 10001, 'O', '20260101'),
(1, @PolIARD_DSM, 'Data Center', 'DC-CASA-001', 'Data Center Tier III', 'Digital Solutions', '20260101', '20261231', 10005, 'O', '20260101'),
(1, @PolAutoOmar, 'Hyundai Tucson', '11223-G-1', 'SUV', 'Omar Tazi', '20260101', '20260630', 9019, 'O', '20260101'),

-- SITE 2 (RABAT)
(2, @PolAutoGDA, 'Ford Transit', '77889-E-1', 'Vehicule Livraison', 'Khalil Benjelloun', '20260101', '20261231', 9015, 'O', '20260101'),
(2, @PolAutoBCM, 'Volkswagen Passat', '99001-F-1', 'Vehicule Service', 'Omar Khattabi', '20260101', '20261231', 9017, 'O', '20260101'),
(2, @PolIARD_GDA, 'Entrepot Principal', 'ENT-001-GDA', 'Entrepot 15000m', 'GDA', '20260101', '20261231', 10009, 'O', '20260101'),
(2, @PolAutoRachid, 'Dacia Sandero', '11224-G-2', 'Citadine', 'Rachid Belkadi', '20260101', '20261231', 9020, 'O', '20260101'),
(2, @PolAutoImad, 'Toyota Yaris', '55666-A-1', 'Citadine', 'Imad', '20260101', '20261231', 9030, 'O', '20260101');

INSERT INTO dbo.Garanties (fk_site_id, FK_Risque_Id, Libelle, Capital, Franchise, CreatedAt) VALUES
-- SITE 1
(1, 1, 'Responsabilité Civile', 5000000.00, '0', '20260101'),
(1, 1, 'Tierce Collision', 250000.00, '2500', '20260101'),
(1, 2, 'Responsabilité Civile', 5000000.00, '0', '20260101'),
(1, 4, 'Incendie', 5000000.00, '5000', '20260101'),
(1, 5, 'Incendie Data Center', 20000000.00, '15000', '20260101'),

-- SITE 2
(2, 7, 'Responsabilité Civile', 5000000.00, '0', '20260101'),
(2, 9, 'Incendie Entrepot', 18000000.00, '12000', '20260101'),
(2, 11, 'Responsabilité Civile', 5000000.00, '0', '20260101');

INSERT INTO dbo.Quittances (fk_site_id, Id, FK_Police_Id, NumQuittance, DateDu, DateAu, Montant, Solde, DateEcheance, Statut, CreatedAt) VALUES
-- SITE 1
(1, 7001, @PolAutoDSM, 'QUIT-001', '20260101', '20260630', 45000.00, 0.00, '20260215', 'R', '20260101'),
(1, 7009, @PolSanteDSM, 'QUIT-002', '20260101', '20260630', 250000.00, 0.00, '20260215', 'R', '20260101'),
(1, 7018, @PolIARD_ERS, 'QUIT-003', '20260101', '20261231', 450000.00, 0.00, '20260228', 'R', '20260101'),

-- SITE 2
(2, 8001, @PolAutoGDA, 'QUIT-004', '20260101', '20260630', 35000.00, 15000.00, '20260215', 'E', '20260101'),
(2, 8002, @PolSanteBCM, 'QUIT-005', '20260101', '20261231', 150000.00, 0.00, '20260215', 'R', '20260101');

INSERT INTO dbo.Sinistres (fk_site_id, Id, FK_Risque_Id, FK_Police_Id, FK_Adherent_Id, NumeroSin, DateSin, DateDeclaration, Statut, DateStatut, MT_Dommages, MT_Franchise, MT_Indemnite, Observations, CreatedAt) VALUES
-- SITE 1
(1, 8001, 1, @PolAutoDSM, NULL, 55001, '20260215', '20260216', 'C', '20260310', 15000.00, '2500', 12500.00, 'Accident avec tiers Bd Mohammed V - Constat amiable', '20260216'),
(1, 8011, NULL, @PolSanteDSM, 5005, 55011, '20260510', '20260512', 'E', '20260512', 2450.00, '490', 0.00, 'Analyses biologiques + Radio pulmonaire', '20260512'),
(1, 8019, 3, @PolATDSM, NULL, 55019, '20260210', '20260212', 'E', '20260212', 4500.00, '500', 0.00, 'Accident trajet - Fracture du bras droit', '20260212'),
(1, 8023, 5, @PolIARD_DSM, NULL, 55023, '20260710', '20260711', 'E', '20260711', 3500000.00, '20000', 0.00, 'Panne électrique générale Data Center - Service interrompu 48h', '20260711'),

-- SITE 2
(2, 8101, 7, @PolAutoGDA, NULL, 66001, '20260310', '20260311', 'C', '20260401', 8000.00, '1000', 7000.00, 'Collision véhicule livraison - Tiers identifié', '20260311'),
(2, 8102, NULL, @PolSanteBCM, 5014, 66002, '20260805', '20260807', 'C', '20260901', 3200.00, '640', 2560.00, 'Consultation cardiologue + Examens', '20260807');

-- 12. DOCUMENTS (PolDocument)
INSERT INTO dbo.PolDocument (fk_site_id, fk_police_id, fk_document_id, libelle) VALUES
-- SITE 1
(1, @PolAutoDSM, 101, 'Carte Grise Dacia Duster'),
(1, @PolSanteDSM, 601, 'Liste Adhérents DSM 2026'),
(1, @PolIARD_DSM, 1001, 'Certification DC Tier III DS Maroc'),

-- SITE 2
(2, @PolAutoGDA, 201, 'Carte Grise Ford Transit'),
(2, @PolSanteBCM, 701, 'Convention Tiers Payant BCM 2026');

INSERT INTO dbo.ReclamationsIdt (fk_site_id, FK_User_Client, DateReclamation, Sujet, Statut, DateStatut, Nature, CreatedAt) VALUES
-- SITE 1
(1, @UserClient1, '20260210 09:15:00', 'Demande de cartes vertes Flotte 2026', 'C', '20260212 14:20:00', 'I', '20260210 09:15:00'),
(1, @UserAdherent1, '20260520 14:30:00', 'Suivi remboursement dossier 55011', 'C', '20260521 10:15:00', 'S', '20260520 14:30:00'),

-- SITE 2
(2, @UserAdherent2, '20260701 08:30:00', 'Demande carte tiers payant BCM', 'C', '20260701 16:00:00', 'S', '20260701 08:30:00');

DECLARE @R1 INT = (SELECT Id FROM dbo.ReclamationsIdt WHERE fk_site_id=1 AND Sujet LIKE '%cartes vertes%');
DECLARE @R2 INT = (SELECT Id FROM dbo.ReclamationsIdt WHERE fk_site_id=1 AND Sujet LIKE '%remboursement%');
DECLARE @R3 INT = (SELECT Id FROM dbo.ReclamationsIdt WHERE fk_site_id=2 AND Sujet LIKE '%tiers payant%');

INSERT INTO dbo.ReclamationsDet (fk_site_id, FK_Reclamation_Id, FK_User_Id, DateMessage, Nature, Message) VALUES
(1, @R1, @UserClient1, '20260210 09:15:00', 'C', 'Veuillez nous transmettre les cartes vertes 2026. Urgent.'),
(1, @R1, @AdminId, '20260212 14:20:00', 'A', 'Les cartes vertes sont disponibles dans votre espace documents.'),
(1, @R2, @UserAdherent1, '20260520 14:30:00', 'C', 'Mon dossier 55011 du 12 mai est toujours en attente.'),
(1, @R2, @AdminId, '20260521 10:15:00', 'A', 'Virement de 2450 DH effectué ce jour.'),
(2, @R3, @UserAdherent2, '20260701 08:30:00', 'C', 'Je nai pas recu ma carte tiers payant.'),
(2, @R3, @ComRabatId, '20260701 16:00:00', 'A', 'Votre carte est disponible à l''agence de Rabat.');
GO

INSERT INTO dbo.UserSimulationClients (fk_user_id, fk_client_id) VALUES
(1, 1001), (1, 1002), (1, 3001), (1, 3002), -- Admin simulates all
(2, 1001), (2, 1002), -- Com Casa simulates Casa
(8, 3001), (8, 3002); -- Com Rabat simulates Rabat
GO

INSERT INTO dbo.sinComplement (
    fk_site_id, fk_sinistre_id, Ref_Sinistre, Date_Sinistre, Victime, Lieu, Type_Sinistre, Circonstances, Lesion, Etape, ITT, 
    IPP_Estime, IPP_Traitant, IPP_Conseil, IPP_Retenu, Frais_Medicaux, Frais_Transport, Indem_Jrn, Nature_indem, Montant_indem,
    HONR_MED, IPP_EVA, Salaire, AGE, CCR_EV, COUT_TOT, Dt_Presc_DC, Dt_Presc_Bien
) VALUES
(
    1, 8019, 55019, '20260210', 'Ahmed El Mansouri', 'Atelier 2 - Digital Solutions', 'Accident de trajet', 'Glissade plaque de verglas', 'Fracture fermée radius droit', 'Arrêt', '30 jours', 
    0.00, 0.00, 0.00, 0.00, 2500.00, 150.00, 1500.00, 'Rente', 1500.00,
    1200.00, 8.50, 6500.00, 34, 3500.00, 9850.00, NULL, NULL
);
GO

PRINT '=== DONNES DE TEST MULTI-SITES EXPERT IMPORTES AVEC SUCCES ===';
GO

SET IDENTITY_INSERT dbo.SitePermission ON;
INSERT INTO dbo.SitePermission (Id, Code, Description) VALUES
(1, 'utilisateurs:lire', 'Afficher la liste des utilisateurs'),
(2, 'utilisateurs:creer', 'Ajouter des utilisateurs'),
(3, 'utilisateurs:modifier', 'Modifier des utilisateurs'),
(4, 'utilisateurs:supprimer', 'Supprimer des utilisateurs'),
(5, 'utilisateurs:synchroniser', 'Synchroniser les comptes'),
(6, 'utilisateurs:gerer_roles', 'Gérer l''attribution des rôles'),
(7, 'utilisateurs:gerer_sites', 'Gérer l''accès aux sites'),
(8, 'utilisateurs:gerer_permissions_sites', 'Gérer les permissions par site'),

(9, 'sites:lire', 'Afficher la liste des sites'),
(10, 'sites:creer', 'Ajouter des sites'),
(11, 'sites:modifier', 'Modifier des sites'),
(12, 'sites:supprimer', 'Supprimer des sites'),

(13, 'simulations:lire', 'Afficher la liste des simulations'),
(14, 'simulations:creer', 'Ajouter des simulations'),
(15, 'simulations:modifier', 'Modifier des simulations'),
(16, 'simulations:supprimer', 'Supprimer des simulations'),

(17, 'clients:lire', 'Afficher la liste des clients'),
(18, 'clients:creer', 'Ajouter des clients'),
(19, 'clients:modifier', 'Modifier des clients'),
(20, 'clients:supprimer', 'Supprimer des clients'),
(21, 'clients:creer_utilisateur', 'Créer un compte pour un client'),
(22, 'clients:lier', 'Associer un client à un profil'),
(23, 'clients:delier', 'Délier un client d''un utilisateur'),
(24, 'clients:modifier_parent', 'Modifier le parent d''un client'),
(25, 'clients:gerer_emails', 'Gérer les adresses emails'),
(26, 'clients:gerer_options', 'Gérer les options du client'),

(27, 'adherents:lire', 'Afficher la liste des adhérents'),
(28, 'adherents:creer', 'Ajouter des adhérents'),
(29, 'adherents:modifier', 'Modifier des adhérents'),
(30, 'adherents:supprimer', 'Supprimer des adhérents'),
(31, 'adherents:creer_utilisateur', 'Créer un compte pour un adhérent'),
(32, 'adherents:lier', 'Associer un adhérent à un profil'),
(33, 'adherents:delier', 'Délier un adhérent'),

(34, 'reclamations:lire', 'Afficher la liste des réclamations'),
(35, 'reclamations:creer', 'Créer des réclamations'),
(36, 'reclamations:modifier', 'Modifier les réclamations'),
(37, 'reclamations:supprimer', 'Supprimer des réclamations'),

(38, 'documents:lire', 'Afficher la liste des documents'),
(39, 'documents:creer', 'Ajouter des documents'),
(40, 'documents:modifier', 'Modifier des documents'),
(41, 'documents:supprimer', 'Supprimer des documents'),

(42, 'roles:lire', 'Afficher la liste des rôles'),
(43, 'roles:creer', 'Créer des rôles'),
(44, 'roles:modifier', 'Modifier des rôles'),
(45, 'roles:supprimer', 'Supprimer des rôles'),
(46, 'roles:gerer_permissions', 'Paramétrer les autorisations');
SET IDENTITY_INSERT dbo.SitePermission OFF;
GO

-- Rôles Globaux (SiteId NULL)
SET IDENTITY_INSERT dbo.SiteRole ON;
INSERT INTO dbo.SiteRole (Id, Name, Description, SiteId) VALUES
(1, 'Super Admin Global', 'Accès total à tout', NULL),
(2, 'Gestionnaire Clients', 'Peut lire et gérer les clients', NULL),
(3, 'Commercial cabinet', 'Role pour les commercial cabinet', NULL);
SET IDENTITY_INSERT dbo.SiteRole OFF;
GO

-- Permissions des rôles
-- Rôle 1 : Super Admin Global (Toutes les 46 permissions)
INSERT INTO dbo.SiteRolePermission (SiteRoleId, SitePermissionId, Actif) VALUES
(1, 1, 'O'), (1, 2, 'O'), (1, 3, 'O'), (1, 4, 'O'), (1, 5, 'O'), (1, 6, 'O'), (1, 7, 'O'), (1, 8, 'O'), 
(1, 9, 'O'), (1, 10, 'O'), (1, 11, 'O'), (1, 12, 'O'), 
(1, 13, 'O'), (1, 14, 'O'), (1, 15, 'O'), (1, 16, 'O'), 
(1, 17, 'O'), (1, 18, 'O'), (1, 19, 'O'), (1, 20, 'O'), (1, 21, 'O'), (1, 22, 'O'), (1, 23, 'O'), (1, 24, 'O'), (1, 25, 'O'), (1, 26, 'O'), 
(1, 27, 'O'), (1, 28, 'O'), (1, 29, 'O'), (1, 30, 'O'), (1, 31, 'O'), (1, 32, 'O'), (1, 33, 'O'), 
(1, 34, 'O'), (1, 35, 'O'), (1, 36, 'O'), (1, 37, 'O'), 
(1, 38, 'O'), (1, 39, 'O'), (1, 40, 'O'), (1, 41, 'O'), 
(1, 42, 'O'), (1, 43, 'O'), (1, 44, 'O'), (1, 45, 'O'), (1, 46, 'O');
GO

-- Rôle 2 : Gestionnaire Clients (Permissions clients et réclamations)
INSERT INTO dbo.SiteRolePermission (SiteRoleId, SitePermissionId, Actif) VALUES
(2, 17, 'O'), (2, 18, 'O'), (2, 19, 'O'), (2, 20, 'O'), (2, 21, 'O'), 
(2, 22, 'O'), (2, 23, 'O'), (2, 24, 'O'), (2, 25, 'O'), (2, 26, 'O'), 
(2, 34, 'O'), (2, 35, 'O'), (2, 36, 'O'), (2, 37, 'O');
GO

-- Rôle 3 : Commercial cabinet
INSERT INTO dbo.SiteRolePermission (SiteRoleId, SitePermissionId, Actif) VALUES
(3, 1, 'O'), (3, 9, 'O'), (3, 17, 'O'), (3, 19, 'O'), (3, 21, 'O'), 
(3, 23, 'O'), (3, 27, 'O'), (3, 28, 'O'), (3, 29, 'O'), (3, 31, 'O'), 
(3, 32, 'O'), (3, 33, 'O'), (3, 34, 'O'), (3, 35, 'O'), (3, 36, 'O'), 
(3, 37, 'O'), (3, 38, 'O'), (3, 40, 'O');
GO

INSERT INTO dbo.UserSiteRole (UserId, SiteId, SiteRoleId) VALUES
(1, 1, 1), -- AdminId a Super Admin sur Casa
(1, 2, 2), -- AdminId a Gestionnaire Clients sur Rabat
(2, 1, 2); -- ComCasaId a Gestionnaire Clients sur Casa
GO

PRINT '=== DONNES DE TEST APPROLES IMPORTES AVEC SUCCES ===';
GO
