#!/bin/bash

# number_guess DATABASE
# TABLE users_register   
# player_id, INT UNIQUE  SERIAL  
# username VARCHAR 22 UNIQUE

# TABLE games 
# game_id SERIAL PRIMARY KEY
# player_id, INT FOREIGN KEY
# games_played, INT DEFAULT 0  
# best_game INT


PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

SECRET_NUMBER=$((1 + RANDOM%1000))

NUMBER_OF_GUESSES=0

echo -e "Enter your username:"
read USER_NAME

PLAYER_ID=$($PSQL "SELECT player_id FROM users_register WHERE username='$USER_NAME'")

if [[ $PLAYER_ID ]]
then
  #read username from database
  USERNAME_DB=$($PSQL "SELECT username FROM users_register WHERE player_id=$PLAYER_ID")
  #games played
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM games WHERE player_id=$PLAYER_ID")
  #best game
  BEST_GAME=$($PSQL "SELECT best_game FROM games WHERE player_id=$PLAYER_ID")

  echo -e "Welcome back, $USERNAME_DB! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."

else
  #insert new player to db
  $PSQL "INSERT INTO users_register(username) VALUES('$USER_NAME')" > /dev/null
  echo -e "Welcome, $USER_NAME! It looks like this is your first time here."

fi


# game

echo "Guess the secret number between 1 and 1000:"
read USER_NUMBER

while true 
do
  if [[ $USER_NUMBER =~ ^[0-9]+$ ]]
  then

  if [[ $USER_NUMBER -gt $SECRET_NUMBER ]]
  then
    echo -n "It's lower than that, guess again:"
    read USER_NUMBER
    NUMBER_OF_GUESSES=$(( $NUMBER_OF_GUESSES + 1 ))
  else
    if [[ $USER_NUMBER -lt $SECRET_NUMBER ]]
    then
      echo -n "It's higher than that, guess again:"
      read USER_NUMBER
      NUMBER_OF_GUESSES=$(( $NUMBER_OF_GUESSES + 1 ))
    else
      # winning case
      NUMBER_OF_GUESSES=$(( $NUMBER_OF_GUESSES + 1 ))

      #register to db

      if [[ -n $GAMES_PLAYED  ]]
      then
      #update number of games
      GAMES_PLAYED=$(( $GAMES_PLAYED + 1 ))
      $PSQL "UPDATE games SET games_played=$GAMES_PLAYED WHERE player_id=$PLAYER_ID" > /dev/null
      #update NUMBER_OF_GUESSES and best game
        if [[ $NUMBER_OF_GUESSES -lt $BEST_GAME ]]
        then
          $PSQL "UPDATE games SET best_game=$NUMBER_OF_GUESSES WHERE player_id=$PLAYER_ID" > /dev/null
        fi
      else
      #insert number of games
      PLAYER_ID=$($PSQL "SELECT player_id FROM users_register WHERE username='$USER_NAME'")
      GAMES_PLAYED=0
      GAMES_PLAYED=$(( $GAMES_PLAYED + 1 ))
      BEST_GAME=$NUMBER_OF_GUESSES
      $PSQL "INSERT INTO games(player_id, games_played, best_game) VALUES($PLAYER_ID,$GAMES_PLAYED, $BEST_GAME)" > /dev/null
    fi
    # end of register db

      echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
      break
      #end of winnign case
    fi
  fi
    
  else
    echo "That is not an integer, guess again:"
    read USER_NUMBER
  fi
done
