#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\n~~~~~ GUESS NUMBER ~~~~~\n"

echo "Enter your username":
read USER

USER_INFO=$($PSQL "SELECT user_id, username, games_played, best_game FROM users WHERE username='$USER'")
if [[ -z $USER_INFO ]]
then
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USER')")
  USERNAME=$USER
  echo -e "\nWelcome, $USER! It looks like this is your first time here."
else
  IFS='|' read USER_ID USERNAME GAMES_PLAYED BEST_GAME <<< "$USER_INFO"
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

RANDOM_NUMBER=$((RANDOM % 1000 + 1))
echo -e "\nGuess the secret number between 1 and 1000:"
read GUESS
GUESS_COUNT=0

while true
do
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo -e "\nThat is not an integer, guess again:"
    read GUESS
    continue
  fi

  GUESS_COUNT=$((GUESS_COUNT + 1))

  if [[ $GUESS -eq $RANDOM_NUMBER ]]
  then
    break
  elif [[ $GUESS -gt $RANDOM_NUMBER ]]
  then
    echo -e "It's lower than that, guess again:\n"
    read GUESS
  else
    echo -e "It's higher than that, guess again:\n"
    read GUESS
  fi
done

echo -e "\nYou guessed it in $GUESS_COUNT tries. The secret number was $RANDOM_NUMBER. Nice job!"

USER_INFO=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME'")
IFS='|' read GAMES_PLAYED BEST_GAME <<< "$USER_INFO"

NEW_GAMES_PLAYED=$((GAMES_PLAYED + 1))

if [[ $BEST_GAME -eq 0 || $GUESS_COUNT -lt $BEST_GAME ]]
then
  NEW_BEST_GAME=$GUESS_COUNT
else
  NEW_BEST_GAME=$BEST_GAME
fi

INFO_UPDATE=$($PSQL "UPDATE users SET games_played=$NEW_GAMES_PLAYED, best_game=$NEW_BEST_GAME WHERE username='$USERNAME'")

