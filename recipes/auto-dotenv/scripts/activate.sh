#!/usr/bin/env bash

if [ -e "./.env" ]; then

    if [ ! -v "DOTENV_STACK" ]; then
        # Parse .env file
        dotenv_keys=$(sed -e '/^$/d' -e '/^#/d' -e 's/^export //' -e 's/=.*//' .env)

        # Split string by spaces
        if [ -n "$ZSH_VERSION" ]; then
            dotenv_keys=$(echo $dotenv_keys | tr '\n' ' ')
            dotenv_keys=(${(s/ /)dotenv_keys})
        fi

        # Preserve environment variables
        DOTENV_STACK=()

        for key in $dotenv_keys; do
            if [ -n "$ZSH_VERSION" ]; then
                DOTENV_STACK+="$key=${(P)key}";
            else
                DOTENV_STACK+=("$key=${!key}")
            fi
        done

        unset dotenv_keys
    fi

    # Load new environment variables
    source ./.env

fi
