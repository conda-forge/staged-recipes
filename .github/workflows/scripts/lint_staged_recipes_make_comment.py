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
    parser = argparse.ArgumentParser(description='Lint staged recipes.')
    parser.add_argument('--owner', type=str, required=True, help='the repo owner')
    parser.add_argument('--workflow-run-id', type=int, required=True, help='the ID of the workflor run')
    parser.add_argument('--head-sha', type=str, required=True, help='the head SHA of the PR')

    args = parser.parse_args()

    gh = github.Github(auth=github.Auth.Token(os.environ["GH_TOKEN"]))
    repo = gh.get_repo(f"{args.owner}/staged-recipes")

    summary = _get_latest_run_summary(repo, args.workflow_run_id)
    if summary:
        print(summary)
        commit = repo.get_commit(args.head_sha)
        for pr in commit.get_pulls():
            if pr.base.repo.full_name == repo.full_name:
                pr.create_issue_comment(summary)
                break
