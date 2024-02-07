packer {
  required_plugins {
    docker = {
      version = ">= 1.0.8"
      source  = "github.com/hashicorp/docker"
    }

    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1"
    }

  }
}

variable "example_key" {
  type    = string
  default = ""
}

variable "ansible_host" {
  type    = string
  default = "default"
}

variable "docker_username" {
  type    = string
  default = ""
}

variable "docker_key" {
  type    = string
  default = ""
}

variable "ansible_verbosity" {
  type    = string
  default = null 
}

source "docker" "ubuntu" {
  image  = "makoruhikage/ubuntu-python-example:jammy"
  commit = true
  run_command = ["-d", "-i", "-t", "--entrypoint=/bin/sh", "--name", "${var.ansible_host}", "--", "{{.Image}}"]
}

build {
  name = "learn-packer"
  sources = [
    "source.docker.ubuntu"
  ]

  provisioner "ansible" {
    use_proxy = false
    playbook_file   = "./playbook.yml"
    user = "ubuntu"
    extra_arguments = [
      "${var.ansible_verbosity}",
      "--extra-vars",
      "ansible_host=${var.ansible_host} ansible_connection=docker",
    ]
    ansible_env_vars = ["EXAMPLE_KEY=${var.example_key}"]
  }

  post-processors {
    post-processor "docker-tag"  {
      repository = "makoruhikage/test-packer-ansible"
      tags = ["qa"]
    }

    post-processor "docker-push" {
      login = true
      login_username = "${var.docker_username}"
      login_password = "${var.docker_key}"
    }
  } 
}

