install_docker() {
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
}

install_docker_compose() {
    curl -L "https://github.com/docker/compose/releases/download/1.25.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
}

configure_code() {
    git clone https://github.com/michaeljacinto/docker-compose /home/todo-app
}

apt-get update && apt-get upgrade

install_docker

install_docker_compose

