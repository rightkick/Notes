resource "local_file" "pet" {
    filename = "/home/alex/terraform-test.txt"
    content = "We love IaaS!"
    file_permission = "0700"
}