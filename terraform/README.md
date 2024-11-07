# Terraform Notes

## Intention
These notes are a high level introduction to Terraform taken during my study of the tool. It is not meant to be used as a reference since many details are not included here but it should be still useful for a quick and dirty introduction to get a good feeling and understanding of the tool.


## Introduction
Terraform uses HCL to define infrastructure as code. It uses different providers that abstract the interactions with the infrastructure they configure. The providers include different resource types that can be used to define the desired state for the target infra. Terraform follows an immutable approach and by default it deletes the resources prior to creating a new version of them.


## Steps to run Terraform
- Create `yourfilename.tf` file
- Optionally validate your configuration file: `terraform validate`
- Run `terraform init`
- Review execution plan running `terraform plan`
- Apply the changes by running `terraform apply`


## Configuration
You can have several `.tf` files within your root config directory so as to organize your code.
Usually the files are split as follows:
- `main.tf`
- `variables.tf`
- `outputs.tf`
- `providers.tf`

You can use multiple providers and resource types within a configuration file.
Whenever you change the providers defined within a configuration file you need to run `terraform init` in order to initialize the providers required.


## Providers
Terraform relies on plugins called providers which bundle a set of functionality around cloud solutions or other solutions that expose an API. There are different types of providers such as **official**, **partner** and **community** providers. The providers are usually a go binary that is served through a registry and is by default locally downloaded when used. One can use a custom shared mirror to reduce traffic and share such providers with other users. The Terraform providers are downloaded when running `terraform init` and by default the latest version is downloaded whenever this command is run. As a best practice it is recommended to pin the version of the required providers.

To pin a specific provider to a specific version you define it as follows:
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
    type = <string|number|bool|list|set|map|tuple|object>
    description = "variable description"
}

output <var_name> {
  value = <resource related value>
}
```

Within a Terraform configuration file, you can reference the variables's value following a syntax similar to json paths such as `var.<var_name>.attribute`.

You can have vars defined also in a file ending in `.tfvars` or `.tfvars.json`. Example `terraform.tfvars`:
```
var_1="value1"
var_2="value2"
```

Files that are named as `terraform.tfvars`, `terraform.tfvars.json`, `*.auto.tfvars`, `*.auto.tfvars`.json are automatically loaded from Terraform. Files that do not follow this rule should be passed at command line using `-var-file` flag. Example: `terraform apply -var-file variables.tfvars`.

The variables can be for **input** or **output** purposes. The input variables (defined with a `variable` block) are used to feed configuration files while the output variables (defined with an `output` block) can be used for both feeding configuration files and displaying their value in the console.

There are different ways to define input variables (listed in ascending precedence):
- export env variables using `TF_VAR_<var_name>` (lower precedence)
- define variables in `terraform.tfvars`
- define variables in `variables.auto.tfvars`
- pass variables through command line with `-var-file` (higher precedence)

You should be aware of the variable definition precedence that Terraform follows, in order to understand the final value that the variables will have in case there are different conflicting definitions.

You can define also variables within a `locals` block, which are scoped as local variables within the Terraform project. These variables are then referenced with `local.<variable name>`. Example: 

```
locals {
  <var_name1> = <value1>
  <var_name2> = <value2>
}
```


## Terraform State
Terraform state keeps the state of the deployed infrastructure. The state is stored by default in a local file named `terraform.tfstate` located within the current configuration directory and this file should not be version controlled since it may include sensitive information. 

When working with a team it is recommended to have the Terraform state stored at a remote backend such as a central S3 bucket or shared storage with state locking enabled so as to avoid state corruption and enhance security. State locking is usually done from a DB backend (dynamodb or other). Usually one uses encrypted AWS S3 and DynamoDB to have the state stored remotely in a secure way. One needs a single S3 bucket and a single DynamoDB table to manage the states for different Terraform projects, as long as the S3 bucket uses a different key per project when defined as a backend under the project so as to avoid race conditions and state corruption. This unique S3 key can be automatically used from the Terraform as a distinct DynamoDB lock ID so as to avoid state locking from unrelated projects.

Example backend configuration for a project: 
```
terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket"
    key            = "myproject1/terraform.tfstate"
    region         = "eu-central-1"
    profile        = "aws_account_profile"
    dynamodb_table = "shared-terraform-lock-table"
    encrypt        = true
  }
} 
```

The S3 bucket and DynamoDB table are usually defined under a separate Terraform project which has the sole purpose of bringing these resources up. This project is a minimal one and can use local Terraform state so as to avoid the chicken-&-egg problem. 

Example: 
```
resource "aws_s3_bucket" "s3_tf_state" {
  bucket = "terraform-state-bucket"
}

resource "aws_s3_bucket_versioning" "s3_tf_state_versioning" {
  bucket = aws_s3_bucket.s3_tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_tf_state_encryption" {
  bucket = aws_s3_bucket.s3_tf_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "shared-terraform-lock-table"
  billing_mode = "PROVISIONED"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}
