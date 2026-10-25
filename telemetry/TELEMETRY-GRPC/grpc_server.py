import grpc
from concurrent import futures
from datetime import datetime
import subprocess
import time

import telemetry_pb2
import telemetry_pb2_grpc


TARGETS = {
    "LEAF-01": "172.16.100.1",
    "LEAF-02": "172.16.100.2",
    "5G-CORE": "172.16.100.20",
    "gNodeB-UE": "172.16.100.30",
    "ZTNA-GATEWAY": "172.16.100.40",
}


def measure_ping(ip):
    try:
        result = subprocess.run(
            ["ping", "-c", "1", "-W", "1", ip],
            capture_output=True,
            text=True,
            timeout=2
        )

        if result.returncode != 0:
            return "DOWN", 0.0

        output = result.stdout

        if "time=" in output:
            latency = output.split("time=")[1].split()[0]
            return "UP", float(latency)

        return "UP", 0.0

    except Exception:
        return "DOWN", 0.0


class TelemetryService(
    telemetry_pb2_grpc.TelemetryServiceServicer
):
    def StreamMetrics(self, request, context):
        while context.is_active():
            for name, ip in TARGETS.items():
                status, latency = measure_ping(ip)

                yield telemetry_pb2.Metric(
                    timestamp=datetime.now().strftime(
                        "%Y-%m-%d %H:%M:%S"
                    ),
                    source=name,
                    status=status,
                    latency_ms=latency
                )

            time.sleep(2)


def serve():
    server = grpc.server(
        futures.ThreadPoolExecutor(max_workers=10)
    )

    telemetry_pb2_grpc.add_TelemetryServiceServicer_to_server(
        TelemetryService(),
        server
    )

    server.add_insecure_port("0.0.0.0:50051")
    server.start()

    print("NETCLOUD gRPC TELEMETRY SERVER ACTIVE")
    print("Listening on TCP/50051")

    server.wait_for_termination()


if __name__ == "__main__":
    serve()
