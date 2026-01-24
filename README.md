# TrafficCam

A shell script that downloads snapshot images from a traffic camera at regular intervals and emails them to a specified recipient.

## Features

- **HTML Email Formatting** - Beautiful, styled emails with tables and color (can be disabled with `--html-off`)
- **Configurable capture settings** - Customize image count, interval, camera URL, and more via environment variables
- **Retry logic** - Automatically retries failed downloads up to 3 times
- **Timestamped logging** - Clear, detailed output showing exactly what's happening
- **Dependency checking** - Verifies required tools are installed before running
- **Session statistics** - Summary of successful and failed captures at completion
- **Systemd integration** - Easy setup as a systemd service or timer

## Requirements

- **bash** - Version 4.0 or higher recommended
- **curl** - For downloading camera images
- **mpack** - For sending email attachments
- **ssmtp** - Must be configured for outbound email delivery

### Installing Dependencies

On Debian/Ubuntu:

```bash
sudo apt-get install curl mpack ssmtp
```

On Fedora/RHEL:

```bash
sudo dnf install curl mpack ssmtp
```

On macOS (using Homebrew):

```bash
brew install curl mpack
# ssmtp alternative: configure postfix or use msmtp
```

## Usage

### Basic Usage

```bash
./trafficcam.sh
```

This runs with default settings: 10 images captured at 60-second intervals, sent as HTML emails.

**Disable HTML email formatting:**

```bash
./trafficcam.sh --html-off
```

### Configuration via Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `TRAFFICCAM_COUNT` | Number of images to capture | `10` |
| `TRAFFICCAM_INTERVAL` | Seconds between captures | `60` |
| `TRAFFICCAM_URL` | Camera image URL | `http://link.to/camimage.jpg` |
| `TRAFFICCAM_EMAIL` | Recipient email address | `USERNAME@gmail.com` |
| `TRAFFICCAM_SUBJECT` | Email subject line | `TrafficCam` |
| `TRAFFICCAM_TEMP` | Temporary directory path | `$HOME/TEMP` |

### Examples

**Capture 5 images every 30 seconds:**

```bash
TRAFFICCAM_COUNT=5 TRAFFICCAM_INTERVAL=30 ./trafficcam.sh
```

**Use a custom camera URL and email:**

```bash
TRAFFICCAM_URL="http://camera.example.com/snapshot.jpg" \
TRAFFICCAM_EMAIL="user@example.com" \
./trafficcam.sh
```

**Set up for a specific traffic camera:**

```bash
export TRAFFICCAM_URL="http://traffic.city.gov/cameras/highway101.jpg"
export TRAFFICCAM_EMAIL="commute-alerts@example.com"
export TRAFFICCAM_COUNT=20
export TRAFFICCAM_INTERVAL=120
./trafficcam.sh
```

### Scheduling (Automated Execution)

#### Option 1: systemd (Recommended)

Systemd provides better logging, process management, and system integration than cron.

**One-time execution as a service:**

1. Create a service file at `/etc/systemd/system/trafficcam.service`:

```ini
[Unit]
Description=TrafficCam - Traffic Camera Snapshot Service
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
User=YOUR_USERNAME
WorkingDirectory=/home/YOUR_USERNAME
Environment="TRAFFICCAM_URL=http://camera.example.com/snapshot.jpg"
Environment="TRAFFICCAM_EMAIL=user@example.com"
Environment="TRAFFICCAM_COUNT=10"
Environment="TRAFFICCAM_INTERVAL=60"
ExecStart=/path/to/trafficcam.sh
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

2. Enable and start the service:

```bash
sudo systemctl daemon-reload
sudo systemctl enable trafficcam.service
sudo systemctl start trafficcam.service
```

**Scheduled execution with systemd timer:**

For recurring executions (e.g., daily at 7:00 AM), use a systemd timer instead of cron:

1. Create the service file as shown above (without `[Install]` section)

2. Create a timer file at `/etc/systemd/system/trafficcam.timer`:

```ini
[Unit]
Description=TrafficCam Timer - Run during morning commute
Requires=trafficcam.service

[Timer]
# Run at 7:00 AM on weekdays
OnCalendar=Mon-Fri 07:00:00
Persistent=true

[Install]
WantedBy=timers.target
```

3. Enable and start the timer:

```bash
sudo systemctl daemon-reload
sudo systemctl enable trafficcam.timer
sudo systemctl start trafficcam.timer
```

4. Check timer status:

```bash
# View timer schedule
sudo systemctl list-timers trafficcam.timer

# View service logs
sudo journalctl -u trafficcam.service -f
```

#### Option 2: Cron (Fallback)

If you don't have systemd or prefer cron:

```bash
# Edit crontab
crontab -e

