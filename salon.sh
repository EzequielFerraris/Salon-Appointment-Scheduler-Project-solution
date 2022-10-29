#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Deltha's Salon~~~~~\n"

# get available services
AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

MAIN_MENU() {

  if [[ $1 ]]
  then
    echo -e "\n$1"
  else 
    echo -e "Welcome to our appointment app!\nChoose the service you want and we will appoint a session for you.\n" 
  fi

  # if no services available
  if [[ -z $AVAILABLE_SERVICES ]]
  then
    # send to main menu
    echo "Sorry, we don't have any services available right now."
    EXIT
    
  #if services available  
  else
    # display available services
    echo -e "\nHere are the services we offer:"
    echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
    do
      echo "$SERVICE_ID) $SERVICE_NAME"
    done
  fi

  # ask the client to pick a service
  echo -e "\nWhich kind of service do you want to get?"
  read SERVICE_ID_SELECTED

  # if input is not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
  # send to main menu
    MAIN_MENU "That is not a valid service number." 
  else
    #SERVICE INFO
    SERVICE_SELECTED=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    # Service does not exist
    if [[ -z $SERVICE_SELECTED ]]
    then
    # send to main menu
        MAIN_MENU "That is not a valid service number."
    else
        SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_SELECTED")
        GET_DETAILS
    fi
  fi

  EXIT
}

GET_DETAILS() {
  # get customer info
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # if customer doesn't exist
  if [[ -z $CUSTOMER_ID ]]
  then
  # get new customer name
    echo -e "\nWhat's your name?"
    read CUSTOMER_NAME
  # insert new customer
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')") 
  fi

  # get customer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  # get customer name
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  #Ask for a date to book
  echo -e "\nPlease introduce a time to make the appointment"
  read SERVICE_TIME

  #Insert appointment
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_SELECTED, '$SERVICE_TIME')") 

  echo "I have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $(echo $SERVICE_TIME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
}

EXIT() {
  echo ""
}

MAIN_MENU
