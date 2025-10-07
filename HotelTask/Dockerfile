FROM ubuntu:22.04

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        cron bash curl coreutils tzdata gnupg lsb-release wget && \
    rm -rf /var/lib/apt/lists/*

RUN wget https://repo.percona.com/apt/percona-release_latest.generic_all.deb && \
    dpkg -i percona-release_latest.generic_all.deb && \
    rm percona-release_latest.generic_all.deb && \
    percona-release setup ps80 && \
    apt-get update && \
    apt-get install -y percona-xtrabackup-80 && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /backups /scripts /var/spool/cron/crontabs

COPY backup-scheduler.sh /backup-scheduler.sh
COPY scripts/ /scripts/
RUN chmod +x /backup-scheduler.sh /scripts/*.sh
ENV TZ=Asia/Gaza
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Run scheduler
ENTRYPOINT ["/bin/bash", "/backup-scheduler.sh"]
