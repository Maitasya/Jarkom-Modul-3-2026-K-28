#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive

MASTER_IP="192.225.4.9"
SLAVE_ID="2"
DB_NAME="db_shibuya_k28"
REPL_USER="replica"
REPL_PASS="ReplicaPass123!"
MASTER_LOG_FILE="mysql-bin.000001"
MASTER_LOG_POS="2005"

apt-get update
apt-get install -y mariadb-server mariadb-client

cat > /etc/mysql/mariadb.conf.d/60-slave.cnf <<'EOC'
[mysqld]
server-id = 2
relay_log = /var/log/mysql/mysql-relay-bin.log
read_only = ON
bind-address = 0.0.0.0
EOC

mkdir -p /var/log/mysql /run/mysqld
chown mysql:mysql /var/log/mysql /run/mysqld

service mariadb restart

# Siapkan skema awal agar tabel sudah tersedia di Slave
mariadb <<EOSQL
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;

USE \`${DB_NAME}\`;

CREATE TABLE IF NOT EXISTS request_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    client_ip VARCHAR(45),
    endpoint VARCHAR(255),
    request_method VARCHAR(10),
    status_code INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
EOSQL

mariadb <<EOSQL
STOP SLAVE;
RESET SLAVE ALL;

CHANGE MASTER TO
    MASTER_HOST='${MASTER_IP}',
    MASTER_PORT=3306,
    MASTER_USER='${REPL_USER}',
    MASTER_PASSWORD='${REPL_PASS}',
    MASTER_LOG_FILE='${MASTER_LOG_FILE}',
    MASTER_LOG_POS=${MASTER_LOG_POS};

START SLAVE;
EOSQL

echo "=== STATUS SLAVE ==="
mariadb -e "SHOW SLAVE STATUS\\G"
