#!/bin/bash

# ================= CONFIG =================
KEYCLOAK_URL="http://localhost:8180"
ADMIN_USER="admin"

read -s -p "Mot de passe : " ADMIN_PASS
echo ""

REALM_NAME="MyASK"
CLIENT_ADMIN="client_admin"
CLIENT_EXTRANET="client_extranet"
CLIENT_MOBILE="client_mobile"
CLIENT_API="client_api"
CLIENT_API_SECRET="5LMx5RWmWVefy4APRBqp0SjLethYoJ6L"

REDIRECT_ADMIN="\"http://localhost:5173/*\",\"http://192.168.20.110:8003/*\""
REDIRECT_EXTRANET="\"http://localhost:5174/*\",\"http://192.168.20.110:8004/*\""
REDIRECT_MOBILE="\"assurplus://*\""

# Détection automatique du chemin vers kcadm.sh
if [ -z "$KCADM_PATH" ]; then
    if command -v kcadm.sh &> /dev/null; then
        KCADM_PATH="kcadm.sh"
    elif [ -f "/opt/keycloak/bin/kcadm.sh" ]; then
        KCADM_PATH="/opt/keycloak/bin/kcadm.sh"
    elif [ -f "./kcadm.sh" ]; then
        KCADM_PATH="./kcadm.sh"
    else
        KCADM_PATH="/opt/keycloak/bin/kcadm.sh"
    fi
fi

# ================= SMTP CONFIG =================
# Configuration Microsoft 365 / Office 365
SMTP_HOST="smtp.office365.com"
SMTP_PORT="587"
# Renseignez vos identifiants ci-dessous :
SMTP_FROM="votre.email@votre-domaine.com"
SMTP_USER="votre.email@votre-domaine.com"
SMTP_PASS="votre_mot_de_passe"
SMTP_FROM_DISPLAY="MyASK"

clear
echo "------------------------------------------------------------"
echo "KEYCLOAK AUTO CONFIG : $REALM_NAME"
echo "------------------------------------------------------------"

echo "[1/6] Authentification..."
"$KCADM_PATH" config credentials --server "$KEYCLOAK_URL" --realm master --user "$ADMIN_USER" --password "$ADMIN_PASS" >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "[ERREUR] Connexion echouee."
    exit 1
fi
echo "OK"

echo "[2/6] Configuration du Realm..."
"$KCADM_PATH" get realms/"$REALM_NAME" >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "Realm $REALM_NAME existe deja (IGNORER)."
else
    "$KCADM_PATH" create realms -s realm="$REALM_NAME" -s enabled=true -s resetPasswordAllowed=true -s editUsernameAllowed=false -s verifyEmail=true >/dev/null
    echo "Realm $REALM_NAME cree."
fi

echo "[3/6] Configuration des Roles..."
CREATE_ROLE() {
    local ROLE_NAME="$1"
    "$KCADM_PATH" get roles/"$ROLE_NAME" -r "$REALM_NAME" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "Le role $ROLE_NAME existe deja (IGNORER)."
    else
        "$KCADM_PATH" create roles -r "$REALM_NAME" -s name="$ROLE_NAME" >/dev/null
        echo "Role $ROLE_NAME cree avec succes."
    fi
}

CREATE_ROLE "admin_cabinet"
CREATE_ROLE "commercial_cabinet"
CREATE_ROLE "client"
CREATE_ROLE "adherent"
echo "Roles OK."

echo "[4/6] Configuration des Clients..."
CREATE_CLIENT() {
    local NAME="$1"
    local REDIRECT="$2"
    local PUBLIC="$3"
    
    local CLIENT_UUID=$("$KCADM_PATH" get clients -r "$REALM_NAME" -q clientId="$NAME" --fields id --format csv --noquotes 2>/dev/null | tail -n +2 | tr -d '"\r\n')
    if [ -n "$CLIENT_UUID" ]; then
        echo "Le client $NAME existe deja (IGNORER)."
    else
        "$KCADM_PATH" create clients -r "$REALM_NAME" -s clientId="$NAME" -s enabled=true -s publicClient="$PUBLIC" -s "redirectUris=[$REDIRECT]" -s "webOrigins=[\"*\"]" -s standardFlowEnabled=true >/dev/null 2>&1
        echo "Le client $NAME a ete cree avec succes."
    fi
}

