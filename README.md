# "The Supermario" project
_This project is designed to deploy the super Mario game in the cloud with the high availability automatically_

## Before you start
You should prepare your environment, from where the playbook should be run.
You have to install the tools described below:
- Terraform- https://learn.hashicorp.com/tutorials/terraform/install-cli
- Ansible - https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html
- AWS CLI - https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html

This pipeline tested and works with versions:
- Terraform : v1.0.3
- Ansible   : v2.9.6
- AWS-CLI   : v1.16.59

Make sure you have ssh RSA key generate (or create a new one)

## Configure AWS CLI
```
aws configure
```

## How to run
To make it possible to connect with the cloud export those variables in your system
```
export AWS_ACCESS_KEY_ID=?
export AWS_PRIVATE_ACCESS_KEY=?
```
## To initialize terraform run the command
Go to the project root directory
```
terraform init
```
## To set up the environment run the command

```
terraform apply
```

_In the end, you will get the public URL of the load balancer in your terminal, which will let you access the environment via the WEB._
