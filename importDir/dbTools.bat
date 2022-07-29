@echo off
SET start=%time%

IF EXIST ".\sqlExecute" (
  set dir=.\
  set absolutePatch=%CD%\
  goto StartScript
)
IF EXIST ".\importDir\sqlExecute" (
  set dir=.\importDir\
  set absolutePatch=%CD%\importDir\
  goto StartScript
)
IF EXIST ".\..\importDir\sqlExecute" (
  set dir=.\..\importDir\
  set absolutePatch=%CD%\..\importDir\
  goto StartScript
)

:StartScript
IF NOT EXIST %dir%localDb (
    mkdir %dir%localDb
)
:: Set type of script execution
SET type=0
IF "%1"=="help" SET type=0
IF "%1"=="import" SET type=1
IF "%1"=="importFile" SET type=2
IF "%1"=="exportFile" SET type=3
IF "%1"=="history" SET type=4
IF "%1"=="importFileList" SET type=5
IF "%1"=="importFileClear" SET type=6
IF "%1"=="autoImport" SET type=7
IF "%1"=="enableAutoImport" SET type=8

:: Set DB name to download
SET db=%2
IF %type%==0 (
    IF NOT "%1"=="help" SET db=%1
)
IF %type%==0 (
    IF NOT "%db%"=="" SET type=1
)

:: Set limit for history
SET limit=%2
if "%limit%"=="" SET limit=10

:: Help
IF %type%==0 (
    ECHO Dostepne komendy
    ECHO ----------------------------------------------------------------------------------------------------------
    ECHO "<numer/nazwa klienta>" lub "import <numer/nazwa klienta>" - np. "dbTools.bat demo" po odpaleniu komendy otwiera sie przegladarka w ktorej logujemy sie do phpmyadmin nastepnie przechodzimy do zakladki eksport i nic nie zminiajac wykonujemy eksport do pliku sql, po pobraniu wracamy do konsoli i klikamy enter aby kontynuowac. Baza zostanie automatycznie zaimportowana z folderu pobrane w windows nastapnie usunieta z tego folderu.
    ECHO.
    ECHO "importFile <nazwa pliku>" - np. "dbTools.bat importFile demo" baza musi znajdowac sie w folderze "importDir\localDb" i miec nazwe pliku taka sama jak podajemy w skrypcie np. demo.sql
    ECHO.
    ECHO "exportFile <nazwa pliku>" - np. "dbTools.bat exportFile" demo druga czesc komendy to nazwa jaka bedzie mial nasz plik po wyeksportowaniu
    ECHO.
    ECHO "history <limit>" lub "history" - np. "dbTools.bat history 20" [domyslny limit 10] Pokazuje historie eksportu i importu baz danych na lokalny serwer
    ECHO.
    ECHO "importFileList" - pokazuje liste lokalnych plikow baz danych mozliwych do zaimportowania przy pomocy komendy dbTools.bat importFile
    ECHO.
    ECHO "importFileClear" - komenda kasuje wszystkie lokalne pliki baz danych [kasowanie lokalnych plikow nie wplywa na baze juz zaimportowana do dockera]
    ECHO.
    ECHO "autoImport <numer/nazwa klienta>" - np. "dbTools.bat autoImport demo" Automatycznie pobiera baze klienta
    ECHO.
    ECHO "enableAutoImport <login_do_phpmyadmin> <haslo_do_phpmyadmin>" - komenda tworzy plik logowania dla komendy autoImport
    ECHO.
    goto End
)
:: Import client DB from production
IF %type%==1 (
    IF EXIST %absolutePatch%autoImport\login.txt (
        SET count=0
        COPY %dir%autoImport\autoImportStart.html %dir%autoImport\tmpLogin.html >NUL
        for /f "tokens=*" %%x in (%absolutePatch%autoImport\login.txt) do call :Execute %%x
        goto startPage

        :Execute
            powershell -Command "(gc %dir%autoImport\tmpLogin.html) -replace '#%count%#', '%1' | Out-File -encoding Default %dir%autoImport\tmpLogin.html"
            set /a count+=1
            goto :eof

        :startPage
            start firefox -url "file:///%CD%%dir%autoImport\tmpLogin.html"
            goto DeleteTmpLoginFile

        :DeleteTmpLoginFile
            timeout 2 > NUL
            DEL %dir%autoImport\tmpLogin.html
    )
    start firefox "localhost:8081/db_export.php?db=%db%"

    ECHO Oczekiwanie na pobranie bazy
    PAUSE
    ECHO.

    ECHO Dodanie nazwy bazy danych
    :: Add client DB name to imported DB
    IF EXIST "\Users\%USERNAME%\Downloads\%db%.sql" (
        ECHO.>>\Users\%USERNAME%\Downloads\%db%.sql
        ECHO INSERT INTO options VALUES ^('original_account', '%db%', 'Nazwa bazy klienta pobrana do localhost'^) ON DUPLICATE KEY UPDATE nazwa = 'original_account', wartosc = '%db%', opis = 'Nazwa bazy klienta pobrana do localhost'; >> \Users\%USERNAME%\Downloads\%db%.sql
    )
    IF EXIST "\Users\%USERNAME%\OneDrive\Downloads\%db%.sql" (
        ECHO.>>\Users\%USERNAME%\OneDrive\Downloads\%db%.sql
        ECHO INSERT INTO options VALUES ^('original_account', '%db%', 'Nazwa bazy klienta pobrana do localhost'^) ON DUPLICATE KEY UPDATE nazwa = 'original_account', wartosc = '%db%', opis = 'Nazwa bazy klienta pobrana do localhost'; >> \Users\%USERNAME%\OneDrive\Downloads\%db%.sql
    )

    ECHO Czyszczenie bazy danych
    cmd.exe /c "docker exec -i mariadb mysql -uimport -pimporthaslo < %dir%sqlExecute\clearDb.sql"

    ECHO Import bazy danych
    IF EXIST "\Users\%USERNAME%\Downloads\%db%.sql" cmd.exe /c "docker exec -i mariadb mysql -uimport -pimporthaslo testdb < \Users\%USERNAME%\Downloads\%db%.sql"
    IF EXIST "\Users\%USERNAME%\OneDrive\Downloads\%db%.sql" cmd.exe /c "docker exec -i mariadb mysql -uimport -pimporthaslo testdb < \Users\%USERNAME%\OneDrive\Downloads\%db%.sql"

    ECHO Zmiana hasla dla uzytkownika astcon / Zmiana czasu wylogowania w przypadku braku aktywnosci na 86400 sekund
    cmd.exe /c "docker exec -i mariadb mysql -uimport -pimporthaslo testdb < %dir%sqlExecute\changePass.sql"

    ECHO Kasowanie pliku sql
    IF EXIST "\Users\%USERNAME%\Downloads\%db%.sql" DEL \Users\%USERNAME%\Downloads\%db%.sql
    IF EXIST "\Users\%USERNAME%\OneDrive\Downloads\%db%.sql" DEL \Users\%USERNAME%\OneDrive\Downloads\%db%.sql

    goto Next
)

