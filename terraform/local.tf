# Required providers
terraform {
  required_providers {
    local = {
      source = "hashicorp/local"
      version = "2.5.0"
    }
  }
}

# Iterate through a list to create few files
resource "local_file" "pet1" {
    filename = var.filename[count.index]
    content = "We love IaaS!"
    file_permission = "0700"
    count = length(var.filename)
}

# Another better way to iterate through a list that has been converted to a set
resource "local_file" "pet2" {
    filename = each.value
    content = "We love IaaS!"
    file_permission = "0700"
    for_each = toset(var.filename)
}