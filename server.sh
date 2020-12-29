#! /bin/bash
if ! [ -p "server.pipe" ];then
	mkfifo "server.pipe"
fi
commands=("init" "insert" "show" "update" "rm" "ls" "shutdown")
while true; do
	exitcode=0
       while read -r -a array; do
        len=${#array[@]}
	arg=()
	if [[ "${commands[@]}" =~ ${array[1]} ]];then
		status=1
	fi
	if [ "$len" -lt 3 -o "$status" != 1 ]; then
		exitcode=1
	else
		if ! [ -p "${array[0]}".pipe ];then
			mkfifo "${array[0]}".pipe
		fi
		arg[0]="${array[2]}"
		for (( j=1,i=3; i< "$len" ; i++,j++ ));do
			if ! [ -z "${array[$i]}" ]; then
				arg[j]="${array[$i]}"
			fi
		done
	fi
	case "${array[1]}" in
	init)
		pipeOut=$(./init.sh "${arg[0]}")
		echo "$pipeOut" > "${array[0]}".pipe
	;;
	insert)
                payload=$(sed 's/--/ /g' <<< "${arg[2]}")
#		echo "$payload" > "${array[0]}".pipe
		pipeOut=$(./insert.sh "${arg[0]}" "${arg[1]}" "$payload")
		echo "$pipeOut" > "${array[0]}".pipe
	;;
	show)
#		pipeOut=()
#		while IFS= read -r line; do
#			pipeOut+=( "$line" )
#		done < <($(./show.sh "${arg[0]}" "${arg[1]}"))
#		pipeOut=$(sed 's/ /--/g' <<< "$pipeOut")
		pipeOut=$(./show.sh "${arg[0]}" "${arg[1]}")
		pipeOut=$(sed 's/ /--/g' <<< "$pipeOut")
		echo "$pipeOut" > "${array[0]}".pipe
	;;
	update)
		pipeOut=$(./insert.sh "${arg[0]}" "${arg[1]}" "${arg[2]}" "${arg[3]}")
		echo "$pipeOut" > "${array[0]}".pipe
	;;
	rm)
		pipeOut=$(./rm.sh "${arg[0]}" "${arg[1]}")
		echo "$pipeOut" > "${array[0]}".pipe
	;;
	ls)
		if [ "${#arg[@]}" -eq 1 ];then
			pipeOut=$(./ls.sh "${arg[0]}")
                elif [  "${#arg[@]}" -eq 2 ];then
                        pipeOut=$(./ls.sh "${arg[0]}" "${arg[1]}")
		fi
		echo -e "$pipeOut" > "${array[0]}".pipe
	;;
	shutdown)
		p=($(ls *.pipe))
		for (( i=0; i< "${#p[@]}" ; i++ ));do
			rm "${p[$i]}"
		done
		exit "$exitcode"
	;;
	*)
		echo "Error: bad request" > "${array[0]}".pipe
	;;
	esac
done<server.pipe
done