:: Import DB from SQL file
IF %type%==2 (
    ECHO Czyszczenie bazy danych
    cmd.exe /c "docker exec -i mariadb mysql -uimport -pimporthaslo < %dir%sqlExecute\clearDb.sql"

    ECHO Import bazy danych
    cmd.exe /c "docker exec -i mariadb mysql -uimport -pimporthaslo testdb < %dir%localDb\%db%.sql"

    ECHO Zmiana hasla dla uzytkownika astcon / Zmiana czasu wylogowania w przypadku braku aktywnosci na 86400 sekund
    cmd.exe /c "docker exec -i mariadb mysql -uimport -pimporthaslo testdb < %dir%sqlExecute\changePass.sql"

    goto Next
)

:: Export local DB to sql file
IF %type%==3 (
    IF not exist "%dir%localDb\%db%.sql" (
        Echo Rozpoczecie eksportu bazy do pliku %db%.sql
        cmd.exe /c "docker exec mariadb mysqldump -uimport -pimporthaslo testdb > %dir%localDb\%db%.sql"
        goto Next
    ) else (
        CHOICE /C yn /T 10 /D N /m "Istneje juz plik o takiej nazwie czy chcesz go podmienic"
        IF errorlevel 2 goto N1
        IF errorlevel 1 goto Y1
        :Y1
            Echo Kasowanie poprzedniego pliku sql
            DEL %dir%localDb\%db%.sql
            Echo Rozpoczecie eksportu bazy do pliku %db%.sql
            cmd.exe /c "docker exec mariadb mysqldump -uimport -pimporthaslo testdb > %dir%localDb\%db%.sql"
            goto Next
        :N1
            ECHO Eksport przerwany
            goto Next
    )
)

if %type%==4 (
    docker exec -i mariadb mysql -uimport -pimporthaslo dbTools  -e "SELECT execute_date_server, windows_time, db_name, execute_info FROM history ORDER BY id DESC LIMIT %limit%;"
    goto End
)

