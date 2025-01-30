#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Salon Otorongacz ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo "Welcome to Salon Otorongacz, please select a option."
  echo -e "\n1. Select a service\n2. Exit"

  # Prompt user for service selection
  read MAIN_MENU_SELECTION
  case $MAIN_MENU_SELECTION in
   1) SERVICE_MENU ;;
   2) EXIT ;;
   *) MAIN_MENU "Please select a valid option."
  esac
}

SERVICE_MENU() {
  # prompt user to input service ID selected
  echo "What would you like today?"
  # display available services
  SERVICE_AVAILABLE=$($PSQL "SELECT service_id, name FROM services")
  echo "$SERVICE_AVAILABLE" | while read SERVICE_ID BAR NAME 
    do 
      echo "$SERVICE_ID) $NAME"
    done
  read SERVICE_ID_SELECTED 

  # if input is not a number 
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # send to main menu
    MAIN_MENU "Please enter a valid option."
  else
  

  # get customer phone number
  echo -e "\nWhat is your phone number?"
  read CUSTOMER_PHONE

  # find customer name
  CUSTOMER_NAME=$($PSQL "SELECT name from customers WHERE phone='$CUSTOMER_PHONE'")

  # if customer doesn't exist
  if [[ -z $CUSTOMER_NAME ]]
  then
    # ask for customer name 
    echo -e "I don't have a record for that phone number. What's your name?"
    read CUSTOMER_NAME

    # insert name into customers database
    CUSTOMER_ID=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE') RETURNING customer_id")
  
  # if customer already exists
  else
  # get name
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  fi
  fi
  # Ask for the time of the appointment
  echo -e "What time would you like your service?"
  read SERVICE_TIME
   # Insert time into the appointments table
  APPOINTMENT_ID=$($PSQL "INSERT INTO appointments(service_id, customer_id, time) VALUES($SERVICE_ID_SELECTED, $CUSTOMER_ID, '$SERVICE_TIME') RETURNING appointment_id")

  # Display confirmation message
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME,$CUSTOMER_NAME."
}

EXIT() {
  echo -e "\nThank you for stopping in.\n"
}

MAIN_MENU
