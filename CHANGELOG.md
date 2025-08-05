# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-08-04

### Added
- Initial production-ready release of Syslog to SentinelOne SDL HEC Bridge
- Support for Linux/Unix system logs with enhanced metadata
- Support for FortiGate firewall logs with comprehensive security context
- Support for ZScaler proxy logs with web security event details
- Rootless container implementation for improved security
- Environment-based configuration via .env file
- Comprehensive documentation and examples

### Changed
- Updated syslog-ng configuration with optimized performance settings
- Improved log matching patterns for better accuracy
- Enhanced error handling and logging
- Optimized Docker build and runtime configuration

### Fixed
- Resolved permission issues in container startup
- Fixed environment variable handling in syslog-ng configuration
- Improved log message formatting and metadata enrichment

## [0.1.0] - 2025-08-01

### Added
- Initial project setup and basic configuration
- Support for receiving syslog messages over UDP
- Basic forwarding to SentinelOne SDL HEC endpoint
- Docker and docker-compose configuration
