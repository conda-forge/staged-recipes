#!/bin/bash

set -euxo pipefail

# Only do anything meaningful in the main ofiwg/libfabric repo.  If
# we're not in that repo, then don't do anything because it confuses
# people who fork the libfabric repo if Nroff Elves commits show up in
# their fork with different git hashes than the Nroff Elves commits on
# the ofiwg/libfabric repo.
if test -n "$REPO"; then
    first=`echo $REPO | cut -d/ -f1`
    second=`echo $REPO | cut -d/ -f2`

    if test "$first" != "ofiwg" -o "$second" != "libfabric"; then
        cat <<EOF

The Nroff Elves are contractually obligated to only operate on the
ofiwg/libfabric repository.

Exiting without doing anything.

EOF
        exit 0
    fi
fi

# In June of 2021, ofiwg/libfabric changed its default branch from
# "master" to "main".  This confuses "hub" (because it still falls
# back to "master" when it can't figure out the target branch name).
# In nroff-elves.yaml, we load $BASE_REPO with
# ${{github.event.repository.default_branch}} and use that to tell
# "hub" what the base branch should be.  This works great... except
# sometimes $BASE_REPO is blank (when it should have a valid branch
# name in it).  So if we get here and $BASE_REPO is blank, just assume
# that it should be "main".  This is lame and shouldn't be necessary,
# but it prevents us all from getting Github Action failure emails.
# Sigh.
if test -z "$BASE_REF"; then
    BASE_REF=main
fi

# If we're here, we want to generate some nroff.  Woo hoo!
for file in `ls man/*.md`; do
    perl config/md2nroff.pl --source=$file
done

for file in `ls fabtests/man/*.md`; do
    perl config/md2nroff.pl --source=$file
done

git config --global user.name "OFIWG Bot"
git config --global user.email "ofiwg@lists.openfabrics.org"

branch_name=pr/update-nroff-generated-man-pages-$BASE_REF
git checkout -b $branch_name

set +e
git commit -as -m 'Updated nroff-generated man pages'
st=$?
set -e

if test $st -ne 0; then
    echo "Nothing to commit -- nothing to do!"
    exit 0
fi

# Yes, we committed something.  Push the branch and make a PR.
# Extract the PR number.
git push --set-upstream origin $branch_name
url=`gh pr create --base $BASE_REF --title 'Update nroff-generated man pages' --body ''`
pr_num=`echo $url | cut -d/ -f7`

# Wait for the required "DCO" CI to complete
i=0
sleep_time=5
max_seconds=300
i_max=`expr $max_seconds / $sleep_time`

echo "Waiting up to $max_seconds seconds for DCO CI to complete..."
while test $i -lt $i_max; do
    date
    set +e
    status=`gh pr checks | egrep '^DCO' | awk '{ print $2 }'`
    set -e
    if test "$status" = "pass"; then
        echo "DCO CI is complete!"
        break
    fi
    sleep $sleep_time
    i=`expr $i + 1`
done

status=0
if test $i -lt $i_max; then
    # rebase the commit onto the base branch
    gh pr merge $pr_num -r

    # command to do it by hand when "hub" was used which didn't have command
    # to merge a PR. keep it here for reference.
    #curl \
    #    -XPUT \
    #    -H "Authorization: token $GITHUB_TOKEN" \
    #    https://api.github.com/repos/$GITHUB_REPOSITORY/pulls/$pr_num/merge
else
    echo "Sad panda; DCO CI didn't complete -- did not merge $url"
    status=1
fi

# Delete the remote branch
git push origin --delete $branch_name
exit $status
