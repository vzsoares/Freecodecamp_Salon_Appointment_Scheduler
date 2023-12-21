#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --csv -c"

OP(){
  A=$($PSQL "$1")
  echo $(echo "$A" | tail -n +2)
}

echo -e "\n~~ Welcome to the Barber's Cut ~~\n"

SERVICES=$($PSQL "SELECT service_id, name FROM services")

SERVICE_MENU(){
  echo "What service would you like?"
  echo "$SERVICES" | tail -n +2 | while IFS="," read -r SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  echo -e "Or type 'exit' to exit\n"
  read SERVICE_ID_SELECTED
  if [[ $SERVICE_ID_SELECTED == 'exit' ]]
  then
    return
  elif [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # Show options again
    SERVICE_MENU
  else
    SERVICE_NAME=$(OP "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_NAME ]]
    then
      echo "No such service."
      SERVICE_MENU
    fi
    # validate if service exists
    echo -e "\nWhat is you phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$(OP "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_NAME  ]]
    then
      echo -e "\nWhat is your name"
      read CUSTOMER_NAME
      CREATE_CUSTOMER=$(OP "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
    fi
    CUSTOMER_ID=$(OP "SELECT customer_id FROM customers WHERE name = '$CUSTOMER_NAME'")

    echo -e "\nWhat's your prefered time?"
    read SERVICE_TIME
    CREATE_APPOINTMENT=$(OP "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID','$SERVICE_ID_SELECTED', '$SERVICE_TIME')")

    echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

SERVICE_MENU