IF %type%==5 (
    dir /b %dir%localDb\
    goto End
 )

 IF %type%==6 (
     CHOICE /C yn /T 10 /D N /m "Czy na pewno chcesz usunac wszystkie lokalne pliki baz danych"
     IF errorlevel 2 goto Nclear
     IF errorlevel 1 goto Yclear
     :Yclear
          DEL /Q %dir%localDb\* >NUL
          goto Next
     :Nclear
         ECHO Przerwano czyszczenie lokalnych plikow baz danych
         goto End
 )

 IF %type%==7 (
      IF NOT EXIST %absolutePatch%autoImport\login.txt (
          ECHO Brak pliku login.txt
          goto End
      )
      SET count=0
      COPY %dir%autoImport\autoImportStart.html %dir%autoImport\tmpLogin.html >NUL
      for /f "tokens=*" %%x in (%absolutePatch%autoImport\login.txt) do call :ExecuteAuto %%x
      goto startPageAuto

      :ExecuteAuto
          powershell -Command "(gc %dir%autoImport\tmpLogin.html) -replace '#%count%#', '%1' | Out-File -encoding Default %dir%autoImport\tmpLogin.html"
          set /a count+=1
          goto :eof

      :startPageAuto
          COPY %dir%autoImport\import.side %dir%autoImport\tmp.side >NUL
          powershell -Command "(gc %dir%autoImport\tmp.side) -replace '#DB#', '%db%' | Out-File -encoding Default %dir%autoImport\tmp.side"
          powershell -Command "(gc %dir%autoImport\tmp.side) -replace '#ABSOLUTEPATCH#', '%absolutePatch%' | Out-File -encoding Default %dir%autoImport\tmp.side"
          powershell -Command "(gc %dir%autoImport\tmp.side) -replace '\\ftpprod\\..', '' | Out-File -encoding Default %dir%autoImport\tmp.side"
          powershell -Command "(gc %dir%autoImport\tmp.side) -replace '\\', '\\\\' | Out-File -encoding Default %dir%autoImport\tmp.side"
          timeout 1 > NUL
          start cmd /k selenium-side-runner %dir%autoImport\tmp.side

      ECHO Czyszczenie bazy danych
      cmd.exe /c "docker exec -i mariadb mysql -uimport -pimporthaslo < %dir%sqlExecute\clearDb.sql"

      ECHO Oczekiwanie na pobranie bazy
      IF EXIST "C:\Users\%USERNAME%\Downloads" SET LookForFile="C:\Users\%USERNAME%\Downloads\%db%.sql"
      IF EXIST "C:\Users\%USERNAME%\OneDrive\Downloads" SET LookForFile="C:\Users\%USERNAME%\OneDrive\Downloads\%db%.sql"
      SET lastSize=10000000000000000000;

      :CheckForFile
          IF EXIST %LookForFile% GOTO CheckSize
          TIMEOUT /T 1 >nul
          GOTO CheckForFile

      :CheckSize
          FOR /F "usebackq" %%A IN ('%LookForFile%') DO set size=%%~zA

          IF "%size%"=="%lastSize%" GOTO NextStep

          TIMEOUT /T 1 >nul

          SET lastSize=%size%
          GOTO CheckSize

      :NextStep
      ECHO Dodanie nazwy bazy danych
      :: Add client DB name to imported DB
      IF EXIST "\Users\%USERNAME%\Downloads\%db%.sql" (
          ECHO.>>\Users\%USERNAME%\Downloads\%db%.sql
          ECHO INSERT INTO options VALUES ^('original_account', '%db%', 'Nazwa bazy klienta pobrana do localhost'^) ON DUPLICATE KEY UPDATE nazwa = 'original_account', wartosc = '%db%', opis = 'Nazwa bazy klienta pobrana do localhost'; >> \Users\%USERNAME%\Downloads\%db%.sql
      )
      IF EXIST "\Users\%USERNAME%\OneDrive\Downloads\%db%.sql" (
          ECHO.>>\Users\%USERNAME%\OneDrive\Downloads\%db%.sql
          ECHO INSERT INTO options VALUES ^('original_account', '%db%', 'Nazwa bazy klienta pobrana do localhost'^) ON DUPLICATE KEY UPDATE nazwa = 'original_account', wartosc = '%db%', opis = 'Nazwa bazy klienta pobrana do localhost'; >> \Users\%USERNAME%\OneDrive\Downloads\%db%.sql
      )
      ECHO Import bazy danych
      IF EXIST "\Users\%USERNAME%\Downloads\%db%.sql" cmd.exe /c "docker exec -i mariadb mysql -uimport -pimporthaslo testdb < \Users\%USERNAME%\Downloads\%db%.sql"
      IF EXIST "\Users\%USERNAME%\OneDrive\Downloads\%db%.sql" cmd.exe /c "docker exec -i mariadb mysql -uimport -pimporthaslo testdb < \Users\%USERNAME%\OneDrive\Downloads\%db%.sql"

      ECHO Zmiana hasla dla uzytkownika astcon / Zmiana czasu wylogowania w przypadku braku aktywnosci na 86400 sekund
      cmd.exe /c "docker exec -i mariadb mysql -uimport -pimporthaslo localhost < %dir%sqlExecute\changePass.sql"

      ECHO Kasowanie pliku sql
      IF EXIST "\Users\%USERNAME%\Downloads\%db%.sql" DEL \Users\%USERNAME%\Downloads\%db%.sql
      IF EXIST "\Users\%USERNAME%\OneDrive\Downloads\%db%.sql" DEL \Users\%USERNAME%\OneDrive\Downloads\%db%.sql

      DEL %dir%autoImport\tmp.side
      DEL %dir%autoImport\tmpLogin.html

      goto Next
 )
 IF %type%==8 (
    ECHO Tworzenie pliku login.txt
    COPY NUL %dir%autoImport\login.txt >nul
    ECHO %2 > %dir%autoImport\login.txt
    call :btoa b64[0] "%3"
    goto SeleniumInstall
    :btoa <var_to_set> <str>
    for /f "delims=" %%I in (
        'powershell "[convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes(\"%~2\"))"'
    ) do ECHO %%I>> %dir%autoImport\login.txt
    goto :EOF

    :SeleniumInstall
    ECHO Instalacja selenium
    start cmd /k npm install -g selenium-side-runner
    TIMEOUT /T 30 >nul
    ECHO Instalacja chromedriver
    start cmd /k npm install -g chromedriver
    TIMEOUT /T 10 >nul
    ECHO Kopiowanie chromedriver
    cmd.exe /c "COPY %absolutePatch%..\installDir\chromedriver.exe \Windows\chromedriver.exe"
    TIMEOUT /T 1 >nul
    taskkill /F /IM cmd.exe >NUL
 )

