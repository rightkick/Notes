# Terraform Notes

## Intention
These notes are a high level introduction to Terraform taken during my study of the tool. It is not meant to be used as a reference since many details are not included here.

## Introduction
Terraform uses HCL to define infrastructure as code. It uses different providers that abstract the interactions with the infrastructure they configure. The providers include different resource types that can be used to define the desired state for the target infra. Terraform follows an immutable approach and by default it deletes the resources prior to creating a new version of them.

## Steps to run Terraform
- Create `yourfilename.tf` file
- Run `terraform init`
- Review execution plan running `terraform plan`
- Apply the changes by running `terraform apply`

## Configuration
You can have several .tf files within your root config directory so as to organize your code.
Usually the files are split as follows:
- `main.tf`
- `variables.tf`
- `outputs.tf`
- `providers.tf`

You can use multiple providers and resource types within a configuration file.
Whenever you change the providers defined within a configuration file you need to run `terraform init` in order to initialize the providers required.

## Providers
Terraform relies on plugins called providers which bundle a set of functionality around cloud solutions or other solutions that expose an API. There are different types of providers such as official, partner and community providers. The providers are usually a go binary that is served through a registry and is locally downloaded when used. One can use a custom shared mirror to reduce traffic while using providers with other users. The terraform providers are downloaded when running `terraform init` and by default the latest version is downloaded whenever this command is run. As a best practice it is recommended to pin the version of the required providers.

To pin a specific provider version you do as below:
```
terraform {
  required_providers {
    local = {
      source = "hashicorp/local"
      version = "2.5.0"
    }
  }
}
```

Apart form specifying a specific version of a provider you can define also a range of versions or use negative expression to avoid a specific version, using symbols such as `!=, <, >, <=, ~`.

## Variables
Usually variables are grouped into a file named `variables.tf`. Example:
```
variable <var_name> {
    default = "default value"
    type = <string|number|bool|tuple|list|set|map|object>
    description = "variable description"
}
```

Within a terraform configuration file, you can reference the variables's value following a syntax similar to json paths such as `var.<var_name>.attribute`.

You can have vars defined also in a file ending in `.tfvars` or `.tfvars.json`. Example `terraform.tfvars`:
```
var_1="value1"
var_2="value2"
```

Files that are named as `terraform.tfvars`, `terraform.tfvars.json`, `*.auto.tfvars`, `*.auto.tfvars`.json are automatically loaded from terraform. Files that do not follow this rule should be passed at command line using `-var-file` flag. Example: `terraform apply -var-file variables.tfvars`.

There are different ways to define variables (listed in ascending precedence):
- export env variables using `TF_VAR_<var_name>` (lower precedence)
- define variables in `terraform.tfvars`
- define variables in `variables.auto.tfvars`
- pass variables through command line with `-var-file` (higher precedence)

You should be aware of the variable definition precedence that terraform follows, in order to understand the final value that the variables will have in case there are different conflicting definitions.

The variables can be for **input** or **output** purposes. The input variables are used to feed configuration files while the output variables can be used for both feeding configuration files and displaying their value in the console.

## Terraform state
It keeps the state of the deployed infrastructure. The state is stored in a local file named `terraform.tfstate` and this file should not be version controlled in git since it may include sensistive information. When working with a team it is best stored in a central S3 bucket or shared storage.

## Terraform commands
- `terraform init`: initialize the project. It will download any providers also locally to be used when applying the code.
- `terraform plan`: shows the planned execution. It is similar to a dry-run apply.
- `terraform validate`: validate that your configuration is correct.
- `terraform fmt`: formats the configuration for improved readability.
- `terraform show`: prints the current state of the infrastructure.
- `terraform providers`: prints the list of used providers.
- `terraform output`: print the values of output variables.
- `terraform refresh`: it refreshes local state with the actual infra state. Useful to incorporate manual changes into the state. This command is run automatically from `terraform plan` or `terraform apply`.
- `terraform graph`: print resource dependencies in a dot format. The graph can be visualized with graphviz application or similar. Example: `terraform graph | dot -Tsvg > graph.svg`.

## Lifecycle management
One can affect how terraform handles the lifecycle of resources when updating the infrastructure through the use of lifecycle rules. Example:
```
resource `local_file` `test_file`{
    filename = "test_file.txt"
    contenct = "moo"
    file_permissions = "0700"

    lifecycle {
        create_before_destroy = true
    }
}
```

Other useful lifecycle rules:
- `prevent_destroy`: protects a resource from accidental deletion
- `ignore_changes`: terraform will ignore changes manually introduced to a specific resource attribute. Subsequent terraform applies will not change the subject resource.

## Data sources
Data sources or data resources are used to retrieve data from externally defined resources. These resources may be already provisioned or created through other IaC tools such as Ansible or other and can be of any type supported from Terraform. Example:
```
resource "local_file" "dog" {
    filename = "/tmp/pets.txt"
    content = data.local_file.dog.content
}

data "local_file" "dog" {
    filename="/root/dog.txt"
}
```

## Working with AWS
AWS publishes an AWS provider that can be used to interact with AWS. You can configure your local AWS cli so as terraform to be able to authenticate with AWS and interact with it.




