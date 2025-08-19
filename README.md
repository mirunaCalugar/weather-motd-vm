# 🌦️ Weather MOTD VM

This project automates a VM so that it fetches and displays the current weather
for a chosen city **at startup** and **on login**, by updating the system MOTD
(*Message of the Day*).

---

## 🎯 Features
- Fetches weather from [wttr.in](https://wttr.in) (daily) or Open-Meteo (weekly).
- City configurable in `/etc/default/weather`.
- Clean MOTD on every run (idempotent).
- Runs automatically at boot using `systemd`.
- **Bonus:** Shows system uptime and disk usage.
- **Bonus:** Logs updates in `/var/log/weather.log`.

---

## 📂 Files
- `/usr/local/sbin/weather.sh` – main script (executable, idempotent)
- `/etc/systemd/system/weather.service` – systemd unit file
- `/etc/default/weather` – environment configuration
- `README.md` – documentation

---

## ⚙️ Installation

Clone repo:
```bash
git clone https://github.com/mirunaCalugar/weather-motd-vm.git
cd weather-motd-vm

---

## ✅ Usage

Show current MOTD (displayed automatically on login):
```bash
cat /etc/motd

