# Przygotowanie WSL do instalacji projektu

1. W menu start Funkcje systemu Windows -> Włączyć Podsystem Windows dla systemu linux i restart komputera
2. Odpalić PowerShell jak administrator -> "Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform" i restart komputera
3. Pobrać i zainstalować https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi
4. W powershell odpalić "wsl --set-default-version 2"
5. Przenieść plik installDir/.wslconfig do folderu C:/Users/<nasz użytkownik>
6. W sklepie Microsoftu zainstalować Debian -> otworzyć Debian poprzez MicrosoftStore i dodać swojego użytkownika i hasło
7. (Opcjonalnie) Jeżeli podczas instalacji wyskoczy błąd z brakiem wirtualizacji należy włączyć w BIOS Virtualization

# Instalacja docker desktop

1. https://www.docker.com/get-started/
2. Po instalacji w ustawieniach -> General sprawdzić czy wlączona jest opcja "Use the WSL 2 based engine"
3. Po instalacji w ustawieniach -> Resources -> wsl integration zaznaczyć Debian

# Instalacja projektu

1. Pobiramy projekt z git do głównego folderu dockera
```
git clone -b master

```
2. Komenda w windows (wykonujemy w głównym folderze dockera w którym zanjduje się Dockerfile)``docker build -t apache_php .`` budowanie trwa około 10-15 min

# Pierwsze odpalenie localhost

Wykonać komendy ``wsl -e ln importDir/dbTools.bat ftpprod/dbTools.bat`` (po wykonaniu komendy można wykonywać dbTools.bat bezpośrednio z folderu ftpprod)

Następnie ``cmd.exe /c "mklink /D ftpprod\i images"`` jeżeli wyskoczy komunikat o barku uprawnień należy odpalić cmd jako administrator przejść do folderu docker i ponownie wykonać komendę

Pierwsze odpalenie localhost ``docker-compose up -d`` pierwsze odpalenie trwa około 5 min (wykonujemy w głównym folderze dockera w którym zanjduje się docker-compose.yml)

Kolejne uruchomienia jeżeli jest taka potrzeba wykonujemy bezpośrednio z aplikacji Docker desktop przyciskiem play w zakładce Containers, standardowo docker desktop uruchamia się i startuje localhost automatycznie po włączeniu komputera

# DB tools

### Import produkcyjnej bazy klienta

``dbTools.bat <numer/nazwa klienta>`` lub ``dbTools.bat import <numer/nazwa klienta>`` np. ``dbTools.bat demo`` po odpaleniu komendy otwiera się przeglądarka w której logujemy się do phpmyadmin następnie przechodzimy do zakładki eksport i nic nie zminiając wykonujemy eksport do pliku sql, po pobraniu wracamy do konsoli i klikamy enter aby kontynuować. Baza zostanie automatycznie zaimportowana z folderu pobrane w windows następnie usunięta z tego folderu.

### Import bazy z pliku

``dbTools.bat importFile <nazwa pliku>`` np. ``dbTools.bat importFile demo`` baza musi znajdować się w folderze importDir\localDb i mieć nazwę pliku taką samą jak podajemy w skrypcie np. ``demo.sql``

### Eksport bazy do pliku sql

``dbTools.bat exportFile <nazwa pliku>`` np. ``dbTools.bat exportFile demo`` druga cześć komendy to nazwa jaką będzie miał nasz plik po wyeksportowaniu

### Historia import/eksportu
``dbTools.bat history <limit>`` lub ``dbTools.bat history`` np. ``dbTools.bat history 20`` (domyślny limit 10) Pokazuje historię eksportu i importu baz danych na lokalny serwer

### Lokalne pliki bazy danych

``dbTools.bat importFileList`` pokazuje liste lokalnych plików baz danych możliwych do zaimportowania przy pomocy komendy ``dbTools.bat importFile``

### Czyszczenie lokalnych plików baz danych

``dbTools.bat importFileClear`` komenda kasuje wszystkie lokalne pliki baz danych z wyłączeniem bazy demo.sql (kasowanie lokalnych plików nie wpływa na bazę już zaimportowaną do dockera)

### Automatyczny import bazy/Automatyczne logowanie

Aby system automatycznie nas logował podczas pobierania bazy przy użyciu ``dbTools.bat <numer/nazwa klienta>`` należy w pierwszej kolejności wykonać komendę `` .\dbTools.bat enableAutoImport <login_do_phpmyadmin> <hasło_do_phpmyadmin>`` komendę należy odpalić w CMD jako administrator będąc w folderze importDir

Aby działało pełne automatyczne pobieranie ``dbTools.bat autoImport <numer/nazwa klienta>`` np. ``dbTools.bat autoImport demo`` należy w pierwszej kolejności zainstalować node.js w wersji 17 (https://nodejs.org/dist/v17.9.1/node-v17.9.1-x64.msi) i potem wykonać komendę `` .\dbTools.bat enableAutoImport <login_do_phpmyadmin> <hasło_do_phpmyadmin>`` komendę należy odpalić w CMD jako administrator będąc w folderze importDir

### PHPMyadmin

znajduje się pod adresem ``localhost:8081`` Login: ``root`` Hasło: ``haslohaslo123 ``

# Konfiguracja xDebug dla PHPStorm

1. W ustawieniach->PHP->Debug ustawić port 9003 i checkbox "Can accept external connections"
2. W ustwieniach->Build,Execu...->Docker ustawić patch mapings Virtual machne na ``/var/www/code`` a komputer na ``C:\Users\kuba\PhpstormProjects\docker\ftpprod``
3. W ustawieniach PHP->Servers dodać nowy serwer nazwa ``localhost.test`` host ``localhost.test`` port ``80`` zaznaczyć checkbox ``Use pach mapings`` i ustawić dla ``C:\Users\kuba\PhpstormProjects\docker\test`` maping na ``/var/www/code``

# Konfiguracja xDebug dla Visual Studo

1. Zainstalować rzszerzenie PHP Debug i Docker
2. Utworzyć plik launch.json dla "Docker: Debug in Container"
3. Dodać w konfiguracji
```
"configurations": [
    {
        "name": "Listen for XDebug on Docker",
        "type": "php",
        "request": "launch",
        "port": 9003,
        "pathMappings": {
            "/var/www/code": "${workspaceFolder}/test"
        },
        "hostname": "localhost.test"
    }
]
```
# Przydatne komendy Dockerowe

### Przenoszenie plików z Windows do Docker:

W przypadku plików które chcemy mieć w /var/www/code wystarczy dodać taki plik do folderu ftpprod

W innych przypadkach wykonać komendę ``docker cp <scieżka pliku windows> apache:<scieżka pliku debian>``

### Komendy dockerowe dla Mariadb:

Komenda wejścia do Mariadb ``docker exec -it mariadb bash``

Kopiowanie plików do mariadb ``docker cp <scieżka pliku windows> mariadb:<scieżka pliku debian>``

Wejście do mariadb jako admin (możliwość wykonywania zapytań sql) ``mysql -uroot -phaslohaslo123``

### Komendy dockerowe dla apache/php i dodatki:

Komenda wejścia do apache/php ``docker exec -it apache bash``

Kopiowanie plików do apache/php ``docker cp <scieżka pliku windows> apache:<scieżka pliku apache>`` np ``docker cp ./tmp apache:/var/www/code``

Kopiowanie plików z apache/php do windows ``docker cp apache:<scieżka pliku apache> <scieżka pliku windows>`` np ``docker cp apache:/var/www/code ./``