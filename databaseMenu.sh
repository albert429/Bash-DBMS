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
                                        echo "Your value is valid within the dataType"
                                    else
                                        echo "Error: Must be an integer!"
                                        valid=false

                                    fi
                                    ;;
                                string)
                                    if [[ "$value" =~ ^[a-zA-Z\ ]+$ ]]; then
                                        echo "Your value is valid within the dataType"
                                    else
                                        echo "Error: Must contain only letters!"
                                        valid=false
                                    fi
                                    ;;
                                esac
                                if $isPK; then
                                    for forb in "${forbiddenValues[@]}"; do
                                        if [[ "$value" == "$forb" ]]; then
                                            valid=false
                                            echo "This is the primary key! Its value can't match another value in the same column!"
                                            break
                                        elif [[ "$value" == "" ]]; then
                                            valid=false
                                            echo "This is the primary key! Its value can't be NULL or Empty"
                                            break
                                        fi

                                    done
                                fi
                                if $valid; then
                                    echo "Stored $value under the column $pk"
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
            read -p "Select the table you want to read from : " selectTable
            if [ -f "$selectTable".csv ]; then
                columns=($(awk -F: '{print $1}' "$selectTable.meta"))
                echo -e "Select whether you would like to display the entire table or a certain row \n"
                while true; do
                    select ch in "The entire table" "Select a row" "Exit"; do
                        case "$REPLY" in
                        1)
                            echo -e "Displaying the entire table: \n"
                            column -t -s',' "$selectTable.csv"
                            ;;
                        2)
                            echo -e "select the column you would like to search with \n"
                            select col in "${columns[@]}" "done"; do
                                if [[ "$col" == "done" ]]; then
                                    break 2
                                elif [[ -n "$col" ]]; then
                                    mapfile -t rows < <(awk -F, -v col="$REPLY" 'NR > 1 {print $col}' "$selectTable.csv")
                                    echo -e "Select which row you would like to select: \n"
                                    select row in "${rows[@]}"; do
                                        if [[ -n "$row" ]]; then
                                            actualRow=$((REPLY + 1))
                                            awk -F, -v row="$actualRow" 'NR == 1 || NR == row' "$selectTable.csv" | column -t -s','
                                            break 2
                                        fi
                                    done
                                fi
                            done

                            ;;
                        3)
                            echo -e "Exiting \n"
                            break 2
                            ;;
                        esac
                        echo ""
                        break 2
                    done
                done
            else
                echo "There is no table with the name $selectTable !"
            fi
            ;;
        6)
            echo -e "Deleting from a table \n"
            read -p "Select the table you want to delete from : " deleteTable
            if [ -f "$deleteTable".csv ]; then
                columns=($(awk -F: '{print $1}' "$deleteTable.meta"))
                echo -e "Select whether you would like to delete the entire table or a certain row \n"
                while true; do
                    select ch in "The entire table" "Select a row" "Exit"; do
                        case "$REPLY" in
                        1)
                            echo -e "Deleting the entire table: \n"
                            sed -i '2,$d' "$deleteTable.csv"
                            echo -e "All rows in the table $deleteTable has been deleted"
                            ;;
                        2)
                            echo -e "select the column you would like to search with \n"
                            select col in "${columns[@]}" "done"; do
                                if [[ "$col" == "done" ]]; then
                                    break 2
                                elif [[ -n "$col" ]]; then
                                    mapfile -t rows < <(awk -F, -v col="$REPLY" 'NR > 1 {print $col}' "$deleteTable.csv")
                                    echo -e "select the row you would like to delete: \n"
                                    select row in "${rows[@]}"; do
                                        if [[ -n "$row" ]]; then
                                            actualRow=$((REPLY + 1))
                                            sed -i "${actualRow}d" "$deleteTable.csv"
                                            echo -e "The selected row has been deleted!"
                                            break 2
                                        fi
                                    done
                                fi
                            done

                            ;;
                        3)
                            echo -e "Exiting \n"
                            break 2
                            ;;
                        esac
                        echo ""
                        break 2
                    done
                done
            else
                echo "There is no table with the name $selectTable !"
            fi
            ;;
        7)
            echo -e "Updating a table \n"
            read -p "Select the table you want to Update : " UpdateTable
            if [ -f "$UpdateTable".csv ]; then
                columns=($(awk -F: '{print $1}' "$UpdateTable.meta"))
                echo -e "select the column you would like to search with \n"
                select col in "${columns[@]}" "Exit"; do
                    if [[ "$col" == "Exit" ]]; then
                        break 2
                    elif [[ -n "$col" ]]; then
                        mapfile -t rows < <(awk -F, -v col="$REPLY" 'NR > 1 {print $col}' "$UpdateTable.csv")
                        echo -e "select the value you wish to update: \n"
                        select row in "${rows[@]}"; do
                            if [[ -n "$row" ]]; then
                                read -p "Enter the new value to replace ($row) with: " newVal
                                sed -i "s/$row/$newVal/g" "$UpdateTable".csv 
                                break 2
                                echo -e "The Value Has been Updated successfuly"
                            else
                                echo "Wrong input, please select from the given menu"
                            fi
                            
                        done
                    fi
                done
            else
                echo "There is no table with the name $UpdateTable !"
            fi
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
