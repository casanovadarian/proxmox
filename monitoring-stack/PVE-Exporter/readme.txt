# Python y Pip:
apt update
apt install python3 python3-pip

#Instalar el Exporter:
pip3 install prometheus-pve-exporter

#Crear el Archivo de Configuración (pve.yml): Crea un 
#archivo para que el Exporter sepa cómo autenticarse con la API de Proxmox.
nano /etc/prometheus/pve.yml

#Contenido del archivo (usando el token):
default:
  user: tu_usuario@pve # Ej: prometheus@pve
  token_name: token_id_que_creaste # Ej: exporter
  token_value: el_valor_secreto_que_guardaste
  verify_ssl: False # Cambia a True si usas certificados válidos

#Configurar como Servicio Systemd
sudo nano /etc/systemd/system/pve_exporter.service

#Pega el siguiente contenido:
[Unit]
Description=PVE Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=pveAuditor
Group=
Type=simple
ExecStart=

[Install]
WantedBy=multi-user.target

#Iniciar y Habilitar el Servicio
sudo systemctl daemon-reload
sudo systemctl start pve_exporter
sudo systemctl enable pve_exporter

sudo systemctl status pve_exporter
