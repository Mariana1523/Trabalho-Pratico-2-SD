@echo off
color 0A
cls

echo ===================================================
echo   AUTOMATIZACAO DOS 6 TESTES P2P (WINDOWS)
echo ===================================================
echo Preparando o ambiente...
taskkill /F /IM python.exe >nul 2>&1
FOR /D %%p IN ("dados_peer_*") DO rmdir "%%p" /s /q 2>nul
echo.

:: =================================================================
:: TESTE 1: 2 PEERS | FILE A (10 KB) | BLOCO 1024
:: =================================================================
echo [TESTE 1/6] 2 PEERS - FILE A (10 KB) - BLOCO: 1024 BYTES
python p2p.py --preparar 10 --bloco 1024
start "Seeder_8000" cmd /c "title Seeder_8000 & python p2p.py --porta 8000 --vizinhos 8001 --seeder --bloco 1024"
timeout /t 2 /nobreak >nul
start "Leecher_8001" cmd /c "title Leecher_8001 & python p2p.py --porta 8001 --vizinhos 8000 --bloco 1024"
echo Aguardando download...
timeout /t 3 /nobreak >nul
taskkill /F /IM python.exe >nul 2>&1
timeout /t 1 /nobreak >nul
move dados_peer_8001 Resultado_Teste_1_File_A_10KB >nul 2>&1
FOR /D %%p IN ("dados_peer_*") DO rmdir "%%p" /s /q 2>nul
echo.

:: =================================================================
:: TESTE 2: 2 PEERS | FILE B (1 MB) | BLOCO 1024
:: =================================================================
echo [TESTE 2/6] 2 PEERS - FILE B (1 MB) - BLOCO: 1024 BYTES
python p2p.py --preparar 1024 --bloco 1024
start "Seeder_8000" cmd /c "title Seeder_8000 & python p2p.py --porta 8000 --vizinhos 8001 --seeder --bloco 1024"
timeout /t 2 /nobreak >nul
start "Leecher_8001" cmd /c "title Leecher_8001 & python p2p.py --porta 8001 --vizinhos 8000 --bloco 1024"
echo Aguardando download...
timeout /t 5 /nobreak >nul
taskkill /F /IM python.exe >nul 2>&1
timeout /t 1 /nobreak >nul
move dados_peer_8001 Resultado_Teste_2_File_B_1MB >nul 2>&1
FOR /D %%p IN ("dados_peer_*") DO rmdir "%%p" /s /q 2>nul
echo.

:: =================================================================
:: TESTE 3: 2 PEERS | FILE C (10 MB) | BLOCO 1024
:: =================================================================
echo [TESTE 3/6] 2 PEERS - FILE C (10 MB) - BLOCO: 1024 BYTES
python p2p.py --preparar 10240 --bloco 1024
start "Seeder_8000" cmd /c "title Seeder_8000 & python p2p.py --porta 8000 --vizinhos 8001 --seeder --bloco 1024"
timeout /t 2 /nobreak >nul
start "Leecher_8001" cmd /c "title Leecher_8001 & python p2p.py --porta 8001 --vizinhos 8000 --bloco 1024"
echo Aguardando download...
timeout /t 10 /nobreak >nul
taskkill /F /IM python.exe >nul 2>&1
timeout /t 1 /nobreak >nul
move dados_peer_8001 Resultado_Teste_3_File_C_10MB >nul 2>&1
FOR /D %%p IN ("dados_peer_*") DO rmdir "%%p" /s /q 2>nul
echo.

