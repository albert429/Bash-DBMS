#!/bin/bash

# Create databases directory if it doesn't exist
if [ ! -d "databases" ]; then
    mkdir -p databases
fi

echo -e "Welcome to your DataBase Mangement Software. \n"
PS3="Selection : "
while true; do
    select ch in "Create a new DataBase" "List all available Databases" "Connect to a DataBase" "Drop a DataBase" "Exit"; do
        case "$REPLY" in
        1)
            echo -e "Creating a new Database: \n"
            read -p "Please enter the database name: " databaseName
            for d in databases/*/; do
                if [ -d "$d" ]; then
                    d="${d%/}"
                    d2="${d##*/}" ## getting rid of the long name leaving only the directory name
                    if [ "$d2" == "$databaseName" ]; then
                        echo -e "There is already a database with this name! Please choose another name. \n"
                    else
                        mkdir "databases/$databaseName"
                        echo -e "A new database has been created with the name $databaseName \n"
                    fi
                else
                    mkdir "databases/$databaseName" ## If there is no any databases available, this conditon is here to make the first one
                    echo -e "A new database has been created with the name $databaseName \n"
                fi
            done
            ;;
        2)
            echo -e "Printing Available Databases: \n"
            ## counting available databases in the databases directory.
            dir_count=0
            if [ -d databases ]; then
                for d in databases/*/; do
                    if [ -d "$d" ]; then
                        ((dir_count++))
                    fi
                done
            fi
            ## if there is at least one database it will be printed, else a message will be printed
            if [ "$dir_count" -gt 0 ]; then
                for d in databases/*/; do
                    if [ -d "$d" ]; then
                        d="${d%/}"
                        echo "${d##*/}"
                    fi
                    echo ""
                done
            else
                echo -e "There are no Available databases right now!\n"
            fi
            ;;
        3)
            read -p "Please enter the name of the database you wish to connect to: " connectedDatabase
            for d in databases/*/; do
                if [ -d "$d" ]; then
                    d="${d%/}"
                    d2="${d##*/}"
                    if [ "$d2" == "$connectedDatabase" ]; then ## checks if the database you want to connect to exists
                        ./databaseMenu.sh "$d2"
                    else
                        echo -e "There are no Databases with this name! \n"
                    fi
                fi
            done
            ;;
        4)
            read -p "Please enter the database name you wish to drop: " dropDatabase
            for d in databases/*/; do
                if [ -d "$d" ]; then
                    d="${d%/}"
                    d2="${d##*/}"
                    if [ "$d2" == "$dropDatabase" ]; then ## checks if the database you want to get rid of is available
                        read -p "Do you want to continue? (y/n): " confirm
                        if [[ "$confirm" =~ ^[Yy]$ ]]; then ## double confirming that You want to delete the database
                            echo "Continuing..."
                            rm -r "$d" # Changed from rmdir to rm -r to remove non-empty directories
                            echo -e "The Database named $dropDatabase has been removed! \n"
                        else                        #!/bin/bash
                        
                        # Create databases directory if it doesn't exist
                        if [ ! -d "databases" ]; then
                            mkdir -p databases
                        fi
                        
                        echo -e "Welcome to your DataBase Mangement Software. \n"
                        PS3="Selection : "
                        # ...existing code...                        #!/bin/bash
                        
                        # Create databases directory if it doesn't exist
                        if [ ! -d "databases" ]; then
                            mkdir -p databases
                        fi
                        
                        echo -e "Welcome to your DataBase Mangement Software. \n"
                        PS3="Selection : "
                        # ...existing code...
                            echo -e "Aborted. \n"
                            exit 1
                        fi
                    else
                        echo -e "There are no Databases with this name! \n"
                    fi
                fi
            done
            ;;
        5)
            exit
            ;;
        *)
            echo -e "please select one of choices, $REPLY is out of range.\n" ## makes sure that the choices is not out of range
            ;;
        esac
        break
    done
done
