#! /bin/bash

HELP="
    usage: $0 [ -w value -c value -m value -u username -p password ]

        -w --> Warning value of number of connections
        -c --> Critical value number of connections
        -m --> Maximum number of connections configuring to Neo4J database
        -u --> Neo4J Username < default username: neo4j)
        -p --> Neo4J Password < default password neo4j)
"
if [ "$#" -lt 2 ]; then 
    echo "${HELP}"   
else 
    while [ -n "${1}" ]; do
        case "${1}" in
            -w | --warning-connections)
                w_connections="${2}"
                shift
                shift
                ;;
            -c | --critical-count)
                c_connections="${2}"
                shift
                shift
                ;;
            -m | --max-connections)
                max_connections="${2}"
                shift
                shift
                ;;
            -u | --username)
                username="${2}"
                shift
                shift
                ;;
            -p | --password)
                password="${2}"
                shift
                shift
                ;;
        esac
    done

    if [ -z "${c_connections}" -o -z "${w_connections}" ]; then
        status="${HELP}"
        message_string="Both critical and warning thresholds must be defined"
        status_code=1
    else
        connection_check="$(cypher-shell -u "$username" -p "$password" "RETURN 1;")"
        if [ $? -ge 1 ]; then
            status="Connection ERROR"
            message_string="$connection_check"
            status_code=1
        else
            current_connections="$(cypher-shell -u "$username" -p "$password" "CALL dbms.listConnections()" | wc -l | awk '{print $1}')"
            available_connections="$(echo "$max_connections-($current_connections-1)" | bc -l | tr -d '\r')"

            if [ "$available_connections" -le "$c_connections" ]; then
                status="CRITICAL"
                message_string="Only $available_connections connections left available on Neo4J"
                status_code=1
            elif [ "$available_connections" -le "$w_connections" ]; then
                status="WARNING"
                message_string="Only $available_connections connections left available on Neo4J"
                status_code=2
            else
                status="OK"
                message_string="There are $available_connections connections available on Neo4J"
                status_code=0
            fi
        fi
    fi
    status_message="${status}: ${message_string}"
    echo "$status_message"
    exit "${status_code}"
fi    
