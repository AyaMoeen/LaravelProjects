FROM ubuntu:22.04

# Install basic tools
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        cron bash curl coreutils tzdata gnupg lsb-release wget mysql-client && \
    rm -rf /var/lib/apt/lists/*

# Install Percona Repository
RUN wget https://repo.percona.com/apt/percona-release_latest.generic_all.deb && \
    dpkg -i percona-release_latest.generic_all.deb && \
    rm percona-release_latest.generic_all.deb

# Enable Percona repositories
RUN percona-release setup ps80

# Install BOTH XtraBackup AND Percona Toolkit
RUN apt-get update && \
    apt-get install -y percona-xtrabackup-80 percona-toolkit && \
    rm -rf /var/lib/apt/lists/*

# Create necessary directories
RUN mkdir -p /backups /scripts /var/spool/cron/crontabs /archive-logs

# Copy scripts
COPY backup-scheduler.sh /backup-scheduler.sh
COPY scripts/ /scripts/
RUN chmod +x /backup-scheduler.sh /scripts/*.sh

# Set timezone
ENV TZ=Asia/Gaza
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Run scheduler
ENTRYPOINT ["/bin/bash", "/backup-scheduler.sh"]