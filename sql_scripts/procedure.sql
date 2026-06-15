USE [IBS_Extranet_Mobile]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE dbo.sp_GetPolices
    @FK_User_Id INT,
    @Source CHAR(1),
    @Token VARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    
    IF NOT EXISTS (SELECT 1 FROM dbo.sysUser WHERE Id = @FK_User_Id AND token = @Token)
    BEGIN
        RAISERROR('Session expiree', 16, 1);
        RETURN;
    END

    DECLARE @UserNature CHAR(1);
    SELECT @UserNature = Nature FROM dbo.sysUser WHERE Id = @FK_User_Id;

    SELECT 
        p.Id AS id,
        p.Branche AS branche,
        p.Police AS police,
        p.DateEcheance AS dateEcheance,
        CASE p.Statut 
            WHEN 'E' THEN 'En cours' 
            WHEN 'S' THEN 'Suspendu' 
            WHEN 'R' THEN 'R' + CHAR(233) + 'sili' + CHAR(233) 
            WHEN 'M' THEN 'Mise en demeure' 
            ELSE p.Statut 
        END AS statut,
        CASE p.Statut 
            WHEN 'E' THEN 'success' 
            WHEN 'S' THEN 'warning' 
            ELSE 'error' 
        END AS statut_variant,
        CASE WHEN p.Statut = 'E' THEN 1 ELSE 0 END AS is_active,
        p.Module AS module,
        p.PBistime AS PBistime,
        p.bp AS bp,
        p.bpconsome AS bpconsome,
        c.RaisonSociale AS client,
        c.Particulier AS particulier,
        com.RaisonSociale AS compagnie
    FROM dbo.Polices p
    INNER JOIN dbo.Clients c ON p.Fk_Client_Id = c.Id
    OUTER APPLY (
        SELECT TOP 1 x.FK_User_Id
        FROM dbo.UsersXClients x
        WHERE x.FK_User_Id = @FK_User_Id
          AND x.Actif = 'O'
          AND (x.FK_Client_Id = c.Id OR x.FK_Client_Id = c.Fk_Client_Id)
    ) uxc
    INNER JOIN dbo.Compagnies com ON p.FK_Compagnie_Id = com.Id
    WHERE 
        (@Source = 'A' AND @UserNature IN ('A'))
        OR (
            uxc.FK_User_Id IS NOT NULL 
            AND (
                (@Source = 'M' AND c.Particulier = 'O')
                OR (@Source = 'E' AND c.Particulier = 'N')
            )
        )
        OR EXISTS (SELECT 1 FROM dbo.Adherents WHERE FK_Police_Id = p.Id AND FK_User_Id = @FK_User_Id AND Actif = 'O');
    
    RETURN;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_GetSinistres
    @FK_User_Id   INT,
    @Source       CHAR(1),
    @Token        VARCHAR(MAX),
    @FK_Police_Id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.sysUser WHERE Id = @FK_User_Id AND token = @Token)
    BEGIN
        RAISERROR('Session expiree', 16, 1);
        RETURN;
    END

    DECLARE @UserNature CHAR(1);
    SELECT @UserNature = Nature FROM dbo.sysUser WHERE Id = @FK_User_Id;

    SELECT 
        s.Id AS id,
        s.NumeroSin AS numero,
        s.DateSin AS date,
        s.DateDeclaration AS dateDeclaration,
        CASE s.Statut 
            WHEN 'E' THEN 'En cours' 
            WHEN 'C' THEN 'Cl' + CHAR(244) + 'tur' + CHAR(233) 
            WHEN 'R' THEN 'R' + CHAR(233) + 'ouvert' 
            ELSE s.Statut 
        END AS statut,
        CASE s.Statut 
            WHEN 'E' THEN 'warning' 
            WHEN 'C' THEN 'success' 
            WHEN 'R' THEN 'error' 
            ELSE 'neutral' 
        END AS statut_variant,
        CASE WHEN s.Statut = 'E' THEN 1 ELSE 0 END AS is_active,
        ISNULL(s.MT_Indemnite, 0) AS mtRembourse,
        ISNULL(s.MT_Dommages, 0) AS mtDommage,
        ISNULL(s.MT_Dommages, 0) AS mtFrais,
        ISNULL(s.MT_Franchise, 0) AS mtFranchise,
        ISNULL(s.Observations, '') AS observation,
        CASE 
            WHEN p.Branche LIKE '%Sant%' THEN a.NomComplet
            ELSE ISNULL(r.Libelle, '-')
        END AS objet,
        CASE 
            WHEN p.Branche LIKE '%Sant%' THEN CAST(a.NumAdhesion AS VARCHAR(50))
            ELSE r.Identifiant
        END AS identifiant,
        p.Id AS policeId,
        p.Police AS police,
        p.Branche AS branche,
        sc.Ref_Sinistre AS refSinistre,
        sc.Date_Sinistre AS dateSinistre,
        sc.Victime AS victime,
        sc.Lieu AS lieu,
        sc.Type_Sinistre AS typeSinistre,
        sc.Circonstances AS circonstances,
        sc.Lesion AS lesion,
        sc.Etape AS etape,
        sc.ITT AS itt,
        sc.IPP_Estime AS ippEstime,
        sc.IPP_Traitant AS ippTraitant,
        sc.IPP_Conseil AS ippConseil,
        sc.IPP_Retenu AS ippRetenu,
        sc.Frais_Medicaux AS fraisMedicaux,
        sc.Frais_Transport AS fraisTransport,
        sc.Indem_Jrn AS indemJrn,
        sc.Nature_indem AS natureIndem,
        sc.Montant_indem AS montantIndem,
        sc.HONR_MED AS honrMed,
        sc.IPP_EVA AS ippEva,
        sc.Salaire AS salaire,
        sc.AGE AS age,
        sc.CCR_EV AS ccrEv,
        sc.COUT_TOT AS coutTot
    FROM dbo.Sinistres s
    INNER JOIN dbo.Polices p ON s.FK_Police_Id = p.Id
    INNER JOIN dbo.Clients c ON p.Fk_Client_Id = c.Id
    LEFT JOIN dbo.Risques r ON s.FK_Risque_Id = r.Id
    LEFT JOIN dbo.Adherents a ON s.FK_Adherent_Id = a.Id
    OUTER APPLY (
        SELECT TOP 1 x.FK_User_Id
        FROM dbo.UsersXClients x
        WHERE x.FK_User_Id = @FK_User_Id
          AND x.Actif = 'O'
          AND (x.FK_Client_Id = c.Id OR x.FK_Client_Id = c.Fk_Client_Id)
    ) uxc
    LEFT JOIN dbo.sinComplement sc ON s.Id = sc.fk_sinistre_id
    WHERE (@FK_Police_Id IS NULL OR s.FK_Police_Id = @FK_Police_Id)
      AND
      (
          (@Source = 'A' AND @UserNature IN ('A'))
          OR
          (@Source = 'E' AND @UserNature = 'C' AND c.Particulier = 'N' AND uxc.FK_User_Id IS NOT NULL)
          OR
          (@Source = 'M' AND @UserNature = 'C' AND c.Particulier = 'O' AND uxc.FK_User_Id IS NOT NULL)
          OR
          (s.FK_Adherent_Id IN (SELECT Id FROM dbo.Adherents WHERE FK_User_Id = @FK_User_Id AND Actif = 'O'))
      );

    RETURN;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_GetSinistresEncour
    @FK_User_Id INT,
    @Source CHAR(1),
    @Token VARCHAR(MAX),
    @FK_Police_Id INT
AS
BEGIN
    SET NOCOUNT ON;
    
    IF NOT EXISTS (SELECT 1 FROM dbo.sysUser WHERE Id = @FK_User_Id AND token = @Token)
    BEGIN
        RAISERROR('Session expiree', 16, 1);
        RETURN;
    END

    DECLARE @UserNature CHAR(1);
    SELECT @UserNature = Nature FROM dbo.sysUser WHERE Id = @FK_User_Id;

    SELECT 
        s.Id AS id,
        s.NumeroSin AS numero,
        s.DateSin AS date,
        s.DateDeclaration AS dateDeclaration,
        'En cours' AS statut,
        ISNULL(s.MT_Indemnite, 0) AS mtRembourse,
        ISNULL(s.MT_Dommages, 0) AS mtDommage,
        ISNULL(s.MT_Dommages, 0) AS mtFrais,
        ISNULL(s.MT_Franchise, 0) AS mtFranchise,
        ISNULL(s.Observations, '') AS observation,
        CASE 
            WHEN p.Branche LIKE '%Sant%' THEN a.NomComplet
            ELSE ISNULL(r.Libelle, '-')
        END AS objet,
        CASE 
            WHEN p.Branche LIKE '%Sant%' THEN CAST(a.NumAdhesion AS VARCHAR(50))
            ELSE r.Identifiant
        END AS identifiant,
        p.Id AS policeId,
        p.Police AS police,
        p.Branche AS branche,
        sc.Ref_Sinistre AS refSinistre,
        sc.Date_Sinistre AS dateSinistre,
        sc.Victime AS victime,
        sc.Lieu AS lieu,
        sc.Type_Sinistre AS typeSinistre,
        sc.Circonstances AS circonstances,
        sc.Lesion AS lesion,
        sc.Etape AS etape,
        sc.ITT AS itt,
        sc.IPP_Estime AS ippEstime,
        sc.IPP_Traitant AS ippTraitant,
        sc.IPP_Conseil AS ippConseil,
        sc.IPP_Retenu AS ippRetenu,
        sc.Frais_Medicaux AS fraisMedicaux,
        sc.Frais_Transport AS fraisTransport,
        sc.Indem_Jrn AS indemJrn,
        sc.Nature_indem AS natureIndem,
        sc.Montant_indem AS montantIndem,
        sc.HONR_MED AS honrMed,
        sc.IPP_EVA AS ippEva,
        sc.Salaire AS salaire,
        sc.AGE AS age,
        sc.CCR_EV AS ccrEv,
        sc.COUT_TOT AS coutTot
    FROM dbo.Sinistres s
    INNER JOIN dbo.Polices p ON s.FK_Police_Id = p.Id
    INNER JOIN dbo.Clients c ON p.Fk_Client_Id = c.Id
    LEFT JOIN dbo.Risques r ON s.FK_Risque_Id = r.Id
    LEFT JOIN dbo.Adherents a ON s.FK_Adherent_Id = a.Id
    OUTER APPLY (
        SELECT TOP 1 x.FK_User_Id
        FROM dbo.UsersXClients x
        WHERE x.FK_User_Id = @FK_User_Id
          AND x.Actif = 'O'
          AND (x.FK_Client_Id = c.Id OR x.FK_Client_Id = c.Fk_Client_Id)
    ) uxc
    LEFT JOIN dbo.sinComplement sc ON s.Id = sc.fk_sinistre_id
    WHERE s.Statut = 'E'
        AND (@FK_Police_Id IS NULL OR s.FK_Police_Id = @FK_Police_Id)
        AND (
            (@Source = 'A' AND @UserNature IN ('A'))
            OR
            (@Source = 'E' AND @UserNature = 'C' AND c.Particulier = 'N' AND uxc.FK_User_Id IS NOT NULL)
            OR
            (@Source = 'M' AND @UserNature = 'C' AND c.Particulier = 'O' AND uxc.FK_User_Id IS NOT NULL)
            OR
            (s.FK_Adherent_Id IN (SELECT Id FROM dbo.Adherents WHERE FK_User_Id = @FK_User_Id AND Actif = 'O'))
        );
    
    RETURN;
END
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetRisques]
    @FK_User_Id INT,
    @Source CHAR(1),
    @Token VARCHAR(MAX),
    @FK_Police_Id INT
AS
BEGIN
    SET NOCOUNT ON;
    
    IF NOT EXISTS (SELECT 1 FROM dbo.sysUser WHERE Id = @FK_User_Id AND token = @Token)
    BEGIN
        RAISERROR('Session expiree', 16, 1);
        RETURN;
    END

    DECLARE @UserNature CHAR(1);
    SELECT @UserNature = Nature FROM dbo.sysUser WHERE Id = @FK_User_Id;

    SELECT 
        r.Id AS id,
        r.Libelle AS nom,
        r.Libelle AS marque,
        r.Identifiant AS identifiant,
        ISNULL(r.Description, 'Risque') AS description,
        r.DateDu AS dateMiseEnCirculation,
        r.DateEcheance AS dateEcheance,
        r.Statut AS statut
    FROM dbo.Risques r
    INNER JOIN dbo.Polices p ON r.FK_Police_Id = p.Id
    INNER JOIN dbo.Clients c ON p.Fk_Client_Id = c.Id
    OUTER APPLY (
        SELECT TOP 1 x.FK_User_Id
        FROM dbo.UsersXClients x
        WHERE x.FK_User_Id = @FK_User_Id
          AND x.Actif = 'O'
          AND (x.FK_Client_Id = c.Id OR x.FK_Client_Id = c.Fk_Client_Id)
    ) uxc
    WHERE (
        (@FK_Police_Id IS NULL OR p.Id = @FK_Police_Id)
        AND (
            (@Source = 'A' AND @UserNature IN ('A'))
            OR (uxc.FK_User_Id IS NOT NULL AND ((@Source = 'M' AND c.Particulier = 'O') OR (@Source = 'E' AND c.Particulier = 'N')))
            OR EXISTS (SELECT 1 FROM dbo.Adherents WHERE FK_Police_Id = p.Id AND FK_User_Id = @FK_User_Id AND Actif = 'O')
        )
    );
    
    RETURN;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_GetQuittances
    @FK_User_Id INT,
    @Source CHAR(1),
    @Token VARCHAR(MAX),
    @FK_Police_Id INT