```

The S3 bucket created is encrypted using the default AWS KMS key for the s3 service (aws/s3) and has versioning enabled. 

You can manipulate the Terraform state with `terraform state` commands. For example, in order to rename a resource without recreating it, you can rename it in the state file, using `terraform state mv ...`, and then manually rename the resource in the configuration file also. In this way `terraform apply` will not detect any changes.

In order to isolate the state between different projects, you can either work within different configuration directories or make use of the **workspaces** which automatically keep state under a subdirectory named `terraform.tfstate.d/workspace_name` located within the same configuration directory. Using workspaces is one way to follow the DRY pattern and avoid repeating code as you can use `terraform.workspace` within your configuration code to differentiate your configuration according to the current workspace you are using. From my current understanding I would use **modules** instead of workspaces but I guess there is a use case for workspaces also. 

Example where we use the `terraform.workspace` as a key to use the respective value from declared map variables `var.region` and `var.ami`: 
```
variable "region" {
    type = map
    default = {
        "us-payroll" = "us-east-1"
        "uk-payroll" = "eu-west-2"
        "india-payroll" = "ap-south-1"
    }

}
variable "ami" {
    type = map
    default = {
        "us-payroll" = "ami-24e140119877avm"
        "uk-payroll" = "ami-35e140119877avm"
        "india-payroll" = "ami-55140119877avm"
    }
}

module "payroll_app" {
    source = "../modules/payroll-app"
    app_region = lookup(var.region,terraform.workspace)
    ami = lookup(var.ami,terraform.workspace)
}
```

Few commands for workspaces: 
- `terraform workspace list` : list available workspaces
- `terraform workspace new <work-space-name>` : create a new workspace
- `terraform workspace select <work-space-name>` : switch to a specific workspace


## Terraform Commands
- `terraform init`: initialize the project. It will download any providers also locally to be used when applying the code.
- `terraform plan`: shows the planned execution. It is similar to a dry-run apply.
- `terraform validate`: validate that your configuration is correct.
- `terraform fmt`: formats the configuration for improved readability.
- `terraform show`: prints the current state of the infrastructure.
- `terraform providers`: prints the list of used providers.
- `terraform output`: print the values of output variables.
- `terraform refresh`: it refreshes local state with the actual infra state. Useful to incorporate manual changes into the state. This command is run automatically from `terraform plan` or `terraform apply`.
- `terraform graph`: print resource dependencies in a dot format. The graph can be visualized with graphviz application or similar. Example: `terraform graph | dot -Tsvg > graph.svg`.
- `terraform state list`: list the configured resources, as recorded from the state file.
- `terraform state show <resource>`: show attributes of a matching resource, as recorded from the state file.


## Lifecycle Management
One can affect how Terraform handles the lifecycle of resources when updating the infrastructure through the use of lifecycle rules. Example:
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
- `ignore_changes`: Terraform will ignore changes manually introduced to a specific resource attribute. Subsequent terraform applies will not change the subject resource.


## Data Sources
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


## Terraform Provisioners
Provisioners are used to run a set of tasks after the resource has been deployed (create-time provisioners) or destroyed (destroy-time provisioners). These tasks can be run remotely or locally at the deployed resource. Failure of a provisioner will cause `terraform apply` to fail by default. This behavior can be adjusted (`on_failure = continue`) so as the `terraform apply` to not fail in such cases. Resources created while the provisioner is in failed state are marked as tainted.

You can use `local-exec` provisioner to run ansible playbooks. This is useful if you need to do a lot of configuration tasks that are not well handled from scripting languages.

Example:
```
provisioner "local-exec" {
  command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i '${self.ipv4_address}',     --private-key ${var.pvt_key} -e 'pub_key=${var.pub_key}' apache-install.yml"
}
```

Provisioners are defined within a resource thus they can use the `self` construct to refer to the resource.

As a best practice, provisioners should be used as a last resort tool and one should try to avoid them if the desired outcome can be implemented with available resource type attributes such as user data. The reason of avoiding provisioners is that they introduce complexity and they do not follow the declarative model.


## Tainted Resources
When a failure is detected during a `terraform apply`, the affected resources are marked as **tainted**. This means that at a subsequent `terraform apply` the resources will be recreated to address the taint.
The taint mechanism is a means also to force the recreation of a resource by marking it as tainted with `terraform taint <resource>`. One can also untaint a resource with `terraform untaint <resource>`.


## Debugging Terraform
You can enable different levels of log verbosity for Terraform using the `TF_LOG` environment variable.

The available levels are the following, listed in increased verbosity order:
- ERROR
- WARNING
- INFO
- DEBUG
- TRACE

To set the level you would do: `export TF_LOG=DEBUG`. To redirect the logs to a specific file you can do `export TF_LOG_PATH=/tmp/tf.log`. You can unset the previous with `unset TF_LOG_PATH`.


## Terraform Import
You can bring resources under Terraform management by importing them. This is useful when such resources are already provisioned through other tools or manually and you need to update your terraform state about their existence.

In order to import resources you need first to define them into the Terraform configuration file. Terraform, as of this writing, does not support the automatic definition of the resources during import (check it out, it might have changed by now). One easy way to import a resource is to define a basic entry of the resource that you need to import without defining any attributes in the configuration file, import the resource with `terraform import <resource name> <resource ID>`, inspect the resource details from Terraform state (`terraform state show <resource>`) and then populate the resource attributes in the Terraform configuration file. You need to make sure then that Terraform will not affect the imported resources by running `terraform plan`.

Example where we import an EC2 instance using the instance ID:
```
terraform import aws_instance.myvm i-5fa8523b300f09917
```

## Terraform Modules
Terraform modules are a collection of configuration files so as to follow a DRY approach and avoid repeating code. They can be thought as templates which you can include at your config files and overwrite few variables so as to finally deploy your specific resources.

The modules can be either local ones, usually located under a modules subfolder at your file-system or can be sourced from the official Terraform registry. As as best practice, it is recommended to define a specific module version when sourcing from the registry. The modules at the registry usually provide submodules that assist to define more specific aspects of the deployed resource.

Example using a local module:
```
module "aws_ec2" "myVM" {
  source = "../modules/aws_ec2"
  ami = foo
}
```

Example using a module from the registry:
```
module "s3-bucket_example" {
  source  = "terraform-aws-modules/s3-bucket/aws//examples/complete"
  version = "4.2.0"
}
```

## Terraform Functions
Can be used to manipulate and transform data. There are different types of functions, such as numeric, string, conversion or collection functions. Some common functions are:

- `file(path)`: reads the content of a file
- `toset(list)`: converts a list to a set value.
- `length()`: determines the length of a given list, map, or string.
- `split(separator,string)`: transform a string to a list
- `lower(string)`: convert string to lower case
- `upper(string)`: convert string to upper case
- `substr(string, offset, length)`: extract a substring from a string
- `join(list)`: convert list to a string
- `index(list,"value")`: get the index number from a list element
- `element(list)`: get an item from a list
- `contains(list)`: check if an element exists in a list
- `keys(map)`: get the keys from a map/dictionary
- `values(map)`: get the values from a map/disctionary
- `lookup(map,key)`: get a specific value from a map key.

It is advised to reference the terraform docs for the full list of supported functions. There are plenty of them.

You can use also `terraform console` to investigate or troubleshoot the result of a terraform interpolations or verify the values of variables. The Terraform console will load all defined resources and variables so you can test and verify them.

Example: 
```
terraform console

