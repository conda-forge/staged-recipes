import argparse
import os

import github
import requests


def _get_latest_run_summary(repo, workflow_run_id):
    latest_run = repo.get_workflow_run(workflow_run_id)
    for job in latest_run.jobs():
        pass

    r = requests.get(job.logs_url())

    summary = ""
    in_summary = False
    for line in r.text.splitlines():
        line = line.strip()
        if "###START-OF-SUMMARY###" in line:
            in_summary = True
            head_len = len(line.split("###START-OF-SUMMARY###")[0])
            continue

        if "###END-OF-SUMMARY###" in line:
            in_summary = False
            break

        if in_summary:
            line = line[head_len:]
            summary += line + "\n"

    return summary


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Lint staged recipes.")
    parser.add_argument(
        "--head-repo-owner", type=str, required=True, help="the head repo owner"
    )
    parser.add_argument(
        "--workflow-run-id", type=int, required=True, help="the ID of the workflor run"
    )
    parser.add_argument(
        "--head-sha", type=str, required=True, help="the head SHA of the PR"
    )

    args = parser.parse_args()

    gh = github.Github(auth=github.Auth.Token(os.environ["GH_TOKEN"]))
    head_repo = gh.get_repo(f"{args.head_repo_owner}/staged-recipes")
    base_repo = gh.get_repo("conda-forge/staged-recipes")

    summary = _get_latest_run_summary(base_repo, args.workflow_run_id)
    if summary:
        print(summary)
        commit = head_repo.get_commit(args.head_sha)
        pr = None
        for _pr in commit.get_pulls():
            if _pr.base.repo.full_name == base_repo.full_name:
                pr = _pr
                break

        if pr is None:
            # for reasons I do not follow, sometimes the head commit API
            # to get pull requests does not return the PR.
            # So we try looking at PRs from base repo and find the same
            # sha+head repo but limit the search since staged-recipes
            # gets tons of PRs.
            max_tries = 50
            num_tries = 0
            for _pr in base_repo.get_pulls():
                if (
                    _pr.head.sha == args.head_sha
                    and _pr.head.repo.full_name == head_repo.full_name
                ):
                    pr = _pr
                    break
                num_tries += 1
                if num_tries == max_tries:
                    break

        if pr is not None:
            comment = None
            for _comment in pr.get_issue_comments():
                if "Hi! This is the staged-recipes linter" in _comment.body:
                    comment = _comment

            if comment:
                if comment.body != summary:
                    curr_fline = comment.body.splitlines()[0].strip()
                    new_fl = summary.splitlines()[0].strip()
                    if curr_fline == new_fl:
                        comment.edit(summary)
                    else:
                        pr.create_issue_comment(summary)
            else:
                pr.create_issue_comment(summary)
        else:
            print("No PR found for the given commit. No comment being made!")
