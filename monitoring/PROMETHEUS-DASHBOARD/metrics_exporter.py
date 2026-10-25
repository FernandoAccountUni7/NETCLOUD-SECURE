from prometheus_client import start_http_server, Gauge
import subprocess
import time

TARGETS = {
    # Management / Fabric
    "AUTOMATION": "172.16.100.10",
    "LEAF-01": "172.16.100.1",
    "LEAF-02": "172.16.100.2",

    # 5G
    "5G-CORE": "172.16.100.20",
    "gNodeB-UE": "172.16.100.30",

    # Seguridad
    "ZTNA-GATEWAY": "172.16.100.40",
    "SECURITY-TEST": "172.16.100.60",
    "VNF-FIREWALL": "10.61.0.2",
    "VNF-FIREWALL-BACKUP": "10.60.0.254",

    # Servicios
    "VNF-LOADBALANCER": "10.60.0.10",
    "DATA-SERVER": "10.60.0.2",
    "THROUGHPUT-SERVER": "10.60.0.3",

    # F5G
    "F5G-OLT": "10.60.0.20",

    # Telemetria
    "MONITORING-SERVER": "172.16.100.50",
    "TELEMETRY-GRPC": "172.16.100.70",
    "TELEMETRY-COLLECTOR": "172.16.100.71",
    "PROMETHEUS-DASHBOARD": "172.16.100.80",
}

status_metric = Gauge(
    "netcloud_node_up",
    "Estado de disponibilidad del nodo",
    ["node", "ip"]
)

latency_metric = Gauge(
    "netcloud_latency_ms",
    "Latencia ICMP hacia el nodo",
    ["node", "ip"]
)

def ping(ip):
    try:
        result = subprocess.run(
            ["ping", "-c", "1", "-W", "1", ip],
            capture_output=True,
            text=True,
            timeout=2
        )

        if result.returncode != 0:
            return 0, 0.0

        if "time=" in result.stdout:
            latency = float(
                result.stdout.split("time=")[1].split()[0]
            )
            return 1, latency

        return 1, 0.0

    except Exception:
        return 0, 0.0

if __name__ == "__main__":

    start_http_server(9100)

    while True:

        for name, ip in TARGETS.items():

            state, latency = ping(ip)

            status_metric.labels(
                node=name,
                ip=ip
            ).set(state)

            latency_metric.labels(
                node=name,
                ip=ip
            ).set(latency)

        time.sleep(5)
