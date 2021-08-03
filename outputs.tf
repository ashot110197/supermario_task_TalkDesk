### The Ansible inventory file
resource "local_file" "AnsibleInventory" {
 content = templatefile("inventory.tmpl",
 {
    public-ip = aws_instance.supermario_instance.*.public_ip
 }
 )
 filename = "hosts"
}