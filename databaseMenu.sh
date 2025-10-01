#!/bin/bash

echo "$1";
cd "databases/$1";

echo -e "You are now connected to the database called $1 \n"
PS3="$1 : "
select ch in "Create a new Table" "List all available tables" "Drop a table" "Insert into a table" "Select from a table" "Delete from a table" "Update a table" "Exit"; do
        case "$REPLY" in
        1)
            echo -e "Creating a new Table: \n"
            read -p "Please enter the table name: " tableName
            touch "$tableName".csv
            touch "$tableName".meta
            echo -e "A new table has been created with the name $tableName \n"
            echo -e "Please define your table structure: \n"
            first_coloumn_flag=1
            while true; do
                read -p "Please enter the column name or type 'done' to finish: " columnName
                if [ "$columnName" == "done" ]; then
                    break
                fi
                read -p "Please enter the data type for $columnName (e.g., integer, string): " dataType
                echo "$columnName:$dataType" >> "$tableName".meta

                if [ $first_coloumn_flag -eq 1 ]; then
                    echo -n "$columnName" >> "$tableName".csv
                    first_coloumn_flag=0
                else
                    echo -n ",$columnName" >> "$tableName".csv
                fi

                echo -e "Column $columnName with data type $dataType added to table $tableName \n"
            done   
            ;;
        2)
            echo -e "Listing all available tables: \n"
            ls *.csv 2> /dev/null | sed 's/\.csv$//'
            ;;
        3)
            echo -e "Dropping a table \n"
            read -p "Please enter the table name you want to drop: " dropTable
            if [ -f "$dropTable".csv ]; then
                rm "$dropTable".csv
                rm "$dropTable".meta
                echo -e "The table named $dropTable has been removed! \n"
            else
                echo -e "Table $dropTable does not exist. \n"
            fi
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