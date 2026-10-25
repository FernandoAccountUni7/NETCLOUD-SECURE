import grpc

import telemetry_pb2
import telemetry_pb2_grpc


SERVER = "172.16.100.70:50051"
LOGFILE = "/opt/netcloud/telemetry_stream.log"


def main():
    channel = grpc.insecure_channel(SERVER)
    stub = telemetry_pb2_grpc.TelemetryServiceStub(channel)

    print("NETCLOUD gRPC TELEMETRY COLLECTOR")
    print(f"Connected to {SERVER}")
    print("-" * 70)

    try:
        stream = stub.StreamMetrics(
            telemetry_pb2.Empty()
        )

        for metric in stream:
            line = (
                f"{metric.timestamp} | "
                f"{metric.source:<14} | "
                f"{metric.status:<4} | "
                f"latency={metric.latency_ms:.3f} ms"
            )

            print(line, flush=True)

            with open(LOGFILE, "a") as log:
                log.write(line + "\n")

    except grpc.RpcError as error:
        print(f"gRPC ERROR: {error}")


if __name__ == "__main__":
    main()
