#!/bin/bash 

echo "Welcome to your DataBase Mangement Software."
PS3="Selection : "
while true; do 
select ch  in "Create a new DataBase" "List all available Databases"  "Connect to a DataBase" "Drop a DataBase" "Exit"
    do 
	    case "$REPLY" in
                1) ls 
		        ;;
		        2) echo "Printing Available Databases:"; 
                   dir_count=0
                   if [ -d databases ]; then
                        for d in databases/*/; do
                            if [ -d "$d" ]; then
                                ((dir_count++))
                            fi
                        done
                    fi

                    if [ "$dir_count" -gt 0 ]; then
                        for d in databases/*/; do
                            if [ -d "$d" ]; then
                                d="${d%/}"
                                echo "${d##*/}"
                            fi
                        done
                    else    
                        echo "There are no Available databases right now!"
                    fi
                ;;
		        3) ls
		        ;;
                4) ls
                ;;
                5) exit
                ;;
		        *) echo "please select one of choices, $REPLY is out of range."
                ;;
        esac
        break;
    done
done