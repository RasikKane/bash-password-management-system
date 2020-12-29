#! /bin/bash

commands=("init" "insert" "show" "edit" "rm" "ls" "shutdown")

status=0

array=("$@")
len=${#array[@]}

if [[  "${commands[@]}" =~ ${array[1]} ]];then
        status=1
fi

if  { [ \( "$len" -lt 3 -o "$len" -gt 4 \) -a  "${array[1]}" != "shutdown" ] || [ "$status" != 1 ] ;}; then
        echo "Error: parameter problem"
        exitcode=1
elif [ -p "server.pipe" ];then
	exitcode=0
	case "${array[1]}" in
	init)
                if [ "$len" -eq 3 ];then
	        	echo  "${array[0]}" "${array[1]}" "${array[2]}" > server.pipe
			while ! [ -p "${array[0]}".pipe ];do
				sleep 1
			done
		        read pipeIn < "${array[0]}".pipe
			echo "$pipeIn"
			exitcode=0
		else
			echo "Error: parameters problem"
			exitcode=1
		fi
	;;
	insert)
		if [ "$len" -eq 4 ];then
			read -p 'Please write login: ' login
			read -sp 'Please write password: ' pass
			echo -e "\n"
			if { [[ $login == *"--"* ]] || [[ $pass == *"--"* ]] ;}; then
				echo "Do not use pattern -- in user input"
			else
				login=$(sed 's/ /--/g' <<< $login)
				pass=$(sed 's/ /--/g' <<< $pass)
				payload="login:--$login\npassword:--$pass"
	                	echo  "${array[0]}" "${array[1]}" "${array[2]}" "${array[3]}" "$payload" > server.pipe
		                while ! [ -p "${array[0]}".pipe ];do
	        	                sleep 1
		                done
		                read pipeIn < "${array[0]}".pipe
	                	echo -e "$pipeIn"
                		exitcode=0
			fi
                else
                        echo "Error: parameters problem"
                        exitcode=1
		fi
	;;
	show)
                if [ "$len" -eq 4 ];then
	                echo  "${array[0]}" "${array[1]}" "${array[2]}" "${array[3]}" > server.pipe
        	        while ! [ -p "${array[0]}".pipe ];do
                	        sleep 1
	                done
                        while read pipeIn; do
                                str="$(sed 's/--/ /g' <<< "$pipeIn")"
				if [[ $str == *"login: "* ]];then
					str=$(sed 's/login: / /1' <<< "$str")
					echo "${array[0]}'s login for ${array[3]} is: $str"
                                elif [[ $str == *"password: "* ]];then
                                        str=$(sed 's/password: / /1' <<< "$str")
                                        echo "${array[0]}'s password for ${array[3]} is: $str"
				else
					echo "$str"
				fi
                        done < "${array[0]}".pipe

#        	        read -r pipeIn < "${array[0]}".pipe
#			pipeIn=$(sed 's/--/ /g' <<< "$pipeIn")
#			login=$(sed 's/.*login:  \(.*\)n/\1/' <<< $pipeIn)
#			pass=$(sed 's/ /--/g' <<< $pipeIn)
#			echo "$login"
#			echo "$pass"
#	                echo "$pipeIn"
		        exitcode=0
                else
                        echo "Error: parameters problem"
                        exitcode=1
		fi
	;;
	edit)
		if [ "$len" -eq 4 ];then
	                echo "${array[0]}" "show" "${array[2]}" "${array[3]}" > server.pipe

                        while ! [ -p "${array[0]}".pipe ];do
                                sleep 1
                        done
                        while read pipeIn; do
                                str="$(sed 's/--/ /g' <<< "$pipeIn")"
                                if [[ $str == *"login: "* ]];then
                                        echo "$str" >> tempEdit
                                elif [[ $str == *"password: "* ]];then
                                        echo "$str" >> tempEdit
                                else
                                        echo "$str"
                                fi
                        done < "${array[0]}".pipe
			if [ -f tempEdit ];then
				nano tempEdit
				payload=$(cat tempEdit)
				rm tempEdit
#				if [[ $(wc -l <<<"$payload") == 2 ]];then
#				echo "$payload" 1
#				fi
				if {  { [[ $(wc -l <<<"$payload") == 2 ]] && ! [[ "$payload" == *"--"* ]] ;} && { [[ "$payload" == *"login: "* ]] && [[ "$payload" == *"password: "* ]] ;} ;}; then
					while read line;do
    						s="$s\n$line"
					done <<< "$payload"
					payload=$"${s:2}"
					payload=$(sed 's/ /--/g' <<< "$payload")
					echo "${array[0]}" "update" "${array[2]}" "${array[3]}" "f" "$payload" > server.pipe
					read pipeIn < "${array[0]}".pipe
					echo "$pipeIn"
			                exitcode=0
				else
					echo "Error: edited details not confirming with standard"
				fi
			fi
                else
                        echo "Error: parameters problem"
                        exitcode=1
		fi
	;;
	rm)
		if [ "$len" -eq 4 ];then
	                echo  "${array[0]}" "${array[1]}" "${array[2]}" "${array[3]}" > server.pipe
        	        while ! [ -p "${array[0]}".pipe ];do
                	        sleep 1
	                done
	                read pipeIn < "${array[0]}".pipe
	                echo "$pipeIn"
                	exitcode=0
                else
                        echo "Error: parameters problem"
                        exitcode=1
		fi
	;;
	ls)
		flag=0
		if [ "$len" -eq 4 ];then
	                echo  "${array[0]}" "${array[1]}" "${array[2]}" "${array[3]}" > server.pipe
			flag=1
                elif [ "$len" -eq 3 ];then
                        echo  "${array[0]}" "${array[1]}" "${array[2]}" > server.pipe
			flag=1
		fi
		if [ "$flag" = 1 ];then
	        	while ! [ -p "${array[0]}".pipe ];do
        	        	sleep 1
		        done
		        while read pipeIn; do
				echo "$pipeIn"
			done < "${array[0]}".pipe
	                exitcode=0
                else
                        echo "Error: parameters problem"
                        exitcode=1
		fi
	;;
	shutdown)
		if [ "$len" -eq 2 ];then
	                echo  "${array[0]}" "${array[1]}" > server.pipe
	                exitcode=0
                else
                        echo "Error: parameters problem"
                        exitcode=1
		fi
                exitcode=0
	;;
	*)
		echo "Error: bad request"
	;;
	esac
else
	echo "Error: bad server connection"
	exitcode=1
fi
rm -rf "${array[0]}".pipe
exit "$exitcode"