:: =================================================================
:: TESTE 4: 4 PEERS | FILE A (20 KB) | BLOCO 4096
:: =================================================================
echo [TESTE 4/6] 4 PEERS - FILE A (20 KB) - BLOCO: 4096 BYTES
python p2p.py --preparar 20 --bloco 4096
start "Seeder_8000" cmd /c "title Seeder_8000 & python p2p.py --porta 8000 --vizinhos 8001 8002 8003 --seeder --bloco 4096"
timeout /t 2 /nobreak >nul
start "Leecher_8001" cmd /c "title Leecher_8001 & python p2p.py --porta 8001 --vizinhos 8000 8002 8003 --bloco 4096"
start "Leecher_8002" cmd /c "title Leecher_8002 & python p2p.py --porta 8002 --vizinhos 8000 8001 8003 --bloco 4096"
start "Leecher_8003" cmd /c "title Leecher_8003 & python p2p.py --porta 8003 --vizinhos 8000 8001 8002 --bloco 4096"
echo Aguardando download...
timeout /t 5 /nobreak >nul
taskkill /F /IM python.exe >nul 2>&1
timeout /t 1 /nobreak >nul
move dados_peer_8001 Resultado_Teste_4_Peer_8001_20KB >nul 2>&1
move dados_peer_8002 Resultado_Teste_4_Peer_8002_20KB >nul 2>&1
move dados_peer_8003 Resultado_Teste_4_Peer_8003_20KB >nul 2>&1
FOR /D %%p IN ("dados_peer_*") DO rmdir "%%p" /s /q 2>nul
echo.

:: =================================================================
:: TESTE 5: 4 PEERS | FILE B (5 MB) | BLOCO 4096
:: =================================================================
echo [TESTE 5/6] 4 PEERS - FILE B (5 MB) - BLOCO: 4096 BYTES
python p2p.py --preparar 5120 --bloco 4096
start "Seeder_8000" cmd /c "title Seeder_8000 & python p2p.py --porta 8000 --vizinhos 8001 8002 8003 --seeder --bloco 4096"
timeout /t 2 /nobreak >nul
start "Leecher_8001" cmd /c "title Leecher_8001 & python p2p.py --porta 8001 --vizinhos 8000 8002 8003 --bloco 4096"
start "Leecher_8002" cmd /c "title Leecher_8002 & python p2p.py --porta 8002 --vizinhos 8000 8001 8003 --bloco 4096"
start "Leecher_8003" cmd /c "title Leecher_8003 & python p2p.py --porta 8003 --vizinhos 8000 8001 8002 --bloco 4096"
echo Aguardando download...
timeout /t 8 /nobreak >nul
taskkill /F /IM python.exe >nul 2>&1
timeout /t 1 /nobreak >nul
move dados_peer_8001 Resultado_Teste_5_Peer_8001_5MB >nul 2>&1
move dados_peer_8002 Resultado_Teste_5_Peer_8002_5MB >nul 2>&1
move dados_peer_8003 Resultado_Teste_5_Peer_8003_5MB >nul 2>&1
FOR /D %%p IN ("dados_peer_*") DO rmdir "%%p" /s /q 2>nul
echo.

:: =================================================================
:: TESTE 6: 4 PEERS | FILE C (20 MB) | BLOCO 4096
:: =================================================================
echo [TESTE 6/6] 4 PEERS - FILE C (20 MB) - BLOCO: 4096 BYTES
python p2p.py --preparar 20480 --bloco 4096
start "Seeder_8000" cmd /c "title Seeder_8000 & python p2p.py --porta 8000 --vizinhos 8001 8002 8003 --seeder --bloco 4096"
timeout /t 2 /nobreak >nul
start "Leecher_8001" cmd /c "title Leecher_8001 & python p2p.py --porta 8001 --vizinhos 8000 8002 8003 --bloco 4096"
start "Leecher_8002" cmd /c "title Leecher_8002 & python p2p.py --porta 8002 --vizinhos 8000 8001 8003 --bloco 4096"
start "Leecher_8003" cmd /c "title Leecher_8003 & python p2p.py --porta 8003 --vizinhos 8000 8001 8002 --bloco 4096"
echo Aguardando download (Aprox 20s)...
timeout /t 20 /nobreak >nul
taskkill /F /IM python.exe >nul 2>&1
timeout /t 1 /nobreak >nul
move dados_peer_8001 Resultado_Teste_6_Peer_8001_20MB >nul 2>&1
move dados_peer_8002 Resultado_Teste_6_Peer_8002_20MB >nul 2>&1
move dados_peer_8003 Resultado_Teste_6_Peer_8003_20MB >nul 2>&1
FOR /D %%p IN ("dados_peer_*") DO rmdir "%%p" /s /q 2>nul

echo.
echo ===================================================
echo TODOS OS TESTES FORAM CONCLUIDOS COM SUCESSO!
echo ===================================================
del /q teste.bin metadata.json 2>nul
pause