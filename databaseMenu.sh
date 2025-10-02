#!/bin/bash
validDataTypes=("int" "string")
echo "$1"
cd "databases/$1" || return

echo -e "You are now connected to the database called $1 \n"
PS3="$1 : "
while true; do
    select ch in "Create a new Table" "List all available tables" "Drop a table" "Insert into a table" "Select from a table" "Delete from a table" "Update a table" "Exit"; do
        case "$REPLY" in
        1)
            echo -e "Creating a new Table: \n"
            read -p "Please enter the table name: " tableName
            if [ -f "$tableName".csv ]; then
                echo -e "A table with the name $tableName already exits! \n"
            else
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
                    echo -e "select the data type of your column"
                    select pk in "${validDataTypes[@]}"; do
                        if [[ -n "$pk" ]]; then
                            echo "$columnName:$pk" >>"$tableName".meta
                            if [ $first_coloumn_flag -eq 1 ]; then
                                echo -n "$columnName" >>"$tableName".csv
                                first_coloumn_flag=0
                            else
                                echo -n ",$columnName" >>"$tableName".csv
                            fi
                            echo -e "Column $columnName with data type $pk added to table $tableName \n"
                            break
                        else
                            echo "Invalid choice, try again."
                        fi
                    done
                done
                echo "" >>"$tableName".csv # Adds newline for future inserts
                echo -e "Columns defined. Now select a primary key."
                columns=($(awk -F: '{print $1}' "$tableName.meta"))
                select pk in "${columns[@]}"; do
                    if [[ -n "$pk" ]]; then
                        sed -i "s/^$pk:.*/&:PRIMARY_KEY/" "$tableName.meta"
                        echo "$pk set as PRIMARY KEY"
                        break
                    else
                        echo "Invalid choice, try again."
                    fi
                done
            fi
            ;;
        2)
            echo -e "Listing all available tables: \n"
            ls *.csv 2>/dev/null | sed 's/\.csv$//'
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
            echo ""
            ;;
        4)
            row=""
            unset values # ← Clears old data
            declare -A values
            echo -e "Inserting into a table \n"
            read -p "Select the table you want to insert into : " insertTable
            if [ -f "$insertTable".csv ]; then
                columns=($(awk -F: '{print $1}' "$insertTable.meta"))
                echo -e "Select the column you want to insert into or select (done) to exit:"
                while true; do
                    select pk in "${columns[@]}" "done"; do
                        if [[ "$pk" == "done" ]]; then
                            break 2
                        elif [[ -n "$pk" ]]; then
                            dataType=$(awk -F: -v name="$pk" '$1 == name {print $2}' "$insertTable.meta")
                            isPK=$(awk -F: -v name="$pk" '$1 == name {print ($3 == "PRIMARY_KEY") ? "true" : "false"}' "$insertTable.meta")
                            if $isPK; then
                                forbiddenValues=($(awk -F, -v col="$REPLY" '{print $col}' "$insertTable.csv"))
                            fi
                            while true; do
                                read -p "Enter value for $pk ($dataType): " value
                                valid=true
                                case $dataType in
                                int)
                                    if [[ "$value" =~ ^[0-9]+$ ]]; then
                                        echo "Stored $value under the column $pk"
                                    else
                                        echo "Error: Must be an integer!"
                                        valid=false

                                    fi
                                    ;;
                                string)
                                    if [[ "$value" =~ ^[a-zA-Z\ ]+$ ]]; then
                                        echo "Stored $value under the column $pk"
                                    else
                                        echo "Error: Must contain only letters!"
                                        valid=false
                                    fi
                                    ;;
                                esac
                                if $isPK; then
                                    for forb in "${forbiddenValues[@]}"; do
                                        if [[ "$value" == "$forb" ]]; then
                                            valid=false;
                                            echo "This is the primary key! Its value can't match another value in the same column!"
                                            break;
                                        elif [[ "$value" == "" ]]; then
                                            valid=false;
                                            echo "This is the primary key! Its value can't be NULL or Empty"
                                            break;
                                        fi
                                        
                                    done
                                fi
                                if $valid; then
                                    values[$pk]="$value"
                                    break # Exit validation loop
                                fi
                            done

                            break
                        else
                            echo "Invalid choice, try again."
                        fi
                    done
                done
                for col in "${columns[@]}"; do
                    val="${values[$col]:-}"
                    row="$row,$val"
                done
                row="${row:1}" # Remove first character (the leading comma)

                echo "$row" >>"$insertTable.csv"
                echo "Row inserted!"
            else
                echo -e "there is no table with that name!"
            fi
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
            cd ../..
            exit
            ;;
        *)
            echo -e "please select one of choices, $REPLY is out of range.\n" ## makes sure that the choices is not out of range
            ;;
        esac
        break
    done
done
