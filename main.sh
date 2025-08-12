#!/bin/bash

PIDFILE="/tmp/nloy.pid"

if [[ ! -f "$PIDFILE" ]]; then
    touch "$PIDFILE"
fi

red() {
    echo -e "\033[31m$1\033[0m"
}

green() {
    echo -e "\033[32m$1\033[0m"
}

yellow() {
    echo -e "\033[33m$1\033[0m"
}

blue() {
    echo -e "\033[34m$1\033[0m"
}

white() {
    echo -e "\033[37m$1\033[0m"
}

logo() {
    red "    _   ____               "
    green "   / | / / /   ____  __  __"
    yellow "  /  |/ / /   / __ \/ / / /"
    blue " / /|  / /___/ /_/ / /_/ / "
    red "/_/ |_/_____/\____/\__, /  "
    green "                  /____/   "
    echo -e "\n"
}

help() {
    logo
    echo -n "$(blue "Usage: ")"
    echo -e "nloy COMMAND\n"
    echo "Commands:"
    echo "  help       Show this help message"
    echo "  deploy     Deploy an application"
    echo "  ps         Check active deployments status"
    echo -e "\nRun $(blue "nloy COMMAND help") for more information on a command."
}

success() {
    echo "$(green "Success:") $1"
}

error() {
    echo "$(red "Error:") $1"
}

find_free_port() {
    local port=$1
    while ss -tuln | grep -q ":$port"; do
        ((port++))
    done
    echo $port
}

deploy_react() {
    if [ ! -f "package.json" ]; then
        error "package.json not found in the current directory."
        return
    elif [[ ! -f "vite.config.js" && ! -f "vite.config.ts" ]]; then
        error "vite config not found in the current directory."
        return
    fi

    local PORT=$(find_free_port 3000)

    blue "Installing dependencies for React Vite deployment..."
    npm install > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        error "Failed to install dependencies."
        return
    fi

    blue "Building React Vite application..."
    npm run build > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        error "Failed to build React Vite application."
        return
    fi

    blue "Starting React Vite deployment..."
    npm run preview -- --port "$PORT" > /dev/null 2>&1 &
    local PREVIEW_PID=$!

    sleep 1
    local PID=$(lsof -t -i TCP:$PORT -s TCP:LISTEN)
    if [ -n "$PID" ]; then
        echo "$PID|react|$PORT" >> "$PIDFILE"
        success "React Vite deployment started on port $PORT (PID: $PID)"
    else
        error "Failed to detect server PID for port $PORT"
    fi
}

deploy() {
    if [[ -z "$1" || "$1" == "help" ]]; then
        echo -e "$(blue "Usage:") nloy deploy COMMAND\n"
        echo "Commands:"
        echo -e "  react      Start a React Vite deployment"
        echo -e "  node       Start a Node.js deployment\n"
        echo "Run $(blue "nloy deploy COMMAND help") for more information on a command."
        return
    fi

    case "$1" in
        react)
            deploy_react
            ;;
        node)
            echo "Starting Node.js deployment..."
            # Add Node.js deployment logic here
            ;;
        help)
            echo -e "$(blue "Usage:") nloy deploy COMMAND\n"
            echo "Available commands for deploy:"
            echo "  react      Start a React Vite deployment"
            echo "  node       Start a Node.js deployment"
            ;;
        *)
            echo "$(red "Unknown deploy command:") $2"
            help
            ;;
    esac
}

kill_process() {
    if [[ ! -f "$PIDFILE" || ! -s "$PIDFILE" ]]; then
        error "No active deployments found."
        return
    fi

    if [[ -z "$1" ]]; then
        error "Please provide a PID to kill."
        return
    fi

    local PID_LINE
    PID_LINE=$(grep -E "^$1\|" "$PIDFILE")

    if [[ -z "$PID_LINE" ]]; then
        error "No deployment found with PID $1."
        return
    fi

    local PID
    PID=$(echo "$PID_LINE" | cut -d'|' -f1)

    if kill -0 "$PID" 2>/dev/null; then
        kill "$PID"
        sed -i "/^${PID}\|/d" "$PIDFILE"  # Needs escaping of the pipe
        sed -i "/^${PID}\\|/d" "$PIDFILE" # Proper escape for literal '|'
        success "Deployment with PID $PID has been killed."
    else
        error "No process found with PID $PID."
    fi
}

ps() {
    if [[ ! -f "$PIDFILE" || ! -s "$PIDFILE" ]]; then
        error "No active deployments found."
        return
    fi

    green "Active deployments:"
    while IFS="|" read -r PID NAME PORT; do
        if kill -0 "$PID" 2>/dev/null; then
            echo "$(green "PID:") $PID | $(blue "Name:") $NAME | $(yellow "Port:") $PORT"
        else
            echo "$(red "PID:") $PID | $(blue "Name:") $NAME | $(yellow "Port:") $PORT (not running)"
        fi
    done < "$PIDFILE"
}

if [[ -z "$1" || "$1" == "help" ]]; then
    help
elif [ "$1" == "deploy" ]; then
    deploy $2
elif [ "$1" == "ps" ]; then
    ps
elif [ "$1" == "kill" ]; then
    kill_process $2
else
    echo "$(red "Unknown command:") $1"
    help
fi

