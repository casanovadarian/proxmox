terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.2-rc06"
    }
  }
}


provider "proxmox" {
  # Corregido: Usa pm_api_url
  pm_api_url = "https://10.12.112.233:8006/api2/json"

  # Corregido: Usa pm_tls_insecure
  pm_tls_insecure = true

  # Corregido: Usa pm_user (con el realm, ejemplo: uclv@pam)
  pm_api_token_id = "uclv@pve!terraform" # ¡Asegúrate de incluir tu realm (ej: @pve, @pam)!

  # Corregido: Usa pm_password
  pm_api_token_secret = "4ed2bda2-f6f3-4273-834d-ff2a6461616a"


}