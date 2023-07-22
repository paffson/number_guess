#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t -q --no-align -c"

MAIN() {
echo "Enter your username: "
read USERNAME
if [ ${#USERNAME} -gt 22 ]; then
  echo "User name length cannot exceed 22"
  exit 1
fi
USERDATA=$($PSQL "select user_id, name from users where name='$USERNAME'")
ORIGINAL_IFS=$IFS
IFS="|"
read USER_ID NAME <<< $USERDATA
IFS=$ORIGINAL_IFS
if [ $NAME ]; then
  GAMEDATA=$($PSQL "select count(*), min(guesses) from games where user_id = $USER_ID")
  IFS="|"
  read COUNT MIN <<< $GAMEDATA
  IFS=$ORIGINAL_IFS
  echo "Welcome back, $NAME! You have played $COUNT games, and your best game took $MIN guesses."
else
  USER_ID=$($PSQL "insert into users(name) values('$USERNAME') returning user_id")
  if [ -z $USER_ID ]; then
    echo "Error: couldn't add a user. Exiting."
    exit 1
  fi
  echo "Welcome, $USERNAME! It looks like this is your first time here."
fi
GAME $USER_ID $NAME
}
GAME() {
RANDOM_NUMBER=$(( (RANDOM % 10) + 1 ))
echo random: $RANDOM_NUMBER
echo Guess the secret number between 1 and 10:
read GUESS
TRIES=1
while [ $GUESS != $RANDOM_NUMBER ]; do
  #echo loop $TRIES
  if [[ $GUESS -lt $RANDOM_NUMBER ]]; then
    HI_LO="higher"
  else
    HI_LO="lower"
  fi
  echo -e "It's $HI_LO than that, guess again: "

  read GUESS
  ((TRIES++))
done
echo tries: $TRIES
}
MAIN