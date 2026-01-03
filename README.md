# TrafficCam

A shell script that downloads snapshot images from a traffic camera at regular intervals and emails them to a specified recipient.

## Features

- **Configurable capture settings** - Customize image count, interval, camera URL, and more via environment variables
- **Retry logic** - Automatically retries failed downloads up to 3 times
- **Timestamped logging** - Clear, detailed output showing exactly what's happening
- **Dependency checking** - Verifies required tools are installed before running
- **Session statistics** - Summary of successful and failed captures at completion

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

This runs with default settings: 10 images captured at 60-second intervals.

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

### Scheduling with Cron

To run the script automatically (e.g., during morning commute hours):

```bash
# Edit crontab
crontab -e

# Add entry to run at 7:00 AM on weekdays
0 7 * * 1-5 TRAFFICCAM_URL="http://camera.example.com/snapshot.jpg" TRAFFICCAM_EMAIL="user@example.com" /path/to/trafficcam.sh >> /var/log/trafficcam.log 2>&1
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
