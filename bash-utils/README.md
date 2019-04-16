[![pipeline status](https://gitlab.com/yeti-coolers/yeti-bash/dev/bash-utils/badges/master/pipeline.svg)](https://gitlab.com/yeti-coolers/yeti-bash/dev/bash-utils/commits/master)

# bash-utils

> Collection of bash scripts and functions to improve productivity and consistency.

[version-comment]: # (
VERSION tagging is automated using bumpversion.sh
do not change VERSION here manually
instead commit changes and execute ./bumpversion.sh
bumpversion will automatically increment the patch version everywhere
)

VERSION: 0.0.2

## Usage

Open a terminal session and execute the commands below to load the bash_util functions into memory.

```bash
# load bash_util functions into memory
source bash_util.sh

# display script usage documentation
./bash_utils.sh

# bring all the GitLab projects in the gitlab/src/yeti-coolers/yeti-terraform/dev directory located in
# your users HOME directory up to date with origin/master
git_fetch_projects ${HOME}/gitlab/src/yeti-coolers/yeti-terraform/dev

# same thing using the default behavior with the current directory being the root of the dataflow-templates project
cd ${HOME}/gitlab/src/yeti-coolers/yeti-dataflow/dev/dataflow-templates
git_fetch_projects
```

| [bash_util.sh] function     |  Description |
| :-------------------------- | :----------- |
| bump_version                | Update release tag and version and commit and push release and tag. |
| docker_log_status           | Convenience function to log docker build and push command status. |
| docker_build_and_push       | Build and push docker image to GitLab repository and Google repository. |
| docker_shazam               | Holy Docker Batman!  docker build, push, git tag and commit it all in one command. |
| gcloud_auth_application_default | Authenticate as the application default login. |
| gcloud_authenticate         | Authenticate as Compute Engine default service and authenticate to Google Docker container registries. |
| gcloud_authenticate_docker  | Configure Google Cloud docker repositories. |
| gcloud_install              | Install Google Cloud SDK, Apply any outstanding gcloud cli software updates (just in case) and if gcloud .json credential file does not exists create it. |
| gcloud_configure            | Configure the [gcloud] cli, setting [gcloud config] values. |
| gcloud_configure_ssh        | Configure the gcloud google_compute_engine ssh public and private key. |
| gcs_bucket_label            | Label Google Cloud Storage bucket owner and purpose for audit and billing. |
| git_fetch_projects          | Recursively bring the GitLab projects in the supplied directory up to date with 'origin/master'. |
| gitlab_ci_setup             | GitLab CI/CD, install and configure gcloud cli. |
| gke_configure               | Initialize GKE node_tag and gke_instance_group_uri environment variables. |
| terraform_install           | Install latest version of terraform. |
| terraform_tfvars            | Create [terraform.tfvars] variable definition file. |
| terraform_init              | Use `terraform_init` to see the terraform plan but not apply. |
| terraform_shazam            | Holy Terraform Batman!  Terraform it all in one command. |
| yaml_file_parse             | Parse well behaved yaml files and create lower case environment variables (name and value both all lower case). |
| help                        | Usage documentation. |


## Who Owns This

* Department: Data and Analytics ([Adam Cox](adam.cox@yeti.com))
* Contact: [Brent Dorsey](brent.dorsey@yeti.com)


[url-alias-comment]: # (Markdown variables.  Use variables to make your markdown easier for developers to read and edit.)

[bash_util.sh]: bash_util.sh
[gcloud]: https://cloud.google.com/sdk/gcloud/reference/
[gcloud config]: https://cloud.google.com/sdk/gcloud/reference/config/
[google_storage_bucket]: https://www.terraform.io/docs/providers/google/r/storage_bucket.html
[google_storage_bucket]: https://www.terraform.io/docs/providers/google/r/storage_bucket.html
[google_project_iam_policy]: https://www.terraform.io/docs/providers/google/r/google_service_account.html
[google_project_services]: https://www.terraform.io/docs/providers/google/d/google_project_services.html
[google_storage_bucket_iam_binding]: https://www.terraform.io/docs/providers/google/r/google_project_iam_policy.html 
[google_storage_bucket_iam_binding]: https://www.terraform.io/docs/providers/google/r/google_project_iam_policy.html 
