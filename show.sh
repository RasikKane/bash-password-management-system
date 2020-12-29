#! /bin/bash
exitcode=1

if [ $# -gt 2 ]; then
    echo "Error: parameters problem"
elif [ $# -lt 2 ]; then
         echo "Error: parameters problem"
elif [ $# -eq 2 ];then
        dir_name=$1
        f_name=./$2
        #check if the argument leads to a present directory
        if ! [ -d "$dir_name" ]; then
                echo "Error: user does not exists"
        elif [ -d "$dir_name" ]; then
		if ! [ -f "$dir_name/$f_name" ]; then
			echo "Error: service does not exists"
                elif [ -f "$dir_name/$f_name" ]; then
			cat "$dir_name/$f_name"
                fi
        fi
else
        echo "Error: parameters problem"
fi
# at the end of the script an exit code 0 means everything went well
exit "$exitcode"
