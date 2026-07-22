@echo off
setlocal enabledelayedexpansion

:: ================= CONFIG =================
set "KEYCLOAK_URL=http://localhost:8180"
set "ADMIN_USER=Abdessamad.yalid"
set /p ADMIN_PASS=Mot de passe : 

set "REALM_NAME=MyASK"
set "CLIENT_ADMIN=client_admin"
set "CLIENT_EXTRANET=client_extranet"
set "CLIENT_MOBILE=client_mobile"
set "CLIENT_API=client_api"
set "CLIENT_API_SECRET=5LMx5RWmWVefy4APRBqp0SjLethYoJ6L"

set "REDIRECT_ADMIN=http://105.155.251.73:3443/*"
set "REDIRECT_EXTRANET=http://105.155.251.73:4443/*"
set "REDIRECT_MOBILE=assurplus://*"

set "KCADM_PATH=C:\keycloak\bin\kcadm.bat"
:: ================= SMTP CONFIG =================
:: Configuration Microsoft 365 / Office 365
set "SMTP_HOST=smtp.office365.com"
set "SMTP_PORT=587"
:: Renseignez vos identifiants ci-dessous :
set "SMTP_FROM=noreplay@askassurace.ma"
set "SMTP_USER=noreplay@askassurace.ma"
set "SMTP_PASS=KQxcq975"
set "SMTP_FROM_DISPLAY=MyASK"

cls
echo ------------------------------------------------------------
echo KEYCLOAK AUTO CONFIG : %REALM_NAME%
echo ------------------------------------------------------------

:STEP1
echo [1/6] Authentification...
call "%KCADM_PATH%" config credentials --server %KEYCLOAK_URL% --realm master --user %ADMIN_USER% --password %ADMIN_PASS% >nul 2>&1
if %ERRORLEVEL% NEQ 0 echo [ERREUR] Connexion echouee. & pause & exit /b 1
echo OK

:STEP2
echo [2/6] Configuration du Realm...
call "%KCADM_PATH%" get realms/%REALM_NAME% >nul 2>&1
if %ERRORLEVEL% EQU 0 goto :REALM_EXISTS
call "%KCADM_PATH%" create realms -s realm=%REALM_NAME% -s enabled=true -s resetPasswordAllowed=true -s editUsernameAllowed=false -s verifyEmail=true >nul
echo Realm %REALM_NAME% cree.
goto :STEP3
:REALM_EXISTS
echo Realm %REALM_NAME% existe deja (IGNORER).

:STEP3
echo [3/6] Configuration des Roles...
call :CREATE_ROLE admin_cabinet
call :CREATE_ROLE commercial_cabinet
call :CREATE_ROLE client
call :CREATE_ROLE adherent
echo Roles OK.

:STEP4
echo [4/6] Configuration des Clients...
call :CREATE_CLIENT "%CLIENT_ADMIN%" "%REDIRECT_ADMIN%" true
call :CREATE_CLIENT "%CLIENT_EXTRANET%" "%REDIRECT_EXTRANET%" true
call :CREATE_CLIENT "%CLIENT_MOBILE%" "%REDIRECT_MOBILE%" true

call "%KCADM_PATH%" get clients -r %REALM_NAME% > tmp_clients.json 2>nul
findstr /C:"\"clientId\" : \"%CLIENT_API%\"" tmp_clients.json >nul
set "FIND_ERR=%ERRORLEVEL%"
del tmp_clients.json 2>nul
if %FIND_ERR% EQU 0 goto :SKIP_CLIENT_API
echo Creation du client API...
call "%KCADM_PATH%" create clients -r %REALM_NAME% -s clientId=%CLIENT_API% -s enabled=true -s publicClient=false -s serviceAccountsEnabled=true -s standardFlowEnabled=true -s clientAuthenticatorType=client-secret -s secret=%CLIENT_API_SECRET% >nul 2>&1
:SKIP_CLIENT_API
if %ERRORLEVEL% EQU 0 echo Client API OK.

:STEP5
echo [5/6] Configuration SMTP et Securite...
:: Configuration du serveur SMTP, Securite de production
if not "%SMTP_HOST%"=="" (
    call "%KCADM_PATH%" update realms/%REALM_NAME% -s smtpServer.host=%SMTP_HOST% -s smtpServer.port=%SMTP_PORT% -s smtpServer.from=%SMTP_FROM% -s smtpServer.fromDisplayName="%SMTP_FROM_DISPLAY%" -s smtpServer.auth=true -s smtpServer.user=%SMTP_USER% -s smtpServer.password=%SMTP_PASS% -s smtpServer.starttls=true >nul 2>&1
)
call "%KCADM_PATH%" update realms/%REALM_NAME% -s verifyEmail=true -s resetPasswordAllowed=true -s editUsernameAllowed=false -s bruteForceProtected=true -s sslRequired=external -s "passwordPolicy=length(8) and digits(1) and lowerCase(1) and upperCase(1) and specialChars(1)" >nul 2>&1