AS
BEGIN
    SET NOCOUNT ON;
    
    IF NOT EXISTS (SELECT 1 FROM dbo.sysUser WHERE Id = @FK_User_Id AND token = @Token)
    BEGIN
        RAISERROR('Session expiree', 16, 1);
        RETURN;
    END

    DECLARE @UserNature CHAR(1);
    SELECT @UserNature = Nature FROM dbo.sysUser WHERE Id = @FK_User_Id;

    SELECT 
        q.Id AS id,
        q.NumQuittance AS numero,
        q.DateDu AS dateDebut,
        q.DateAu AS dateFin,
        ISNULL(q.Montant, 0) AS montantTotal,
        ISNULL(q.Solde, 0) AS montantImpaye,
        q.DateEcheance AS dateEcheance,
        CASE q.Statut 
            WHEN 'E' THEN 'En cours' 
            WHEN 'S' THEN 'Suspendue' 
            WHEN 'R' THEN 'R' + CHAR(233) + 'gl' + CHAR(233) + 'e' 
            WHEN 'M' THEN 'Mise en demeure' 
            WHEN 'A' THEN 'Annul' + CHAR(233) + 'e' 
            ELSE q.Statut 
        END AS statut,
        CASE q.Statut 
            WHEN 'E' THEN 'error' 
            WHEN 'S' THEN 'warning' 
            WHEN 'R' THEN 'success' 
            ELSE 'neutral' 
        END AS statut_variant,
        CASE WHEN q.Statut = 'R' THEN 1 ELSE 0 END AS is_active,
        p.Police AS police
    FROM dbo.Quittances q
    INNER JOIN dbo.Polices p ON q.FK_Police_Id = p.Id
    INNER JOIN dbo.Clients c ON p.Fk_Client_Id = c.Id
    OUTER APPLY (
        SELECT TOP 1 x.FK_User_Id
        FROM dbo.UsersXClients x
        WHERE x.FK_User_Id = @FK_User_Id
          AND x.Actif = 'O'
          AND (x.FK_Client_Id = c.Id OR x.FK_Client_Id = c.Fk_Client_Id)
    ) uxc
    WHERE (
        (@FK_Police_Id IS NULL OR p.Id = @FK_Police_Id)
        AND (
            (@Source = 'A' AND @UserNature IN ('A'))
            OR (uxc.FK_User_Id IS NOT NULL AND ((@Source = 'M' AND c.Particulier = 'O') OR (@Source = 'E' AND c.Particulier = 'N')))
        )
    );
    
    RETURN;
END
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetImpayes]
    @FK_User_Id INT,
    @Source CHAR(1),
    @Token VARCHAR(MAX),
    @FK_Police_Id INT,
    @Encour CHAR(1)
AS
BEGIN
    SET NOCOUNT ON;
    
    IF NOT EXISTS (SELECT 1 FROM dbo.sysUser WHERE Id = @FK_User_Id AND token = @Token)
    BEGIN
        RAISERROR('Session expiree', 16, 1);
        RETURN;
    END

    DECLARE @UserNature CHAR(1);
    SELECT @UserNature = Nature FROM dbo.sysUser WHERE Id = @FK_User_Id;

    IF @FK_Police_Id IS NOT NULL
    BEGIN
        SELECT 
            q.Id AS id,
            q.NumQuittance AS numero,
            q.DateDu AS dateDebut,
            q.DateAu AS dateFin,
            ISNULL(q.Montant, 0) AS montantTotal,
            ISNULL(q.Solde, 0) AS montantImpaye,
            q.DateEcheance AS dateEcheance,
            p.Branche AS branche,
            c.RaisonSociale AS client
        FROM dbo.Quittances q
        INNER JOIN dbo.Polices p ON q.FK_Police_Id = p.Id
        INNER JOIN dbo.Clients c ON p.Fk_Client_Id = c.Id
        OUTER APPLY (
            SELECT TOP 1 x.FK_User_Id
            FROM dbo.UsersXClients x
            WHERE x.FK_User_Id = @FK_User_Id
              AND x.Actif = 'O'
              AND (x.FK_Client_Id = c.Id OR x.FK_Client_Id = c.Fk_Client_Id)
        ) uxc
        WHERE ((@Encour = 'O' AND q.Solde > 0) OR (@Encour = 'N'))
            AND p.Id = @FK_Police_Id
            AND (
                (@Source = 'A' AND @UserNature IN ('A'))
                OR (uxc.FK_User_Id IS NOT NULL AND ((@Source = 'M' AND c.Particulier = 'O') OR (@Source = 'E' AND c.Particulier = 'N')))
            );
    END
    ELSE
    BEGIN
        SELECT 
            q.Id AS id,
            q.NumQuittance AS numero,
            p.Police AS numPolice,
            p.Branche AS branche,
            q.DateDu AS dateDebut,
            q.DateAu AS dateFin,
            ISNULL(q.Montant, 0) AS montantTotal,
            ISNULL(q.Solde, 0) AS montantImpaye,
            q.DateEcheance AS dateEcheance,
            c.RaisonSociale AS client
        FROM dbo.Quittances q
        INNER JOIN dbo.Polices p ON q.FK_Police_Id = p.Id
        INNER JOIN dbo.Clients c ON p.Fk_Client_Id = c.Id
        OUTER APPLY (
            SELECT TOP 1 x.FK_User_Id
            FROM dbo.UsersXClients x
            WHERE x.FK_User_Id = @FK_User_Id
              AND x.Actif = 'O'
              AND (x.FK_Client_Id = c.Id OR x.FK_Client_Id = c.Fk_Client_Id)
        ) uxc
        WHERE ((@Encour = 'O' AND q.Solde > 0) OR (@Encour = 'N'))
            AND (
                (@Source = 'A' AND @UserNature IN ('A'))
                OR (uxc.FK_User_Id IS NOT NULL AND ((@Source = 'M' AND c.Particulier = 'O') OR (@Source = 'E' AND c.Particulier = 'N')))
            );
    END

    RETURN;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_GetAdherents
    @FK_User_Id INT,
    @Source CHAR(1),
    @Token VARCHAR(MAX),
    @FK_Police_Id INT
AS
BEGIN
    SET NOCOUNT ON;
    
    IF NOT EXISTS (SELECT 1 FROM dbo.sysUser WHERE Id = @FK_User_Id AND token = @Token)
    BEGIN
        RAISERROR('Session expiree', 16, 1);
        RETURN;
    END

    DECLARE @UserNature CHAR(1);
    SELECT @UserNature = Nature FROM dbo.sysUser WHERE Id = @FK_User_Id;

    DECLARE @IsAdmin BIT = 0;
    DECLARE @IsCommercial BIT = 0;

    IF EXISTS (SELECT 1 FROM dbo.Roles WHERE FK_User_Id = @FK_User_Id AND Role = 'admin_cabinet')
    BEGIN
        SET @IsAdmin = 1;
    END
    ELSE IF EXISTS (SELECT 1 FROM dbo.Roles WHERE FK_User_Id = @FK_User_Id AND Role = 'commercial_cabinet')
    BEGIN
        SET @IsCommercial = 1;
    END
    ELSE IF @UserNature = 'A'
    BEGIN
        SET @IsAdmin = 1;
    END

    SELECT 
        a.Id AS id,
        a.NomComplet AS nom,
        a.Email AS email,
        a.NumAdhesion AS numAdhesion,
        a.Matricule AS matricule,
        a.DateNaissance AS dateNaissance,
        a.DateAdhesion AS dateAdhesion,
        a.Actif AS actif,
        a.Telephone AS telephone,
        a.FK_User_Id AS fkUserId,
        u.Nom AS userNom
    FROM dbo.Adherents a
    INNER JOIN dbo.Polices p ON a.FK_Police_Id = p.Id
    INNER JOIN dbo.Clients c ON p.Fk_Client_Id = c.Id
    OUTER APPLY (
        SELECT TOP 1 x.FK_User_Id
        FROM dbo.UsersXClients x
        WHERE x.FK_User_Id = @FK_User_Id
          AND x.Actif = 'O'
          AND (x.FK_Client_Id = c.Id OR x.FK_Client_Id = c.Fk_Client_Id)
    ) uxc
    LEFT JOIN dbo.sysUser u ON a.FK_User_Id = u.Id
    WHERE (@Source = 'A' OR @FK_Police_Id IS NULL OR p.Id = @FK_Police_Id)
        AND a.Actif = 'O'
        AND (
            (@Source = 'A' AND @IsAdmin = 1)
            OR
            (@Source = 'A' AND @IsCommercial = 1 AND EXISTS (
                SELECT 1 FROM dbo.UserSimulationClients usc 
                WHERE usc.fk_user_id = @FK_User_Id AND usc.fk_client_id = c.Id
            ))
            OR
            (uxc.FK_User_Id IS NOT NULL AND (@Source = 'E' AND c.Particulier = 'N'))
            OR
            (uxc.FK_User_Id IS NOT NULL AND (@Source = 'M' AND c.Particulier = 'O'))
            OR
            (a.FK_User_Id = @FK_User_Id)
        );
    
    RETURN;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_GetPersACharge
    @FK_User_Id INT,
    @Source CHAR(1),
    @Token VARCHAR(MAX),
    @FK_Adherent_Id INT
AS
BEGIN
    SET NOCOUNT ON;
    
    IF NOT EXISTS (SELECT 1 FROM dbo.sysUser WHERE Id = @FK_User_Id AND token = @Token)
    BEGIN
        RAISERROR('Session expiree', 16, 1);
        RETURN;
    END

    DECLARE @UserNature CHAR(1);
    SELECT @UserNature = Nature FROM dbo.sysUser WHERE Id = @FK_User_Id;

    SELECT 
        pc.Id AS id,
        pc.Nom AS nom,
        pc.Lien AS lien,
        pc.DateNaissance AS dateNaissance,
        pc.DateAdhesion AS dateAdhesion
    FROM dbo.PersACharge pc
    INNER JOIN dbo.Adherents a ON pc.FK_Adherent_Id = a.Id
    INNER JOIN dbo.Polices p ON a.FK_Police_Id = p.Id
    INNER JOIN dbo.Clients c ON p.Fk_Client_Id = c.Id
    OUTER APPLY (
        SELECT TOP 1 x.FK_User_Id
        FROM dbo.UsersXClients x
        WHERE x.FK_User_Id = @FK_User_Id
          AND x.Actif = 'O'
          AND (x.FK_Client_Id = c.Id OR x.FK_Client_Id = c.Fk_Client_Id)
    ) uxc
    WHERE a.Id = @FK_Adherent_Id
        AND a.Actif = 'O'
        AND (
            (@Source = 'A' AND @UserNature IN ('A'))
            OR
            (a.FK_User_Id = @FK_User_Id)
            OR
            (uxc.FK_User_Id IS NOT NULL AND ((@Source = 'M' AND c.Particulier = 'O') OR (@Source = 'E' AND c.Particulier = 'N')))
        );
    
    RETURN;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_GetGarantiesByRisque
    @FK_User_Id INT,
    @Source CHAR(1),
    @Token VARCHAR(MAX),
    @FK_Risque_Id INT
AS
BEGIN
    SET NOCOUNT ON;
    
    IF NOT EXISTS (SELECT 1 FROM dbo.sysUser WHERE Id = @FK_User_Id AND token = @Token)
    BEGIN
        RAISERROR('Session expiree', 16, 1);
        RETURN;
    END

    DECLARE @UserNature CHAR(1);
    SELECT @UserNature = Nature FROM dbo.sysUser WHERE Id = @FK_User_Id;

    SELECT 
        g.Id AS id,
        g.Libelle AS nom,
        ISNULL(g.Capital, 0) AS capital,
        ISNULL(g.Franchise, 0) AS franchise
    FROM dbo.Garanties g
    INNER JOIN dbo.Risques r ON g.FK_Risque_Id = r.Id
    INNER JOIN dbo.Polices p ON r.FK_Police_Id = p.Id
    INNER JOIN dbo.Clients c ON p.Fk_Client_Id = c.Id
    OUTER APPLY (
        SELECT TOP 1 x.FK_User_Id
        FROM dbo.UsersXClients x
        WHERE x.FK_User_Id = @FK_User_Id
          AND x.Actif = 'O'
          AND (x.FK_Client_Id = c.Id OR x.FK_Client_Id = c.Fk_Client_Id)
    ) uxc
    WHERE r.Id = @FK_Risque_Id
        AND (
            (@Source = 'A' AND @UserNature IN ('A'))
            OR
            (uxc.FK_User_Id IS NOT NULL AND ((@Source = 'M' AND c.Particulier = 'O') OR (@Source = 'E' AND c.Particulier = 'N')))
            OR
            EXISTS (SELECT 1 FROM dbo.Adherents WHERE FK_Police_Id = p.Id AND FK_User_Id = @FK_User_Id AND Actif = 'O')
        );
    
    RETURN;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_GetReclamations
    @FK_User_Id INT,
    @Source CHAR(1),
    @Token VARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    
    IF NOT EXISTS (SELECT 1 FROM dbo.sysUser WHERE Id = @FK_User_Id AND token = @Token)
    BEGIN
        RAISERROR('Session expiree', 16, 1);
        RETURN;
    END

    DECLARE @UserNature CHAR(1);
    SELECT @UserNature = Nature FROM dbo.sysUser WHERE Id = @FK_User_Id;

    SELECT 
        r.Id AS id,
        r.DateReclamation AS dateReclamation,
        r.Sujet AS sujet,
        CASE r.Statut 
            WHEN 'E' THEN 'En cours' 
            WHEN 'C' THEN 'Cl' + CHAR(244) + 'tur' + CHAR(233) 
            ELSE r.Statut 
        END AS statut,
        CASE r.Statut 
            WHEN 'E' THEN 'warning' 
            WHEN 'C' THEN 'success' 
            ELSE 'neutral' 
        END AS statut_variant,
        CASE WHEN r.Statut = 'E' THEN 1 ELSE 0 END AS is_active,
        r.DateStatut AS dateStatut,
        CASE r.Nature 
            WHEN 'R' THEN 'R' + CHAR(233) + 'clamation' 
            WHEN 'D' THEN 'Demande d''info' 
            WHEN 'S' THEN 'Sinistre' 
            ELSE r.Nature 
        END AS nature,
        u.Nom AS client
    FROM dbo.ReclamationsIdt r
    INNER JOIN dbo.sysUser u ON r.FK_User_Client = u.Id
    WHERE (@UserNature IN ('A')) OR (r.FK_User_Client = @FK_User_Id)
    ORDER BY r.DateReclamation DESC;
    
    RETURN;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_GetReclamationDetails
    @FK_User_Id INT,
    @Source CHAR(1),
    @Token VARCHAR(MAX),
    @FK_Reclamation_Id INT
