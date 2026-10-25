import subprocess
from datetime import datetime

devices = {
    "AUTOMATION": "172.16.100.10",
    "LEAF-01": "172.16.100.1",
    "LEAF-02": "172.16.100.2",
    "5G-CORE": "172.16.100.20",
    "gNodeB-UE": "172.16.100.30",
    "ZTNA-GATEWAY": "172.16.100.40",
}

logfile = "/opt/netcloud/events.log"

with open(logfile, "a") as log:
    log.write(f"\n===== SCAN {datetime.now()} =====\n")

    for name, ip in devices.items():
        result = subprocess.run(
            ["ping", "-c", "2", "-W", "1", ip],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL
        )

        status = "UP" if result.returncode == 0 else "DOWN"

        line = f"{datetime.now()} | {name:15} | {ip:15} | {status}"

        print(line)
        log.write(line + "\n")
