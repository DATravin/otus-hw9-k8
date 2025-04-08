
# resource "yandex_resourcemanager_folder" "folder1" {
#   cloud_id = "my_cloud_id"
# }

# resource "yandex_logging_group" "yandex_logging_group_my" {
#   name      = "test-logging-group"
#   folder_id = "${data.folder1.test_folder.id}"
# }

resource "yandex_kms_symmetric_key" "kms-key" {
  name              = "kms-key"
  description       = "Ключ для шифрования важной информации кластера"
  default_algorithm = "AES_128"
  rotation_period   = "8760h" # 1 год
}


# Создаем кластер Kubernetes
resource "yandex_kubernetes_cluster" "k8s_cluster" {
  name       = "my-k8-cluster"
  network_id = var.network_id

  master {
    version = "1.28"
    zonal {
      zone      = var.provider_config.zone
      subnet_id = var.subnet_id
    }
    security_group_ids = [var.security_group_id]
    public_ip = true

    maintenance_policy {
      auto_upgrade = true
    }
  }

  service_account_id      = var.service_account_id
  node_service_account_id = var.service_account_id

  release_channel = "REGULAR"

  kms_provider {
    key_id = yandex_kms_symmetric_key.kms-key.id
  }
}

# Создаем группу узлов
resource "yandex_kubernetes_node_group" "k8s_node_group" {
  cluster_id = yandex_kubernetes_cluster.k8s_cluster.id
  name       = "k8s-node-group"
  version    = "1.28"

  instance_template {
    platform_id = "standard-v2"


    network_interface {
      nat        = true
      subnet_ids = [var.subnet_id]
    }

    resources {
      memory = 4
      cores  = 2
    }

    boot_disk {
      type = "network-ssd"
      size = 64
    }

    scheduling_policy {
      preemptible = true
    }
  }

  scale_policy {
    fixed_scale {
      size = 1
    }
  }

  allocation_policy {
    location {
      zone = var.provider_config.zone
    }
  }
}









# resource "yandex_kubernetes_cluster" "zonal_cluster" {
#   name        = "k8-test"
#   description = "kuber for testing purpuses"

#   network_id = var.network_id

#   master {
#     version = "1.30"
#     zonal {
#       zone      = var.provider_config.zone
#       subnet_id = var.subnet_id
#     }

#     public_ip = true

#     security_group_ids = ["${var.security_group_id}"]

#     maintenance_policy {
#       auto_upgrade = true

#       maintenance_window {
#         start_time = "15:00"
#         duration   = "3h"
#       }
#     }

#     # master_logging {
#     #   enabled                    = true
#     #   log_group_id               = yandex_logging_group_my.id
#     #   kube_apiserver_enabled     = true
#     #   cluster_autoscaler_enabled = true
#     #   events_enabled             = true
#     #   audit_enabled              = true
#     # }
#   }

#   service_account_id      = var.service_account_id
#   node_service_account_id = var.service_account_id

#   labels = {
#     my_key       = "my_value"
#     my_other_key = "my_other_value"
#   }

#   release_channel         = "RAPID"
#   network_policy_provider = "CALICO"

#   # kms_provider {
#   #   key_id = sym_key.kms_key_resource_name.id
#   # }
# }





# provider "yandex" {
#   token     = "ваш_токен"
#   cloud_id  = "идентификатор_облака"
#   folder_id = "идентификатор_папки"
#   zone      = "ru-central1-a"
# }

# resource "yandex_kubernetes_cluster" "example" {
#   name     = "example-cluster"
#   network_id = "ваш_network_id"

#   master {
#     version = "1.21"
#   }

#   node_pool {
#     name = "example-node-pool"

#     resources {
#       memory = "4Gi"
#       cores  = 2
#       disk_size = 20
#     }

#     scale {
#       initial = 3
#       min     = 1
#       max     = 5
#     }

#     labels = {
#       environment = "dev"
#     }

#     taints {
#       key    = "node-type"
#       value  = "development"
#       effect = "NoSchedule"
#     }
#   }

#   workload_level = "HIGH"
#   security_group_ids = ["ваш_идентификатор_группы_безопасности"]

#   maintenance_policy {
#     maintenance_window {
#       maintenance_start_time = "2022-10-10T12:00:00Z"
#       maintenance_end_time   = "2022-10-10T14:00:00Z"
#     }
#   }

#   # Опционально, добавить интеграцию с Yandex.Cloud Monitoring
#   monitoring_config {
#     enabled       = true
#     retention_days = 30
#   }
# }



# resource "yandex_kubernetes_node_group" "my_node_group" {
#   cluster_id  = yandex_kubernetes_cluster.zonal_cluster.id
#   name        = "name"
#   description = "description"
#   version     = "1.30"

#   labels = {
#     "key" = "value"
#   }

#   instance_template {
#     platform_id = "standard-v2"

#     network_interface {
#       nat        = true
#       subnet_ids = ["${var.subnet_id}"]
#     }

#     resources {
#       memory = 2
#       cores  = 2
#     }

#     boot_disk {
#       type = "network-hdd"
#       size = 64
#     }

#     scheduling_policy {
#       preemptible = false
#     }

#     container_runtime {
#       type = "containerd"
#     }
#   }

#   scale_policy {
#     fixed_scale {
#       size = 1
#     }
#   }

#   allocation_policy {
#     location {
#       zone = "ru-central1-a"
#     }
#   }

#   maintenance_policy {
#     auto_upgrade = true
#     auto_repair  = true

#     maintenance_window {
#       day        = "monday"
#       start_time = "15:00"
#       duration   = "3h"
#     }

#     maintenance_window {
#       day        = "friday"
#       start_time = "10:00"
#       duration   = "4h30m"
#     }
#   }
# }
