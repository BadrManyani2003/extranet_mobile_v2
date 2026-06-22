const db = require('./src/services/db.service');

const q1 = `
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
            c.Fk_Client_Id AS parentId,
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
            c.Fk_Client_Id AS parentId,
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
`;

const q2 = `
CREATE OR ALTER PROCEDURE dbo.ps_UpdateClientParent
    @FK_User_Id    INT,
    @Token         VARCHAR(MAX),
    @Source        VARCHAR(50),
    @FK_Client_Id  INT,
    @FK_Parent_Id  INT = NULL,
    @Role          VARCHAR(50) = 'admin_cabinet'
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @UserNature CHAR(1);
    SELECT @UserNature = Nature FROM dbo.sysUser WHERE Id = @FK_User_Id;

    -- Admin OU commercial
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

    -- Vérifier que le client existe
    IF NOT EXISTS (SELECT 1 FROM dbo.Clients WHERE Id = @FK_Client_Id)
    BEGIN
        RAISERROR('Client introuvable', 16, 1);
        RETURN;
    END

    -- Vérifier qu'on n'associe pas le client à lui-même
    IF @FK_Client_Id = @FK_Parent_Id
    BEGIN
        RAISERROR('Un client ne peut pas etre son propre parent', 16, 1);
        RETURN;
    END

    -- Éviter une boucle directe
    IF @FK_Parent_Id IS NOT NULL
    BEGIN
        IF EXISTS (
            SELECT 1 FROM dbo.Clients WHERE Id = @FK_Parent_Id AND Fk_Client_Id = @FK_Client_Id
        )
        BEGIN
            RAISERROR('Cette association cree une boucle de parent-enfant directe', 16, 1);
            RETURN;
        END
    END

    UPDATE dbo.Clients
    SET Fk_Client_Id = @FK_Parent_Id,
        UpdatedAt = GETDATE()
    WHERE Id = @FK_Client_Id;

    SELECT 1 as success;
END
`;

async function main() {
    try {
        console.log("Applying stored procedure ps_GetClients...");
        await db.execute(q1);
        console.log("Applying stored procedure ps_UpdateClientParent...");
        await db.execute(q2);
        console.log("Success! Both procedures applied to SQL Server database.");
        process.exit(0);
    } catch (err) {
        console.error("Error applying SQL stored procedures:", err);
        process.exit(1);
    }
}

main();
