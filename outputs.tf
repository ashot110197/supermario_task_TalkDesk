### The Ansible inventory file
resource "local_file" "AnsibleInventory" {
 content = templatefile("inventory.tmpl",
 {
    public-ip = aws_instance.supermario_instance.*.public_ip
 }
 )
 filename = "hosts"
}

output "lb_pub_dns" {
   value = aws_lb.supermario.dns_name
}