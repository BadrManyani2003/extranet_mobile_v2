USE [IBS_Extranet_Mobile];
GO

PRINT '>>> Desactivation des contraintes de cles etrangeres...';
EXEC sp_MSforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT all";
GO

PRINT '>>> Suppression des donnees existantes dans le bon ordre...';
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
DELETE FROM dbo.Roles;
UPDATE dbo.sysUser SET CreatedBy = NULL;
DELETE FROM dbo.sysUser;
DELETE FROM dbo.Compagnies;
GO

PRINT '>>> Creation de la procedure de copie securisee (avec verification des champs communs)...';
GO
CREATE OR ALTER PROCEDURE dbo.CopyTableFromR (@TableName NVARCHAR(128))
AS
BEGIN
    DECLARE @ColumnList NVARCHAR(MAX);
    DECLARE @Sql NVARCHAR(MAX);
    DECLARE @HasIdentity BIT = 0;

    -- Verification que les champs existent dans les deux bases
    SELECT @ColumnList = STRING_AGG('[' + c1.name + ']', ', ')
    FROM IBS_Extranet_Mobile_R.sys.columns c1
    INNER JOIN IBS_Extranet_Mobile.sys.columns c2 
        ON c1.name = c2.name 
        AND c1.object_id = OBJECT_ID('IBS_Extranet_Mobile_R.dbo.' + @TableName) 
        AND c2.object_id = OBJECT_ID('IBS_Extranet_Mobile.dbo.' + @TableName)
    WHERE c1.object_id = OBJECT_ID('IBS_Extranet_Mobile_R.dbo.' + @TableName);

    IF @ColumnList IS NOT NULL
    BEGIN
        SELECT @HasIdentity = 1 
        FROM IBS_Extranet_Mobile.sys.identity_columns 
        WHERE object_id = OBJECT_ID('IBS_Extranet_Mobile.dbo.' + @TableName);

        SET @Sql = '';
        
        IF @HasIdentity = 1
            SET @Sql = @Sql + 'SET IDENTITY_INSERT [IBS_Extranet_Mobile].[dbo].[' + @TableName + '] ON; ';

        SET @Sql = @Sql + 'INSERT INTO [IBS_Extranet_Mobile].[dbo].[' + @TableName + '] (' + @ColumnList + ') ';
        SET @Sql = @Sql + 'SELECT ' + @ColumnList + ' FROM [IBS_Extranet_Mobile_R].[dbo].[' + @TableName + ']; ';

        IF @HasIdentity = 1
            SET @Sql = @Sql + 'SET IDENTITY_INSERT [IBS_Extranet_Mobile].[dbo].[' + @TableName + '] OFF; ';

        PRINT '>>> Copie de la table : ' + @TableName;
        PRINT '    Champs trouves : ' + @ColumnList;
        
        BEGIN TRY
            EXEC sp_executesql @Sql;
            PRINT '    OK: Table copiee avec succes.';
        END TRY
        BEGIN CATCH
            PRINT '    ERREUR: Impossible de copier la table ' + @TableName;
            PRINT '    Message: ' + ERROR_MESSAGE();
        END CATCH
    END
    ELSE
    BEGIN
        PRINT '>>> ATTENTION: Table non trouvee ou aucun champ commun : ' + @TableName;
    END
END
GO

PRINT '>>> Debut de la copie des donnees...';
EXEC dbo.CopyTableFromR 'Compagnies';
EXEC dbo.CopyTableFromR 'sysUser';
EXEC dbo.CopyTableFromR 'Roles';
EXEC dbo.CopyTableFromR 'Postes_Autorises';
EXEC dbo.CopyTableFromR 'userConnection';
EXEC dbo.CopyTableFromR 'Clients';
EXEC dbo.CopyTableFromR 'UsersXClients';
EXEC dbo.CopyTableFromR 'UserSimulationClients';
EXEC dbo.CopyTableFromR 'Polices';
EXEC dbo.CopyTableFromR 'Risques';
EXEC dbo.CopyTableFromR 'Adherents';
EXEC dbo.CopyTableFromR 'PersACharge';
EXEC dbo.CopyTableFromR 'Quittances';
EXEC dbo.CopyTableFromR 'Sinistres';
EXEC dbo.CopyTableFromR 'sinComplement';
EXEC dbo.CopyTableFromR 'Garanties';
EXEC dbo.CopyTableFromR 'PolDocument';
EXEC dbo.CopyTableFromR 'StdDocument';
EXEC dbo.CopyTableFromR 'ReclamationsIdt';
EXEC dbo.CopyTableFromR 'ReclamationsDet';
GO

PRINT '>>> Reactivation des contraintes de cles etrangeres...';
EXEC sp_MSforeachtable "ALTER TABLE ? WITH CHECK CHECK CONSTRAINT all";
GO

PRINT '>>> Nettoyage...';
DROP PROCEDURE dbo.CopyTableFromR;
GO

PRINT '>>> Migration terminee ! Les champs ont bien ete verifies avant insertion.';
GO
