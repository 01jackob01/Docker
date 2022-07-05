#!/bin/bash
start=%time%

if [ -d sqlExecute ]; then
  dir=../importDir
  absolutePatch=%CD%/
elif  [ -d importDir/sqlExecute ]; then
  dir=importDir
  absolutePatch=%CD%/importDir/
elif  [ -d ../importDir/sqlExecute ]; then
  dir=../importDir
  absolutePatch=%CD%/../importDir/
fi

if [ ! -d $dir/localDb ]; then
    mkdir $dir/localDb
fi

type=0

if [ "$1"=="import" ]; then
  type=1
fi

db=$1
if [ $type==0 ]; then
  db=$1
  type=1
fi

if [ $type==1 ]; then
  #open "localhost:8081/db_export.php?db=$1"
  echo "Oczekiwanie na pobranie bazy"
  printf "%s " "Press enter to continue"
  read ans
  if [ ! -f ~/Downloads/$db.sql ]; then
      echo "Brak bazy '$db' do importu"
    exit 0
  fi
  echo "Czyszczenie bazy danych"
  docker exec -i mariadb mysql -uimport -pimporthaslo < $dir/sqlExecute/clearDb.sql
  echo "Dodanie danych o importowanym koncie"
  echo"">>~/Downloads/$db.sql
  echo "INSERT INTO options VALUES ('original_account', '$db', 'Nazwa bazy klienta pobrana do localhost') ON DUPLICATE KEY UPDATE nazwa = 'original_account', wartosc = '$db', opis = 'Nazwa bazy klienta pobrana do localhost';" >> ~/Downloads/$db.sql
  echo "Rozpoczęcie import bazy danych"
  docker exec -i mariadb mysql -uimport -pimporthaslo testdb < ~/Downloads/$db.sql
  echo "Zmiana czasu wylogowania w przypadku braku aktywności na 86400 sekund"
  docker exec -i mariadb mysql -uimport -pimporthaslo testdb < $dir/sqlExecute/changePass.sql
fi
#echo "Kasowanie pliku sql"
#rm ~/Downloads/$db.sql
echo "Zakończono import bazy danych"