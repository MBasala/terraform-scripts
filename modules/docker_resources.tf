resource "docker_network" "gerrit_network" {
  name = "gerrit_network"
}

resource "docker_image" "gerrit" {
  name = "gerritcodereview/gerrit:3.4.0"
}

resource "docker_container" "gerrit" {
  name  = "gerrit"
  image = docker_image.gerrit.latest

  ports {
    internal = 8080
    external = 8080
  }

  ports {
    internal = 29418
    external = 29418
  }

  networks_advanced {
    name = docker_network.gerrit_network.name
  }
}

resource "docker_image" "dns" {
  name = "your_dns_image"
}

resource "docker_container" "dns" {
  name  = "dns"
  image = docker_image.dns.latest

  ports {
    internal = 53
    external = 53
  }

  networks_advanced {
    name = docker_network.gerrit_network.name
  }
}

resource "docker_image" "openipa" {
  name = "freeipa/freeipa-server:centos-8"
}

resource "docker_container" "openipa" {
  name  = "openipa"
  image = docker_image.openipa.latest

  env = [
    "IPA_SERVER_INSTALL_OPTS=-U -r EXAMPLE.COM --no-ntp",
    "PASSWORD=Admin123",
  ]

  ports {
    internal = 80
    external = 80
  }

  ports {
    internal = 443
    external = 443
  }

  ports {
    internal = 389
    external = 389
  }

  ports {
    internal = 636
    external = 636
  }

  networks_advanced {
    name = docker_network.gerrit_network.name
  }
}

resource "docker_image" "git_cluster" {
  name = "your_git_cluster_image"
}

resource "docker_container" "git_cluster" {
  name  = "git_cluster"
  image = docker_image.git_cluster.latest

  ports {
    internal = 3000
    external = 3000
  }

  networks_advanced {
    name = docker_network.gerrit_network.name
  }
}

