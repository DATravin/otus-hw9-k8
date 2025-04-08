#!/bin/bash

# мое

# Функция для логирования
function log() {
    sep="----------------------------------------------------------"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $sep " | tee -a $HOME/user_data_execution.log
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [INFO] $1" | tee -a $HOME/user_data_execution.log
}

# Устанавливаем yc CLI
log "Installing yc CLI"
export HOME="/home/ubuntu"
curl https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash

# Проверяем, что yc доступен
if command -v yc &> /dev/null; then
    log "yc CLI is now available"
    yc --version
else
    log "yc CLI is still not available. Adding it to PATH manually"
    export PATH="$PATH:$HOME/yandex-cloud/bin"
    yc --version
fi

# Устанавливаем переменные

log "add env variables"
echo "S3_ACCESS_KEY=${access_key}" >> /home/ubuntu/.bashrc
echo "S3_SECRET_KEY=${secret_key}" >> /home/ubuntu/.bashrc
echo "S3_BUCKET_NAME=${s3_bucket_name}" >> /home/ubuntu/.bashrc
echo "S3_ENDPOINT_URL=https://storage.yandexcloud.net/" >> /home/ubuntu/.bashrc

log "exports"
export HOME="/home/ubuntu"

# Настраиваем s3cmd как прокинуть туда переменные?
log "Configuring s3cmd"
cat <<EOF > /home/ubuntu/.s3cfg
[default]
access_key = ${access_key}
secret_key = ${secret_key}
host_base = storage.yandexcloud.net
host_bucket = %(bucket)s.storage.yandexcloud.net
use_https = True
EOF

chown ubuntu:ubuntu /home/ubuntu/.s3cfg
chmod 600 /home/ubuntu/.s3cfg

# Создаем директорию для скриптов на прокси-машине
log "Creating scripts directory on proxy machine"
mkdir -p /home/ubuntu/app
mkdir -p /home/ubuntu/app_test

chown ubuntu:ubuntu /home/ubuntu/app
chmod 777 /home/ubuntu/app

chown ubuntu:ubuntu /home/ubuntu/app_test
chmod 777 /home/ubuntu/app_test


log "Configuring .env"
cat <<EOF > /home/ubuntu/app/.env
[default]
S3_ACCESS_KEY = ${access_key}
S3_SECRET_KEY = ${secret_key}
S3_BUCKET_NAME = ${s3_bucket_name}
S3_ENDPOINT_URL = https://storage.yandexcloud.net/
EOF

chown ubuntu:ubuntu /home/ubuntu/app/.env
chmod 777 /home/ubuntu/app/.env



log "Configuring .env2"
cat <<EOF > /home/ubuntu/app_test/.env
[default]
S3_ACCESS_KEY = ${access_key}
S3_SECRET_KEY = ${secret_key}
S3_BUCKET_NAME = ${s3_bucket_name}
S3_ENDPOINT_URL = https://storage.yandexcloud.net/
EOF

chown ubuntu:ubuntu /home/ubuntu/app_test/.env
chmod 777 /home/ubuntu/app_test/.env

log "installing kubectl"
sudo apt install -y  snapd
snap install kubectl --classic


log "Setup completed successfully"
