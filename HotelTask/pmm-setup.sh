#!/bin/sh

echo "🔄 Waiting for PMM Server to be ready..."
sleep 40

echo "🚀 Starting pmm-agent..."
nohup pmm-agent --config-file=/usr/local/percona/pmm2/config/pmm-agent.yaml > /tmp/pmm-agent.log 2>&1 &

sleep 5

STORAGE_NAME="local-backups"
BACKUP_PATH="/backups"

echo "🔧 Configuring PMM client with pmm-admin..."
pmm-admin config \
  --server-insecure-tls \
  --server-url=http://admin:admin@percona-pmm:80 \
  --force

echo "🔍 Waiting for pmm-agent to be ready..."
for i in $(seq 1 30); do
  if pmm-admin status > /dev/null 2>&1; then
    echo "✅ pmm-agent is ready!"
    break
  fi
  echo "⏳ Waiting... ($i/30)"
  sleep 2
done

echo "📋 Checking pmm-agent status..."
pmm-admin status

echo "🧩 Adding MySQL Primary to PMM..."
pmm-admin add mysql \
  --query-source=perfschema \
  --username=root \
  --password=rootpassword \
  --host=mysql-primary \
  --port=3306 \
  --service-name=mysql-primary \
  --metrics-mode=auto || echo "⚠️ mysql-primary already exists or failed to add."

echo "🧩 Adding MySQL Secondary to PMM..."
pmm-admin add mysql \
  --query-source=perfschema \
  --username=root \
  --password=rootpassword \
  --host=mysql-secondary \
  --port=3306 \
  --service-name=mysql-secondary \
  --metrics-mode=auto || echo "⚠️ mysql-secondary already exists or failed to add."

echo "✅ PMM Client setup complete. Monitoring primary and secondary instances..."
echo "📜 Tailing pmm-agent logs..."
tail -f /tmp/pmm-agent.log
