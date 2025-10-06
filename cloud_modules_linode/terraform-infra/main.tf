variable "linode_api_token" {
  description = "Linode API Token"
  type        = string
}

variable "tenant_id" {
  description = "Tenant ID for bucket naming"
  type        = string
}

variable "local_ip" {
  description = "Local IP address for the firewall allow list"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key for the bastion host"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "region" {
  description = "Region for all resources"
  type        = string
  default     = "us-ord"
}

terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = ">=3.0.0"
    }
  }
}

provider "linode" {
  token = var.linode_api_token
}

resource "linode_object_storage_bucket" "input_data_storage" {
  label  = "input-data-storage-${var.tenant_id}"
  region = var.region
}

resource "linode_object_storage_key" "input_data_storage_key" {
  depends_on = [linode_object_storage_bucket.input_data_storage]
  label      = "input-data-storage-key-${var.tenant_id}"
  bucket_access {
    region      = linode_object_storage_bucket.input_data_storage.region
    bucket_name = linode_object_storage_bucket.input_data_storage.label
    permissions = "read_write"
  }
}

resource "linode_object_storage_bucket" "internal_result_storage" {
  label  = "internal-result-storage-${var.tenant_id}"
  region = var.region
}

resource "linode_object_storage_key" "internal_result_storage_key" {
  depends_on = [linode_object_storage_bucket.internal_result_storage]
  label      = "internal-result-storage-key-${var.tenant_id}"
  bucket_access {
    region      = linode_object_storage_bucket.internal_result_storage.region
    bucket_name = linode_object_storage_bucket.internal_result_storage.label
    permissions = "read_write"
  }
}

resource "linode_lke_cluster" "datastream_lke_cluster" {
  label       = "datastream-lke-cluster-${var.tenant_id}"
  region      = var.region
  k8s_version = "1.33"

  pool {
    type     = "g6-standard-1"
    count    = 1 # TODO 3
  }
}

resource "local_file" "kubeconfig" {
  depends_on = [linode_lke_cluster.datastream_lke_cluster]
  filename   = "${path.module}/kubeconfig-${var.tenant_id}.yaml"
  content    = base64decode(linode_lke_cluster.datastream_lke_cluster.kubeconfig)
}

resource "linode_vpc" "datastream_vpc" {
  label       = "datastream-vpc-${var.tenant_id}"
  region      = var.region
  description = "Datastream VPC for tenant ${var.tenant_id}"
}

resource "linode_vpc_subnet" "datastream_subnet" {
  vpc_id = linode_vpc.datastream_vpc.id
  label  = "datastream-subnet-${var.tenant_id}"
  ipv4   = "10.0.0.0/24"
}

resource "linode_database_postgresql_v2" "postgresql_instance" {
  depends_on = [
  ]
  label      = "datastream-postgresql-${var.tenant_id}"
  engine_id  = "postgresql/14"
  region     = var.region
  type       = "g6-nanode-1"
  allow_list = [linode_vpc_subnet.datastream_subnet.ipv4]
}

resource "linode_instance" "bastion" {
  label           = "bastion-${var.tenant_id}"
  region          = var.region
  type            = "g6-nanode-1"
  image           = "linode/ubuntu22.04"
  authorized_keys = [trimspace(file(var.ssh_public_key))]
  private_ip      = true
  interface {
    purpose = "public"
  }
  interface {
    purpose   = "vpc"
    subnet_id = linode_vpc_subnet.datastream_subnet.id
  }
}

resource "linode_firewall" "datastream_firewall" {
  label           = "bastion-and-k8s-fw-${var.tenant_id}"
  inbound_policy  = "DROP"
  outbound_policy = "DROP"
  inbound {
    label    = "allow_tcp_22_from_local_ip"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "22"
    ipv4     = [format("%s/32", var.local_ip)]
  }
  inbound {
    label    = "allow_tcp_6443_from_bastion_ip"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "6443"
    ipv4     = [format("%s/32", tolist(linode_instance.bastion.ipv4)[1])]
  }
  outbound {
    label    = "allow_all_outbound_traffic"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "1-65535"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }
  linodes = [linode_instance.bastion.id]
}

output "tenant_id" {
  value = var.tenant_id
}

output "input_data_storage_secret" {
  value = {
    storage_name = linode_object_storage_bucket.input_data_storage.label
    region       = linode_object_storage_bucket.input_data_storage.region
    access_key   = linode_object_storage_key.input_data_storage_key.access_key
    secret_key   = linode_object_storage_key.input_data_storage_key.secret_key
  }
  sensitive = true
}

output "internal_result_storage_secret" {
  value = {
    storage_name = linode_object_storage_bucket.internal_result_storage.label
    region       = linode_object_storage_bucket.internal_result_storage.region
    access_key   = linode_object_storage_key.internal_result_storage_key.access_key
    secret_key   = linode_object_storage_key.internal_result_storage_key.secret_key
  }
  sensitive = true
}

output "postgresql_instance" {
  value = {
    host          = linode_database_postgresql_v2.postgresql_instance.host_primary
    port          = linode_database_postgresql_v2.postgresql_instance.port
    root_user     = linode_database_postgresql_v2.postgresql_instance.root_username
    root_password = linode_database_postgresql_v2.postgresql_instance.root_password
  }
  sensitive = true
}

output "bastion_public_ip" {
  value = tolist(linode_instance.bastion.ipv4)[0]
}
