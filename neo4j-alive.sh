#! /bin/bash

HELP="
    usage: $0 [ -u username -p password ]

        -u --> Username of Neo4J
        -p --> Password of Neo4J
"
if [ "$#" -lt 2 ]; then 
    echo "${HELP}"    
else 
    default_username="neo4j"
    default_password="GBRjQIX-h305bec-zO77HHw-5uBwvS9"

    while [ -n "${1}" ]; do
        case "${1}" in
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

    if [ -z "${username}" ]; then
        username="${default_username}"
    fi

    if [ -z "${password}" ]; then
        password="${default_password}"
    fi
    
    connection_check="$(cypher-shell -u "$username" -p "$password" "RETURN 1;")"
    if [ "$?" -eq 0 ]; then
        status="OK"
        message_string="Postgres is alive"
        status_code=0
    else
        status="CRITICAL"
        message_string="$connection_check"
        status_code=1

    fi

    status_message="${status}: ${message_string}"
    echo "$status_message"
    exit "${status_code}"
fi
