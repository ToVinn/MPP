@echo off
setlocal enabledelayedexpansion
title Echoes of Astra - Game Launcher

echo ========================================================
echo         ECHOES OF ASTRA - 2D ANIME FANTASY RPG
echo ========================================================
echo.

rem Dapatkan direktori proyek saat ini (portable di komputer mana saja)
set "PROJECT_DIR=%~dp0"
if "%PROJECT_DIR:~-1%"=="\" set "PROJECT_DIR=%PROJECT_DIR:~0,-1%"

set "GODOT_EXE="

rem 1. Cek apakah 'godot' ada di sistem PATH
where godot >nul 2>nul
if %errorlevel% equ 0 (
    for /f "tokens=*" %%g in ('where godot') do (
        set "GODOT_EXE=%%g"
        goto :found
    )
)

rem 2. Cek apakah ada file Godot*.exe di folder proyek ini
for %%f in ("%PROJECT_DIR%\Godot*.exe") do (
    if exist "%%f" (
        set "GODOT_EXE=%%f"
        goto :found
    )
)

rem 3. Cek apakah ada file Godot*.exe di folder parent / subfolder parent
for %%f in ("%PROJECT_DIR%\..\Godot*.exe") do (
    if exist "%%f" (
        set "GODOT_EXE=%%f"
        goto :found
    )
)
for /d %%d in ("%PROJECT_DIR%\..\Godot*") do (
    for %%f in ("%%d\Godot*.exe") do (
        if exist "%%f" (
            set "GODOT_EXE=%%f"
            goto :found
        )
    )
)

rem 4. Cek di folder Downloads user saat ini
for %%f in ("%USERPROFILE%\Downloads\Godot*.exe") do (
    if exist "%%f" (
        set "GODOT_EXE=%%f"
        goto :found
    )
)
for /d %%d in ("%USERPROFILE%\Downloads\Godot*") do (
    for %%f in ("%%d\Godot*.exe") do (
        if exist "%%f" (
            set "GODOT_EXE=%%f"
            goto :found
        )
    )
)

:prompt_user
echo [INFO] Godot Engine 4 executable tidak ditemukan secara otomatis.
echo.
echo Silakan drag-and-drop file Godot.exe Anda ke jendela ini,
echo atau ketik path lengkap file Godot.exe, lalu tekan ENTER:
echo.
set /p "USER_INPUT_EXE=> "

rem Bersihkan tanda petik jika ada
set "USER_INPUT_EXE=%USER_INPUT_EXE:"=%"

if exist "%USER_INPUT_EXE%" (
    set "GODOT_EXE=%USER_INPUT_EXE%"
    goto :found
) else (
    echo.
    echo [ERROR] File tidak ditemukan di path: "%USER_INPUT_EXE%"
    echo Silakan coba lagi atau unduh Godot 4 dari https://godotengine.org
    echo.
    goto :prompt_user
)

:found
echo [SUCCESS] Menggunakan Godot Engine:
echo "!GODOT_EXE!"
echo.
echo Membuka game dari direktori:
echo "!PROJECT_DIR!"
echo.
echo Menjalankan Echoes of Astra...
echo.

rem Jalankan game dengan path direktori saat ini
start "" "!GODOT_EXE!" --path "!PROJECT_DIR!"

exit /b 0
