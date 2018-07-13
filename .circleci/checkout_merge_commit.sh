#!/bin/bash


# Update PR refs for testing.
if [[ -n "${CIRCLE_PR_NUMBER}" ]]
then
    FETCH_REFS="${FETCH_REFS} +refs/pull/${CIRCLE_PR_NUMBER}/head:pr/${CIRCLE_PR_NUMBER}/head"
    FETCH_REFS="${FETCH_REFS} +refs/pull/${CIRCLE_PR_NUMBER}/merge:pr/${CIRCLE_PR_NUMBER}/merge"
fi

# Retrieve the refs.
if [[ -n "${CIRCLE_PR_NUMBER}" ]]
then
    git fetch -u origin ${FETCH_REFS}
fi

# Checkout the PR merge ref.
if [[ -n "${CIRCLE_PR_NUMBER}" ]]
then
    git checkout -qf "pr/${CIRCLE_PR_NUMBER}/merge"
fi

# Check for merge conflicts.
if [[ -n "${CIRCLE_PR_NUMBER}" ]]
then
    git branch --merged | grep "pr/${CIRCLE_PR_NUMBER}/head" > /dev/null
fi
