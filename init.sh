#! /bin/bash
exitcode=1

#check the arguments
if [ $# -eq 0 ]; then
    echo "Error: parameters problem"

elif [ $# -ne 1 ]; then
    echo "Error: parameters problem"

elif [ $# -eq 1 ]; then
	./p.sh "$1"
	dir_name=$1

	#check if the argument leads to a present directory
	if [ -d "$dir_name" ]; then
    		echo "Error: user already exists"

	elif ! [ -d "$dir_name" ]; then
		mkdir ./"$dir_name"
		if [ -d "$dir_name" ]; then
    			echo "OK: user created"
			exitcode=0 # the exit code 0 means everything went well
		fi
	fi
	./v.sh "$1"
fi
# at the end of the script an exit code 0 means everything went well
exit "$exitcode"

