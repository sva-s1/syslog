FROM balabit/syslog-ng:4.9.0

# Add OCI label for source repository
LABEL org.opencontainers.image.source=https://github.com/sva-s1/syslog

# Install required packages
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates tzdata gettext-base; \
    rm -rf /var/lib/apt/lists/*

# Create directories with proper permissions
RUN mkdir -p /var/lib/syslog-ng /var/log/syslog-ng /var/run/syslog-ng /etc/syslog-ng && \
    chown -R 1000:1000 /var/lib/syslog-ng /var/log/syslog-ng /var/run/syslog-ng /etc/syslog-ng && \
    chmod -R 755 /var/lib/syslog-ng /var/log/syslog-ng /var/run/syslog-ng /etc/syslog-ng

# Copy configuration template
COPY --chown=1000:1000 syslog-ng.conf.tmpl /etc/syslog-ng/syslog-ng.conf.tmpl

# Copy entrypoint script
COPY --chmod=755 entrypoint.sh /entrypoint.sh

EXPOSE 5514/udp
WORKDIR /var/lib/syslog-ng

# Default to user 1000:1000 (can be overridden)
USER 1000:1000

ENTRYPOINT ["/entrypoint.sh"]
CMD ["syslog-ng","-F","--no-caps"]

