resource "hcloud_load_balancer" "masters_lb" {
  name               = "masters_lb"
  load_balancer_type = "lb11"
  location           = var.location
  labels = {
    type = "masters_lb"
  }
  algorithm {
    type = "round_robin"
  }
}

resource "hcloud_load_balancer_target" "load_balancer_master_target" {
  count            = var.instances
  type             = "server"
  load_balancer_id = hcloud_load_balancer.masters_lb.id
  server_id        = hcloud_server.kube-master[count.index].id
}

resource "hcloud_load_balancer_service" "masters_service" {
  load_balancer_id = hcloud_load_balancer.masters_lb.id
  protocol         = var.services_protocol
  listen_port      = var.services_masters_source_port
  destination_port = var.services_masters_source_port

  health_check {
    protocol = var.services_protocol
    port     = var.services_masters_source_port
    interval = "10"
    timeout  = "10"
    http {
      path         = "/"
      status_codes = ["2??", "3??"]
    }
  }
}

resource "hcloud_load_balancer_network" "masters_network" {
  load_balancer_id        = hcloud_load_balancer.masters_lb.id
  subnet_id               = hcloud_network_subnet.hc_private_subnet.id
  enable_public_interface = "true"
  ip                      = var.lb_masters_private_ip
  depends_on = [
    hcloud_network_subnet.hc_private_subnet
  ]
}