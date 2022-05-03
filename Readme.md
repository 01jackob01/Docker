## Przygotowanie WSL do instalacji projektu

1. W menu start Funkcje systemu Windows -> Włączyć Podsystem Windows dla systemu linux i restart komputera
2. Odpalić PowerShell jak administrator -> "Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform" i restart komputera
3. Pobrać i zainstalować https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi
4. W powershell odpalić "wsl --set-default-version 2"
5. W sklepie Microsoftu zainstalować Ubuntu 20.04 -> uruchomić Ubuntu i dodać użytkownika systim hasło swoje

## Instalacja docker desktop

1. https://www.docker.com/get-started/
2. W ustawieniach -> General sprawdzić czy wlączona jest opcja "Use the WSL 2 based engine"
3. W ustawieniach -> Resources -> wsl integration zaznaczyć nasze ubuntu

## Tworzenie klucza do GITa

1. ``ssh-keygen -t ed25519 -C "test@mail.pl"``
2. ``eval "$(ssh-agent -s)"``
3. ``ssh-add ~/.ssh/id_ed25519``
4. Skopiować zawartość ``~/.ssh/id_ed25519.pub`` do GitHub Settings -> SSH and GPG key -> New SSH key
5. Test połączenia ``ssh -T git@github.com``

1.``ssh-keygen``
2. ``cat ~/.ssh/id_rsa.pub``
3. ``ssh-keyscan github.com >> ~/keys/known_hosts``

## Instalacja projektu

1. Komenda w wsl ``docker build -t apache_php .``
2. W ``C:\Windows\System32\drivers\etc\hosts`` dodać na końcu linijki
```
127.0.0.1 localhost.test.pl
127.0.0.1 www.localhost.test.pl
127.0.0.1 http:://localhost.test.pl
```

## Odpalenie localhost

Odpalenie w tle ``docker-compose up -d``

Oddpalenie z komunikatami ``docker-compose up``

## Import bazy

1. ``sudo docker cp db.sql mysql:/var/opt/mysql.backup``
2. ``docker exec -it mysql bash``
3. ``mysql -u root -p``
4. ``create database DB_NAME``
5. ``use DB_NAME``
6. ``source /var/opt/mysql.backup``

Krótka wersja
``docker exec -i <nazwa_kontynera> mysql -uroot -p<hasło> <nazwa bazy danych> < importDir/db.sql``

## Konfiguracja xDebug dla PHPStorm

1. W ustawieniach->PHP->Debug ustawić port 9003 i checkbox "Can accept external connections"
2. W ustwieniach->Build,Execu...->Docker ustawić patch mapings Virtual machne na \var\www\site a komputer na \Projekt\www

## Konfiguracja xDebug dla Visual Studo

1. Zainstalować rzszerzenie PHP Debug
2. Utworzyć plik launch.json dla "Docker: Debug in Container"
3. Dodać w konfiguracji
```
{
    "name": "Listen for XDebug on Docker",
    "type": "php",
    "request": "launch",
    "port": 9003,
    "pathMappings": {
        "/var/www/site/": "${workspaceFolder}/www"
    }
}
```