AS
BEGIN
    SET NOCOUNT ON;
    
    IF NOT EXISTS (SELECT 1 FROM dbo.sysUser WHERE Id = @FK_User_Id AND token = @Token)
    BEGIN
        RAISERROR('Session expiree', 16, 1);
        RETURN;
    END

    DECLARE @UserNature CHAR(1);
    SELECT @UserNature = Nature FROM dbo.sysUser WHERE Id = @FK_User_Id;

    IF EXISTS (SELECT 1 FROM dbo.ReclamationsIdt WHERE Id = @FK_Reclamation_Id 
               AND (@UserNature IN ('A') OR FK_User_Client = @FK_User_Id))
    BEGIN
        DECLARE @LastMsgId INT;
        SELECT @LastMsgId = MAX(Id) FROM dbo.ReclamationsDet WHERE FK_Reclamation_Id = @FK_Reclamation_Id;

        SELECT 
            rd.Id AS id,
            rd.DateMessage AS dateMessage,
            CASE rd.Nature 
                WHEN 'C' THEN 'Client' 
                WHEN 'A' THEN 'Admin' 
                ELSE rd.Nature 
            END AS nature,
            rd.Message AS message,
            rd.FK_User_Id AS fkUserId,
            u.Nom AS envoyeur,
            CASE WHEN rd.FK_User_Id = @FK_User_Id AND rd.Id = @LastMsgId THEN 1 ELSE 0 END AS canDelete
        FROM dbo.ReclamationsDet rd
        INNER JOIN dbo.sysUser u ON rd.FK_User_Id = u.Id
        WHERE rd.FK_Reclamation_Id = @FK_Reclamation_Id
        ORDER BY rd.DateMessage ASC;
        
        RETURN;
    END
    
    RAISERROR('Reclamation introuvable', 16, 1);
    RETURN;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_CreateReclamation
    @FK_User_Id INT,
    @Source CHAR(1),
    @Token VARCHAR(MAX),
    @Sujet VARCHAR(255),
    @Nature CHAR(1),
    @Message VARCHAR(2000)
AS
BEGIN
    SET NOCOUNT ON;
    
    IF NOT EXISTS (SELECT 1 FROM dbo.sysUser WHERE Id = @FK_User_Id AND token = @Token)
    BEGIN
        RAISERROR('Session expiree', 16, 1);
        RETURN;
    END

    DECLARE @NewId INT;
    DECLARE @UserNature CHAR(1);
    SELECT @UserNature = Nature FROM dbo.sysUser WHERE Id = @FK_User_Id;

    INSERT INTO dbo.ReclamationsIdt (FK_User_Client, Sujet, Nature, Statut, DateStatut)
    VALUES (@FK_User_Id, @Sujet, @Nature, 'E', GETDATE());

    SET @NewId = SCOPE_IDENTITY();

    INSERT INTO dbo.ReclamationsDet (FK_Reclamation_Id, FK_User_Id, Nature, Message)
    VALUES (@NewId, @FK_User_Id, @UserNature, @Message);

    SELECT @NewId AS id;
    
    RETURN;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_AddMessageReclamation
    @FK_User_Id INT,
    @Source CHAR(1),
    @Token VARCHAR(MAX),
    @FK_Reclamation_Id INT,
    @Nature CHAR(1),
    @Message VARCHAR(2000)
AS
BEGIN
    SET NOCOUNT ON;
    
    IF NOT EXISTS (SELECT 1 FROM dbo.sysUser WHERE Id = @FK_User_Id AND token = @Token)
    BEGIN
        RAISERROR('Session expiree', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM dbo.ReclamationsIdt WHERE Id = @FK_Reclamation_Id AND Statut = 'C')
    BEGIN
        RAISERROR('La reclamation est cloturee', 16, 1);
        RETURN;
    END

    DECLARE @UserNature CHAR(1);
    SELECT @UserNature = Nature FROM dbo.sysUser WHERE Id = @FK_User_Id;

    IF EXISTS (SELECT 1 FROM dbo.ReclamationsIdt 
               WHERE Id = @FK_Reclamation_Id 
               AND (@UserNature IN ('A') OR FK_User_Client = @FK_User_Id))
    BEGIN
        INSERT INTO dbo.ReclamationsDet (FK_Reclamation_Id, FK_User_Id, Nature, Message)
        VALUES (@FK_Reclamation_Id, @FK_User_Id, @UserNature, @Message);

        UPDATE dbo.ReclamationsIdt 
        SET Statut = 'E', 
            DateStatut = GETDATE() 
        WHERE Id = @FK_Reclamation_Id;
        
        RETURN;
    END
    
    RAISERROR('Action non autorisee', 16, 1);
    RETURN;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_UpdateReclamationStatus
    @FK_User_Id INT,
    @Source CHAR(1),
    @Token VARCHAR(MAX),
    @FK_Reclamation_Id INT,
    @Statut CHAR(1)
AS
BEGIN
    SET NOCOUNT ON;
    
    IF NOT EXISTS (SELECT 1 FROM dbo.sysUser WHERE Id = @FK_User_Id AND token = @Token)
    BEGIN
        RAISERROR('Session expiree', 16, 1);
        RETURN;
    END

    IF @Statut NOT IN ('E', 'C')
    BEGIN
        RAISERROR('Statut invalide. Valeurs acceptees : E (En cours), C (Cloture)', 16, 1);
        RETURN;
    END

    DECLARE @UserNature CHAR(1);
    SELECT @UserNature = Nature FROM dbo.sysUser WHERE Id = @FK_User_Id;

    IF EXISTS (
        SELECT 1 FROM dbo.ReclamationsIdt 
        WHERE Id = @FK_Reclamation_Id 
        AND (@UserNature IN ('A') OR FK_User_Client = @FK_User_Id)
    )
    BEGIN
        UPDATE dbo.ReclamationsIdt 
        SET Statut = @Statut, 
            DateStatut = GETDATE() 
        WHERE Id = @FK_Reclamation_Id;
        
        RETURN;
    END
    
    RAISERROR('Action non autorisee', 16, 1);
    RETURN;
END
GO

CREATE OR ALTER PROCEDURE dbo.ps_SaveUser
    @FK_User_Id    INT,
    @Token         VARCHAR(MAX),
    @Source        VARCHAR(50),
    @FK_Target_Id  INT,
    @Id_Auth       VARCHAR(255),
    @Nom           VARCHAR(255),
    @Telephone     VARCHAR(20),
    @Email         VARCHAR(255),
    @Nature        CHAR(1),
    @Extranet      CHAR(1),
    @Mobile        CHAR(1)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @UserNature CHAR(1);
    SELECT @UserNature = Nature FROM dbo.sysUser WHERE Id = @FK_User_Id;

    DECLARE @IsAdmin BIT = 0;
    DECLARE @IsCommercial BIT = 0;

    IF EXISTS (SELECT 1 FROM dbo.Roles WHERE FK_User_Id = @FK_User_Id AND Role = 'admin_cabinet')
    BEGIN
        SET @IsAdmin = 1;
    END
    ELSE IF EXISTS (SELECT 1 FROM dbo.Roles WHERE FK_User_Id = @FK_User_Id AND Role = 'commercial_cabinet')
    BEGIN
        SET @IsCommercial = 1;
    END
    ELSE IF @UserNature = 'A'
    BEGIN
        SET @IsAdmin = 1;
    END

    -- Admin cabinet OU commercial cabinet
    IF NOT (@Source = 'A' AND (@IsAdmin = 1 OR @IsCommercial = 1))
    BEGIN
        RAISERROR('Action non autorisee', 16, 1);
        RETURN;
    END

    -- Le commercial ne peut creer/modifier que des utilisateurs de nature client ('C')
    IF @IsAdmin = 0 AND @IsCommercial = 1 AND @Nature <> 'C'
    BEGIN
        RAISERROR('Le commercial ne peut gerer que les utilisateurs de nature Client', 16, 1);
        RETURN;
    END

    -- Si c'est une modification par un commercial, il faut s'assurer qu'il en est le créateur ou qu'il gère le client/adhérent de simulation lié
    IF @FK_Target_Id <> 0 AND @IsAdmin = 0 AND @IsCommercial = 1
    BEGIN
        IF NOT (
            EXISTS (SELECT 1 FROM dbo.sysUser WHERE Id = @FK_Target_Id AND CreatedBy = @FK_User_Id)
            OR EXISTS (
                SELECT 1 FROM dbo.UsersXClients uxc
                INNER JOIN dbo.UserSimulationClients usc ON uxc.FK_Client_Id = usc.fk_client_id
                WHERE uxc.FK_User_Id = @FK_Target_Id AND usc.fk_user_id = @FK_User_Id
            )
            OR EXISTS (
                SELECT 1 FROM dbo.Adherents a
                INNER JOIN dbo.Polices p ON a.FK_Police_Id = p.Id
                INNER JOIN dbo.UserSimulationClients usc ON p.Fk_Client_Id = usc.fk_client_id
                WHERE a.FK_User_Id = @FK_Target_Id AND usc.fk_user_id = @FK_User_Id
            )
        )
        BEGIN
            RAISERROR('Action non autorisee sur cet utilisateur : il n''est pas associe a votre perimetre de simulation', 16, 1);
            RETURN;
        END
    END

    IF EXISTS (SELECT 1 FROM dbo.sysUser WHERE Email = @Email AND Id <> @FK_Target_Id)
    BEGIN
        RAISERROR('Email deja utilise', 16, 1);
        RETURN;
    END

    IF @FK_Target_Id = 0
    BEGIN
        INSERT INTO dbo.sysUser (Id_Auth, Nom, Telephone, Email, Nature, Extranet, Mobile, CreatedBy)
        VALUES (@Id_Auth, @Nom, @Telephone, @Email, @Nature, @Extranet, @Mobile, @FK_User_Id);
        SELECT SCOPE_IDENTITY() AS newId;
    END
    ELSE
    BEGIN
        UPDATE dbo.sysUser
        SET Id_Auth = @Id_Auth, Nom = @Nom, Telephone = @Telephone,
            Email = @Email, Nature = @Nature, Extranet = @Extranet, Mobile = @Mobile
        WHERE Id = @FK_Target_Id;
        SELECT @FK_Target_Id AS newId;
    END
END
GO

