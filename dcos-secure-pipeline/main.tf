provider "aws" {
  region = "us-east-1"
}

variable "dcos_install_mode" {
  description = "specifies which type of command to execute. Options: install or upgrade"
  default     = "install"
}

data "http" "whatismyip" {
  url = "http://whatismyip.akamai.com/"
}

module "dcos" {
  source  = "dcos-terraform/dcos/aws"
  version = "~> 0.2.0"

  providers = {
    aws = "aws"
  }

  cluster_name        = "djannot"
  dcos_instance_os    = "centos_7.5"
  ssh_public_key_file = "~/.ssh/id_rsa.pub"
  #admin_ips           = ["${data.http.whatismyip.body}/32"]
  admin_ips           = ["0.0.0.0/0"]

  num_masters        = "1"
  num_private_agents = "15"
  num_public_agents  = "2"

  dcos_version = "2.0.2"

  dcos_variant              = "ee"
  dcos_license_key_contents = "${file("./license.txt")}"
  #dcos_variant = "open"

  dcos_security = "permissive"
  private_agents_instance_type = "m4.2xlarge"
  public_agents_instance_type = "m4.2xlarge"
  #private_agents_instance_type = "c4.8xlarge"
  #public_agents_instance_type = "c4.8xlarge"

  public_agents_additional_ports = ["8443", "9999", "10500", "10339"]

  tags = {
    owner = "denisjannot",
    expiration = "120h"
  }
}

output "masters-ips" {
  value = "${module.dcos.masters-ips}"
}

output "cluster-address" {
  value = "${module.dcos.masters-loadbalancer}"
}

output "public-agents-loadbalancer" {
  value = "${module.dcos.public-agents-loadbalancer}"
}
