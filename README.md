# Lightweight VNC Remote Desktop (Fluxbox)

This project provides a simple, lightweight remote desktop solution using Docker. It combines:
* **TigerVNC:** A high-performance VNC server.
* **Fluxbox:** An extremely lightweight and fast window manager.
* **noVNC:** A web-based VNC client, allowing you to connect from any browser.
* **Debian Bullseye (slim):** A minimal and stable base.

## 📦 Files

* `Dockerfile`: The build recipe for the Docker image.
* `entrypoint.sh`: The startup script that configures and launches VNC.
* `README.md`: This file.

## ⚙️ Configuration

The container is configured using environment variables set at runtime.

| Variable | Description | Default |
| :--- | :--- | :--- |
| `VNC_PW` | The password to access the VNC session. | `secret` |
| `VNC_RESOLUTION` | The desktop resolution. | `1280x720` |
| `VNC_USER` | The non-root user to create. *(Note: This must match the `VNC_USER` build-arg in the Dockerfile if you change it)* | `docker` |

---

## 🚀 How to Use

### 1. Build the Image

From the directory containing the `Dockerfile`, run:

```bash
docker build -t lightweight-vnc .
```

docker run --rm \
  -p 6901:6901 \
  -p 5901:5901 \
  -e VNC_PW=mypassword \
  -e VNC_RESOLUTION=1920x1080 \
  --shm-size=1g \
  lightweight-vnc

docker run --rm \
  -p 6901:6901 \
  -p 5901:5901 \
  -e VNC_PW=mypassword \
  -e VNC_RESOLUTION=1920x1080 \
  --shm-size=1g \
  lightweight-vnc

http://localhost:6901
vnc://localhost:5901


### Makefile Quick Reference

| Command | Description |
| :--- | :--- |
| `make build` | Builds the `lightweight-vnc` Docker image. |
| `make run` | **Start Fresh:** Runs a new, temporary (ephemeral) session. |
| `make run-persistent` | **Start & Persist:** Runs a new container that saves data. |
| `make start` | Restarts the existing persistent container. |
| `make stop` | Stops the persistent container. |
| `make logs` | Views the live logs of the persistent container. |
| `make shell` | Opens a bash shell inside the running container. |
| `make clean` | Stops and **permanently removes** the persistent container. |
| `make help` | Shows all available commands. |

**Note:** You can override variables on any command, e.g., `make VNC_PW=newpass run`.