# Add entry to run at 7:00 AM on weekdays
0 7 * * 1-5 TRAFFICCAM_URL="http://camera.example.com/snapshot.jpg" TRAFFICCAM_EMAIL="user@example.com" /path/to/trafficcam.sh >> /var/log/trafficcam.log 2>&1
```

### Systemd Troubleshooting

Common issues when using systemd and how to resolve them:

#### Service fails to start

**Check service status:**
```bash
sudo systemctl status trafficcam.service
```

**View detailed logs:**
```bash
sudo journalctl -u trafficcam.service -n 50 --no-pager
```

**Common causes:**
- Incorrect file paths in the service file
- Wrong username or permissions
- Missing environment variables

#### Network not available

If the service starts before the network is ready:

```ini
# Add to [Unit] section of service file
After=network-online.target
Wants=network-online.target
```

#### Permission denied errors

Ensure the script is executable:
```bash
chmod +x /path/to/trafficcam.sh
```

Ensure the user has access to the temporary directory:
```bash
mkdir -p ~/TEMP
chmod 755 ~/TEMP
```

#### Timer not firing

**Check timer status:**
```bash
# List all timers
sudo systemctl list-timers

# Check specific timer
sudo systemctl status trafficcam.timer
```

**Enable the timer if disabled:**
```bash
sudo systemctl enable trafficcam.timer
sudo systemctl start trafficcam.timer
```

#### Environment variables not working

Systemd doesn't load shell profiles. Define all variables in the service file:

```ini
[Service]
Environment="TRAFFICCAM_URL=http://example.com/cam.jpg"
Environment="TRAFFICCAM_EMAIL=user@example.com"
```

Or use an environment file:

```ini
[Service]
EnvironmentFile=/etc/trafficcam/trafficcam.env
```

#### Email not sending

**Check if ssmtp is configured:**
```bash
cat /etc/ssmtp/ssmtp.conf
```

**Test email manually:**
```bash
echo "Test" | mail -s "Test" user@example.com
```

**View service logs for email errors:**
```bash
sudo journalctl -u trafficcam.service | grep -i "email\|mpack"
```

#### Viewing logs in real-time

```bash
# Follow service logs
sudo journalctl -u trafficcam.service -f

# View logs from today
sudo journalctl -u trafficcam.service --since today

# View logs with priority level ERROR or higher
sudo journalctl -u trafficcam.service -p err
```

## Output

The script provides detailed, timestamped output:

```
[2026-01-03 08:00:00] [INFO] ============================================
[2026-01-03 08:00:00] [INFO] TrafficCam - Starting capture session
[2026-01-03 08:00:00] [INFO] ============================================
[2026-01-03 08:00:00] [INFO] Configuration:
[2026-01-03 08:00:00] [INFO]   - Images to capture: 10
[2026-01-03 08:00:00] [INFO]   - Capture interval:  60 seconds
[2026-01-03 08:00:00] [INFO]   - Camera URL:        http://link.to/camimage.jpg
[2026-01-03 08:00:00] [INFO]   - Email recipient:   user@example.com
[2026-01-03 08:00:00] [INFO]   - Temp directory:    /home/user/TEMP
[2026-01-03 08:00:00] [INFO] ============================================
[2026-01-03 08:00:00] [INFO] All dependencies verified.
[2026-01-03 08:00:00] [INFO] Using existing temporary directory: /home/user/TEMP
[2026-01-03 08:00:00] [INFO] --------------------------------------------
[2026-01-03 08:00:00] [INFO] Processing image 1 of 10
[2026-01-03 08:00:00] [INFO] --------------------------------------------
[2026-01-03 08:00:00] [INFO] Downloading image (attempt 1/3)...
[2026-01-03 08:00:01] [SUCCESS] Image downloaded successfully.
[2026-01-03 08:00:01] [INFO] Sending email to user@example.com...
[2026-01-03 08:00:02] [SUCCESS] Email sent successfully!
...
```

## Configuring ssmtp for Gmail

1. Install ssmtp
2. Edit `/etc/ssmtp/ssmtp.conf`:

```
root=USERNAME@gmail.com
mailhub=smtp.gmail.com:587
AuthUser=USERNAME@gmail.com
AuthPass=YOUR_APP_PASSWORD
UseSTARTTLS=YES
FromLineOverride=YES
```

> **Note:** For Gmail, you'll need to create an [App Password](https://support.google.com/accounts/answer/185833) since regular passwords won't work with ssmtp.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Credits

**Author:** Léon "Avic" Simmons ([@Avicennasis](https://github.com/Avicennasis))
