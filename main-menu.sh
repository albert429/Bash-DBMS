#!/bin/bash

# Create databases directory if it doesn't exist
if [ ! -d "databases" ]; then
    mkdir -p databases
fi

# ASCII Art Header
cat << "EOF"
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║           ██████╗ ██████╗ ███╗   ███╗███████╗                ║
║           ██╔══██╗██╔══██╗████╗ ████║██╔════╝                ║
║           ██║  ██║██████╔╝██╔████╔██║███████╗                ║
║           ██║  ██║██╔══██╗██║╚██╔╝██║╚════██║                ║
║           ██████╔╝██████╔╝██║ ╚═╝ ██║███████║                ║
║           ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝                ║
║                                                              ║
║        Welcome to your Database Management System v1.0       ║
║                    Built with Bash                           ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF

echo -e " \n"
PS3="Selection : "
while true; do
    select ch in "Create a new DataBase" "List all available Databases" "Connect to a DataBase" "Drop a DataBase" "Exit"; do
        case "$REPLY" in
        1)
            echo -e "Creating a new Database: \n"
            read -p "Please enter the database name: " databaseName

            if [ -d "databases/$databaseName" ]; then
                echo -e "There is already a database with this name! Please choose another name. \n"
            else
                mkdir "databases/$databaseName"
                echo -e "A new database has been created with the name $databaseName \n"
            fi
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
            if [ -d "databases/$connectedDatabase" ]; then
                ./databaseMenu.sh "$connectedDatabase"
            else
                echo -e "There are no Databases with this name! \n"
            fi
            ;;
        4)
            read -p "Please enter the database name you wish to drop: " dropDatabase
            if [ -d "databases/$dropDatabase" ]; then
                read -p "Do you want to continue? (y/n): " confirm
                if [[ "$confirm" =~ ^[Yy]$ ]]; then ## double confirming that You want to delete the database
                    echo "Continuing..."
                    rm -r "databases/$dropDatabase" # Changed from rmdir to rm -r to remove non-empty directories
                    echo -e "The Database named $dropDatabase has been removed! \n"
                else
                    echo -e "Aborted. \n"
                    exit 1
                fi
            else
                echo -e "There are no Databases with this name! \n"
            fi

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
