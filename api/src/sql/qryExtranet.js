const qry = {

    getPolices:           "exec dbo.sp_GetPolices           @0, @1, @2",
    getSinistres:         "exec dbo.sp_GetSinistres         @0, @1, @2, @3",
    getSinistresEnCours:  "exec dbo.sp_GetSinistresEncour   @0, @1, @2, @3",
    getRisques:           "exec dbo.sp_GetRisques           @0, @1, @2, @3",
    getQuittances:        "exec dbo.sp_GetQuittances        @0, @1, @2, @3",
    getImpayes:           "exec dbo.sp_GetImpayes           @0, @1, @2, @3, @4",
    getAdherents:         "exec dbo.sp_GetAdherents         @0, @1, @2, @3, @4",
    getPersACharge:       "exec dbo.sp_GetPersACharge       @0, @1, @2, @3",
    getGarantiesByRisque: "exec dbo.sp_GetGarantiesByRisque @0, @1, @2, @3",
    getStats:             "exec dbo.sp_GetStats             @0, @1, @2",
    getStatsKPIs:         "exec dbo.sp_GetStatsKPIs         @0, @1, @2, @3, @4, @5",
    getStatsEvolutionAnnuelle: "exec dbo.sp_GetStatsEvolutionAnnuelle @0, @1, @2, @3, @4, @5",
    getStatsTop5ITT:      "exec dbo.sp_GetStatsTop5ITT      @0, @1, @2, @3, @4, @5",
    getStatsTop10Victimes: "exec dbo.sp_GetStatsTop10Victimes @0, @1, @2, @3, @4, @5",
    getSyntheseSinistresAT: "exec dbo.sp_GetSyntheseSinistresAT @0",
    getStatsRepartition:  "exec dbo.sp_GetStatsRepartition  @0, @1, @2, @3, @4, @5",
    getStatsByPolice:     "exec dbo.ps_GetStatsByPolice     @0, @1, @2, @3",
    getDocumentsByPolice: "exec dbo.sp_GetDocumentsByPolice @0, @1, @2, @3",

    getReclamations:        "exec dbo.sp_GetReclamations          @0, @1, @2, @3",
    // SP admin/commercial — param @3 = rôle pour filtrer les réclamations du commercial
    getAdminReclamations:   "exec dbo.sp_GetAdminReclamations     @0, @1, @2, @3, @4",
    getReclamationDetails:  "exec dbo.sp_GetReclamationDetails    @0, @1, @2, @3",
    createReclamation:      "exec dbo.sp_CreateReclamation        @0, @1, @2, @3, @4, @5, @6",
    addMessageReclamation:  "exec dbo.sp_AddMessageReclamation    @0, @1, @2, @3, @4, @5, @6",
    updateReclamationStatut:"exec dbo.sp_UpdateReclamationStatus  @0, @1, @2, @3, @4, @5",
    deleteReclamation:      "exec dbo.sp_DeleteReclamation        @0, @1, @2, @3, @4",
    deleteMessageReclamation: "exec dbo.sp_DeleteMessageReclamation @0, @1, @2, @3",
    getReclamationStatut:   "exec dbo.sp_GetReclamationStatut @0",

    getUsers:              "exec dbo.ps_GetUsers              @0, @1, @2, @3",
    getSimulationList:     "exec dbo.ps_GetSimulationList     @0, @1, @2, @3",
    getUserSimulationClients: "exec dbo.ps_GetUserSimulationClients @0, @1, @2, @3, @4",
    addUserSimulationClient:  "exec dbo.ps_AddUserSimulationClient  @0, @1, @2, @3, @4, @5",
    deleteUserSimulationClient: "exec dbo.ps_DeleteUserSimulationClient @0, @1, @2, @3, @4, @5",
    saveUser:              "exec dbo.ps_SaveUser              @0, @1, @2, @3, @4, @5, @6, @7, @8, @9, @10, @11",
    deleteUser:            "exec dbo.ps_DeleteUser            @0, @1, @2, @3, @4",
    // @3 = role (admin_cabinet | commercial_cabinet) pour filtrer les clients du commercial
    getClients:            "exec dbo.ps_GetClients            @0, @1, @2, @3, @4",
    createUserFromClient:  "exec dbo.ps_CreateUserFromClient  @0, @1, @2, @3, @4",
    createUserFromAdherent:"exec dbo.ps_CreateUserFromAdherent @0, @1, @2, @3, @4",
    syncKeycloak:          "exec dbo.ps_SyncKeycloak           @0, @1, @2, @3, @4",
    // @5 = role pour vérification permission commercial
    linkUserToClient:      "exec dbo.ps_LinkUserToClient       @0, @1, @2, @3, @4, @5, @6",
    unlinkUserFromClient:  "exec dbo.ps_UnlinkUserFromClient   @0, @1, @2, @3, @4, @5, @6",
    linkUserToAdherent:    "exec dbo.ps_LinkUserToAdherent     @0, @1, @2, @3, @4, @5, @6",
    // @6 = role pour vérification permission commercial
    updateClientOptions:   "exec dbo.ps_UpdateClientOptions    @0, @1, @2, @3, @4, @5, @6, @7",
    updateClientEmails:    "exec dbo.ps_UpdateClientEmails     @0, @1, @2, @3, @4, @5, @6",
    updateClientParent:    "exec dbo.ps_UpdateClientParent     @0, @1, @2, @3, @4, @5, @6",

    updateToken:         "exec dbo.sp_UpdateToken @0, @1",
    getUserInfoByAuthId: "exec dbo.sp_GetUserInfoByAuthId @0",
    getUserByAuthId:     "exec dbo.sp_GetUserByAuthId @0",
    updateUserRoles:     "exec dbo.ps_UpdateUserRoles @0, @1, @2, @3, @4",

    getUserById:              "exec dbo.sp_GetUserById @0",
    updateTokenById:          "exec dbo.sp_UpdateTokenById @0, @1",
    checkSimulationPermission: "exec dbo.ps_CheckSimulationPermission @0, @1",

    getUserActiveSites: "exec dbo.sp_GetUserSites @0",
    getUserPermissions: "exec dbo.sp_GetUserSitesPermissions @0",
    getAllSites:         "exec dbo.sp_GetAllSites",
    getSiteById:        "exec dbo.sp_GetSiteById @0",
    createSite:         "exec dbo.sp_CreateSite @0, @1, @2, @3, @4",
    updateSite:         "exec dbo.sp_UpdateSite @0, @1, @2, @3, @4, @5",
    deleteSite:         "exec dbo.sp_DeleteSite @0",

    uploadDocument:          "exec dbo.sp_UploadDocument @FK_User_Id=@userId, @Token=@token, @Nature=@nature, @Identifiant=@identifiant, @Type=@type, @Document=@document, @fk_site_id=@siteId",
    getDocuments:            "exec dbo.sp_GetDocuments @FK_User_Id=@userId, @Token=@token, @Source=@source, @Nature=@nature, @Identifiant=@identifiant, @DateFrom=@dateFrom, @DateTo=@dateTo, @fk_site_id=@siteId",
    getDocumentById:         "exec dbo.sp_GetDocumentById @FK_User_Id=@userId, @Token=@token, @Source=@source, @DocumentId=@documentId",
    deleteDocument:          "exec dbo.sp_DeleteDocument @FK_User_Id=@userId, @Token=@token, @Source=@source, @DocumentId=@documentId, @fk_site_id=@siteId",
    updateDocumentTransfere: "exec dbo.sp_UpdateDocumentTransfere @FK_User_Id=@userId, @Token=@token, @Source=@source, @DocumentId=@documentId, @Transfere=@transfere, @fk_site_id=@siteId",

    getSiteRoles: "exec dbo.sp_GetSiteRoles @0",
    createSiteRole: "exec dbo.sp_CreateSiteRole @0, @1, @2",
    updateSiteRole: "exec dbo.sp_UpdateSiteRole @0, @1, @2, @3",
    deleteSiteRole: "exec dbo.sp_DeleteSiteRole @0",
    
    getSitePermissions: "exec dbo.sp_GetSitePermissions",
    
    getSiteRolePermissions: "exec dbo.sp_GetSiteRolePermissions @0",
    setSiteRolePermission: "exec dbo.sp_SetSiteRolePermission @0, @1, @2",
    
    getUserSiteRoles: "exec dbo.sp_GetUserSiteRoles @0, @1",
    assignUserSiteRole: "exec dbo.sp_AssignUserSiteRole @0, @1, @2",
    removeUserSiteRole: "exec dbo.sp_RemoveUserSiteRole @0, @1, @2",
    
    getUserPermissionsBySite: "exec dbo.sp_GetUserPermissionsBySite @0, @1"
};

module.exports = qry;