> var.aws_vpc_id
"vpc-f2fb5c88"

> split("-",var.aws_vpc_id)
tolist([
  "vpc",
  "f2fb5c88",
])

> upper(var.aws_vpc_id)
"VPC-F2FB5C88"

> upper(join("+",split("-",var.aws_vpc_id)))
"VPC+F2FB5C88"
```

## Conditional Expressions
You can use conditional expressions in your terraform code. They are used in the same manner as done at most other languages. Some common ones are: `<, >, ==, <=, !, &&, ||, ...`. 


## Looping with Terraform
You can use the `count` approach or `for_each` approach. 

Example using `count`: 
```
variable "cloud_users" {
     type = string
     default = "andrew:ken:faraz:mutsumi:peter:steve:braja"
  
}

resource "aws_iam_user" "cloud" {
    count = length(split(":",var.cloud_users))
    name = split(":",var.cloud_users)[count.index]
}
```

Example using `for_each`: 
```
variable "projects" {
  type        = set(string)
  default     = ["test-project-1", "test-project-2", "test-project-3"]
}

resource "aws_s3_bucket" "bucket" {
  for_each  = var.projects

  bucket = "bucket-${each.value}"
}
```

Here is another example using functions also, where `media` is a list of file paths that we need to upload and we set the bucket key to be the filename:
```
variable "media" {
  type = set(string)
  default = [ 
    "/media/tails.jpg",
    "/media/eggman.jpg",
    "/media/ultrasonic.jpg",
    "/media/knuckles.jpg",
    "/media/shadow.jpg",
      ]
  
}

resource "aws_s3_bucket" "my_bucket" {
     bucket = var.bucket
}

resource "aws_s3_object" "upload_my_bucket" {
    for_each = var.media
    bucket = aws_s3_bucket.my_bucket.id
    source = each.value
    key = element(split("/",each.value),length(split("/",each.value))-1)
}
```

## Dependency graph
Terraform usually will automatically figure out the dependency of the defined resources so as to correctly apply and deploy the resources. In case you need to explicitly configure a dependency between resources then you can ue the `depend_on` attribute within a resource block. 


## Working with cloud providers
AWS, Azure, GCP and other cloud providers publish their own Terraform provider that can be used to facilitate interaction with their cloud infra. You can browse the available providers through the available Terraform registry.

For AWS, you can configure your local AWS cli so as Terraform to be able to authenticate with AWS and interact with it. There are plenty of AWS resource types that you can use to define any type of AWS resource such as EC2, S3, Dynamodb, IAM, etc. Other providers should provide a similar approach to manage resources at their cloud infra through Terraform.

## Tips
- Avoid committing your terraform state into version control. Terraform state files usually contain sensitive information that you would like to keep away from version control. 




