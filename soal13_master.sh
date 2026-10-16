#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive

DB_NAME="db_shibuya_k28"
REPL_USER="replica"
REPL_PASS="ReplicaPass123!"

apt-get update
apt-get install -y mariadb-server mariadb-client

cat > /etc/mysql/mariadb.conf.d/60-master.cnf <<'EOC'
[mysqld]
server-id = 1
log_bin = /var/log/mysql/mysql-bin.log
binlog_format = ROW
bind-address = 0.0.0.0
EOC

service mariadb restart

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

CREATE USER IF NOT EXISTS '${REPL_USER}'@'192.225.4.%'
IDENTIFIED BY '${REPL_PASS}';

GRANT REPLICATION SLAVE ON *.* TO '${REPL_USER}'@'192.225.4.%';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${REPL_USER}'@'192.225.4.%';

CREATE USER IF NOT EXISTS 'appuser'@'192.225.4.%'
IDENTIFIED BY 'AppPass123!';

GRANT SELECT, INSERT, UPDATE, DELETE
ON \`${DB_NAME}\`.* TO 'appuser'@'192.225.4.%';

FLUSH PRIVILEGES;
EOSQL

echo "=== STATUS MASTER ==="
mariadb -e "SHOW MASTER STATUS;"