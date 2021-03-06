<!-- This file was automatically generated by the `build-harness`. Make all changes to `README.yaml` and run `make readme` to rebuild this file. -->

[![Cloud Posse](https://cloudposse.com/logo-300x69.svg)](https://cloudposse.com)

# terraform-aws-ssm-iam-role [![Build Status](https://travis-ci.org/cloudposse/terraform-aws-ssm-iam-role.svg?branch=master)](https://travis-ci.org/cloudposse/terraform-aws-ssm-iam-role) [![Latest Release](https://img.shields.io/github/release/cloudposse/terraform-aws-ssm-iam-role.svg)](https://github.com/cloudposse/terraform-aws-ssm-iam-role/releases/latest) [![Slack Community](https://slack.cloudposse.com/badge.svg)](https://slack.cloudposse.com)


Terraform module to provision an IAM role with configurable permissions to access [SSM Parameter Store](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-paramstore.html).


---

This project is part of our comprehensive ["SweetOps"](https://docs.cloudposse.com) approach towards DevOps. 


It's 100% Open Source and licensed under the [APACHE2](LICENSE).









## Introduction

For more information on how to control access to Systems Manager parameters by using AWS Identity and Access Management, see [Controlling Access to Systems Manager Parameters](https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-paramstore-access.html).

For more information on how to use parameter hierarchies to help organize and manage parameters, see [Organizing Parameters into Hierarchies](https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-paramstore-su-organize.html).

__NOTE:__ This module can be used to provision IAM roles with SSM permissions for [chamber](https://docs.cloudposse.com/tools/chamber/).  

## Usage

This example creates a role with the name `cp-prod-app-all` with permission to read all SSM parameters, 
and gives permission to the entities specified in `assume_role_arns` to assume the role.

```hcl
module "ssm_iam_role" {
  source           = "git::https://github.com/cloudposse/terraform-aws-ssm-iam-role.git?ref=master"
  namespace        = "cp"
  stage            = "prod"
  name             = "app"
  attributes       = ["all"]
  region           = "us-west-2"
  account_id       = "XXXXXXXXXXX"
  assume_role_arns = ["arn:aws:xxxxxxxxxx", "arn:aws:yyyyyyyyyyyy"]
  kms_key_arn      = "arn:aws:kms:us-west-2:123454095951:key/aced568e-3375-4ece-85e5-b35abc46c243"
  ssm_parameters   = ["*"]
  ssm_actions      = ["ssm:GetParametersByPath", "ssm:GetParameters"]
}
```




## Examples

### Example With Permission For Specific Resources

This example creates a role with the name `cp-prod-app-secrets` with permission to read the SSM parameters that begin with `secret-`, 
and gives permission to the entities specified in `assume_role_arns` to assume the role.

```hcl
module "ssm_iam_role" {
  source           = "git::https://github.com/cloudposse/terraform-aws-ssm-iam-role.git?ref=master"
  namespace        = "cp"
  stage            = "prod"
  name             = "app"
  attributes       = ["secrets"]
  region           = "us-west-2"
  account_id       = "XXXXXXXXXXX"
  assume_role_arns = ["arn:aws:xxxxxxxxxx", "arn:aws:yyyyyyyyyyyy"]
  kms_key_arn      = "arn:aws:kms:us-west-2:123454095951:key/aced568e-3375-4ece-85e5-b35abc46c243"
  ssm_parameters   = ["secret-*"]
  ssm_actions      = ["ssm:GetParameters"]
}
```

### Complete Example

This example:

* Provisions a KMS key to encrypt SSM Parameter Store secrets using [terraform-aws-kms-key](https://github.com/cloudposse/terraform-aws-kms-key) module
* Performs `Kops` cluster lookup to find the ARNs of `masters` and `nodes` by using [terraform-aws-kops-metadata](https://github.com/cloudposse/terraform-aws-kops-metadata) module
* Creates a role with the name `cp-prod-chamber-kops` with permission to read all SSM parameters from the path `kops`, 
and gives permission to the Kops `masters` and `nodes` to assume the role

```hcl
module "kms_key" {
  source      = "git::https://github.com/cloudposse/terraform-aws-kms-key.git?ref=master"
  namespace   = "cp"
  stage       = "prod"
  name        = "chamber"
  description = "KMS key for SSM"
}

module "kops_metadata" {
  source       = "git::https://github.com/cloudposse/terraform-aws-kops-metadata.git?ref=master"
  dns_zone     = "us-west-2.prod.cloudposse.co"
  masters_name = "masters"
  nodes_name   = "nodes"
}

module "ssm_iam_role" {
  source           = "git::https://github.com/cloudposse/terraform-aws-ssm-iam-role.git?ref=master"
  namespace        = "cp"
  stage            = "prod"
  name             = "chamber"
  attributes       = ["kops"]
  region           = "us-west-2"
  account_id       = "XXXXXXXXXXX"
  assume_role_arns = ["${module.kops_metadata.masters_role_arn}", "${module.kops_metadata.nodes_role_arn}"]
  kms_key_arn      = "${module.kms_key.key_arn}"
  ssm_parameters   = ["kops/*"]
  ssm_actions      = ["ssm:GetParametersByPath", "ssm:GetParameters"]
}
```



## Makefile Targets
```
Available targets:

  help                                This help screen
  help/all                            Display help for all targets
  lint                                Lint terraform code

```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| account_id | AWS account ID | string | - | yes |
| assume_role_arns | List of ARNs to allow assuming the role. Could be AWS services or accounts, Kops nodes, IAM users or groups | list | - | yes |
| attributes | Additional attributes (e.g. `1`) | list | `<list>` | no |
| delimiter | Delimiter to be used between `namespace`, `stage`, `name` and `attributes` | string | `-` | no |
| kms_key_arn | ARN of the KMS key which will encrypt/decrypt SSM secret strings | string | - | yes |
| max_session_duration | The maximum session duration (in seconds) for the role. Can have a value from 1 hour to 12 hours | string | `3600` | no |
| name | Name (e.g. `app` or `chamber`) | string | - | yes |
| namespace | Namespace (e.g. `cp` or `cloudposse`) | string | - | yes |
| region | AWS Region | string | - | yes |
| ssm_actions | SSM actions to allow | list | `<list>` | no |
| ssm_parameters | List of SSM parameters to apply the actions. A parameter can include a path and a name pattern that you define by using forward slashes, e.g. `kops/secret-*` | list | - | yes |
| stage | Stage (e.g. `prod`, `dev`, `staging`) | string | - | yes |
| tags | Additional tags (e.g. map(`BusinessUnit`,`XYZ`) | map | `<map>` | no |

## Outputs

| Name | Description |
|------|-------------|
| role_arn | The Amazon Resource Name (ARN) specifying the role |
| role_id | The stable and unique string identifying the role |
| role_name | The name of the crated role |




## Related Projects

Check out these related projects.

- [terraform-aws-ssm-parameter-store](https://github.com/cloudposse/terraform-aws-ssm-parameter-store) - Terraform module to populate AWS Systems Manager (SSM) Parameter Store with values from Terraform. Works great with Chamber.
- [terraform-aws-ssm-parameter-store-policy-documents](https://github.com/cloudposse/terraform-aws-ssm-parameter-store-policy-documents) - A Terraform module that generates JSON documents for access for common AWS SSM Parameter Store policies
- [terraform-aws-iam-chamber-user](https://github.com/cloudposse/terraform-aws-iam-chamber-user) - Terraform module to provision a basic IAM chamber user with access to SSM parameters and KMS key to decrypt secrets, suitable for CI/CD systems (e.g. TravisCI, CircleCI, CodeFresh) or systems which are external to AWS that cannot leverage AWS IAM Instance Profiles



## Help

**Got a question?**

File a GitHub [issue](https://github.com/cloudposse/terraform-aws-ssm-iam-role/issues), send us an [email][email] or join our [Slack Community][slack].

## Commercial Support

Work directly with our team of DevOps experts via email, slack, and video conferencing. 

We provide [*commercial support*][commercial_support] for all of our [Open Source][github] projects. As a *Dedicated Support* customer, you have access to our team of subject matter experts at a fraction of the cost of a full-time engineer. 

[![E-Mail](https://img.shields.io/badge/email-hello@cloudposse.com-blue.svg)](mailto:hello@cloudposse.com)

- **Questions.** We'll use a Shared Slack channel between your team and ours.
- **Troubleshooting.** We'll help you triage why things aren't working.
- **Code Reviews.** We'll review your Pull Requests and provide constructive feedback.
- **Bug Fixes.** We'll rapidly work to fix any bugs in our projects.
- **Build New Terraform Modules.** We'll develop original modules to provision infrastructure.
- **Cloud Architecture.** We'll assist with your cloud strategy and design.
- **Implementation.** We'll provide hands-on support to implement our reference architectures. 


## Community Forum

Get access to our [Open Source Community Forum][slack] on Slack. It's **FREE** to join for everyone! Our "SweetOps" community is where you get to talk with others who share a similar vision for how to rollout and manage infrastructure. This is the best place to talk shop, ask questions, solicit feedback, and work together as a community to build *sweet* infrastructure.

## Contributing

### Bug Reports & Feature Requests

Please use the [issue tracker](https://github.com/cloudposse/terraform-aws-ssm-iam-role/issues) to report any bugs or file feature requests.

### Developing

If you are interested in being a contributor and want to get involved in developing this project or [help out](https://github.com/orgs/cloudposse/projects/3) with our other projects, we would love to hear from you! Shoot us an [email](mailto:hello@cloudposse.com).

In general, PRs are welcome. We follow the typical "fork-and-pull" Git workflow.

 1. **Fork** the repo on GitHub
 2. **Clone** the project to your own machine
 3. **Commit** changes to your own branch
 4. **Push** your work back up to your fork
 5. Submit a **Pull Request** so that we can review your changes

**NOTE:** Be sure to merge the latest changes from "upstream" before making a pull request!


## Copyright

Copyright © 2017-2018 [Cloud Posse, LLC](https://cloudposse.com)



## License 

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) 

See [LICENSE](LICENSE) for full details.

    Licensed to the Apache Software Foundation (ASF) under one
    or more contributor license agreements.  See the NOTICE file
    distributed with this work for additional information
    regarding copyright ownership.  The ASF licenses this file
    to you under the Apache License, Version 2.0 (the
    "License"); you may not use this file except in compliance
    with the License.  You may obtain a copy of the License at

      https://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on an
    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied.  See the License for the
    specific language governing permissions and limitations
    under the License.









## Trademarks

All other trademarks referenced herein are the property of their respective owners.

## About

This project is maintained and funded by [Cloud Posse, LLC][website]. Like it? Please let us know at <hello@cloudposse.com>

[![Cloud Posse](https://cloudposse.com/logo-300x69.svg)](https://cloudposse.com)

We're a [DevOps Professional Services][hire] company based in Los Angeles, CA. We love [Open Source Software](https://github.com/cloudposse/)!

We offer paid support on all of our projects.  

Check out [our other projects][github], [apply for a job][jobs], or [hire us][hire] to help with your cloud strategy and implementation.

  [docs]: https://docs.cloudposse.com/
  [website]: https://cloudposse.com/
  [github]: https://github.com/cloudposse/
  [commercial_support]: https://github.com/orgs/cloudposse/projects
  [jobs]: https://cloudposse.com/jobs/
  [hire]: https://cloudposse.com/contact/
  [slack]: https://slack.cloudposse.com/
  [linkedin]: https://www.linkedin.com/company/cloudposse
  [twitter]: https://twitter.com/cloudposse/
  [email]: mailto:hello@cloudposse.com


### Contributors

|  [![Andriy Knysh][aknysh_avatar]][aknysh_homepage]<br/>[Andriy Knysh][aknysh_homepage] |
|---|

  [aknysh_homepage]: https://github.com/aknysh
  [aknysh_avatar]: https://github.com/aknysh.png?size=150


