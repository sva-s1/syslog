# Syslog [ROOTLESS](https://docs.docker.com/engine/security/rootless/) to SentinelOne SDL HEC Bridge

**[Version](VERSION):** 1.1.0  
**Status:** QA TESTING
**Last Updated:** 2025-08-06  
**Docker Image:** `ghcr.io/sva-s1/syslog:1.1.0`

## Overview

A pre-production-ready, containerized service that receives traditional syslog messages from various appliances/virtual-appliances/apps syslog sources and forwards them to the SentinelOne Singularity Data Lake (SDL) using the HTTP Event Collector (HEC) API. The service is designed for security operations, providing rich metadata and context for security analytics.

## Key Features

- **High-Performance Log Processing**
  - Built on **syslog-ng** with optimized configuration
  - Multi-threaded processing for high throughput
  - Batching and compression for efficient network usage

- **Comprehensive Log Source Support**
  - Linux/Unix system logs with security context
  - FortiGate firewall logs with security event details
  - ZScaler proxy logs with web security events

- **Enterprise-Grade Deployment**
  - Rootless container for enhanced security
  - Environment-based configuration
  - Health checks and monitoring
  - Resource constraints and limits

- **Reliable Delivery**
  - Automatic retries on failure
  - Connection pooling and keepalive
  - Configurable timeouts and batch sizes

## Architecture

```
┌─────────────────┐    ┌───────────────────────┐    ┌───────────────────────┐
│                 │    │                       │    │                       │
│  Syslog         │───▶│  syslog-ng Container  │───▶│  SentinelOne SDL      │
│  Sources        │    │  (UDP/5514)           │    │  HEC API              │
│                 │    │                       │    │                       │
└─────────────────┘    └───────────────────────┘    └───────────────────────┘
      ▲                                                       ▲
      │                                                       │
      └───────────────────────────────────────────────────────┘
                      Configuration via .env
```

###  Example Log Sources

| Source Type | Parser Assignment | Example Matchers |
|-------------|-------------------|------------------|
| **Linux/Unix Systems** | `linuxSyslog` | `sshd`, `systemd`, `kernel`, `cron`, `authpriv` |
| **FortiGate Firewall** | `marketplace-fortinetfortigate-latest` | `devname="FortiGate"`, `type="traffic"`, `logid="0000000013"` |
| **ZScaler Internet Access** | `marketplace-zscalerinternetaccess-latest` | `product="NSS"`, `vendor="Zscaler"`, `action="Allow"` |

## Quick Start

### Prerequisites

- Docker and Docker Compose
- SentinelOne HEC write token(s)

### Setup

1. **Clone and configure:**
   ```bash
   git clone <repository-url>
   cd syslog
   cp .env.example .env
   # Edit .env with your SentinelOne token(s)
   ```

2. **Build and start:**
   ```bash
   docker-compose up --build -d
   ```

3. **Test syslog reception:**
   ```bash
   # Test Linux log
   echo "<134>$(date '+%b %d %H:%M:%S') ubuntu-server sshd[12345]: Accepted publickey for admin" | \
   docker run -i --rm --network host ghcr.io/sva-s1/alpine-nc:latest \
   /bin/ash -c "nc -u -w 1 127.0.0.1 5514"
   
   # Test FortiGate log
   cat samples/fortigate-sample.log | \
   docker run -i --rm --network host ghcr.io/sva-s1/alpine-nc:latest \
   /bin/ash -c "nc -u -w 1 127.0.0.1 5514"
   
   # Test ZScaler log
   cat samples/zscaler-sample.log | \
   docker run -i --rm --network host ghcr.io/sva-s1/alpine-nc:latest \
   /bin/ash -c "nc -u -w 1 127.0.0.1 5514"
   ```

4. **View logs:**
   ```bash
   docker-compose logs -f syslog-bridge
   ```

## Configuration

All configuration is managed through the `.env` file:

```bash
# SentinelOne Configuration
S1_HEC_WRITE_TOKEN=your_write_token_here
S1_HEC_READ_TOKEN=your_read_token_here # <- Optional to TEST via API query
S1_HEC_URL=https://ingest.us1.sentinelone.net

# Syslog Configuration
PORT1_PROTOCOL=udp
PORT1_NUMBER=5514
PORT1_TYPE=rfc3164
USER_ID=1000
GROUP_ID=1000
```

## Development

### Project Structure

```
.
├── Dockerfile          # Container build configuration
├── docker-compose.yml  # Service orchestration
├── syslog-ng.conf      # syslog-ng configuration
├── .env                # Environment variables (not in repo)
├── .env.example        # Environment template
├── CHANGELOG.md        # Changes explained
├── README.md           # This file
├── PLAN.md             # Development roadmap
├── VERSION             # Project Version
└── .gitignore          # Git exclusions
```

### Testing

**Local Testing:**
- Send test messages to UDP port 514
- Verify reception in container logs

**Remote Verification:**
- Query SentinelOne API to confirm log ingestion
- Verify correct parser assignment via `sourcetype`

## Version History

### v1.0 (2025-08-04) - Production Ready
- ✅ Complete rootless container implementation (UID/GID 1000)
- ✅ End-to-end HEC forwarding to SentinelOne SDL verified
- ✅ Dynamic parser assignment with source matching
- ✅ FortiGate firewall log support with comprehensive metadata
- ✅ ZScaler proxy log support with comprehensive metadata
- ✅ Linux/Unix system log support with security categorization
- ✅ UDP port 5514 for rootless operation
- ✅ Production-ready architecture with batching, compression, retries
- ✅ Sample log files and testing framework
- ✅ Comprehensive documentation and README

### Previous Versions
#### v0.1 (2025-08-01)
- ✅ Initial project structure and basic syslog-ng configuration
- ✅ Docker containerization foundation
- ✅ Environment-based configuration framework

## Support

For issues and questions, please refer to the project documentation or create an issue in the repository.

---
*Built with ❤️ for secure, scalable log forwarding*
