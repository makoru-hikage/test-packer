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

variable "docker_key" {
  type    = string
  default = ""
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
    # extra_arguments = ["-vvvv"]
    use_proxy = false
    playbook_file   = "./playbook.yml"
    user = "ubuntu"
    extra_arguments = [
      "--extra-vars",
      "ansible_host=${var.ansible_host} ansible_connection=docker",
      # "-vvv",
    ]
    ansible_env_vars = ["EXAMPLE_KEY=${var.example_key}"]
  }

  post-processor "docker-tag" {
    repository = "test-packer"
    tags = ["qa"]
  }
}

