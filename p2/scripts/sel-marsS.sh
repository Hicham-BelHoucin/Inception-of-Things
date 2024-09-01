#!/bin/bash

# Install k3s with the specified IP address
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --write-kubeconfig-mode 644 --node-ip=192.168.56.110" sh -

# Wait for k3s to be ready
while [ ! -d /var/lib/rancher/k3s/server/manifests/ ]; do
    sleep 1
done

# Function to replace placeholders in the template
generate_yaml() {
    local APP_NAME=$1
    local APP_VERSION=$2
    local APP_REPLICAS=$3
    local APP_REPO=$4
    local APP_HOST=$5

    cp /vagrant/app.yaml "/vagrant/${APP_NAME}.yaml"
    sed -i -e "s#{{APP_NAME}}#${APP_NAME}#g" \
        -e "s#{{APP_VERSION}}#${APP_VERSION}#g" \
        -e "s#{{APP_REPLICAS}}#${APP_REPLICAS}#g" \
        -e "s#{{APP_REPO}}#${APP_REPO}#g" \
        -e "s#{{APP_HOST}}#${APP_HOST}#g" "/vagrant/${APP_NAME}.yaml"
}

# Define app details in arrays
APP_NAMES=("app1" "app2" "app3")
APP_VERSIONS=("0.1" "0.2" "0.3")
APP_REPLICAS=("1" "3" "1")
APP_REPO="soofiane262/iot-app"
APP_HOSTS=("app1.com" "app2.com" "")

# Generate and deploy YAML files
for i in "${!APP_NAMES[@]}"; do
    generate_yaml "${APP_NAMES[$i]}" "${APP_VERSIONS[$i]}" "${APP_REPLICAS[$i]}" "${APP_REPO}" "${APP_HOSTS[$i]}"
done
wait

# Deploy the apps automatically
for APP_NAME in "${APP_NAMES[@]}"; do
    cp "/vagrant/${APP_NAME}.yaml" /var/lib/rancher/k3s/server/manifests/
done
