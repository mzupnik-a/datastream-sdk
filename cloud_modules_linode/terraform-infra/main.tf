variable "linode_api_token" {
  description = "Linode API Token"
  type        = string
}

variable "tenant_id" {
  description = "Tenant ID for bucket naming"
  type        = string
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

# resource "linode_object_storage_bucket" "data_input_storage" {
#   label  = "data-input-storage-${var.tenant_id}"
#   region = var.input_storage_region
# }
#
# resource "linode_object_storage_key" "data_input_storage_key" {
#   depends_on = [linode_object_storage_bucket.data_input_storage]
#   label = "data-input-storage-key-${var.tenant_id}"
#   bucket_access {
#     region      = linode_object_storage_bucket.data_input_storage.region
#     bucket_name = linode_object_storage_bucket.data_input_storage.label
#     permissions = "read_write"
#   }
# }
#
# resource "linode_object_storage_bucket" "data_output_storage" {
#   label  = "data-output-storage-${var.tenant_id}"
#   region = var.output_storage_region
# }
#
# resource "linode_object_storage_key" "data_output_storage_key" {
#   depends_on = [linode_object_storage_bucket.data_output_storage]
#   label = "data-output-storage-key-${var.tenant_id}"
#   bucket_access {
#     region      = linode_object_storage_bucket.data_output_storage.region
#     bucket_name = linode_object_storage_bucket.data_output_storage.label
#     permissions = "read_write"
#   }
# }
#
# resource "linode_object_storage_bucket" "monitor_storage" {
#   label  = "monitor-storage-${var.tenant_id}"
#   region = var.monitor_storage_region
# }
#
# resource "linode_object_storage_key" "monitor_storage_key" {
#   depends_on = [linode_object_storage_bucket.monitor_storage]
#   label = "monitor-storage-key-${var.tenant_id}"
#   bucket_access {
#     region      = linode_object_storage_bucket.monitor_storage.region
#     bucket_name = linode_object_storage_bucket.monitor_storage.label
#     permissions = "read_write"
#   }
# }
#
# resource "linode_object_storage_bucket" "configuration_storage" {
#   label  = "configuration-storage-${var.tenant_id}"
#   region = var.config_storage_region
# }
#
# resource "linode_object_storage_key" "configuration_storage_key" {
#   depends_on = [linode_object_storage_bucket.configuration_storage]
#   label = "configuration-storage-key-${var.tenant_id}"
#   bucket_access {
#     region      = linode_object_storage_bucket.configuration_storage.region
#     bucket_name = linode_object_storage_bucket.configuration_storage.label
#     permissions = "read_write"
#   }
# }

# resource "linode_lke_cluster" "datastream_lke_cluster" {
#   label       = "datastream-lke-cluster-${var.tenant_id}"
#   region      = var.lke_cluster_region
#   k8s_version = "1.33"
#
#   pool {
#     type  = "g6-nanode-1"
#     count = 3
#   }
# }
#
# resource "local_file" "kubeconfig" {
#   depends_on = [linode_lke_cluster.datastream_lke_cluster]
#   filename = "${path.module}/kubeconfig-${var.tenant_id}.yaml"
#   content = base64decode(linode_lke_cluster.datastream_lke_cluster.kubeconfig)
# }

resource "linode_vpc" "datastream_vpc" {
  label  = "datastream-vpc-${var.tenant_id}"
  region = var.region
  description = "Datastream VPC for tenant ${var.tenant_id}"
}

resource "linode_vpc_subnet" "datastream_subnet" {
  vpc_id = linode_vpc.datastream_vpc.id
  label  = "datastream-subnet-${var.tenant_id}"
  ipv4   = "10.0.0.0/24"
}

resource "linode_database_postgresql_v2" "postgresql_instance" {
  label     = "datastream-postgresql-${var.tenant_id}"
  engine_id = "postgresql/14"
  region    = var.region
  type      = "g6-nanode-1"
  allow_list = [linode_vpc_subnet.datastream_subnet.ipv4]
}

# resource "random_password" "file_queue_user_password" {
#   length  = 16
#   special = true
# }
#
# resource "random_password" "config_user_password" {
#   length  = 16
#   special = true
# }

output "tenant_id" {
  value = var.tenant_id
}

# output "data_input_storage_secret" {
#   value = {
#     storage_name = linode_object_storage_bucket.data_input_storage.label
#     region       = linode_object_storage_bucket.data_input_storage.region
#     access_key   = linode_object_storage_key.data_input_storage_key.access_key
#     secret_key   = linode_object_storage_key.data_input_storage_key.secret_key
#   }
#   sensitive = true
# }
#
# output "data_output_storage_secret" {
#   value = {
#     storage_name = linode_object_storage_bucket.data_output_storage.label
#     region       = linode_object_storage_bucket.data_output_storage.region
#     access_key   = linode_object_storage_key.data_output_storage_key.access_key
#     secret_key   = linode_object_storage_key.data_output_storage_key.secret_key
#   }
#   sensitive = true
# }
#
# output "monitor_storage_secret" {
#   value = {
#     storage_name = linode_object_storage_bucket.monitor_storage.label
#     region       = linode_object_storage_bucket.monitor_storage.region
#     access_key   = linode_object_storage_key.monitor_storage_key.access_key
#     secret_key   = linode_object_storage_key.monitor_storage_key.secret_key
#   }
#   sensitive = true
# }
#
# output "configuration_storage_secret" {
#   value = {
#     storage_name = linode_object_storage_bucket.configuration_storage.label
#     region       = linode_object_storage_bucket.configuration_storage.region
#     access_key   = linode_object_storage_key.configuration_storage_key.access_key
#     secret_key   = linode_object_storage_key.configuration_storage_key.secret_key
#   }
#   sensitive = true
# }

output "postgresql_instance" {
  value = {
    host          = linode_database_postgresql_v2.postgresql_instance.host_primary
    port          = linode_database_postgresql_v2.postgresql_instance.port
    root_user     = linode_database_postgresql_v2.postgresql_instance.root_username
    root_password = linode_database_postgresql_v2.postgresql_instance.root_password
    # file_queue_user = {
    #   username = "file_queue_user"
    #   password = random_password.file_queue_user_password.result
    # }
    # config_user = {
    #   username = "config_user"
    #   password = random_password.config_user_password.result
    # }
  }
  sensitive = true
}
