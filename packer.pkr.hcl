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

source "docker" "ubuntu" {
  image  = "ubuntu-python:jammy"
  pull = false
  commit = true
  run_command = ["-d", "-i", "-t", "--entrypoint=/bin/sh", "--name", "default", "--", "{{.Image}}"]
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
      "ansible_host=default ansible_connection=docker",
      # "-vvv",
    ]
    ansible_env_vars = ["PERHAPS=Marahil"]
  }

  post-processor "docker-tag" {
    repository = "test-packer"
    tags = ["qa"]
  }
}

