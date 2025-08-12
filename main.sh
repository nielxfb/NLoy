#!/bin/bash

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
    echo "nloy <COMMAND>"
    echo "Commands:"
    echo "  help       Show this help message"
    echo "  deploy     Deploy an application"
    echo "  ps         Check active deployments status"
    echo ""
}

if [[ -z "$1" || "$1" == "help" ]]; then
    help
elif [ "$1" == "deploy" ]; then
    echo "Deploying application..."
    # Add deployment logic here
elif [ "$1" == "ps" ]; then
    echo "Checking active deployments status..."
    # Add status checking logic here
else
    echo -n "$(red "Unknown command: ")"
    white $1
    help
fi

