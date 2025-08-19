# 🌦️ Weather MOTD VM

This project automates a VM so that it fetches and displays the current weather
for a chosen city **at startup** and **on login**, by updating the system MOTD
(*Message of the Day*).

---

## 🎯 Features
- Fetches weather from [wttr.in](https://wttr.in) (daily) or Open-Meteo (weekly).
- City is configurable in `/etc/default/weather`.
- Clean MOTD on every run (idempotent).
- Runs automatically at boot using `systemd`.

---

## 📂 Files
- `/usr/local/sbin/weather.sh` – main script (executable)
- `/etc/systemd/system/weather.service` – systemd unit file
- `/etc/default/weather` – environment configuration (set your city)
- `README.md` – this documentation

---

## ⚙️ Installation

Clone repo:
```bash
git clone https://github.com/mirunaCalugar/weather-motd-vm.git
cd weather-motd-vm
