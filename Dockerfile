# Syslog to SentinelOne SDL HEC Bridge
# Custom image based on official balabit/syslog-ng with proper permissions handling

# Use specific version for production
FROM balabit/syslog-ng:4.9.0

# Set environment variables
ENV SYSLOG_NG_OPTS="--no-caps --default-modules=affile,afprog,afsocket,afuser,basicfuncs,csvparser,dbparser,syslogformat,system-source"

# Install runtime dependencies only
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        tzdata \
        gosu; \
    rm -rf /var/lib/apt/lists/*; \
    # Create required directories with correct permissions
    mkdir -p /var/run/syslog-ng /var/cache/syslog-ng /var/lib/syslog-ng; \
    chown -R root:root /etc/syslog-ng; \
    chmod 755 /etc/syslog-ng; \
    chmod 644 /etc/syslog-ng/syslog-ng.conf; \
    # Create a non-root user for the container
    groupadd -r -g 911 syslog-ng; \
    useradd -r -g syslog-ng -u 911 -d /var/lib/syslog-ng syslog-ng; \
    chown -R syslog-ng:syslog-ng /var/lib/syslog-ng /var/cache/syslog-ng /var/run/syslog-ng;

# Copy configuration files and entrypoint script
COPY --chmod=644 syslog-ng.conf /etc/syslog-ng/syslog-ng.conf
COPY --chmod=755 entrypoint.sh /entrypoint.sh

# Expose syslog port (using non-privileged port for rootless operation)
EXPOSE 5514/udp

# Health check - verify syslog-ng is running and responsive
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD [ "sh", "-c", "test -e /var/run/syslog-ng.pid && kill -0 $(cat /var/run/syslog-ng.pid) 2>/dev/null" ]

# Set working directory
WORKDIR /var/lib/syslog-ng

# Set default user (overridden by entrypoint)
USER 911:911

# Use our custom entrypoint script
# Note: We don't remove the base image's entrypoint to avoid permission issues
# Instead, we'll ensure our entrypoint is used via the ENTRYPOINT directive

# Configure entrypoint and default command
ENTRYPOINT ["/entrypoint.sh"]
CMD ["syslog-ng", "-F", "--no-caps", "--enable-core"]

# Add labels for better maintainability
LABEL maintainer="Your Team <team@example.com>" \
      version="1.0.0" \
      description="Syslog to SentinelOne SDL HEC Bridge" \
      org.opencontainers.image.authors="Your Team <team@example.com>" \
      org.opencontainers.image.version="1.0.0" \
      org.opencontainers.image.title="Syslog to SentinelOne SDL HEC Bridge" \
      org.opencontainers.image.description="A production-ready syslog-ng container that forwards logs to SentinelOne SDL via HEC API"
