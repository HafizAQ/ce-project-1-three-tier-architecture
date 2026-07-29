#!/bin/bash
set -e

cat > /opt/db-placeholder.py <<'PYTHON'
#!/usr/bin/env python3

import json
import socket
import threading
import time

HOST = "0.0.0.0"
PORT = 3306
START_TIME = time.time()
connection_count = 0
lock = threading.Lock()


def handle_client(connection, address):
    global connection_count

    with connection:
        with lock:
            connection_count += 1
            current_connections = connection_count

        response = {
            "status": "db_healthy",
            "service": "mysql-placeholder",
            "port": PORT,
            "client": address[0],
            "connections": current_connections,
            "uptime_seconds": round(time.time() - START_TIME, 2)
        }

        connection.sendall(
            (json.dumps(response) + "\n").encode("utf-8")
        )


def main():
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind((HOST, PORT))
    server.listen(50)

    print(f"Database placeholder listening on {HOST}:{PORT}", flush=True)

    while True:
        connection, address = server.accept()
        thread = threading.Thread(
            target=handle_client,
            args=(connection, address),
            daemon=True
        )
        thread.start()


if __name__ == "__main__":
    main()
PYTHON

chmod +x /opt/db-placeholder.py

cat > /etc/systemd/system/db-placeholder.service <<'SERVICE'
[Unit]
Description=Three-Tier Database Placeholder
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 /opt/db-placeholder.py
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable --now db-placeholder.service
