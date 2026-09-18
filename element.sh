#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else
  INFO=$($PSQL "SELECT 
                e.atomic_number, symbol, name, type, atomic_mass, 
                melting_point_celsius, boiling_point_celsius 
                FROM elements AS e
                INNER JOIN properties AS p ON e.atomic_number=p.atomic_number
                INNER JOIN types AS t ON p.type_id = t.type_id
                WHERE e.atomic_number::VARCHAR='$1' OR e.symbol='$1' OR e.name='$1';")
  if [[ -z $INFO ]]
  then
    echo -e "I could not find that element in the database."
  else
    IFS='|' read ATOMIC_NUMBER SYMBOL NAME TYPE MASS MELTING_POINT BOILING_POINT <<< "$INFO"
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
  fi
fi