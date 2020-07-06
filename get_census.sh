#!/bin/bash
#
# Request data from the Census API.
# NB: A future version will sum variables that share a label.
# 
# Patrick Lavallee Delgado
# University of Chicago
# February 2020
# 
################################################################################
# Capture and initialize constants.
################################################################################
config_path=$1
if [[ $2 == '' ]]
then
    db_path='acs.sqlite3'
else
    db_path=$2
fi
awk_path='preprocess.awk'
STATES=(01 02 04 05 06 08 09 10 12 13 {15..42} {44..51} {53..56})
################################################################################
# Read the configuration file.
################################################################################
geography=$(cat $config_path | grep '^geography' | sed -E 's/^[^:]*: *(.*)/\1/')
table=$(cat $config_path | grep '^table' | sed -E 's/^[^:]*: *(.*)/\1/')
endpoint=$(cat $config_path | grep '^endpoint' | sed -E 's/^[^:]*: *(.*)/\1/')
requests=($(cat $config_path | grep -En '^[0-9]{4}' | cut -f 1 -d ':'))
# Create the destination table if it does not exist yet.
sqlite3 $db_path << EOF
CREATE TABLE IF NOT EXISTS $table (
$(printf '\t')year INTEGER,
$(printf '\t')$geography INTEGER,
$(
    cat $config_path \
    | head -n $((${requests[2]} - 1)) \
    | tail -n $((${requests[2]} - ${requests[1]} - 1)) \
    | sed -Ee 's/^.*: ?([A-Za-z0-9_]*) *$/\1/' \
    | sed -e "s/^/$(printf '\t')/g" -e "s/$/ NUMERIC,/g" -e '$s/.$//'
)
);
EOF
################################################################################
# Request the data from the API.
################################################################################
for r in ${!requests[@]}
do 
    # Identify the lines in the config file that correspond to this request.
    begin=${requests[$r]}
    if [[ $r == $((${#requests[@]} - 1)) ]]
    then
        end=$(cat $config_path | wc -l | sed 's/$/+1/g' | bc)
    else
        end=${requests[$r + 1]}
    fi
    # Get the year of the data.
    year=$(
        cat $config_path \
        | head -n $begin \
        | tail -n 1 \
        | sed -E 's/(^[0-9]{4}).*$/\1/'
    )
    # Collect the variable codes and labels for this request.
    variables=$(
        cat $config_path \
        | head -n $(($end - 1)) \
        | tail -n $(($end - $begin - 1)) \
        | sed -E 's/^ *([A-Z0-9_]*):.*$/\1/' \
        | grep '^[A-Z0-9]' \
        | tr '\n' ',' \
        | sed 's/,$//'
    )
    # Request these variables by state.
    for state in ${STATES[@]}
    do 
        # Write the API call.
        call=$(echo $endpoint | sed "s/!!YEAR!!/$year/")'get='$variables
        if [[ $geography == 'state' ]]
        then
            call=$call'&for='$geography':'$state
        else
            call=$call'&for='$geography':*&in=state:'$state
        fi
        # echo $call
        # Request the data and load the response into the database.
        wget -qO- $call \
        | tail -n +2 \
        | sed -Ee 's/^\[{1,2}"//' -Ee 's/"\]{1,2},?$//' \
        | awk -v yr=$year -v geo=$geography -f $awk_path \
        | sqlite3 $db_path '.import /dev/stdin '$table
    done
done
