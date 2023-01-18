# !/bin/bash
# SIMPLE DC AUTO CHAT TO CHANNEL [ RANDOM MSG ]
# CREATED BY : ./LAZYBOY - JAVAGHOST TEAM

# INPUT FIELD SEPARATORS
IFS=$'\n'

# CREATE ARRAY FROM FILE
RANDOM_MSG_FILE="list_random_msg.txt"
RANDOM_MSG=($(< "${RANDOM_MSG_FILE}"))

# LOG RESPONSE
LOG_RESPONSE=".MSG_RESPONSE.tmp"

# DEFAUTL DELAY MSG
DELAY="60"

# EMPETY ARRAY
END_MSG=()

# BASE URL
DISCORD_BASE_URL="https://discordapp.com"

# SETUP YOUR DISCORD TOKEN HEREEE
DISCORD_TOKEN="Java.Ghost.13-3-7"
if [[ -z $DISCORD_TOKEN ]]; then
	echo "[ ERROR ] - PLEASE SETUP YOUR DISCORD TOKEN"
	exit
fi

# SET UA
USERAGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/97.0.4692.71 Safari/537.36"

# BANNER
echo '''
               ____  ______   ___         __        ________          __ 
              / __ \/ ____/  /   | __  __/ /_____  / ____/ /_  ____ _/ /_
             / / / / /      / /| |/ / / / __/ __ \/ /   / __ \/ __ `/ __/
            / /_/ / /___   / ___ / /_/ / /_/ /_/ / /___/ / / / /_/ / /_  
           /_____/\____/  /_/  |_\__,_/\__/\____/\____/_/ /_/\__,_/\__/  
                    
                        - JAVAGHOST DISCORD AUTOCHAT -
'''

# ASK INPUT
read -p "[ ? ] CHANNEL TARGET ID : " ASK_CHANNEL
if [[ -z $ASK_CHANNEL ]]; then
	echo "[ ERROR ] - PLEASE INPUT VALID CHANNEL ID"
	exit
else
	echo -e "[ ? ] $(< $RANDOM_MSG_FILE wc -l) RANDOM MSG WILL BE SEND TO CHANNEL : ${ASK_CHANNEL} - WITH DELAY ${DELAY}sec/MESSAGE\n"

	# LOG MSG FILE
	LOG_MSG_FILE="log_msg_${ASK_CHANNEL}.tmp"
	
	# CREATE LOG MSG
	if [[ ! -e "${LOG_MSG_FILE}" ]]; then
		touch $LOG_MSG_FILE
	fi
fi

# FUNC FOR SEND MSG USING DISCORD API
function DISCORD_SEND_MSG(){
	curl -sXPOST "${DISCORD_BASE_URL}/api/channels/${ASK_CHANNEL}/messages" \
			-H "Authorization: ${DISCORD_TOKEN}" \
			-H "User-Agent: ${USERAGENT}" \
			-H "Content-Type: application/json" \
			-d "{\"content\":\"${1}\"}"
}

# FUNC FOR DELETE MSG
function DISCORD_DEL_MSG(){
	curl -sXDELETE "${DISCORD_BASE_URL}/api/v6/channels/${ASK_CHANNEL}/messages/${1}"\
			-H "Authorization: ${DISCORD_TOKEN}" \
			-H "User-Agent: ${USERAGENT}"
}

# MAIN SCRIPT
while [[ true ]]; do
	# CREATE RANDOM MSG FROM ARRAY
	GET_RANDOM_MSG="${RANDOM_MSG[$(date "+%s") % ${#RANDOM_MSG[@]}]}"
	if [[ -z "$GET_RANDOM_MSG" ]]; then
		continue
	fi

	LOG_MSG=$(cat "$LOG_MSG_FILE")
	if [[ "${END_MSG[@]}" =~ "$GET_RANDOM_MSG" ]]; then
		if [[ "${#END_MSG[@]}" -eq "${#RANDOM_MSG[@]}" ]]; then
			echo -e "\n[ ! ] ALL MESSAGE ALREADY SENDING TO THIS CHANNEL [ ${ASK_CHANNEL} ]"
			echo "[ INFO ] REMOVE ${LOG_MSG_FILE} TO RUN AGAIN THIS TOOL"
			break
		fi
	else
		END_MSG+=("$GET_RANDOM_MSG")
	fi

	if ! [[ "$LOG_MSG" =~ "$GET_RANDOM_MSG" ]]; then
		# CHECK RESPONSE
		DISCORD_SEND_MSG "${GET_RANDOM_MSG}" | grep -Po '"(content|id)": "\K[^"]+' | head -n2 | tr "\n" ":" > "${LOG_RESPONSE}"

		# CHECK
		GET_RESPONSE=$(cat "${LOG_RESPONSE}" | cut -d ":" -f2)
		if [[ ! -z "${GET_RESPONSE}" ]]; then
			# INFO
			echo -e " [ $(date "+%X") ] - SUCCESS SENDING MSG : ${GET_RANDOM_MSG} - TO CHANNEL ID : ${ASK_CHANNEL}"
			echo "$GET_RANDOM_MSG" >> $LOG_MSG_FILE
			sleep "${DELAY}s"

			# DEL MESSAGE
			MSG_ID=$(cat "${LOG_RESPONSE}" | cut -d ":" -f1)
			DISCORD_DEL_MSG "${MSG_ID}"
		else
			echo -e " [ $(date "+%X") ] - FAILED SENDING MSG : ${GET_RANDOM_MSG} - TO CHANNEL ID : ${ASK_CHANNEL}"
			echo "$GET_RANDOM_MSG" >> $LOG_MSG_FILE
			sleep "${DELAY}s"
		fi
	fi
done
# END