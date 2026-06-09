import argparse
import os

import requests


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Lint staged recipes.")
    parser.add_argument("--full-name", type=str, required=True, help="the full repo name (e.g., conda-forge/staged-recipes)")
    parser.add_argument("--head-ref", type=str, required=True, help="the `head_ref` property of the merge group")
    parser.add_argument("--head-sha", type=str, required=True, help="the `head_sha` property of the merge group")

    args = parser.parse_args()

    try:
        requests.post(
            "https://conda-forge.herokuapp.com/staged-recipes/merge-queue-linting-hook",
            headers={
                "CF_WEBSERVICES_TOKEN": os.environ["CF_WEBSERVICES_TOKEN"]
            },
            json={"full_name": args.full_name, "head_sha": args.head_sha, "head_ref": args.head_ref},
            timeout=(None, 0.00001),
        )
    except requests.exceptions.ReadTimeout:
        # we swallow this error since we do not wait for a response
        pass
