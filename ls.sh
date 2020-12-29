#! /bin/bash

exitcode=1
flag=0

if [ $# -gt 2 ]; then
    echo -e "Error: parameters problem"

elif [ $# -lt 1 ]; then
         echo "Error: parameters problem"

elif [ $# -le 2 ];then
        dir_name=$1
	if { [ "$#" -eq 2 ]  && ! [ -z "$2" ] ;};then
        	f_name=$2
		flag=1
	fi

        #check if the argument leads to a present directory
        if ! [ -d "$dir_name" ]; then
                echo "Error: user does not exists"

        elif [ -d "$dir_name" ]; then
		if [ "$flag" -eq 1 ];then
	                if ! [ -d "$dir_name/$f_name" ]; then
        	                echo "Error: folder does not exists"
        	        elif [ -d "$dir_name/$f_name" ]; then
				cd "$dir_name"
				echo "OK:"
				tree  --noreport "$f_name"
				cd ..
				exitcode=0
			fi
                else
			echo "OK:"
			tree --noreport "$dir_name"
			exitcode=0
		fi
        fi

else
        echo "Error: parameters problem"

fi

exit "$exitcode"
