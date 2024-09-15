import argparse
import time
import os

import github
import requests


def _get_latest_run_summary(pr):
    all_runs = []
    for r in repo.get_workflow_runs(head_sha=pr.head.sha):
        if r.name == "staged-recipes linter":
            all_runs.append(r)

    all_times = [r.created_at for r in all_runs]

    latest_time = max(all_times)

    for r in all_runs:
        if r.created_at == latest_time:
            latest_run = r

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
    parser.add_argument('--pr-num', type=int, required=True, help='the PR number')

    args = parser.parse_args()

    # hack to wait for the workflow to finish
    time.sleep(60)

    gh = github.Github(auth=github.Auth.Token(os.environ["GH_TOKEN"]))
    repo = gh.get_repo(f"{args.owner}/staged-recipes")
    pr = repo.get_pull(args.pr_num)

    summary = _get_latest_run_summary(pr)
    if summary:
        print(summary)
        pr.create_issue_comment(summary)
