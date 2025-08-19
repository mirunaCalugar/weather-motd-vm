# 🌦️ Weather MOTD VM

This project automates a Virtual Machine (VM) so that it fetches and displays the **current weather** for a chosen city **at startup** and **on login**, by updating the system MOTD (*Message of the Day*).

---

## 🎯 Features
- Fetches weather from [wttr.in](https://wttr.in) (**daily**) or [Open-Meteo](https://open-meteo.com) (**weekly**).
- City is configurable in `/etc/default/weather`.
- Always generates a **clean MOTD** (no duplicates, idempotent).
- Runs automatically at boot using `systemd`.
- **Bonus 1:** Displays system uptime.
- **Bonus 2:** Displays root filesystem disk usage.
- **Bonus 3:** Logs every run into `/var/log/weather.log`.

---

## 📂 Project Files

| File | Purpose |
|------|----------|
| `/usr/local/sbin/weather.sh` | Main script (fetches weather + updates MOTD) |
| `/etc/systemd/system/weather.service` | Systemd unit file (runs script at boot) |
| `/etc/default/weather` | Environment config (city name stored here) |
| `README.md` | Project documentation |

---

## ⚙️ Installation (Step by Step)

1. **Clone the repository**
   ```bash
   git clone https://github.com/mirunaCalugar/weather-motd-vm.git
   cd weather-motd-vm

##  Usage
1. **Check MOTD**
```bash
cat /etc/motd
2. **Manual refresh**
```bash
sudo systemctl restart weather.service
3. **Run directly**
```bash
sudo /usr/local/sbin/weather.sh --today --stdout
sudo /usr/local/sbin/weather.sh --week --stdout




