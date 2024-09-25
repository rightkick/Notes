resource "local_file" "pet" {
    filename = "/home/alex/pets.txt"
    content = "We love pets!"
    file_permission = "0700"
}