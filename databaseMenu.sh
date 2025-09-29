#!/bin/bash

echo "$1";
cd "databases/$1";

echo -e "You are now connected to the database called $1 \n"
PS3="$1 : "
select ch in "Create a new Table" "List all available tables" "Drop a table" "Insert into a table" "Select from a table" "Delete from a table" "Update a table" "Exit"; do
        case "$REPLY" in
        1)
            echo -e "Creating a new Table: \n"
            ;;
        2)
            echo -e "Listing all available tables: \n"
            ;;
        3)
            echo -e "Dropping a table \n"
            ;;
        4)
            echo -e "Inserting into a table \n"
            ;;
        5)  
            echo -e "Selecting from a table \n"
            ;;
        6)  
            echo -e "Deleting from a table \n"
            ;;
        7)  
            echo -e "Updating a table \n"
            ;;
        8)  
            echo -e "Returning to main menu \n"
            cd ../..;
            exit;
            ;;
        *)
            echo -e "please select one of choices, $REPLY is out of range.\n" ## makes sure that the choices is not out of range
            ;;
        esac
    done