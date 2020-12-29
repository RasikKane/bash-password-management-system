#! /bin/bash

exitcode=1

if [ $# -gt 2 ]; then
    echo -e "Error: parameters problem"

elif [ $# -lt 2 ]; then
         echo "Error: parameters problem"

elif [ "$1" != "" -a "$2" != "" ];then
	./p.sh "$1"
        dir_name=$1
        f_name=$2
        #check if the argument leads to a present directory
        if ! [ -d "$dir_name" ]; then
                echo "Error: user does not exists"

        elif [ -d "$dir_name" ]; then
                if ! [ -f "$dir_name/$f_name" ]; then
                        echo "Error: service does not exists"
                elif  [ -f "$dir_name/$f_name" ]; then
                        rm "$dir_name/$f_name"
                        if ! [ -f "$dir_name/$f_name" ]; then
                                echo "OK: service removed"
                                exitcode=0
                        fi
		fi
	fi
	./v.sh "$1"
else
        echo "Error: parameters problem"
fi

exit "$exitcode"