:: Force les actions (Mdp, Email, 2FA) au premier login pour TOUS les nouveaux utilisateurs
echo Activation des actions requises (UPDATE_PASSWORD, VERIFY_EMAIL, CONFIGURE_TOTP)...
call "%KCADM_PATH%" update authentication/required-actions/UPDATE_PASSWORD -r %REALM_NAME% -s defaultAction=true -s enabled=true
call "%KCADM_PATH%" update authentication/required-actions/VERIFY_EMAIL -r %REALM_NAME% -s defaultAction=true -s enabled=true
call "%KCADM_PATH%" update authentication/required-actions/CONFIGURE_TOTP -r %REALM_NAME% -s defaultAction=true -s enabled=true
call "%KCADM_PATH%" update authentication/required-actions/UPDATE_PROFILE -r %REALM_NAME% -s defaultAction=false -s enabled=false
echo Actions requises OK.

:STEP6
echo [6/6] Permissions du Compte de Service (%CLIENT_API%)...
:: On recupere d'abord le username du service account (format standard: service-account-clientid)
:: On lui assigne le role 'realm-admin' du client 'realm-management' pour qu'il puisse gerer le realm via l'API
echo Assignation du role realm-admin au compte service-account-%CLIENT_API%...
call "%KCADM_PATH%" add-roles -r %REALM_NAME% --uusername service-account-%CLIENT_API% --cclientid realm-management --rolename realm-admin
if %ERRORLEVEL% EQU 0 (
    echo Role realm-admin assigne avec succes.
) else (
    echo [ERREUR] Impossible d'assigner le role realm-admin.
)

echo ------------------------------------------------------------
echo CONFIGURATION TERMINEE AVEC SUCCES
echo ------------------------------------------------------------
echo Note: Tous les nouveaux utilisateurs devront :
echo       1. Verifier leur adresse email.
echo       2. Changer leur mot de passe (8 car. min, maj, min, chiffre, special).
echo       3. Configurer l'authentification a deux facteurs (Google Authenticator).
echo ------------------------------------------------------------
pause
exit /b 0

:: ================================================================
:: SOUS-ROUTINES
:: ================================================================

:CREATE_ROLE
set "ROLE_NAME=%1"
call "%KCADM_PATH%" get roles/%ROLE_NAME% -r %REALM_NAME% >nul 2>&1
if %ERRORLEVEL% EQU 0 goto :ROLE_EXISTS
call "%KCADM_PATH%" create roles -r %REALM_NAME% -s name=%ROLE_NAME% >nul
echo Role %ROLE_NAME% cree avec succes.
exit /b
:ROLE_EXISTS
echo Le role %ROLE_NAME% existe deja (IGNORER).
exit /b

:CREATE_CLIENT
set "_NAME=%~1"
set "_REDIRECT=%~2"
set "_PUBLIC=%~3"
call "%KCADM_PATH%" get clients -r %REALM_NAME% > tmp_check.json 2>nul
findstr /C:"\"clientId\" : \"!_NAME!\"" tmp_check.json >nul
if %ERRORLEVEL% EQU 0 goto :CLIENT_EXISTS
call "%KCADM_PATH%" create clients -r %REALM_NAME% -s clientId=!_NAME! -s enabled=true -s publicClient=!_PUBLIC! -s "redirectUris=[\"!_REDIRECT!\"]" -s "webOrigins=[\"*\"]" -s standardFlowEnabled=true >nul 2>&1
echo Le client !_NAME! a ete cree avec succes.
del tmp_check.json
exit /b
:CLIENT_EXISTS
echo Le client !_NAME! existe deja (IGNORER).
del tmp_check.json
exit /b

:CREATE_CLIENT_ROLE
set "C_ROLE_NAME=%2"
call "%KCADM_PATH%" get clients/%1/roles/%C_ROLE_NAME% -r %REALM_NAME% >nul 2>&1
if %ERRORLEVEL% EQU 0 goto :C_ROLE_EXISTS
call "%KCADM_PATH%" create clients/%1/roles -r %REALM_NAME% -s name=%C_ROLE_NAME% >nul
echo Le role client %C_ROLE_NAME% a ete cree.
exit /b
:C_ROLE_EXISTS
echo Le role client %C_ROLE_NAME% existe deja (IGNORER).
exit /b