CREATE OR ALTER PROCEDURE dbo.ps_DeleteUser
    @FK_User_Id    INT,
    @Token         VARCHAR(MAX),
    @Source        VARCHAR(50),
    @FK_Delete_Id  INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @UserNature CHAR(1);
    SELECT @UserNature = Nature FROM dbo.sysUser WHERE Id = @FK_User_Id;

    DECLARE @IsAdmin BIT = 0;
    DECLARE @IsCommercial BIT = 0;

    IF EXISTS (SELECT 1 FROM dbo.Roles WHERE FK_User_Id = @FK_User_Id AND Role = 'admin_cabinet')
    BEGIN
        SET @IsAdmin = 1;
    END
    ELSE IF EXISTS (SELECT 1 FROM dbo.Roles WHERE FK_User_Id = @FK_User_Id AND Role = 'commercial_cabinet')
    BEGIN
        SET @IsCommercial = 1;
    END
    ELSE IF @UserNature = 'A'
    BEGIN
        SET @IsAdmin = 1;
    END

    IF NOT (@Source = 'A' AND (@IsAdmin = 1 OR @IsCommercial = 1))
    BEGIN
        RAISERROR('Action non autorisee', 16, 1);
        RETURN;
    END

    -- Si commercial, vérifier qu'il a le droit de gérer l'utilisateur (créateur ou simulation)
    IF @IsAdmin = 0 AND @IsCommercial = 1
    BEGIN
        IF NOT (
            EXISTS (SELECT 1 FROM dbo.sysUser WHERE Id = @FK_Delete_Id AND CreatedBy = @FK_User_Id)
            OR EXISTS (
                SELECT 1 FROM dbo.UsersXClients uxc
                INNER JOIN dbo.UserSimulationClients usc ON uxc.FK_Client_Id = usc.fk_client_id
                WHERE uxc.FK_User_Id = @FK_Delete_Id AND usc.fk_user_id = @FK_User_Id
            )
            OR EXISTS (
                SELECT 1 FROM dbo.Adherents a
                INNER JOIN dbo.Polices p ON a.FK_Police_Id = p.Id
                INNER JOIN dbo.UserSimulationClients usc ON p.Fk_Client_Id = usc.fk_client_id
                WHERE a.FK_User_Id = @FK_Delete_Id AND usc.fk_user_id = @FK_User_Id
            )
        )
        BEGIN
            RAISERROR('Action non autorisee : cet utilisateur n''est pas associe a votre perimetre de simulation', 16, 1);
            RETURN;
        END
    END

    IF EXISTS (SELECT 1 FROM UsersXClients WHERE FK_User_Id = @FK_Delete_Id)
    BEGIN
        RAISERROR('Impossible de supprimer : cet utilisateur est lie a un client', 16, 1);
        RETURN;
    END
    
    IF EXISTS (SELECT 1 FROM dbo.Adherents WHERE FK_User_Id = @FK_Delete_Id)
    BEGIN
        RAISERROR('Impossible de supprimer : cet utilisateur est lie a un adherent', 16, 1);
        RETURN;
    END
    
    DELETE FROM dbo.Roles            WHERE FK_User_Id = @FK_Delete_Id;
    DELETE FROM dbo.Postes_Autorises WHERE FK_User_Id = @FK_Delete_Id;
    DELETE FROM dbo.UsersXClients    WHERE FK_User_Id = @FK_Delete_Id;
    DELETE FROM dbo.sysUser          WHERE Id         = @FK_Delete_Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.ps_GetClients
    @FK_User_Id   INT,
    @Token        VARCHAR(MAX),
    @Source       VARCHAR(50),
    @Role         VARCHAR(50) = 'admin_cabinet'   -- Nouveau : 'admin_cabinet' | 'commercial_cabinet'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @UserNature CHAR(1);
    SELECT @UserNature = Nature FROM dbo.sysUser WHERE Id = @FK_User_Id;

    -- Vérification : admin cabinet OU commercial cabinet
    IF NOT (@Source = 'A' AND (
        @UserNature IN ('A')
        OR EXISTS (SELECT 1 FROM dbo.Roles WHERE FK_User_Id = @FK_User_Id AND Role IN ('admin_cabinet','commercial_cabinet','COMMERCIAL'))
    ))
    BEGIN
        RAISERROR('Action non autorisee', 16, 1);
        RETURN;
    END

    -- Admin : tous les clients
    IF @Role = 'admin_cabinet' AND NOT EXISTS (SELECT 1 FROM dbo.Roles WHERE FK_User_Id = @FK_User_Id AND Role = 'commercial_cabinet')
    BEGIN
        SELECT 
            c.Id AS id,
            c.RaisonSociale AS raisonSociale,
            c.Particulier AS particulier,
            c.Email AS email,
            c.Adresse AS adresse,
            c.recClt AS recClt,
            c.recAdh AS recAdh,
            c.EmailChargeCompte AS emailChargeCompte,
            cParent.RaisonSociale AS parentClient,
            STUFF((
                SELECT ', ' + u.Nom
                FROM dbo.UsersXClients x
                INNER JOIN dbo.sysUser u ON x.FK_User_Id = u.Id
                WHERE x.FK_Client_Id = c.Id
                FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS userNom,
            STUFF((
                SELECT ', ' + CAST(x.FK_User_Id AS VARCHAR)
                FROM dbo.UsersXClients x
                WHERE x.FK_Client_Id = c.Id
                FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS fkUserId
        FROM dbo.Clients c
        LEFT JOIN dbo.Clients cParent ON c.Fk_Client_Id = cParent.Id
        ORDER BY c.RaisonSociale;
    END
    ELSE
    BEGIN
        -- Commercial : uniquement ses clients de simulation
        SELECT 
            c.Id AS id,
            c.RaisonSociale AS raisonSociale,
            c.Particulier AS particulier,
            c.Email AS email,
            c.Adresse AS adresse,
            c.recClt AS recClt,
            c.recAdh AS recAdh,
            c.EmailChargeCompte AS emailChargeCompte,
            cParent.RaisonSociale AS parentClient,
            STUFF((
                SELECT ', ' + u.Nom
                FROM dbo.UsersXClients x
                INNER JOIN dbo.sysUser u ON x.FK_User_Id = u.Id
                WHERE x.FK_Client_Id = c.Id
                FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS userNom,
            STUFF((
                SELECT ', ' + CAST(x.FK_User_Id AS VARCHAR)
                FROM dbo.UsersXClients x
                WHERE x.FK_Client_Id = c.Id
                FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS fkUserId
        FROM dbo.Clients c
        INNER JOIN dbo.UserSimulationClients usc ON usc.fk_client_id = c.Id AND usc.fk_user_id = @FK_User_Id
        LEFT JOIN dbo.Clients cParent ON c.Fk_Client_Id = cParent.Id
        ORDER BY c.RaisonSociale;
    END
END
GO

CREATE OR ALTER PROCEDURE dbo.ps_CreateUserFromClient
    @FK_User_Id   INT,
    @Token        VARCHAR(MAX),
    @Source       VARCHAR(50),
    @FK_Client_Id INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @UserNature CHAR(1);
    SELECT @UserNature = Nature FROM dbo.sysUser WHERE Id = @FK_User_Id;

    DECLARE @IsAdmin BIT = 0;
    DECLARE @IsCommercial BIT = 0;

    IF EXISTS (SELECT 1 FROM dbo.Roles WHERE FK_User_Id = @FK_User_Id AND Role = 'admin_cabinet')
    BEGIN
        SET @IsAdmin = 1;
    END
    ELSE IF EXISTS (SELECT 1 FROM dbo.Roles WHERE FK_User_Id = @FK_User_Id AND Role = 'commercial_cabinet')
    BEGIN
        SET @IsCommercial = 1;
    END
    ELSE IF @UserNature = 'A'
    BEGIN
        SET @IsAdmin = 1;
    END

    IF NOT (@Source = 'A' AND (@IsAdmin = 1 OR @IsCommercial = 1))
    BEGIN
        RAISERROR('Action non autorisee', 16, 1);
        RETURN;
    END

    IF @IsAdmin = 0 AND @IsCommercial = 1
    BEGIN
        IF NOT EXISTS (
            SELECT 1 FROM dbo.UserSimulationClients 
            WHERE fk_user_id = @FK_User_Id AND fk_client_id = @FK_Client_Id
        )
        BEGIN
            RAISERROR('Acces refuse : ce client ne fait pas partie de vos clients assignes', 16, 1);
            RETURN;
        END
    END
    
    DECLARE @Nom VARCHAR(255), @Email VARCHAR(255), @NewUserId INT;
    SELECT @Nom = RaisonSociale, @Email = Email FROM dbo.Clients WHERE Id = @FK_Client_Id;
    
    IF @Nom IS NULL
    BEGIN
        RAISERROR('Client introuvable', 16, 1);
        RETURN;
    END
    
    IF EXISTS (SELECT 1 FROM dbo.sysUser WHERE Email = @Email)
    BEGIN
        RAISERROR('Email deja utilise', 16, 1);
        RETURN;
    END

    INSERT INTO dbo.sysUser (Nom, Email, Nature, Extranet, Mobile, CreatedBy) 
    VALUES (@Nom, @Email, 'C', 'O', 'N', @FK_User_Id);
    
    SET @NewUserId = SCOPE_IDENTITY();
    
    INSERT INTO dbo.UsersXClients (FK_User_Id, FK_Client_Id, Actif)
    VALUES (@NewUserId, @FK_Client_Id, 'O');
    
    SELECT 
        Id AS id,
        Id_Auth AS idAuth,
        token,
        Nom AS nom,
        Telephone AS telephone,
        Email AS email,
        Nature AS nature,
        Extranet AS extranet,
        Mobile AS mobile,
        CreatedAt AS createdAt,
        UpdatedAt AS updatedAt
    FROM dbo.sysUser WHERE Id = @NewUserId;
END
GO

CREATE OR ALTER PROCEDURE dbo.ps_CreateUserFromAdherent
    @FK_User_Id     INT,
    @Token          VARCHAR(MAX),
    @Source         VARCHAR(50),
    @FK_Adherent_Id INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @UserNature CHAR(1);
    SELECT @UserNature = Nature FROM dbo.sysUser WHERE Id = @FK_User_Id;

    DECLARE @IsAdmin BIT = 0;
    DECLARE @IsCommercial BIT = 0;

    IF EXISTS (SELECT 1 FROM dbo.Roles WHERE FK_User_Id = @FK_User_Id AND Role = 'admin_cabinet')
    BEGIN
        SET @IsAdmin = 1;
    END
    ELSE IF EXISTS (SELECT 1 FROM dbo.Roles WHERE FK_User_Id = @FK_User_Id AND Role = 'commercial_cabinet')
    BEGIN
        SET @IsCommercial = 1;
    END
    ELSE IF @UserNature = 'A'
    BEGIN
        SET @IsAdmin = 1;
    END

    IF NOT (@Source = 'A' AND (@IsAdmin = 1 OR @IsCommercial = 1))
    BEGIN
        RAISERROR('Action non autorisee', 16, 1);
        RETURN;
    END

    DECLARE @AdherentClientId INT;
    SELECT @AdherentClientId = p.Fk_Client_Id
    FROM dbo.Adherents a
    INNER JOIN dbo.Polices p ON a.FK_Police_Id = p.Id
    WHERE a.Id = @FK_Adherent_Id;

    IF @IsAdmin = 0 AND @IsCommercial = 1
    BEGIN
        IF NOT EXISTS (
            SELECT 1 FROM dbo.UserSimulationClients 
            WHERE fk_user_id = @FK_User_Id AND fk_client_id = @AdherentClientId
        )
        BEGIN
            RAISERROR('Acces refuse : cet adherent appartient a un client qui ne fait pas partie de vos clients assignes', 16, 1);
            RETURN;
        END
    END
    
    DECLARE @Nom VARCHAR(255), @Email VARCHAR(255), @NewUserId INT;
    SELECT @Nom = NomComplet, @Email = Email FROM dbo.Adherents WHERE Id = @FK_Adherent_Id;
    
    IF @Nom IS NULL
    BEGIN
        RAISERROR('Adherent introuvable', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM dbo.sysUser WHERE Email = @Email)
    BEGIN
        RAISERROR('Email deja utilise', 16, 1);
        RETURN;
    END

    INSERT INTO dbo.sysUser (Nom, Email, Nature, Extranet, Mobile, CreatedBy) 
    VALUES (@Nom, @Email, 'C', 'N', 'O', @FK_User_Id);
    
    SET @NewUserId = SCOPE_IDENTITY();
    UPDATE dbo.Adherents SET FK_User_Id = @NewUserId WHERE Id = @FK_Adherent_Id;
    
    SELECT 
        Id AS id,
        Id_Auth AS idAuth,
        token,
        Nom AS nom,
        Telephone AS telephone,
        Email AS email,
        Nature AS nature,
        Extranet AS extranet,
        Mobile AS mobile,
        CreatedAt AS createdAt,
        UpdatedAt AS updatedAt
    FROM dbo.sysUser WHERE Id = @NewUserId;
END
GO

CREATE OR ALTER PROCEDURE dbo.ps_GetUsers
    @FK_User_Id INT,
    @Token      VARCHAR(MAX),
    @Source     VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    IF NOT EXISTS (SELECT 1 FROM dbo.sysUser WHERE Id = @FK_User_Id AND token = @Token)
    BEGIN
        RAISERROR('Session expiree', 16, 1);
        RETURN;
    END
    
    DECLARE @UserNature CHAR(1);
    SELECT @UserNature = Nature FROM dbo.sysUser WHERE Id = @FK_User_Id;

    DECLARE @IsAdmin BIT = 0;
    DECLARE @IsCommercial BIT = 0;

    IF EXISTS (SELECT 1 FROM dbo.Roles WHERE FK_User_Id = @FK_User_Id AND Role = 'admin_cabinet')
    BEGIN
        SET @IsAdmin = 1;
    END
    ELSE IF EXISTS (SELECT 1 FROM dbo.Roles WHERE FK_User_Id = @FK_User_Id AND Role = 'commercial_cabinet')
    BEGIN
        SET @IsCommercial = 1;
    END
    ELSE IF @UserNature = 'A'
    BEGIN
        SET @IsAdmin = 1;
    END

    IF @Source = 'A' AND (@IsAdmin = 1 OR @IsCommercial = 1)
    BEGIN
        SELECT 
            u.Id AS id,
            u.Id_Auth AS idAuth,
            u.token,
            u.Nom AS nom,
            u.Telephone AS telephone,
            u.Email AS email,
            u.Nature AS nature,
            u.Extranet AS extranet,
            u.Mobile AS mobile,
            u.CreatedAt AS createdAt,
            u.UpdatedAt AS updatedAt,
            STUFF((
                SELECT ', ' + r.Role
                FROM dbo.Roles r
                WHERE r.FK_User_Id = u.Id
                FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS roles,
            CASE 
                WHEN @IsAdmin = 1 THEN 1
                WHEN @IsCommercial = 1 AND (
                    u.CreatedBy = @FK_User_Id
                    OR EXISTS (
                        SELECT 1 FROM dbo.UsersXClients uxc
                        INNER JOIN dbo.UserSimulationClients usc ON uxc.FK_Client_Id = usc.fk_client_id
                        WHERE uxc.FK_User_Id = u.Id AND usc.fk_user_id = @FK_User_Id
                    )
                    OR EXISTS (
                        SELECT 1 FROM dbo.Adherents a
                        INNER JOIN dbo.Polices p ON a.FK_Police_Id = p.Id
                        INNER JOIN dbo.UserSimulationClients usc ON p.Fk_Client_Id = usc.fk_client_id
                        WHERE a.FK_User_Id = u.Id AND usc.fk_user_id = @FK_User_Id
                    )
                ) THEN 1
                ELSE 0
            END AS canManage
        FROM dbo.sysUser u
        WHERE @IsAdmin = 1 
           OR (@IsCommercial = 1 AND u.Nature = 'C')
        ORDER BY u.Nom;
    END
    ELSE
    BEGIN
        RAISERROR('Action non autorisee', 16, 1);
    END
END
GO



CREATE OR ALTER PROCEDURE [dbo].[ps_GetStatsByPolice]
    @FK_User_Id   INT,
    @Token        VARCHAR(MAX),
    @Source       VARCHAR(50),
    @FK_Police_Id INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @UserNature CHAR(1);
    SELECT @UserNature = Nature FROM dbo.sysUser WHERE Id = @FK_User_Id;

    IF NOT EXISTS (
        SELECT 1 FROM dbo.Polices p
        LEFT JOIN dbo.Clients c ON p.Fk_Client_Id = c.Id
        OUTER APPLY (
            SELECT TOP 1 x.FK_User_Id
            FROM dbo.UsersXClients x
            WHERE x.FK_User_Id = @FK_User_Id
              AND x.Actif = 'O'
              AND (x.FK_Client_Id = c.Id OR x.FK_Client_Id = c.Fk_Client_Id)
        ) uxc
        WHERE p.Id = @FK_Police_Id
          AND (
              (@Source = 'A' AND @UserNature IN ('A'))
              OR (uxc.FK_User_Id IS NOT NULL AND ((@Source = 'M' AND c.Particulier = 'O') OR (@Source = 'E' AND c.Particulier = 'N')))
              OR EXISTS (SELECT 1 FROM dbo.Adherents WHERE FK_Police_Id = p.Id AND FK_User_Id = @FK_User_Id AND Actif = 'O')
          )
    )
    BEGIN
        RAISERROR('Acces refuse a cette police', 16, 1);
        RETURN;
    END

    DECLARE @PrimeAnnuelle DECIMAL(18,2) = 0;
    DECLARE @Impayes DECIMAL(18,2) = 0;
    DECLARE @NbRisques INT = 0;
    DECLARE @NbAdherents INT = 0;
    DECLARE @NbSinistres INT = 0;
    DECLARE @NbSinistresEnCours INT = 0;
    DECLARE @PBistime DECIMAL(18,2) = 0;
    DECLARE @bp DECIMAL(18,2) = 0;
    DECLARE @bpconsome DECIMAL(18,2) = 0;

    SELECT 
        @PBistime = ISNULL(PBistime, 0),
        @bp = ISNULL(bp, 0),
        @bpconsome = ISNULL(bpconsome, 0)
    FROM dbo.Polices
    WHERE Id = @FK_Police_Id;

    SELECT @PrimeAnnuelle = ISNULL(SUM(Montant), 0)
    FROM dbo.Quittances 
    WHERE FK_Police_Id = @FK_Police_Id;

    SELECT @Impayes = ISNULL(SUM(Solde), 0)
    FROM dbo.Quittances 
    WHERE FK_Police_Id = @FK_Police_Id 
      AND Solde > 0;

    SELECT @NbRisques = COUNT(*)
    FROM dbo.Risques 
    WHERE FK_Police_Id = @FK_Police_Id 
      AND Statut = 'O';

    SELECT @NbAdherents = COUNT(*)
    FROM dbo.Adherents 
    WHERE FK_Police_Id = @FK_Police_Id;

    SELECT @NbSinistres = COUNT(*)
    FROM dbo.Sinistres s
    WHERE s.FK_Police_Id = @FK_Police_Id;
    
    SELECT @NbSinistresEnCours = COUNT(*)
    FROM dbo.Sinistres s
    WHERE s.FK_Police_Id = @FK_Police_Id 
      AND s.Statut = 'E';

    SELECT 
        @PrimeAnnuelle AS primeAnnuelle,
        @Impayes AS impayes,
        @NbRisques AS nbRisques,
        @NbAdherents AS nbAdherents,
        @NbSinistres AS nbSinistres,
        @NbSinistresEnCours AS nbSinistresEnCours,
        @PBistime AS PBistime,
        @bp AS bp,
        @bpconsome AS bpconsome;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_DeleteReclamation
    @FK_User_Id        INT,
    @Source            CHAR(1),
    @Token             VARCHAR(MAX),
    @FK_Reclamation_Id INT
AS
BEGIN
    SET NOCOUNT ON;
    
    IF NOT EXISTS (SELECT 1 FROM dbo.sysUser WHERE Id = @FK_User_Id AND token = @Token)
    BEGIN
        RAISERROR('Session expiree', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM dbo.ReclamationsIdt WHERE Id = @FK_Reclamation_Id AND (@Source IN ('E', 'M') OR FK_User_Client = @FK_User_Id))
    BEGIN
        DELETE FROM dbo.ReclamationsDet WHERE FK_Reclamation_Id = @FK_Reclamation_Id;
        DELETE FROM dbo.ReclamationsIdt WHERE Id = @FK_Reclamation_Id;
        RETURN;
    END
    
    RAISERROR('Action non autorisee', 16, 1);
    RETURN;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_GetReclamationStatut
    @ReclamationId INT
AS
BEGIN
    SELECT Statut FROM dbo.ReclamationsIdt WHERE Id = @ReclamationId;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_UpdateToken
    @Token  VARCHAR(MAX),
    @IdAuth VARCHAR(255)
AS
BEGIN
    UPDATE dbo.sysUser SET token = @Token, UpdatedAt = GETDATE() WHERE Id_Auth = @IdAuth;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_GetUserInfoByAuthId
    @IdAuth VARCHAR(255)
AS
BEGIN
    DECLARE @FK_User_Id INT;
    DECLARE @UserNature CHAR(1);
    DECLARE @canReclaim CHAR(1) = 'N';
    
    SELECT @FK_User_Id = Id, @UserNature = Nature 
    FROM dbo.sysUser 
    WHERE Id_Auth = @IdAuth;

    IF @UserNature IN ('A')
    BEGIN
        SET @canReclaim = 'O';
    END
    ELSE IF EXISTS (SELECT 1 FROM dbo.Adherents WHERE FK_User_Id = @FK_User_Id AND Actif = 'O')
    BEGIN
        IF EXISTS (
            SELECT 1 
            FROM dbo.Adherents a
            INNER JOIN dbo.Polices p ON a.FK_Police_Id = p.Id
            INNER JOIN dbo.Clients c ON p.FK_Client_Id = c.Id
            WHERE a.FK_User_Id = @FK_User_Id AND a.Actif = 'O' AND c.recAdh = 'O'
        )
        BEGIN
            SET @canReclaim = 'O';
        END
    END
    ELSE IF EXISTS (SELECT 1 FROM dbo.UsersXClients WHERE FK_User_Id = @FK_User_Id AND Actif = 'O')
    BEGIN
        IF EXISTS (
            SELECT 1 
            FROM dbo.UsersXClients uxc
            INNER JOIN dbo.Clients c ON uxc.FK_Client_Id = c.Id
            WHERE uxc.FK_User_Id = @FK_User_Id AND uxc.Actif = 'O' AND c.recClt = 'O'
        )
        BEGIN
            SET @canReclaim = 'O';
        END
    END

    SELECT 
        Id AS id, 
        Nom AS nom, 
        CASE 
            WHEN CHARINDEX('@', Email) > 1 
            THEN STUFF(Email, 2, CHARINDEX('@', Email) - 2, '*****') 
            ELSE Email 
        END AS email, 
        Mobile AS mobile, 
        Extranet AS extranet,
        @canReclaim AS reclamation
    FROM dbo.sysUser 
    WHERE Id_Auth = @IdAuth;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_GetUserByAuthId
    @IdAuth VARCHAR(255)
AS
BEGIN
    SELECT Id AS id, token, Extranet AS extranet, Mobile AS mobile 
    FROM dbo.sysUser 
    WHERE Id_Auth = @IdAuth;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_DeleteMessageReclamation
    @FK_User_Id INT,
    @Token      VARCHAR(MAX),
    @MessageId  INT
AS
BEGIN
    SET NOCOUNT ON;
    
    IF NOT EXISTS (SELECT 1 FROM dbo.sysUser WHERE Id = @FK_User_Id AND token = @Token)
    BEGIN
        RAISERROR('Session expiree', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM dbo.ReclamationsDet WHERE Id = @MessageId AND FK_User_Id = @FK_User_Id)
    BEGIN
        RAISERROR('Non autorise a supprimer ce message', 16, 1);
        RETURN;
    END

    DECLARE @FK_Reclamation_Id INT;
    SELECT @FK_Reclamation_Id = FK_Reclamation_Id FROM dbo.ReclamationsDet WHERE Id = @MessageId;

    IF EXISTS (SELECT 1 FROM dbo.ReclamationsDet WHERE FK_Reclamation_Id = @FK_Reclamation_Id AND Id > @MessageId)
    BEGIN
        RAISERROR('Impossible de supprimer : ce n''est pas le dernier message', 16, 1);
        RETURN;
    END

    DELETE FROM dbo.ReclamationsDet WHERE Id = @MessageId;
    RETURN;
END
GO

CREATE OR ALTER PROCEDURE dbo.ps_LinkUserToClient
    @FK_User_Id        INT,
    @Token             VARCHAR(MAX),
    @Source            VARCHAR(50),
    @FK_Target_User_Id INT,
    @FK_Client_Id      INT,
    @Role              VARCHAR(50) = 'admin_cabinet'   -- Nouveau param
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @UserNature CHAR(1);
    SELECT @UserNature = Nature FROM dbo.sysUser WHERE Id = @FK_User_Id;

    -- Admin cabinet OU commercial cabinet
    IF NOT (@Source = 'A' AND (
        @UserNature IN ('A')
        OR EXISTS (SELECT 1 FROM dbo.Roles WHERE FK_User_Id = @FK_User_Id AND Role IN ('admin_cabinet','commercial_cabinet','COMMERCIAL'))
    ))
    BEGIN
        RAISERROR('Action non autorisee', 16, 1);
        RETURN;
    END

    -- Commercial : vérifier que le client est dans ses clients de simulation
    IF @Role = 'commercial_cabinet'
    BEGIN
        IF NOT EXISTS (
            SELECT 1 FROM dbo.UserSimulationClients 
            WHERE fk_user_id = @FK_User_Id AND fk_client_id = @FK_Client_Id
        )
        BEGIN
            RAISERROR('Acces refuse : ce client ne fait pas partie de vos clients assignes', 16, 1);
            RETURN;
        END
    END

    IF EXISTS (SELECT 1 FROM dbo.UsersXClients WHERE FK_Client_Id = @FK_Client_Id AND FK_User_Id = @FK_Target_User_Id)
    BEGIN
        RAISERROR('Cet utilisateur est deja lie a ce client', 16, 1);
        RETURN;
    END

    INSERT INTO dbo.UsersXClients (FK_User_Id, FK_Client_Id, Actif)
    VALUES (@FK_Target_User_Id, @FK_Client_Id, 'O');
END
GO

CREATE OR ALTER PROCEDURE dbo.ps_UnlinkUserFromClient
    @FK_User_Id        INT,
    @Token             VARCHAR(MAX),
    @Source            VARCHAR(50),
    @FK_Target_User_Id INT,
    @FK_Client_Id      INT,
    @Role              VARCHAR(50) = 'admin_cabinet'
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @UserNature CHAR(1);
    SELECT @UserNature = Nature FROM dbo.sysUser WHERE Id = @FK_User_Id;

    -- Admin cabinet OU commercial cabinet
    IF NOT (@Source = 'A' AND (
        @UserNature IN ('A')
        OR EXISTS (SELECT 1 FROM dbo.Roles WHERE FK_User_Id = @FK_User_Id AND Role IN ('admin_cabinet','commercial_cabinet','COMMERCIAL'))
    ))
    BEGIN
        RAISERROR('Action non autorisee', 16, 1);
        RETURN;
    END

    -- Commercial : vérifier que le client est dans ses clients de simulation
    IF @Role = 'commercial_cabinet'
    BEGIN
        IF NOT EXISTS (
            SELECT 1 FROM dbo.UserSimulationClients 
            WHERE fk_user_id = @FK_User_Id AND fk_client_id = @FK_Client_Id
        )
        BEGIN
            RAISERROR('Acces refuse : ce client ne fait pas partie de vos clients assignes', 16, 1);
            RETURN;
        END
    END

    DELETE FROM dbo.UsersXClients 
    WHERE FK_User_Id = @FK_Target_User_Id AND FK_Client_Id = @FK_Client_Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.ps_LinkUserToAdherent
    @FK_User_Id        INT,
    @Token             VARCHAR(MAX),
    @Source            VARCHAR(50),
    @FK_Target_User_Id INT,
    @FK_Adherent_Id    INT,
    @Role              VARCHAR(50) = 'admin_cabinet'
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @UserNature CHAR(1);
    SELECT @UserNature = Nature FROM dbo.sysUser WHERE Id = @FK_User_Id;

    -- Admin cabinet OU commercial cabinet
    IF NOT (@Source = 'A' AND (
        @UserNature IN ('A')
        OR EXISTS (SELECT 1 FROM dbo.Roles WHERE FK_User_Id = @FK_User_Id AND Role IN ('admin_cabinet','commercial_cabinet','COMMERCIAL'))
    ))
    BEGIN
        RAISERROR('Action non autorisee', 16, 1);
        RETURN;
    END

    -- Commercial : vérifier que le client de l'adhérent est dans ses clients de simulation
    IF @Role = 'commercial_cabinet'
    BEGIN
        DECLARE @AdherentClientId INT;
        SELECT @AdherentClientId = p.Fk_Client_Id
        FROM dbo.Adherents a
        INNER JOIN dbo.Polices p ON a.FK_Police_Id = p.Id
        WHERE a.Id = @FK_Adherent_Id;

        IF NOT EXISTS (
            SELECT 1 FROM dbo.UserSimulationClients 
            WHERE fk_user_id = @FK_User_Id AND fk_client_id = @AdherentClientId
        )
        BEGIN
            RAISERROR('Acces refuse : cet adherent appartient a un client qui ne fait pas partie de vos clients assignes', 16, 1);
            RETURN;
        END
    END

    UPDATE dbo.Adherents SET FK_User_Id = @FK_Target_User_Id WHERE Id = @FK_Adherent_Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.ps_SyncKeycloak
    @FK_User_Id    INT,
    @Token         VARCHAR(MAX),
    @Source        VARCHAR(50),
    @IdToSync      INT,
    @IdAuth        VARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @UserNature CHAR(1);
    SELECT @UserNature = Nature FROM dbo.sysUser WHERE Id = @FK_User_Id;

    DECLARE @IsAdmin BIT = 0;
    DECLARE @IsCommercial BIT = 0;

    IF EXISTS (SELECT 1 FROM dbo.Roles WHERE FK_User_Id = @FK_User_Id AND Role = 'admin_cabinet')
    BEGIN
        SET @IsAdmin = 1;
    END
    ELSE IF EXISTS (SELECT 1 FROM dbo.Roles WHERE FK_User_Id = @FK_User_Id AND Role = 'commercial_cabinet')
    BEGIN
        SET @IsCommercial = 1;
    END
    ELSE IF @UserNature = 'A'
    BEGIN
        SET @IsAdmin = 1;
    END

    IF NOT (@Source = 'A' AND (@IsAdmin = 1 OR @IsCommercial = 1))
    BEGIN
        RAISERROR('Action non autorisee', 16, 1);
        RETURN;
    END

    -- Si commercial, vérifier qu'il a le droit de gérer l'utilisateur (créateur ou simulation)
    IF @IsAdmin = 0 AND @IsCommercial = 1
    BEGIN
        IF NOT (
            EXISTS (SELECT 1 FROM dbo.sysUser WHERE Id = @IdToSync AND CreatedBy = @FK_User_Id)
            OR EXISTS (
                SELECT 1 FROM dbo.UsersXClients uxc
                INNER JOIN dbo.UserSimulationClients usc ON uxc.FK_Client_Id = usc.fk_client_id
                WHERE uxc.FK_User_Id = @IdToSync AND usc.fk_user_id = @FK_User_Id
            )
            OR EXISTS (
                SELECT 1 FROM dbo.Adherents a
                INNER JOIN dbo.Polices p ON a.FK_Police_Id = p.Id
                INNER JOIN dbo.UserSimulationClients usc ON p.Fk_Client_Id = usc.fk_client_id
                WHERE a.FK_User_Id = @IdToSync AND usc.fk_user_id = @FK_User_Id
            )
        )
        BEGIN
            RAISERROR('Action non autorisee : cet utilisateur n''est pas associe a votre perimetre de simulation', 16, 1);
            RETURN;
        END
    END

    UPDATE dbo.sysUser 
    SET Id_Auth = @IdAuth, UpdatedAt = GETDATE()
    WHERE Id = @IdToSync;

    SELECT 1 as success;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_GetDocumentsByPolice
    @FK_User_Id INT,
    @Source CHAR(1),
    @Token VARCHAR(MAX),
    @FK_Police_Id INT
AS
BEGIN
    SET NOCOUNT ON;
    
    IF NOT EXISTS (SELECT 1 FROM dbo.sysUser WHERE Id = @FK_User_Id AND token = @Token)
    BEGIN
        RAISERROR('Session expiree', 16, 1);
        RETURN;
    END

    DECLARE @UserNature CHAR(1);
    SELECT @UserNature = Nature FROM dbo.sysUser WHERE Id = @FK_User_Id;

    SELECT 
        d.Id AS id,
        d.fk_police_id AS fkPoliceId,
        d.fk_document_id AS fkDocumentId,
        d.libelle AS libelle
    FROM dbo.PolDocument d
    INNER JOIN dbo.Polices p ON d.fk_police_id = p.Id
    INNER JOIN dbo.Clients c ON p.Fk_Client_Id = c.Id
    OUTER APPLY (
        SELECT TOP 1 x.FK_User_Id
        FROM dbo.UsersXClients x
        WHERE x.FK_User_Id = @FK_User_Id
          AND x.Actif = 'O'
          AND (x.FK_Client_Id = c.Id OR x.FK_Client_Id = c.Fk_Client_Id)
    ) uxc
    WHERE p.Id = @FK_Police_Id
        AND (
            (@Source = 'A' AND @UserNature IN ('A'))
            OR (uxc.FK_User_Id IS NOT NULL AND ((@Source = 'M' AND c.Particulier = 'O') OR (@Source = 'E' AND c.Particulier = 'N')))
            OR EXISTS (SELECT 1 FROM dbo.Adherents WHERE FK_Police_Id = p.Id AND FK_User_Id = @FK_User_Id AND Actif = 'O')
        );
    
    RETURN;
END
GO

CREATE OR ALTER PROCEDURE dbo.ps_UpdateUserRoles
    @FK_User_Id    INT,
    @Token         VARCHAR(MAX),
    @Source        VARCHAR(50),
    @Target_User_Id INT,
    @RolesCSV      VARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @UserNature CHAR(1);
    SELECT @UserNature = Nature FROM dbo.sysUser WHERE Id = @FK_User_Id;

    IF NOT (@Source = 'A' AND @UserNature IN ('A'))
    BEGIN
        RAISERROR('Action non autorisee', 16, 1);
        RETURN;
    END

    DELETE FROM dbo.Roles WHERE FK_User_Id = @Target_User_Id;

    INSERT INTO dbo.Roles (FK_User_Id, Role)
    SELECT @Target_User_Id, value
    FROM STRING_SPLIT(@RolesCSV, ',');

    SELECT 1 as success;
END
GO

CREATE OR ALTER PROCEDURE dbo.ps_UpdateClientOptions
    @FK_User_Id    INT,
    @Token         VARCHAR(MAX),
    @Source        VARCHAR(50),
    @FK_Client_Id  INT,
    @recClt        CHAR(1),
    @recAdh        CHAR(1),
    @Role          VARCHAR(50) = 'admin_cabinet'   -- Nouveau param
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @UserNature CHAR(1);
    SELECT @UserNature = Nature FROM dbo.sysUser WHERE Id = @FK_User_Id;

    -- Admin OU commercial autorisés
    IF NOT (@Source = 'A' AND (
        @UserNature IN ('A')
        OR EXISTS (SELECT 1 FROM dbo.Roles WHERE FK_User_Id = @FK_User_Id AND Role IN ('admin_cabinet','commercial_cabinet','COMMERCIAL'))
    ))
    BEGIN
        RAISERROR('Action non autorisee', 16, 1);
        RETURN;
    END

    -- Commercial : vérifier que le client est dans ses clients de simulation
    IF @Role = 'commercial_cabinet'
    BEGIN
        IF NOT EXISTS (
            SELECT 1 FROM dbo.UserSimulationClients 
            WHERE fk_user_id = @FK_User_Id AND fk_client_id = @FK_Client_Id
        )
        BEGIN
            RAISERROR('Acces refuse : ce client ne fait pas partie de vos clients assignes', 16, 1);
            RETURN;
        END
    END

    IF NOT EXISTS (SELECT 1 FROM dbo.Clients WHERE Id = @FK_Client_Id)
    BEGIN
        RAISERROR('Client introuvable', 16, 1);
        RETURN;
    END

    UPDATE dbo.Clients
    SET recClt = @recClt,
        recAdh = @recAdh,
        UpdatedAt = GETDATE()
    WHERE Id = @FK_Client_Id;

    SELECT 1 as success;
END
GO

CREATE OR ALTER PROCEDURE dbo.ps_GetSimulationList
    @FK_User_Id INT,
    @Token      VARCHAR(MAX),
    @Source     VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    IF NOT EXISTS (SELECT 1 FROM dbo.sysUser WHERE Id = @FK_User_Id AND token = @Token)
    BEGIN
        RAISERROR('Session expiree', 16, 1);
        RETURN;
    END
    
    DECLARE @UserNature CHAR(1);
    SELECT @UserNature = Nature FROM dbo.sysUser WHERE Id = @FK_User_Id;

    IF NOT (@Source = 'A' AND (
        @UserNature IN ('A')
        OR EXISTS (SELECT 1 FROM dbo.Roles WHERE FK_User_Id = @FK_User_Id AND Role IN ('admin_cabinet','commercial_cabinet','COMMERCIAL'))
    ))
    BEGIN
        RAISERROR('Action non autorisee', 16, 1);
        RETURN;
    END

    SELECT DISTINCT
        u.Id AS id,
        u.Id_Auth AS idAuth,
        u.token,
        u.Nom AS nom,
        u.Telephone AS telephone,
        u.Email AS email,
        u.Nature AS nature,
        u.Extranet AS extranet,
        u.Mobile AS mobile,
        u.CreatedAt AS createdAt,
        u.UpdatedAt AS updatedAt,
        STUFF((
            SELECT ', ' + r.Role
            FROM dbo.Roles r
            WHERE r.FK_User_Id = u.Id
            FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS roles
    FROM dbo.sysUser u
    INNER JOIN dbo.UsersXClients uxc ON u.Id = uxc.FK_User_Id
    INNER JOIN dbo.Clients c ON uxc.FK_Client_Id = c.Id
    INNER JOIN dbo.UserSimulationClients usc ON (usc.fk_client_id = c.Id OR usc.fk_client_id = c.Fk_Client_Id)
    WHERE usc.fk_user_id = @FK_User_Id
      AND uxc.Actif = 'O'
      AND c.Particulier = 'N'  
    ORDER BY nom;
END
GO

CREATE OR ALTER PROCEDURE dbo.ps_GetUserSimulationClients
    @FK_User_Id INT,
    @Token      VARCHAR(MAX),
    @Source     VARCHAR(50),
    @Target_User_Id INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @UserNature CHAR(1);
    SELECT @UserNature = Nature FROM dbo.sysUser WHERE Id = @FK_User_Id;

    -- Admin cabinet OU commercial cabinet
    IF NOT (@Source = 'A' AND (
        @UserNature IN ('A')
        OR EXISTS (SELECT 1 FROM dbo.Roles WHERE FK_User_Id = @FK_User_Id AND Role IN ('admin_cabinet','commercial_cabinet','COMMERCIAL'))
    ))
    BEGIN
        RAISERROR('Action non autorisee', 16, 1);
        RETURN;
    END

    SELECT 
        c.Id AS id,
        c.RaisonSociale AS raisonSociale,
        c.Email AS email
    FROM dbo.UserSimulationClients usc
    INNER JOIN dbo.Clients c ON usc.fk_client_id = c.Id
    WHERE usc.fk_user_id = @Target_User_Id
    ORDER BY c.RaisonSociale;
END
GO

CREATE OR ALTER PROCEDURE dbo.ps_AddUserSimulationClient
    @FK_User_Id INT,
    @Token      VARCHAR(MAX),
    @Source     VARCHAR(50),
    @Target_User_Id INT,
    @FK_Client_Id INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @UserNature CHAR(1);
    SELECT @UserNature = Nature FROM dbo.sysUser WHERE Id = @FK_User_Id;
    IF NOT (@Source = 'A' AND @UserNature IN ('A'))
    BEGIN
        RAISERROR('Action non autorisee', 16, 1);
        RETURN;
    END
    IF EXISTS (SELECT 1 FROM dbo.UserSimulationClients WHERE fk_user_id = @Target_User_Id AND fk_client_id = @FK_Client_Id)
    BEGIN
        RAISERROR('Ce client est deja associe a cet utilisateur pour la simulation', 16, 1);
        RETURN;
    END
    IF NOT EXISTS (SELECT 1 FROM dbo.Clients WHERE Id = @FK_Client_Id AND Particulier = 'N')
    BEGIN
        RAISERROR('La simulation est uniquement disponible pour les clients entreprises (Particulier=N)', 16, 1);
        RETURN;
    END
    INSERT INTO dbo.UserSimulationClients (fk_user_id, fk_client_id)
    VALUES (@Target_User_Id, @FK_Client_Id);
END
GO

CREATE OR ALTER PROCEDURE dbo.ps_DeleteUserSimulationClient
    @FK_User_Id INT,
    @Token      VARCHAR(MAX),
    @Source     VARCHAR(50),
    @Target_User_Id INT,
    @FK_Client_Id INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @UserNature CHAR(1);
    SELECT @UserNature = Nature FROM dbo.sysUser WHERE Id = @FK_User_Id;
    IF NOT (@Source = 'A' AND @UserNature IN ('A'))
    BEGIN
        RAISERROR('Action non autorisee', 16, 1);
        RETURN;
    END
    DELETE FROM dbo.UserSimulationClients
    WHERE fk_user_id = @Target_User_Id AND fk_client_id = @FK_Client_Id;
END
GO


CREATE OR ALTER PROCEDURE dbo.sp_UploadDocument
    @FK_User_Id  INT,
    @Token       VARCHAR(MAX),
    @Nature      VARCHAR(50),
    @Identifiant INT,
    @Type        VARCHAR(255),
    @Document    VARBINARY(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.sysUser WHERE Id = @FK_User_Id AND token = @Token)
    BEGIN
        RAISERROR('Session expiree', 16, 1);
        RETURN;
    END

    INSERT INTO dbo.StdDocument (Nature, Identifiant, Type, Document, Transfere, FK_User_Id, DateCreation)
    VALUES (@Nature, @Identifiant, @Type, @Document, 'N', @FK_User_Id, GETDATE());

    SELECT SCOPE_IDENTITY() AS id;
    RETURN;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_GetDocuments
    @FK_User_Id  INT,
    @Token       VARCHAR(MAX),
    @Source      VARCHAR(10),
    @Nature      VARCHAR(50),
    @Identifiant INT,
    @DateFrom    DATE,
    @DateTo      DATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.sysUser WHERE Id = @FK_User_Id AND token = @Token)
    BEGIN
        RAISERROR('Session expiree', 16, 1);
        RETURN;
    END

    DECLARE @UserNature CHAR(1);
    SELECT @UserNature = Nature FROM dbo.sysUser WHERE Id = @FK_User_Id;

    IF NOT (@Source = 'A' AND @UserNature IN ('A'))
    BEGIN
        RAISERROR('Action non autorisee', 16, 1);
        RETURN;
    END

    SELECT
        d.Id            AS id,
        d.Nature        AS nature,
        d.Identifiant   AS identifiant,
        CASE 
            WHEN d.Nature = 'sinistre' THEN (SELECT CAST(s.NumeroSin AS VARCHAR(50)) FROM dbo.Sinistres s WHERE s.Id = d.Identifiant)
            WHEN d.Nature = 'police' THEN (SELECT p.Police FROM dbo.Polices p WHERE p.Id = d.Identifiant)
            ELSE NULL
        END             AS reference,
        d.Type          AS type,
        d.Transfere     AS transfere,
        d.DateCreation  AS dateCreation,
        u.Nom           AS utilisateur,
        u.Email         AS utilisateurEmail,
        d.FK_User_Id    AS fkUserId,
        d.TransferePar  AS transfereParId,
        ut.Nom          AS transfereParNom
    FROM dbo.StdDocument d
    INNER JOIN dbo.sysUser u ON d.FK_User_Id = u.Id
    LEFT JOIN dbo.sysUser ut ON d.TransferePar = ut.Id
    WHERE
        (@Nature IS NULL OR d.Nature = @Nature)
        AND (@Identifiant IS NULL OR d.Identifiant = @Identifiant)
        AND (@DateFrom IS NULL OR CAST(d.DateCreation AS DATE) >= @DateFrom)
        AND (@DateTo IS NULL OR CAST(d.DateCreation AS DATE) <= @DateTo)
    ORDER BY d.DateCreation DESC;

    RETURN;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_UpdateDocumentTransfere
    @FK_User_Id  INT,
    @Token       VARCHAR(MAX),
    @Source      VARCHAR(10),
    @DocumentId  INT,
    @Transfere   CHAR(1)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.sysUser WHERE Id = @FK_User_Id AND token = @Token)
    BEGIN
        RAISERROR('Session expiree', 16, 1);
        RETURN;
    END

    DECLARE @UserNature CHAR(1);
    SELECT @UserNature = Nature FROM dbo.sysUser WHERE Id = @FK_User_Id;

    IF NOT (@Source = 'A' AND @UserNature IN ('A'))
    BEGIN
        RAISERROR('Action non autorisee', 16, 1);
        RETURN;
    END

    UPDATE dbo.StdDocument
    SET Transfere = @Transfere,
        TransferePar = CASE WHEN @Transfere = 'O' THEN @FK_User_Id ELSE NULL END
    WHERE Id = @DocumentId;

    SELECT @@ROWCOUNT AS affectedRows;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_GetDocumentById
    @FK_User_Id  INT,
    @Token       VARCHAR(MAX),
    @Source      VARCHAR(10),
    @DocumentId  INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.sysUser WHERE Id = @FK_User_Id AND token = @Token)
    BEGIN
        RAISERROR('Session expiree', 16, 1);
        RETURN;
    END

    DECLARE @UserNature CHAR(1);
    SELECT @UserNature = Nature FROM dbo.sysUser WHERE Id = @FK_User_Id;

    IF EXISTS (
        SELECT 1 FROM dbo.StdDocument
        WHERE Id = @DocumentId
          AND (
              (@Source = 'A' AND @UserNature IN ('A'))
              OR FK_User_Id = @FK_User_Id
          )
    )
    BEGIN
        SELECT
            d.Id            AS id,
            d.Nature        AS nature,
            d.Identifiant   AS identifiant,
            d.Type          AS type,
            d.Document      AS document,
            d.Transfere     AS transfere,
            d.DateCreation  AS dateCreation
        FROM dbo.StdDocument d
        WHERE d.Id = @DocumentId;

        RETURN;
    END

    RAISERROR('Document introuvable ou accès refusé', 16, 1);
    RETURN;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_DeleteDocument
    @FK_User_Id INT,
    @Token      VARCHAR(MAX),
    @Source     VARCHAR(10),
    @DocumentId INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.sysUser WHERE Id = @FK_User_Id AND token = @Token)
    BEGIN
        RAISERROR('Session expiree', 16, 1);
        RETURN;
    END

    DECLARE @UserNature CHAR(1);
    SELECT @UserNature = Nature FROM dbo.sysUser WHERE Id = @FK_User_Id;

    IF NOT (@Source = 'A' AND @UserNature IN ('A'))
    BEGIN
        RAISERROR('Action non autorisee', 16, 1);
        RETURN;
    END

    DELETE FROM dbo.StdDocument WHERE Id = @DocumentId;
END
GO

CREATE OR ALTER FUNCTION dbo.fn_ParseITTJours (@ITT VARCHAR(255))
RETURNS INT
WITH SCHEMABINDING
AS
BEGIN
    RETURN ISNULL(
        TRY_CAST(
            SUBSTRING(
                @ITT,
                1,
                CASE
                    WHEN CHARINDEX(' ', @ITT) > 0 THEN CHARINDEX(' ', @ITT) - 1
                    ELSE LEN(@ITT)
                END
            ) AS INT
        ),
        0
    );
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_CheckSessionAndPoliceAccess
    @FK_User_Id   INT,
    @Token        VARCHAR(MAX),
    @Source       CHAR(1),
    @FK_Police_Id INT,
    @Result       INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1 FROM dbo.sysUser
        WHERE Id = @FK_User_Id AND token = @Token
    )
    BEGIN
        SET @Result = 1;
        RETURN;
    END

    DECLARE @UserNature CHAR(1);
    SELECT @UserNature = Nature FROM dbo.sysUser WHERE Id = @FK_User_Id;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.Polices p
        LEFT JOIN dbo.Clients c
            ON p.Fk_Client_Id = c.Id
        OUTER APPLY (
            SELECT TOP 1 x.FK_User_Id
            FROM dbo.UsersXClients x
            WHERE x.FK_User_Id = @FK_User_Id
              AND x.Actif = 'O'
              AND (x.FK_Client_Id = c.Id OR x.FK_Client_Id = c.Fk_Client_Id)
        ) uxc
        WHERE p.Id = @FK_Police_Id
          AND (
              (@Source = 'A' AND @UserNature IN ('A'))
              OR (
                  uxc.FK_User_Id IS NOT NULL
                  AND (
                      (@Source = 'M' AND c.Particulier = 'O')
                      OR (@Source = 'E' AND c.Particulier = 'N')
                  )
              )
              OR EXISTS (
                  SELECT 1 FROM dbo.Adherents
                  WHERE FK_Police_Id = p.Id
                    AND FK_User_Id   = @FK_User_Id
                    AND Actif        = 'O'
              )
          )
    )
    BEGIN
        SET @Result = 2;
        RETURN;
    END

    SET @Result = 0;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_GetStatsKPIs
    @FK_User_Id   INT,
    @Source       CHAR(1),
    @Token        VARCHAR(MAX),
    @FK_Police_Id INT,
    @Date_Du      DATE,
    @Date_Au      DATE
AS
BEGIN
    SET NOCOUNT ON;

    IF @Date_Du > @Date_Au
    BEGIN
        THROW 50001, 'La date de debut ne peut pas etre superieure a la date de fin.', 1;
        RETURN;
    END

    DECLARE @CheckResult INT;
    EXEC dbo.sp_CheckSessionAndPoliceAccess
        @FK_User_Id   = @FK_User_Id,
        @Token        = @Token,
        @Source       = @Source,
        @FK_Police_Id = @FK_Police_Id,
        @Result       = @CheckResult OUTPUT;

    IF @CheckResult = 1
    BEGIN
        THROW 50002, 'Session expiree.', 1;
        RETURN;
    END
    IF @CheckResult = 2
    BEGIN
        THROW 50003, 'Acces refuse a cette police.', 1;
        RETURN;
    END

    BEGIN TRY
        SELECT
            COUNT(*)                                                        AS nbSinistresTotal,
            ISNULL(SUM(sc.COUT_TOT), 0)                                    AS coutTotal,
            CASE
                WHEN COUNT(*) > 0
                THEN ISNULL(SUM(sc.COUT_TOT), 0) / COUNT(*)
                ELSE 0
            END                                                             AS coutMoyen,
            SUM(dbo.fn_ParseITTJours(sc.ITT))                              AS totalJoursITT,
            SUM(CASE WHEN dbo.fn_ParseITTJours(sc.ITT) > 0 THEN 1 ELSE 0 END)
                                                                            AS nbSinistresWithITT,
            CASE
                WHEN COUNT(*) > 0
                THEN (CAST(SUM(CASE WHEN dbo.fn_ParseITTJours(sc.ITT) > 0 THEN 1 ELSE 0 END)
                      AS DECIMAL(18,2)) / COUNT(*)) * 100.0
                ELSE 0.0
            END                                                             AS tauxITT,
            CASE
                WHEN SUM(CASE WHEN dbo.fn_ParseITTJours(sc.ITT) > 0 THEN 1 ELSE 0 END) > 0
                THEN SUM(dbo.fn_ParseITTJours(sc.ITT))
                     / SUM(CASE WHEN dbo.fn_ParseITTJours(sc.ITT) > 0 THEN 1 ELSE 0 END)
                ELSE 0
            END                                                             AS dureeMoyenneITT,
            ISNULL(SUM(sc.Montant_indem), 0)                               AS mntITTTotal,
            SUM(CASE
                    WHEN ISNULL(sc.IPP_Retenu, 0) > 0
                      OR ISNULL(sc.IPP_EVA, 0)    > 0
                    THEN 1 ELSE 0
                END)                                                        AS nbSinistresWithIPP,
            ISNULL(SUM(sc.CCR_EV), 0)                                      AS ccrTotal
        FROM dbo.Sinistres s
        LEFT JOIN dbo.sinComplement sc ON s.Id = sc.fk_sinistre_id
        WHERE s.FK_Police_Id = @FK_Police_Id
          AND s.DateSin BETWEEN @Date_Du AND @Date_Au;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_GetStatsEvolutionAnnuelle
    @FK_User_Id   INT,
    @Source       CHAR(1),
    @Token        VARCHAR(MAX),
    @FK_Police_Id INT,
    @Date_Du      DATE,
    @Date_Au      DATE
AS
BEGIN
    SET NOCOUNT ON;

    IF @Date_Du > @Date_Au
    BEGIN
        THROW 50001, 'La date de debut ne peut pas etre superieure a la date de fin.', 1;
        RETURN;
    END

    DECLARE @CheckResult INT;
    EXEC dbo.sp_CheckSessionAndPoliceAccess
        @FK_User_Id   = @FK_User_Id,
        @Token        = @Token,
        @Source       = @Source,
        @FK_Police_Id = @FK_Police_Id,
        @Result       = @CheckResult OUTPUT;

    IF @CheckResult = 1 THROW 50002, 'Session expiree.', 1;
    IF @CheckResult = 2 THROW 50003, 'Acces refuse a cette police.', 1;

    BEGIN TRY
        SELECT
            YEAR(s.DateSin)                                                 AS annee,
            COUNT(*)                                                        AS nbSinistres,
            ISNULL(SUM(sc.COUT_TOT), 0)                                    AS coutTotal,
            SUM(CASE WHEN dbo.fn_ParseITTJours(sc.ITT) > 0 THEN 1 ELSE 0 END)
                                                                            AS nbITT,
            CASE
                WHEN COUNT(*) > 0
                THEN (CAST(SUM(CASE WHEN dbo.fn_ParseITTJours(sc.ITT) > 0 THEN 1 ELSE 0 END)
                      AS DECIMAL(18,2)) / COUNT(*)) * 100.0
                ELSE 0.0
            END                                                             AS tauxITT,
            SUM(dbo.fn_ParseITTJours(sc.ITT))                              AS joursITT,
            ISNULL(SUM(sc.Montant_indem), 0)                               AS mntITT
        FROM dbo.Sinistres s
        LEFT JOIN dbo.sinComplement sc ON s.Id = sc.fk_sinistre_id
        WHERE s.FK_Police_Id = @FK_Police_Id
          AND s.DateSin BETWEEN @Date_Du AND @Date_Au
        GROUP BY YEAR(s.DateSin)
        ORDER BY YEAR(s.DateSin) ASC;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_GetStatsTop5ITT
    @FK_User_Id   INT,
    @Source       CHAR(1),
    @Token        VARCHAR(MAX),
    @FK_Police_Id INT,
    @Date_Du      DATE,
    @Date_Au      DATE
AS
BEGIN
    SET NOCOUNT ON;

    IF @Date_Du > @Date_Au
    BEGIN
        THROW 50001, 'La date de debut ne peut pas etre superieure a la date de fin.', 1;
        RETURN;
    END

    DECLARE @CheckResult INT;
    EXEC dbo.sp_CheckSessionAndPoliceAccess
        @FK_User_Id   = @FK_User_Id,
        @Token        = @Token,
        @Source       = @Source,
        @FK_Police_Id = @FK_Police_Id,
        @Result       = @CheckResult OUTPUT;

    IF @CheckResult = 1 THROW 50002, 'Session expiree.', 1;
    IF @CheckResult = 2 THROW 50003, 'Acces refuse a cette police.', 1;

    BEGIN TRY
        WITH CTE_ITT AS (
            SELECT
                YEAR(s.DateSin)              AS annee,
                ISNULL(sc.Victime, 'Inconnu') AS victime,
                dbo.fn_ParseITTJours(sc.ITT)  AS joursITT,
                ISNULL(sc.Montant_indem, 0)   AS mntITT,
                ISNULL(sc.COUT_TOT, 0)        AS coutTotal
            FROM dbo.Sinistres s
            INNER JOIN dbo.sinComplement sc ON s.Id = sc.fk_sinistre_id
            WHERE s.FK_Police_Id = @FK_Police_Id
              AND s.DateSin BETWEEN @Date_Du AND @Date_Au
        )
        SELECT TOP 5
            annee,
            victime,
            joursITT,
            mntITT,
            coutTotal
        FROM CTE_ITT
        WHERE joursITT > 0
        ORDER BY joursITT DESC;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_GetStatsRepartition
    @FK_User_Id   INT,
    @Source       CHAR(1),
    @Token        VARCHAR(MAX),
    @FK_Police_Id INT,
    @Date_Du      DATE,
    @Date_Au      DATE
AS
BEGIN
    SET NOCOUNT ON;

    IF @Date_Du > @Date_Au
    BEGIN
        THROW 50001, 'La date de debut ne peut pas etre superieure a la date de fin.', 1;
        RETURN;
    END

    DECLARE @CheckResult INT;
    EXEC dbo.sp_CheckSessionAndPoliceAccess
        @FK_User_Id   = @FK_User_Id,
        @Token        = @Token,
        @Source       = @Source,
        @FK_Police_Id = @FK_Police_Id,
        @Result       = @CheckResult OUTPUT;

    IF @CheckResult = 1 THROW 50002, 'Session expiree.', 1;
    IF @CheckResult = 2 THROW 50003, 'Acces refuse a cette police.', 1;

    BEGIN TRY
        SELECT
            CASE
                WHEN sc.Circonstances LIKE '%gliss%'
                  OR sc.Circonstances LIKE '%chute%'
                  OR sc.Circonstances LIKE '%faux pas%'       THEN 'Glissage'
                WHEN sc.Circonstances LIKE '%rout%'
                  OR sc.Circonstances LIKE '%trajet%'
                  OR sc.Circonstances LIKE '%voiture%'
                  OR sc.Circonstances LIKE '%collision%'       THEN 'Accident circ.'
                WHEN sc.Circonstances LIKE '%objet%'
                  OR sc.Circonstances LIKE '%charge%'
                  OR sc.Circonstances LIKE '%choc%'            THEN 'Objet/masse mvt'
                WHEN sc.Circonstances LIKE '%robot%'
                  OR sc.Circonstances LIKE '%machine%'
                  OR sc.Circonstances LIKE '%outillage%'       THEN 'Machine'
                WHEN sc.Circonstances LIKE '%brûl%'
                  OR sc.Circonstances LIKE '%feu%'
                  OR sc.Circonstances LIKE '%explosion%'       THEN 'Autre choc'
                ELSE 'Autres'
            END AS catCirconstances,
            CASE
                WHEN sc.Lesion LIKE '%fract%'                  THEN 'Fracture'
                WHEN sc.Lesion LIKE '%plaie%'
                  OR sc.Lesion LIKE '%coupure%'
                  OR sc.Lesion LIKE '%cutan%'                  THEN 'Plaie/coupure'
                WHEN sc.Lesion LIKE '%contus%'
                  OR sc.Lesion LIKE '%choc%'                   THEN 'Contusion'
                WHEN sc.Lesion LIKE '%entors%'
                  OR sc.Lesion LIKE '%ligament%'               THEN 'Entorse'
                WHEN sc.Lesion LIKE '%brûl%'                   THEN 'Brûlures'
                WHEN sc.Lesion LIKE '%trauma%'
                  OR sc.Lesion LIKE '%lombal%'
                  OR sc.Lesion LIKE '%lumb%'                   THEN 'Traumatisme'
                ELSE 'Autres'
            END AS catLesion,
            CASE
                WHEN sc.Type_Sinistre LIKE '%trajet%' THEN 'Accident de trajet'
                ELSE 'Accident sur site'
            END AS catType
        INTO #TempBase
        FROM dbo.Sinistres s
        INNER JOIN dbo.sinComplement sc ON s.Id = sc.fk_sinistre_id
        WHERE s.FK_Police_Id = @FK_Police_Id
          AND s.DateSin BETWEEN @Date_Du AND @Date_Au;

        DECLARE @TotalCount INT;
        SELECT @TotalCount = COUNT(*) FROM #TempBase;

        SELECT
            catCirconstances AS categorie,
            COUNT(*)         AS countVal
        FROM #TempBase
        GROUP BY catCirconstances
        ORDER BY countVal DESC;

        SELECT
            catLesion AS categorie,
            COUNT(*)  AS countVal
        FROM #TempBase
        GROUP BY catLesion
        ORDER BY countVal DESC;

        SELECT
            catType                                                     AS categorie,
            COUNT(*)                                                    AS countVal,
            CASE
                WHEN @TotalCount > 0
                THEN (CAST(COUNT(*) AS DECIMAL(18,2)) / @TotalCount) * 100.0
                ELSE 0.0
            END                                                         AS pourcentage
        FROM #TempBase
        GROUP BY catType
        ORDER BY countVal DESC;

        DROP TABLE #TempBase;

    END TRY
    BEGIN CATCH
        IF OBJECT_ID('tempdb..#TempBase') IS NOT NULL DROP TABLE #TempBase;
        THROW;
    END CATCH
END;
GO

-- ============================================================
-- sp_GetAdminReclamations — Réclamations pour l'admin panel
-- @Role = 'admin_cabinet'    → toutes les réclamations
-- @Role = 'commercial_cabinet' → uniquement les réclamations
--   des clients assignés au commercial (UserSimulationClients)
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_GetAdminReclamations
    @FK_User_Id INT,
    @Source     CHAR(1),
    @Token      VARCHAR(MAX),
    @Role       VARCHAR(50) = 'admin_cabinet'
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.sysUser WHERE Id = @FK_User_Id AND token = @Token)
    BEGIN
        RAISERROR('Session expiree', 16, 1);
        RETURN;
    END

    DECLARE @UserNature CHAR(1);
    SELECT @UserNature = Nature FROM dbo.sysUser WHERE Id = @FK_User_Id;

    -- Vérification : admin cabinet OU commercial cabinet
    IF NOT (@Source = 'A' AND (
        @UserNature IN ('A')
        OR EXISTS (SELECT 1 FROM dbo.Roles WHERE FK_User_Id = @FK_User_Id AND Role IN ('admin_cabinet','commercial_cabinet','COMMERCIAL'))
    ))
    BEGIN
        RAISERROR('Action non autorisee', 16, 1);
        RETURN;
    END

    IF @Role = 'admin_cabinet' AND NOT EXISTS (SELECT 1 FROM dbo.Roles WHERE FK_User_Id = @FK_User_Id AND Role = 'commercial_cabinet')
    BEGIN
        -- Admin : toutes les réclamations
        SELECT
            r.Id                AS id,
            r.DateReclamation   AS dateReclamation,
            r.Sujet             AS sujet,
            CASE r.Statut
                WHEN 'E' THEN 'En cours'
                WHEN 'C' THEN 'Cl' + CHAR(244) + 'tur' + CHAR(233)
                ELSE r.Statut
            END                 AS statut,
            CASE r.Statut
                WHEN 'E' THEN 'warning'
                WHEN 'C' THEN 'success'
                ELSE 'neutral'
            END                 AS statut_variant,
            CASE WHEN r.Statut = 'E' THEN 1 ELSE 0 END AS is_active,
            r.DateStatut        AS dateStatut,
            CASE r.Nature
                WHEN 'R' THEN 'R' + CHAR(233) + 'clamation'
                WHEN 'D' THEN 'Demande d''info'
                WHEN 'S' THEN 'Sinistre'
                WHEN 'I' THEN 'Information'
                ELSE r.Nature
            END                 AS nature,
            u.Nom               AS client
        FROM dbo.ReclamationsIdt r
        INNER JOIN dbo.sysUser u ON r.FK_User_Client = u.Id
        ORDER BY r.DateReclamation DESC;
    END
    ELSE
    BEGIN
        -- Commercial : uniquement les réclamations des clients de simulation
        -- Un client est "du commercial" s'il est dans UserSimulationClients
        -- et que l'utilisateur ayant posé la réclamation est lié à ce client (UsersXClients)
        SELECT
            r.Id                AS id,
            r.DateReclamation   AS dateReclamation,
            r.Sujet             AS sujet,
            CASE r.Statut
                WHEN 'E' THEN 'En cours'
                WHEN 'C' THEN 'Cl' + CHAR(244) + 'tur' + CHAR(233)
                ELSE r.Statut
            END                 AS statut,
            CASE r.Statut
                WHEN 'E' THEN 'warning'
                WHEN 'C' THEN 'success'
                ELSE 'neutral'
            END                 AS statut_variant,
            CASE WHEN r.Statut = 'E' THEN 1 ELSE 0 END AS is_active,
            r.DateStatut        AS dateStatut,
            CASE r.Nature
                WHEN 'R' THEN 'R' + CHAR(233) + 'clamation'
                WHEN 'D' THEN 'Demande d''info'
                WHEN 'S' THEN 'Sinistre'
                WHEN 'I' THEN 'Information'
                ELSE r.Nature
            END                 AS nature,
            u.Nom               AS client
        FROM dbo.ReclamationsIdt r
        INNER JOIN dbo.sysUser u ON r.FK_User_Client = u.Id
        WHERE
            -- Cas 1 : réclamation d'un client (entreprise ou particulier) lié au commercial
            EXISTS (
                SELECT 1
                FROM dbo.UsersXClients uxc
                INNER JOIN dbo.UserSimulationClients usc
                    ON usc.fk_client_id = uxc.FK_Client_Id
                WHERE uxc.FK_User_Id = r.FK_User_Client
                  AND usc.fk_user_id = @FK_User_Id
            )
            OR
            -- Cas 2 : réclamation d'un adhérent dont la police est liée à un client du commercial
            EXISTS (
                SELECT 1
                FROM dbo.Adherents a
                INNER JOIN dbo.Polices p ON a.FK_Police_Id = p.Id
                INNER JOIN dbo.UserSimulationClients usc ON usc.fk_client_id = p.Fk_Client_Id
                WHERE a.FK_User_Id = r.FK_User_Client
                  AND usc.fk_user_id = @FK_User_Id
            )
        ORDER BY r.DateReclamation DESC;
    END

    RETURN;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_GetUserById
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.sysUser WHERE Id = @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_UpdateTokenById
    @Token VARCHAR(MAX),
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.sysUser 
    SET token = @Token, 
        UpdatedAt = GETDATE() 
    WHERE Id = @Id;
END
GO

CREATE OR ALTER PROCEDURE dbo.ps_CheckSimulationPermission
    @AdminId INT,
    @TargetUserId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 1 WHERE EXISTS (
        SELECT 1 
        FROM dbo.sysUser targetUser
        LEFT JOIN dbo.UsersXClients uxc ON targetUser.Id = uxc.FK_User_Id AND uxc.Actif = 'O'
        LEFT JOIN dbo.Adherents a ON targetUser.Id = a.FK_User_Id AND a.Actif = 'O'
        LEFT JOIN dbo.Polices p ON a.FK_Police_Id = p.Id
        LEFT JOIN dbo.Clients c ON c.Id = COALESCE(uxc.FK_Client_Id, p.Fk_Client_Id)
        INNER JOIN dbo.UserSimulationClients usc ON (usc.fk_client_id = c.Id OR usc.fk_client_id = c.Fk_Client_Id)
        WHERE targetUser.Id = @TargetUserId AND usc.fk_user_id = @AdminId
    );
END
GO
