resource "yandex_compute_instance" "vm" {
  name               = var.instance_name
  service_account_id = var.service_account_id
  platform_id        = "standard-v3"


  provisioner "file" {
    content = templatefile("${path.module}/scripts/setup.sh", {
      private_key              = file(var.private_key_path)
      access_key               = var.access_key
      secret_key               = var.secret_key
      s3_bucket_name           = var.s3_bucket_name
      }
    )
    destination = "/home/${var.instance_user}/setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/${var.instance_user}/setup.sh",
      "sudo /home/${var.instance_user}/setup.sh"
    ]
  }

  scheduling_policy {
    preemptible = true
  }

  resources {
    cores  = 2
    memory = 8
    core_fraction = 20 # 20% vCPU
  }

  boot_disk {
    initialize_params {
      image_id = var.ubuntu_image_id
      size     = 20
    }
  }

  network_interface {
    subnet_id = var.subnet_id
    nat       = true
  }

  metadata = {
    ssh-keys = "${var.instance_user}:${file(var.public_key_path)}"
    serial-port-enable = "1"
  }

  connection {
    type        = "ssh"
    user        = var.instance_user
    private_key = file(var.private_key_path)
    host        = self.network_interface.0.nat_ip_address
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sudo add-apt-repository -y \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"",
      "sudo apt-get update",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io",
      "sudo usermod -aG docker $USER",
    ]
  }

}

  # metadata = {
  #   ssh-keys = "ubuntu:${file(var.public_key_path)}"
  #   user-data = templatefile("${path.root}/scripts/user_data.sh", {
  #     token                       = var.yc_token
  #     cloud_id                    = var.yc_cloud_id
  #     folder_id                   = var.yc_folder_id
  #     private_key                 = file(var.private_key_path)
  #     access_key                  = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  #     secret_key                  = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  #     s3_bucket                   = yandex_storage_bucket.data_bucket.bucket
  #     upload_data_to_hdfs_content = file("${path.root}/scripts/upload_data_to_hdfs.sh")
  #     upload_data_from_hdfs_content = file("${path.root}/scripts/upload_data_from_hdfs.sh")
  #   })
  # }



  # provisioner "remote-exec" {
  #   inline = [
  #     "chmod +x /home/${var.instance_user}/setup.sh",
  #     "sudo /home/${var.instance_user}/setup.sh"
  #   ]
  # }
