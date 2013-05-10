#!/bin/bash

# --------- License Info ---------
# Copyright 2013 Emind Systems Ltd - htttp://www.emind.co
# This file is part of Emind Systems DevOps Tool set.
# Emind Systems DevOps Tool set is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# Emind Systems DevOps Tool set is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with Emind Systems DevOps Tool set. If not, see http://www.gnu.org/licenses/.

SERVER_URL=""
API_KEY=""
TIME_DIFF=""
STREAM_NAME=""
INVERT="OFF"

function write_log (){
        logger  -t "check_graylog_stream" "pid=$$ Msg=$*"
}

function get_streams_json()
{
        curl -s -o ${GRAYLOG2_STREAMS_FILE} ${STREAM_URL}
        if [ $? -ne 0 ]; then
                write_log "failed to fetch json from ${STREAM_URL}"
                exit 99
        fi
}

function get_stream_index
{
        TARGET_STREAM_TITLE=$1
        STREAM_INDEX=0
        CURRENT_STREAM_TITLE=""
        SEARCH_STATUS=false
        FIRST_STREAM_TITLE=$(jshon -e ${STREAM_INDEX} -e "title" -u < ${GRAYLOG2_STREAMS_FILE})
         write_log "FIRST_STREAM_TITLE=${FIRST_STREAM_TITLE}"
        while true; do
                CURRENT_STREAM_TITLE=$(jshon -e ${STREAM_INDEX} -e "title" -u < ${GRAYLOG2_STREAMS_FILE})
                if [ "${TARGET_STREAM_TITLE}" == "${CURRENT_STREAM_TITLE}" ]; then
                                SEARCH_STATUS=true
                                break
                elif [ ${STREAM_INDEX} -gt 0 ] && [ "${CURRENT_STREAM_TITLE}" == "${FIRST_STREAM_TITLE}" ]; then
                                break
                fi
                STREAM_INDEX=$(( ${STREAM_INDEX} + 1 ))
        done
        write_log "TARGET_STREAM_TITLE=${TARGET_STREAM_TITLE} STREAM_INDEX=${STREAM_INDEX}"
}

while getopts ig:k:t:s: flag; do
  case $flag in
    g)
                SERVER_URL=$OPTARG
                ;;
    k)
                API_KEY=$OPTARG
                ;;
    t)
        TIME_DIFF=$OPTARG
                ;;
    s)
        STREAM_NAME=$OPTARG
                ;;
    i)
        INVERT="ON"
                ;;
  esac
done

if [ "x${SERVER_URL}" == "x" ] || [ "x${API_KEY}" == "x" ] || [ "x${TIME_DIFF}" == "x" ] || [ "x${STREAM_NAME}" == "x" ]; then
        echo "Missing input parameter"
        echo "Usage: $0 -g <graylog server url> -k <graylog api_key> -t <alarm age> -s <stream name>"
        exit 99
fi

write_log "CMD Params: -g ${SERVER_URL} -k ${API_KEY} -t ${TIME_DIFF} -s ${STREAM_NAME}"

STREAM_URL="${SERVER_URL}/streams.json?api_key=${API_KEY}"
GRAYLOG2_STREAMS_FILE="/tmp/$$.json"

get_streams_json
get_stream_index "${STREAM_NAME}"

LAST_ALARM=$(jshon -e ${STREAM_INDEX} -e "last_alarm" -u < ${GRAYLOG2_STREAMS_FILE} 2> /dev/null)
rm -rf ${GRAYLOG2_STREAMS_FILE}

if [ ${SEARCH_STATUS} == false ]; then
        echo "Unknown Stream:${STREAM_NAME}"
        write_log "Unknown Stream:${STREAM_NAME}"
        exit 99
fi

if [ "${LAST_ALARM}" != "" ]; then
        ALARM_AGE=$(expr $(date +%s) - ${LAST_ALARM})
        #ALARM_TIME=$(date --date="${ALARM_AGE} seconds ago" +%x-%X)
        ALARM_TIME=$(date --date="${ALARM_AGE} seconds ago" -u )
else
        ALARM_AGE=""
fi

ALARM_STATE="UNKNOWN"

if [ "${ALARM_AGE}" != "" ] && [ ${ALARM_AGE} -lt ${TIME_DIFF} ]; then
        ALARM_STATE="ON"
        write_log "Alarm:ON - Stream:${STREAM_NAME} Last-alarm:${ALARM_TIME}"
else
        ALARM_STATE="OFF"
        write_log "Alarm:OFF - Stream:${STREAM_NAME} Last-alarm:${ALARM_TIME}"
fi
write_log "INVERT=$INVERT"

if [ "${ALARM_STATE}" = "ON" ] && [ "$INVERT" = "OFF" ]; then
        echo "Alarm:${ALARM_STATE} - Stream:${STREAM_NAME} Last-alarm:${ALARM_TIME}"
        write_log "Exit Code:2"
        exit 2
elif [ "${ALARM_STATE}" = "OFF" ] && [ "$INVERT" = "OFF" ]; then
        echo "Alarm:${ALARM_STATE} - Stream:${STREAM_NAME} Last-alarm:${ALARM_TIME}"
        write_log "Exit Code:0"
        exit 0
elif [ "${ALARM_STATE}" = "ON" ] && [ "$INVERT" = "ON" ]; then
        echo "Alarm:${ALARM_STATE} - Stream:${STREAM_NAME} Last-alarm:${ALARM_TIME}"
        write_log "Exit Code:0"
        exit 0
elif [ "${ALARM_STATE}" = "OFF" ] && [ "$INVERT" = "ON" ]; then
        echo "Alarm:${ALARM_STATE} - Stream:${STREAM_NAME} Last-alarm:${ALARM_TIME}"
        write_log "Exit Code:2"
        exit 2
fi
