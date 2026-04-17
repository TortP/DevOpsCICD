#!/usr/bin/env bash
set -euo pipefail

# Install DevOps tools on Ubuntu/Debian:
# - Docker
# - Docker Compose plugin
# - Python 3.9+
# - Django via pip

if [[ "${EUID}" -eq 0 ]]; then
  SUDO=""
else
  SUDO="sudo"
fi

APT_UPDATED=0

log() {
  echo "[INFO] $*"
}

warn() {
  echo "[WARN] $*"
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1
}

apt_update_once() {
  if [[ "${APT_UPDATED}" -eq 0 ]]; then
    log "Updating apt package index..."
    ${SUDO} apt-get update -y
    APT_UPDATED=1
  fi
}

force_apt_update() {
  log "Refreshing apt package index..."
  ${SUDO} apt-get update -y
  APT_UPDATED=1
}

install_pkg() {
  local pkg="$1"
  if dpkg -s "${pkg}" >/dev/null 2>&1; then
    log "Package '${pkg}' is already installed. Skipping."
  else
    apt_update_once
    log "Installing package '${pkg}'..."
    ${SUDO} env DEBIAN_FRONTEND=noninteractive apt-get install -y "${pkg}"
  fi
}

ensure_base_packages() {
  install_pkg ca-certificates
  install_pkg curl
  install_pkg gnupg
  install_pkg lsb-release
}

install_docker() {
  if need_cmd docker; then
    log "Docker is already installed. Skipping."
    return
  fi

  log "Installing Docker from Docker official repository..."
  ensure_base_packages

  ${SUDO} install -m 0755 -d /etc/apt/keyrings
  if [[ ! -f /etc/apt/keyrings/docker.gpg ]]; then
    local distro_id
    distro_id="$(. /etc/os-release && echo "${ID}")"
    curl -fsSL "https://download.docker.com/linux/${distro_id}/gpg" | ${SUDO} gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    ${SUDO} chmod a+r /etc/apt/keyrings/docker.gpg
  fi

  local distro_id
  local codename
  distro_id="$(. /etc/os-release && echo "${ID}")"
  codename="$(. /etc/os-release && echo "${VERSION_CODENAME}")"

  if [[ ! -f /etc/apt/sources.list.d/docker.list ]]; then
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/${distro_id} ${codename} stable" |
      ${SUDO} tee /etc/apt/sources.list.d/docker.list >/dev/null
    force_apt_update
  fi

  apt_update_once
  ${SUDO} env DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  log "Docker installation completed."
}

install_docker_compose() {
  if docker compose version >/dev/null 2>&1; then
    log "Docker Compose (plugin) is already installed. Skipping."
  else
    log "Docker Compose plugin not found. Installing docker-compose-plugin..."
    install_pkg docker-compose-plugin
  fi
}

install_python() {
  if need_cmd python3; then
    local py_ver
    py_ver="$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')"
    local py_major py_minor
    py_major="${py_ver%%.*}"
    py_minor="${py_ver##*.}"

    if (( py_major > 3 || (py_major == 3 && py_minor >= 9) )); then
      log "Python ${py_ver} is already installed (>= 3.9). Skipping."
    else
      warn "Detected Python ${py_ver}, but required is >= 3.9. Attempting to install newer Python package."
      apt_update_once
      if apt-cache show python3.11 >/dev/null 2>&1; then
        install_pkg python3.11
      elif apt-cache show python3.10 >/dev/null 2>&1; then
        install_pkg python3.10
      elif apt-cache show python3.9 >/dev/null 2>&1; then
        install_pkg python3.9
      else
        warn "Could not find python3.9+ package in repositories. Keeping system python3 (${py_ver})."
      fi
    fi
  else
    log "Python3 is not installed. Installing..."
    install_pkg python3
  fi

  if need_cmd pip3; then
    log "pip3 is already installed."
  else
    log "Installing pip3..."
    install_pkg python3-pip
  fi
}

install_django() {
  if python3 -m django --version >/dev/null 2>&1; then
    local dj_ver
    dj_ver="$(python3 -m django --version)"
    log "Django ${dj_ver} is already installed. Skipping."
    return
  fi

  log "Installing Django via pip..."
  if python3 -m pip install --upgrade pip >/dev/null 2>&1; then
    :
  fi

  if python3 -m pip install django; then
    log "Django installed successfully."
  else
    warn "Standard pip install failed. Retrying with --break-system-packages (Debian/Ubuntu managed env)..."
    python3 -m pip install --break-system-packages django
    log "Django installed successfully."
  fi
}

main() {
  install_docker
  install_docker_compose
  install_python
  install_django

  log "All tasks completed."
  log "Versions:"
  docker --version || true
  docker compose version || true
  python3 --version || true
  python3 -m django --version || true
}

main "$@"
