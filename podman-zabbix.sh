# 1. Create new pod with name zabbix and exposed ports (web-interface, Zabbix server trapper):

podman pod create --name zabbix -p 8080:8080 -p 10051:10051

# 2. (optional) Start Zabbix agent container in zabbix pod location:

podman run --name zabbix-agent \
    -eZBX_SERVER_HOST="127.0.0.1,localhost" \
    --restart=always \
    --pod=zabbix \
    -d zabbix/zabbix-agent:latest


# 3. Create ./mysql/ directory on host and start Oracle MySQL server 8.0:

mkdir -p ./mysql

podman run --name mysql-server -t \
    -e MYSQL_DATABASE="zabbix" \
    -e MYSQL_USER="zabbix" \
    -e MYSQL_PASSWORD="zabbix_pwd" \
    -e MYSQL_ROOT_PASSWORD="root_pwd" \
    -v ./mysql/:/var/lib/mysql/:Z \
    --restart=always \
    --pod=zabbix \
    -d mysql:8.0 \
    --character-set-server=utf8 --collation-server=utf8_bin \
    --default-authentication-plugin=mysql_native_password

# 3. Start Zabbix server container:

podman run --name zabbix-server-mysql -t \
    -e DB_SERVER_HOST="127.0.0.1" \
    -e MYSQL_DATABASE="zabbix" \
    -e MYSQL_USER="zabbix" \
    -e MYSQL_PASSWORD="zabbix_pwd" \
    -e MYSQL_ROOT_PASSWORD="root_pwd" \
    -e ZBX_JAVAGATEWAY="127.0.0.1" \
    --restart=always \
    --pod=zabbix \
    -d zabbix/zabbix-server-mysql:alpine-6.2-latest

# 4. Start Zabbix Java Gateway container:

podman run --name zabbix-java-gateway -t \
    --restart=always \
    --pod=zabbix \
    -d zabbix/zabbix-java-gateway:alpine-6.2-latest

# 5. Start Zabbix web-interface container:

podman run --name zabbix-web-mysql -t \
    -e ZBX_SERVER_HOST="127.0.0.1" \
    -e DB_SERVER_HOST="127.0.0.1" \
    -e MYSQL_DATABASE="zabbix" \
    -e MYSQL_USER="zabbix" \
    -e MYSQL_PASSWORD="zabbix_pwd" \
    -e MYSQL_ROOT_PASSWORD="root_pwd" \
    --restart=always \
    --pod=zabbix \
    -d zabbix/zabbix-web-nginx-mysql:alpine-6.2-latest
