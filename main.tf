terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_ssh_key" "default" {
  name       = "terra-key"
  public_key = file(var.ssh_public_key_path)
}

resource "digitalocean_droplet" "web_server" {
  image    = var.droplet_image
  name     = var.droplet_name
  region   = var.droplet_region
  size     = var.droplet_size
  ssh_keys = [digitalocean_ssh_key.default.fingerprint]

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file(var.ssh_private_key_path)
    host        = self.ipv4_address
  }

  provisioner "file" {
    source      = "${path.module}/script.sh"
    destination = "/tmp/script.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script.sh",
      "SSH_PRIVATE_KEY='${file(var.ssh_private_key_path)}' GITHUB_REPO='${var.github_repo}' NODE_VERSION='${var.node_version}' DOMAIN_NAME='${var.domain_name}' DB_USER='${var.db_user}' DB_NAME='${var.db_name}' DB_PASSWORD='${var.db_password}' bash /tmp/script.sh"
    ]
  }
}

# Output the droplet's IP address
output "droplet_ip" {
  value = digitalocean_droplet.web_server.ipv4_address
}