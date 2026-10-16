#!/bin/bash
set -e

ROLE="${1:?Gunakan frontend atau api}"
NODE="${2:?Masukkan nama worker}"

DB_HOST="192.225.4.9"
DB_NAME="db_shibuya_k28"
DB_USER="appuser"
DB_PASS="AppPass123!"

GOJO_IP="192.225.1.4"
GETO_IP="192.225.4.2"

if [ "$ROLE" != "frontend" ] && [ "$ROLE" != "api" ]; then
    echo "Role harus frontend atau api"
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive
echo "=== Instalasi worker $NODE ($ROLE) ==="
apt-get update
apt-get install -y nginx php-fpm php-mysql mariadb-client

# Mulai PHP-FPM
for svc in /etc/init.d/php*-fpm; do
    [ -x "$svc" ] && service "$(basename "$svc")" start
done

PHP_SOCK="$(find /run/php -maxdepth 1 -name 'php*-fpm.sock' | head -n 1)"
if [ -z "$PHP_SOCK" ]; then
    echo "ERROR: socket PHP-FPM tidak ditemukan"
    exit 1
fi

mkdir -p /var/www/html

if [ "$ROLE" = "frontend" ]; then
    ALLOW_IP="$GOJO_IP"

    cat > /var/www/html/index.php <<PHP
<?php
header('Content-Type: text/html; charset=utf-8');
echo '<h1>Jujutsu High Frontend</h1>';
echo '<p>Worker: ' . htmlspecialchars('$NODE') . '</p>';
echo '<p>Hostname: ' . htmlspecialchars(gethostname()) . '</p>';
?>
PHP

    SERVER_NAMES="jujutsu.k28.com www.jujutsu.k28.com"
else
    ALLOW_IP="$GETO_IP"

    cat > /var/www/html/index.php <<'PHP'
<?php
header('Content-Type: application/json; charset=utf-8');

$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';
$endpoint = $_SERVER['REQUEST_URI'] ?? '/';
$client_ip = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
$status_code = 200;

mysqli_report(MYSQLI_REPORT_OFF);
$db = new mysqli(
    '192.225.4.9',
    'appuser',
    'AppPass123!',
    'db_shibuya_k28'
);

if ($db->connect_errno) {
    http_response_code(500);
    echo json_encode([
        'error' => 'Database connection failed',
        'worker' => gethostname()
    ]);
    exit;
}

$stmt = $db->prepare(
    'INSERT INTO request_logs
    (client_ip, endpoint, request_method, status_code)
    VALUES (?, ?, ?, ?)'
);

if ($stmt) {
    $stmt->bind_param('sssi', $client_ip, $endpoint, $method, $status_code);
    $stmt->execute();
    $stmt->close();
}

$db->close();

echo json_encode([
    'service' => 'Jujutsu High API',
    'worker' => gethostname(),
    'endpoint' => $endpoint,
    'method' => $method,
    'logged' => true
], JSON_PRETTY_PRINT);
echo "\n";
?>
PHP

    SERVER_NAMES="api.jujutsu.k28.com"
fi

cat > /etc/nginx/sites-available/default <<NGINX
server {
    listen 80;
    server_name $SERVER_NAMES;

    root /var/www/html;
    index index.php index.html;

    # Hanya proxy yang ditentukan boleh mengakses worker
    allow $ALLOW_IP;
    deny all;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:$PHP_SOCK;
    }

    location ~ /\. {
        deny all;
    }
}
NGINX

nginx -t
service nginx restart

echo "=== SELESAI: $NODE ($ROLE) ==="
nginx -t
service nginx status
