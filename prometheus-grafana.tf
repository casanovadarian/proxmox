resource "proxmox_vm_qemu" "cloudinit-prometheus-grafana" {

  # ----------------------------------------------------
  # 1. Configuración Básica de la VM
  # ----------------------------------------------------
  vmid        = 111
  name        = "prometheus-grafana"
  target_node = "pm-132" # Nombre del nodo físico de Proxmox

  # Parámetros Globales
  clone       = "ejemplo"
  full_clone  = true


  memory      = 8192

  onboot      = true      # Se iniciará automáticamente con el nodo Proxmox
  startup = "order=2"


  # ----------------------------------------------------
  # 2. Configuración de Cloud-Init
  # ----------------------------------------------------

  agent       = 1
  os_type     = "cloud-init"
  ipconfig0   = "ip=10.12.112.235/24,gw=10.12.112.254"
  ciuser      = "uclv"
  cipassword  = "uclv"

  # IMPORTANTE: Cambia esto a la ruta absoluta correcta
  sshkeys     = file("~/.ssh/id_ed25519.pub")

  cpu {
    sockets = 2
    cores   = 4
  }

  serial {
    id   = 0
    type = "socket" # Habilita la consola serial para el GUI de Proxmox
  }

  network {
    id       = 0
    model    = "virtio"
    bridge   = "vmbr1" # El bridge de red de tu Proxmox
    firewall = false
    tag      = 0 # Opcional: si no usas VLANs, déjalo en 0
  }

  # ----------------------------------------------------
  # 3. Habilitar Consola Serial y Red
  # ----------------------------------------------------
  scsihw = "virtio-scsi-single"
  disks {
    scsi {
      scsi0 {
        disk {
          size = "32G"
          storage = "local-lvm"
          replicate = "true"
        }
      }
    }
    ide {
      ide0 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      # Usamos el usuario que configuramos en ciuser
      user        = "uclv"
      # Usamos la IP que configuramos en ipconfig0
      host        = "10.12.112.235"
      # Usamos la clave que generamos localmente
      private_key = file("~/.ssh/id_ed25519")
      # IMPORTANTE: Nota que aquí usamos la clave PRIVADA (id_rsa), no la pública (id_rsa.pub)

      # Esperar a que SSH esté disponible (opcional, pero recomendado)
      timeout     = "5m"
    }
    inline = [
      "ip a"
    ]
  }

}