#! /bin/bash

exitcode=1
flag=0

if [ $# -gt 4 ]; then
    echo -e "Error: parameters problem"

elif [ $# -lt 3 ]; then
         echo "Error: parameters problem"

elif [ $# -ge 3 ]; then
        dir_name=$1
        f_name=$2
	if  [ $# -eq 3 ];then
		op=""
		content=$3
	elif [ "$3" == "f" ];then
		op=$3
        	content=$4
	else
		op=""
		content=$4
        fi

	IFS='/' read -r -a array <<< "$f_name"
	len=${#array[@]}

	./p.sh "$1"
        #check if the argument leads to a present directory
        if ! [ -d "$dir_name" ]; then
                echo "Error: user does not exists"

        elif [ -d "$dir_name" ]; then
		if [ -f "$dir_name/$f_name" ];then
			if [ -z "$op" ]; then
				echo "Error: service already exists"
			elif [ "$op" == "f" ]; then
				echo -e "$content">"$dir_name/$f_name"
				echo "OK: service updated"
			fi

                elif ! [ -f "$dir_name/$f_name" ]; then
			if  [ "$len" -gt 1 ]; then
				dname="$dir_name"
				for (( i=0; i< ( "$len"-1 ) ; i++ ));do
					dname="$dname/${array[$i]}"
					if [ -f "$dname" ];then
						flag=1
						echo "Error: can not create folder $dname - file $dname already exists"
					elif ! [ -d "$dname" ]; then
						mkdir "$dname"
					fi
        			done
			fi
			if [ "$flag" -eq 0 ]; then
				touch ./"$dir_name/$f_name"
				echo -e "$content">>"$dir_name/$f_name"
	                	if [ -f  "$dir_name/$f_name" ]; then
        	        		echo "OK: service created"
                	        	exitcode=0 # the exit code 0 means everything went well
				fi
			fi
                fi
        fi
	./v.sh "$1"
else
        echo "Error: parameters problem"

fi

# at the end of the script an exit code 0 means everything went well
exit "$exitcode"

