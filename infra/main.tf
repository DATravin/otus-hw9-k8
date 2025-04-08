# main.tf
locals {
  home = "/home/${var.yc_instance_user}"
  home_app = "/home/${var.yc_instance_user}/app"
  home_app_test = "/home/${var.yc_instance_user}/app_test"

  app_path = "${local.home_app}/app.py"
  inference_path = "${local.home_app}/infrerence_app.py"
  docker_path = "${local.home_app}/Dockerfile"
  entrypoint_path = "${local.home_app}/entrypoint.sh"
  requirements_path = "${local.home_app}/requirements.txt"
  inference_loc_path = "${local.home_app}/inference.py"

  app_test_path = "${local.home_app_test}/app.py"
  docker_test_path = "${local.home_app_test}/Dockerfile"
  entrypoint_test_path = "${local.home_app_test}/entrypoint.sh"
  requirements_test_path = "${local.home_app_test}/requirements.txt"
  inference_test_path = "${local.home_app_test}/inference.py"
}

module "iam" {
  source          = "./modules/iam"
  name            = var.yc_service_account_name
  provider_config = var.yc_config
}

module "network" {
  source          = "./modules/network"
  network_name    = var.yc_network_name
  subnet_name     = var.yc_subnet_name
  provider_config = var.yc_config
}

# module "compute" {
#   source             = "./modules/compute"
#   instance_user      = var.yc_instance_user
#   instance_name      = var.yc_instance_name
#   service_account_id = module.iam.service_account_id
#   subnet_id          = module.network.subnet_id
#   ubuntu_image_id    = var.ubuntu_image_id
#   public_key_path    = var.public_key_path
#   private_key_path   = var.private_key_path
#   provider_config    = var.yc_config
#   access_key         = module.iam.access_key
#   secret_key         = module.iam.secret_key
#   s3_bucket_name     = var.yc_cold_bucket_name
# }

module "kuber" {
  source             = "./modules/kuber"
  network_id         = module.network.network_id
  service_account_id = module.iam.service_account_id
  security_group_id  = module.network.security_group_id
  subnet_id          = module.network.subnet_id
  provider_config    = var.yc_config
}


# resource "local_file" "variables_file" {
#   content = jsonencode({
#     # общие переменные
#     YC_ZONE           = var.yc_config.zone
#     YC_FOLDER_ID      = var.yc_config.folder_id
#     YC_SUBNET_ID      = module.network.subnet_id
#     YC_SSH_PUBLIC_KEY = trimspace(file(var.public_key_path))
#     # S3
#     S3_ENDPOINT_URL     = var.yc_storage_endpoint_url
#     S3_ACCESS_KEY       = module.iam.access_key
#     S3_SECRET_KEY       = module.iam.secret_key
#     S3_BUCKET_NAME_COLD = var.yc_cold_bucket_name
#     # AIRFLOW
#     VM_HOST              = module.compute.external_ip_address

#   })
#   filename        = "./variables.json"
#   file_permission = "0600"
# }


# # Добавляем ресурс для копирования и импорта переменных
# resource "null_resource" "import_variables" {
#   connection {
#     type        = "ssh"
#     user        = var.yc_instance_user
#     private_key = file(var.private_key_path)
#     host        = module.compute.external_ip_address
#   }

#   # Копируем файлы на VM

#   provisioner "file" {
#     source      = "${path.root}/app/app.py"
#     # destination = "/home/${local.variables_path}/app/app.py"
#     # destination = "${local.home}/app/app.py"
#     destination = "${local.app_path}"
#   }

#   provisioner "file" {
#     source      = "${path.root}/app/Dockerfile"
#     #destination = "${local.home}/app/Dockerfile"
#     destination = "${local.docker_path}"
#   }

#   provisioner "file" {
#     source      = "${path.root}/app/entrypoint.sh"
#     #destination = "${local.home}/app/entrypoint.sh"
#     destination = "${local.entrypoint_path}"
#   }

#   provisioner "file" {
#     source      = "${path.root}/app/infrerence_app.py"
#     #destination = "${local.home}/app/inference_app.py"
#     destination = "${local.inference_path}"
#   }

#   provisioner "file" {
#     source      = "${path.root}/app/inference.py"
#     #destination = "${local.home}/app/inference_app.py"
#     destination = "${local.inference_loc_path}"
#   }

#   provisioner "file" {
#     source      = "${path.root}/app/requirements.txt"
#     #destination = "${local.home}/app/requirements.txt"
#     destination = "${local.requirements_path}"
#   }

#   provisioner "file" {
#     source      = "${path.root}/app_test/app.py"
#     # destination = "/home/${local.variables_path}/app/app.py"
#     #destination = "${local.home}/app_test/app.py"
#     destination = "${local.app_test_path}"
#   }

#   provisioner "file" {
#     source      = "${path.root}/app_test/Dockerfile"
#     #destination = "${local.home}/app_test/Dockerfile"
#     destination = "${local.docker_test_path}"
#   }

#   provisioner "file" {
#     source      = "${path.root}/app_test/entrypoint.sh"
#   #  destination = "${local.home}/app_test/entrypoint.sh"
#     destination = "${local.entrypoint_test_path}"
#   }


#   provisioner "file" {
#     source      = "${path.root}/app_test/requirements.txt"
#     #destination = "${local.home}/app_test/requirements.txt"
#     destination = "${local.requirements_test_path}"
#   }

#   provisioner "file" {
#     source      = "${path.root}/app_test/inference.py"
#     #destination = "${local.home}/app_test/requirements.txt"
#     destination = "${local.inference_test_path}"
#   }
# }