:Next
ECHO.

:: Count execution time
SET end=%time%
SET options="tokens=1-4 delims=:.,"
for /f %options% %%a in ("%start%") do set start_h=%%a&set /a start_m=100%%b %% 100&set /a start_s=100%%c %% 100&set /a start_ms=100%%d %% 100
for /f %options% %%a in ("%end%") do set end_h=%%a&set /a end_m=100%%b %% 100&set /a end_s=100%%c %% 100&set /a end_ms=100%%d %% 100

SET /a hours=%end_h%-%start_h%
SET /a mins=%end_m%-%start_m%
SET /a secs=%end_s%-%start_s%
SET /a ms=%end_ms%-%start_ms%

IF %ms% lss 0 set /a secs = %secs% - 1 & set /a ms = 100%ms%
IF %secs% lss 0 set /a mins = %mins% - 1 & set /a secs = 60%secs%
IF %mins% lss 0 set /a hours = %hours% - 1 & set /a mins = 60%mins%
IF %hours% lss 0 set /a hours = 24%hours%
IF 1%ms% lss 100 set ms=0%ms%

SET /a totalsecs = %hours%*3600 + %mins%*60 + %secs%

IF %type%==1 SET endInfo=Import bazy wykonany w %totalsecs%.%ms%s
IF %type%==2 SET endInfo=Import z pliku wykonany w %totalsecs%.%ms%s
IF %type%==3 SET endInfo=Eksport wykonany w %totalsecs%.%ms%s
IF %type%==6 SET endInfo=Usunieto lokalne pliki bazy danych w %totalsecs%.%ms%s
IF %type%==7 SET endInfo=Automatyczny import bazy wykonany w %totalsecs%.%ms%s

ECHO %endInfo%

:: Add history of import export files
COPY %dir%sqlExecute\history.sql %dir%sqlExecute\tmp.sql >NUL
ECHO INSERT INTO history^(db_name, windows_time, execution_time, execute_info^) VALUES ^('%db%', '%time%', '%totalsecs%.%ms%s', '%endInfo%'^); >> %dir%sqlExecute\tmp.sql
cmd.exe /c "docker exec -i mariadb mysql -uimport -pimporthaslo < %dir%sqlExecute\tmp.sql"
DEL %dir%sqlExecute\tmp.sql
goto End

:End

IF %type%==7 (
    taskkill /F /IM cmd.exe >NUL
)