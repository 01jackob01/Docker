@echo off
setlocal EnableDelayedExpansion
SET start=%time%

IF EXIST ".\apache" (
  set dir=.\
  set absolutePatch=%CD%\
  goto StartScript
)
IF EXIST ".\logs\apache" (
  set dir=.\logs\
  set absolutePatch=%CD%\logs\
  goto StartScript
)
IF EXIST ".\..\logs\apache" (
  set dir=.\..\logs\
  set absolutePatch=%CD%\..\logs\
  goto StartScript
)

:StartScript
IF NOT EXIST %dir%localLogs (
    mkdir %dir%localLogs
)

SET type=0
IF "%1"=="help" SET type=0
IF "%1"=="getLogs" SET type=1
IF "%1"=="clearLogs" SET type=2
IF "%1"=="clearLocalLogs" SET type=3
IF "%1"=="showAllErrors" SET type=4
IF "%1"=="searchErrors" SET type==5

IF %type%==0 (
    ECHO Dostepne komendy
    ECHO ----------------------------------------------------------------------------------------------------------
    ECHO "getLogs" - komenda pobiera error logi apacha do lokalnego folderu /logs/localLogs/
    ECHO.
    ECHO "clearLocalLogs" - komenda czysci error logi apacha z lokalnego folderu /logs/localLogs/
    ECHO.
    ECHO "clearLogs" - komenda czysci error logi apacha w dockerze
    ECHO.
    ECHO "showAllErrors" - komenda pokazuje wszystkie fatal errory w logach apacha na dockerze
    ECHO.
    ECHO "searchErrors <dzien> <miesiac>" - np. ".\logTools.bat searchErrors 4 9" komenda wyszukuje wszystkie fatal errory w logach apacha na dockerze
    ECHO.
    goto End
)

IF %type%==1 (
    ECHO Rozpopoczecie pobieranie error.log
    cmd.exe /c "docker cp apache:/var/log/apache2/error.log %dir%localLogs"
    goto End
)
IF %type%==2 (
    ECHO Czyszczenie pliku error.log
    cmd.exe /c "docker exec apache rm -rf /var/log/apache2/error.log"
    cmd.exe /c "docker exec apache touch /var/log/apache2/error.log"
    ECHO Czyszczenie pliku access.log
    cmd.exe /c "docker exec apache rm -rf /var/log/apache2/access.log"
    cmd.exe /c "docker exec apache touch /var/log/apache2/access.log"
    ECHO Restart apache
    cmd.exe /c "docker restart apache"
    goto End
)
IF %type%==3 (
     CHOICE /C yn /T 10 /D N /m "Czy na pewno chcesz usunac wszystkie lokalne pliki logow"
     IF errorlevel 2 goto Nclear
     IF errorlevel 1 goto Yclear
     :Yclear
          DEL /Q %dir%localLogs\* >NUL
          goto End
     :Nclear
         ECHO Przerwano czyszczenie lokalnych plikow baz danych
         goto End
)
IF %type%==4 (
    ECHO Fatal error
    ECHO.
    findstr /L /N /C:"Fatal error" %dir%apache\error.log
    ECHO.
    ECHO Parse error
    ECHO.
    findstr /L /N /C:"Parse error" %dir%apache\error.log
    goto End
)

IF %type%==5 (
    if %3==1 SET month=Jan
    if %3==2 SET month=Feb
    if %3==3 SET month=Mar
    if %3==4 SET month=Apr
    if %3==5 SET month=May
    if %3==6 SET month=Jun
    if %3==7 SET month=Jul
    if %3==8 SET month=Aug
    if %3==9 SET month=Sep
    if %3==10 SET month=Oct
    if %3==11 SET month=Nov
    if %3==12 SET month=Dec
    ECHO Fatal error
    ECHO.
    findstr /N /R /C:"%month%.*%2.*Fatal error" %dir%apache\error.log
    ECHO.
    ECHO Parse error
    ECHO.
    findstr /N /R /C:"%month%.*%2.*Parse error" %dir%apache\error.log
    goto End
)

:End
ECHO Zakonczono wykonywanie komendy