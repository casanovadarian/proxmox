1. Preparar Proxmox (Usuario y Permisos)
Antes de instalar nada, necesitamos que el exporter tenga permiso para leer las métricas de la API de Proxmox:

Crear Usuario: En la interfaz web, ve a Datacenter > Permissions > Users y crea prometheus@pve.

Crear Token: Ve a API Tokens, selecciona al usuario y dale un nombre (ej. monitor). Apunta el Token ID y el Secret, no se volverán a mostrar.

Permisos: Ve a Permissions, añade "API Token Permission". Path: /, Token: prometheus@pve!monitor, Role: PVEAuditor.


2.1 Instalar prometheus-pve-exporter en ambiente virtual
apt install python3.11-venv
python3 -m venv /opt/pve-exporter
# En tu PC con internet (Linux o Windows con Python instalado)
mkdir pve_exporter_pkgs
pip download prometheus-pve-exporter -d ./pve_exporter_pkgs
tar -cvzf pve_exporter_pkgs.tar.gz ./pve_exporter_pkgs
scp pve_exporter_pkgs.tar.gz proxmox:/tmp/
#Dentro de proxmox
cd /tmp
tar -xvzf pve_exporter_pkgs.tar.gz
apt update
apt install python3-yaml python3-requests python3-prometheus-client python3-proxmoxer -y
# Instalar apuntando a la carpeta local de descargas
/opt/pve-exporter/bin/pip install --no-index --find-links=/tmp/pve_exporter_pkgs prometheus-pve-exporter --no-deps
sed -i 's/include-system-site-packages = false/include-system-site-packages = true/' /opt/pve-exporter/pyvenv.cfg

apt update
apt install python3-wrapt -y

#Crear el archivo del servicio
nano /etc/systemd/system/prometheus-pve-exporter.service

[Unit]
Description=Prometheus PVE Exporter
After=network.target

[Service]
Type=simple
User=root
# Verifica que esta ruta sea la correcta de tu entorno virtual
ExecStart=/opt/pve-exporter/bin/pve_exporter /etc/pve-exporter.yml
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target

systemctl daemon-reload
systemctl enable prometheus-pve-exporter
systemctl start prometheus-pve-exporter
systemctl status prometheus-pve-exporter

2.2 Instalar prometheus-pve-exporter
apt update && apt install pipx -y
pipx install prometheus-pve-exporter

2.3 Instalar el exporter
apt update && apt install prometheus-node-exporter -y
systemctl enable --now prometheus-node-exporter


3. descargar y copiar grafana alloy
#En pc con internet
wget https://github.com/grafana/alloy/releases/download/v1.13.0/alloy-1.13.0-1.amd64.deb
scp alloy-1.13.0-1.amd64.deb proxmox:/tmp/

#En los servidores proxmox 
apt install gpg -y
dpkg -i /tmp/alloy-1.13.0-1.amd64.deb 

