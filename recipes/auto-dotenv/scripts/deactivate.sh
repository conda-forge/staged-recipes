#!/usr/bin/env bash

# Reset env variables to pre-activation values
for env_var in ${DOTENV_STACK[@]}; do
    eval $env_var;
done

# Cleanup
unset env_var
unset DOTENV_STACK
