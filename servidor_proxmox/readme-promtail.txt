1. Instalación de Promtail en Proxmox
# Descargar el binario directamente (v2.9.0 como ejemplo)
wget https://github.com/grafana/loki/releases/download/v2.9.0/promtail-linux-amd64.zip

# Instalar unzip si no lo tienes (debería estar en los repos de la UCLV)
apt-get update && apt-get install unzip -y

# Descomprimir y mover
unzip promtail-linux-amd64.zip
mv promtail-linux-amd64 /usr/local/bin/promtail
chmod +x /usr/local/bin/promtail

2. Configuración orientada a Proxmox
# En /etc/promtail/config.yml
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yaml

clients:
  - url: http://10.12.112.235:3100/loki/api/v1/push # Tu IP de Loki en Docker

scrape_configs:
  - job_name: system
    static_configs:
    - targets:
        - localhost
      labels:
        job: proxmox-system
        node: pm-132
        __path__: /var/log/syslog # Logs generales del sistema

  - job_name: pve-auth
    static_configs:
    - targets:
        - localhost
      labels:
        job: proxmox-auth
        node: pm-132
        __path__: /var/log/pveproxy/access.log # Accesos a la interfaz web

  - job_name: pve-cluster
    static_configs:
    - targets:
        - localhost
      labels:
        job: proxmox-cluster
        node: pm-132
        __path__: /var/log/pve/tasks/* # Historial de tareas (crear VM, backups, etc)

3. Crear el servicio Systemd
nano /etc/systemd/system/promtail.service

[Unit]
Description=Promtail service
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/promtail -config.file=/etc/promtail/config.yml
Restart=on-failure

[Install]
WantedBy=multi-user.target

4. Activar el servicio
systemctl daemon-reload
systemctl enable promtail
systemctl start promtail

5. ¿Cómo verificar si Promtail está enviando datos?
nc -zv 10.12.112.235 3100