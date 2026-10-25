#!/bin/sh

ACTIVE=0
SUCCESS=0

while true
do
    if ping -c 1 -W 1 192.168.250.1 >/dev/null 2>&1; then

        SUCCESS=$((SUCCESS + 1))

        # Para volver al primario exigimos 2 heartbeats exitosos
        if [ "$ACTIVE" -eq 1 ] && [ "$SUCCESS" -ge 2 ]; then
            /opt/netcloud/deactivate_failover.sh
            ACTIVE=0
            SUCCESS=0
        fi

    else

        SUCCESS=0

        # Un heartbeat fallido activa inmediatamente el backup
        if [ "$ACTIVE" -eq 0 ]; then
            /opt/netcloud/activate_failover.sh
            ACTIVE=1
        fi

    fi

    sleep 0.5
done
