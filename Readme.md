## Przygotowanie WSL do instalacji projektu

1. W menu start Funkcje systemu Windows -> Włączyć Podsystem Windows dla systemu linux i restart komputera
2. Odpalić PowerShell jak administrator -> "Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform" i restart komputera
3. Pobrać i zainstalować https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi
4. W powershell odpalić "wsl --set-default-version 2"
5  W sklepie Microsoftu zainstalować Ubuntu 20.04 -> uruchomić Ubuntu i dodać użytkownika systim hasło swoje
5. Przenieść do wsl przy pomocy komendy cp lub w dokumentach wejśc przez \\wsl$\Ubuntu-20.04\home\test folder aplikacji

## Instalacja docker desktop

1. https://www.docker.com/get-started/
2. W ustawieniach -> General sprawdzić czy wlączona jest opcja "Use the WSL 2 based engine"
3. W ustawieniach -> Resources -> wsl integration zaznaczyć nasze ubuntu

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