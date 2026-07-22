@echo off
echo ============================================================
echo IBS EXTRANET MOBILE - BUILD ALL SCRIPT
echo ============================================================

echo [0] Cleaning old builds...
if exist "build" rmdir /s /q "build"
if exist "api\dist" rmdir /s /q "api\dist"
if exist "client\dist" rmdir /s /q "client\dist"
if exist "admin\dist" rmdir /s /q "admin\dist"

mkdir "build"

echo [1] Building API...
cd api
call npm run build
if %errorlevel% neq 0 (
    echo [ERROR] API build failed.
    exit /b %errorlevel%
)
cd ..
mkdir "build\api"
xcopy /E /I /Y "api\dist\*" "build\api\" >nul
if exist "api\.env.production" (
    copy /Y "api\.env.production" "build\api\.env" >nul
) else if exist "api\.env" (
    copy /Y "api\.env" "build\api\.env" >nul
)

echo [2] Building Client...
cd client
call npm run build
if %errorlevel% neq 0 (
    echo [ERROR] Client build failed.
    exit /b %errorlevel%
)
cd ..
mkdir "build\client"
xcopy /E /I /Y "client\dist\*" "build\client\" >nul
if exist "client\.env.production" (
    copy /Y "client\.env.production" "build\client\.env" >nul
) else if exist "client\.env" (
    copy /Y "client\.env" "build\client\.env" >nul
)

echo [3] Building Admin...
cd admin
call npm run build
if %errorlevel% neq 0 (
    echo [ERROR] Admin build failed.
    exit /b %errorlevel%
)
cd ..
mkdir "build\admin"
xcopy /E /I /Y "admin\dist\*" "build\admin\" >nul
if exist "admin\.env.production" (
    copy /Y "admin\.env.production" "build\admin\.env" >nul
) else if exist "admin\.env" (
    copy /Y "admin\.env" "build\admin\.env" >nul
)

echo ============================================================
echo BUILD COMPLETE.
echo The compiled files are grouped in the 'build' folder:
echo - API: build\api\
echo - Client: build\client\
echo - Admin: build\admin\
echo ============================================================