CREATE_CLIENT "$CLIENT_ADMIN" "$REDIRECT_ADMIN" "true"
CREATE_CLIENT "$CLIENT_EXTRANET" "$REDIRECT_EXTRANET" "true"
CREATE_CLIENT "$CLIENT_MOBILE" "$REDIRECT_MOBILE" "true"

# API Client
API_UUID=$("$KCADM_PATH" get clients -r "$REALM_NAME" -q clientId="$CLIENT_API" --fields id --format csv --noquotes 2>/dev/null | tail -n +2 | tr -d '"\r\n')
if [ -n "$API_UUID" ]; then
    echo "Client API OK (existe deja)."
else
    echo "Creation du client API..."
    "$KCADM_PATH" create clients -r "$REALM_NAME" -s clientId="$CLIENT_API" -s enabled=true -s publicClient=false -s serviceAccountsEnabled=true -s standardFlowEnabled=true -s clientAuthenticatorType=client-secret -s secret="$CLIENT_API_SECRET" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "Client API OK."
    fi
fi

echo "[5/6] Configuration SMTP et Securite..."
if [ -n "$SMTP_HOST" ]; then
    "$KCADM_PATH" update realms/"$REALM_NAME" \
        -s smtpServer.host="$SMTP_HOST" \
        -s smtpServer.port="$SMTP_PORT" \
        -s smtpServer.from="$SMTP_FROM" \
        -s smtpServer.fromDisplayName="$SMTP_FROM_DISPLAY" \
        -s smtpServer.auth=true \
        -s smtpServer.user="$SMTP_USER" \
        -s smtpServer.password="$SMTP_PASS" \
        -s smtpServer.starttls=true >/dev/null 2>&1
fi

"$KCADM_PATH" update realms/"$REALM_NAME" \
    -s verifyEmail=true \
    -s resetPasswordAllowed=true \
    -s editUsernameAllowed=false \
    -s bruteForceProtected=true \
    -s sslRequired=external \
    -s "passwordPolicy=length(8) and digits(1) and lowerCase(1) and upperCase(1) and specialChars(1)" >/dev/null 2>&1

echo "Activation des actions requises (Mdp, Email, 2FA)..."
"$KCADM_PATH" update authentication/required-actions/UPDATE_PASSWORD -r "$REALM_NAME" -s defaultAction=true -s enabled=true
"$KCADM_PATH" update authentication/required-actions/VERIFY_EMAIL -r "$REALM_NAME" -s defaultAction=true -s enabled=true
"$KCADM_PATH" update authentication/required-actions/CONFIGURE_TOTP -r "$REALM_NAME" -s defaultAction=true -s enabled=true
"$KCADM_PATH" update authentication/required-actions/UPDATE_PROFILE -r "$REALM_NAME" -s defaultAction=false -s enabled=false
echo "Actions requises OK."

echo "[6/6] Permissions du Compte de Service ($CLIENT_API)..."
echo "Assignation du role realm-admin au compte service-account-$CLIENT_API..."
"$KCADM_PATH" add-roles -r "$REALM_NAME" --uusername service-account-"$CLIENT_API" --cclientid realm-management --rolename realm-admin
if [ $? -eq 0 ]; then
    echo "Role realm-admin assigne avec succes."
else
    echo "[ERREUR] Impossible d'assigner le role realm-admin."
fi

echo "------------------------------------------------------------"
echo "CONFIGURATION TERMINEE AVEC SUCCES"
echo "------------------------------------------------------------"
echo "Note: Tous les nouveaux utilisateurs devront :"
echo "      1. Verifier leur adresse email."
echo "      2. Changer leur mot de passe (8 car. min, maj, min, chiffre, special)."
echo "      3. Configurer l'authentification a deux facteurs (Google Authenticator)."
echo "------------------------------------------------------------"
