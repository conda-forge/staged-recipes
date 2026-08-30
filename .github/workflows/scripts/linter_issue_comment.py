import argparse
import logging
import os
import sys

import github


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Rerun the staged-recipe's linter on PR comments."
    )
    parser.add_argument("--owner", type=str, required=True, help="the repo owner")
    parser.add_argument("--pr-num", type=int, required=True, help="the PR number")

    args = parser.parse_args()

    gh = github.Github(auth=github.Auth.Token(os.getenv("GH_TOKEN")))
    repo = gh.get_repo(f"{args.owner}/staged-recipes")
    pr = repo.get_pull(args.pr_num)

    if pr.state == "closed" or pr.merged == True:
        sys.exit(0)

    commit = repo.get_commit(pr.head.sha)

    linter_check_suite = None
    for check_suite in commit.get_check_suites():
        for check_run in check_suite.get_check_runs():
            if check_run.name == "linter":
                linter_check_suite = check_suite
                break
        if linter_check_suite is not None:
            break

    if linter_check_suite is not None:
        try:
            linter_check_suite.rerequest()
        except Exception as e:
            if "This check suite is already re-running" in str(e):
                logging.warning(
                    "Staged-recipes linter for PR %d is already running!",
                    args.pr_num,
                )
            else:
                logging.exception(
                    "Could not rerun staged-recipes linter for PR %d!",
                    args.pr_num,
                    exc_info=e,
                )
            pass
    else:
        logging.warning(
            "Could not find a staged-recipes linter run for PR %d!",
            args.pr_num,
        )
