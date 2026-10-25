from flask import Flask, render_template_string
import requests
from datetime import datetime

app = Flask(__name__)

PROMETHEUS = "http://127.0.0.1:9090"

GROUPS = {
    "Management y Fabric": [
        "AUTOMATION",
        "LEAF-01",
        "LEAF-02",
    ],

    "Core 5G y Acceso Móvil": [
        "5G-CORE",
        "gNodeB-UE",
    ],

    "Seguridad y Zero Trust": [
        "ZTNA-GATEWAY",
        "SECURITY-TEST",
        "VNF-FIREWALL",
        "VNF-FIREWALL-BACKUP",
    ],

    "Aplicaciones y Servicios": [
        "VNF-LOADBALANCER",
        "DATA-SERVER",
        "THROUGHPUT-SERVER",
    ],

    "Acceso F5G": [
        "F5G-OLT",
    ],

    "Telemetría y Monitoreo": [
        "MONITORING-SERVER",
        "TELEMETRY-GRPC",
        "TELEMETRY-COLLECTOR",
        "PROMETHEUS-DASHBOARD",
    ],
}

PROTECTED_NODES = [
    {
        "name": "ZTNA-SERVER",
        "segment": "10.80.0.0/24",
        "state": "PROTECTED",
        "reason": "Acceso restringido por política Zero Trust"
    },
    {
        "name": "SPINE-01",
        "segment": "BGP EVPN Fabric",
        "state": "SEGMENTED",
        "reason": "Plano de control aislado del monitoreo directo"
    },
    {
        "name": "SPINE-02",
        "segment": "BGP EVPN Fabric",
        "state": "SEGMENTED",
        "reason": "Plano de control aislado del monitoreo directo"
    },
    {
        "name": "HOST-A",
        "segment": "VXLAN VNI 10010",
        "state": "ISOLATED",
        "reason": "Host perteneciente a tenant VXLAN"
    },
    {
        "name": "HOST-B",
        "segment": "VXLAN VNI 10010",
        "state": "ISOLATED",
        "reason": "Host perteneciente a tenant VXLAN"
    },
    {
        "name": "BACKEND-1",
        "segment": "10.62.0.0/24",
        "state": "PROTECTED",
        "reason": "Backend interno detrás del balanceador"
    },
    {
        "name": "BACKEND-2",
        "segment": "10.62.0.0/24",
        "state": "PROTECTED",
        "reason": "Backend interno detrás del balanceador"
    },
    {
        "name": "F5G-ONU-1",
        "segment": "F5G Access",
        "state": "SEGMENTED",
        "reason": "Acceso óptico detrás del OLT"
    },
    {
        "name": "F5G-ONU-2",
        "segment": "F5G Access",
        "state": "SEGMENTED",
        "reason": "Acceso óptico detrás del OLT"
    },
]

HTML = """
<!DOCTYPE html>
<html lang="es">

<head>
<meta charset="UTF-8">
<meta http-equiv="refresh" content="5">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>NETCLOUD Monitoring Dashboard</title>

<style>

* {
    box-sizing: border-box;
}

body {
    margin: 0;
    min-height: 100vh;
    font-family: Inter, Arial, Helvetica, sans-serif;
    color: #eef2ff;

    background:
        radial-gradient(circle at 15% 10%, rgba(37,99,235,.18), transparent 30%),
        radial-gradient(circle at 85% 20%, rgba(14,165,233,.12), transparent 28%),
        radial-gradient(circle at 50% 100%, rgba(124,58,237,.10), transparent 35%),
        #070b14;
}

.container {
    max-width: 1500px;
    margin: auto;
    padding: 32px;
}

.glass {
    background: rgba(17,24,39,.65);
    border: 1px solid rgba(148,163,184,.15);
    box-shadow: 0 15px 40px rgba(0,0,0,.25);
    backdrop-filter: blur(18px);
    -webkit-backdrop-filter: blur(18px);
}

.header {
    border-radius: 22px;
    padding: 30px 34px;
    margin-bottom: 22px;
}

.header-content {
    display: flex;
    justify-content: space-between;
    gap: 30px;
    align-items: center;
}

.brand-small {
    color: #60a5fa;
    font-size: 12px;
    letter-spacing: 2px;
    font-weight: bold;
    margin-bottom: 9px;
}

.title {
    font-size: 32px;
    font-weight: 700;
    letter-spacing: -.5px;
}

.subtitle {
    color: #94a3b8;
    margin-top: 8px;
    font-size: 14px;
}

.student {
    text-align: right;
    line-height: 1.65;
    color: #cbd5e1;
    font-size: 13px;
}

.student strong {
    color: #ffffff;
    font-size: 14px;
}

.global-status {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    margin-top: 10px;
    padding: 6px 11px;
    border-radius: 100px;
    font-size: 11px;
    font-weight: bold;
}

.global-ok {
    background: rgba(34,197,94,.10);
    border: 1px solid rgba(34,197,94,.25);
    color: #4ade80;
}

.global-alert {
    background: rgba(239,68,68,.10);
    border: 1px solid rgba(239,68,68,.25);
    color: #f87171;
}

.dot {
    width: 7px;
    height: 7px;
    border-radius: 50%;
    background: currentColor;
    box-shadow: 0 0 9px currentColor;
}

.cards {
    display: grid;
    grid-template-columns: repeat(5,1fr);
    gap: 16px;
    margin-bottom: 22px;
}

.card {
    border-radius: 18px;
    padding: 21px 22px;
    transition: transform .2s ease, border .2s ease;
}

.card:hover {
    transform: translateY(-2px);
    border-color: rgba(96,165,250,.35);
}

.card-label {
    color: #94a3b8;
    font-size: 12px;
    margin-bottom: 10px;
}

.card-value {
    font-size: 29px;
    font-weight: 700;
}

.card-detail {
    margin-top: 5px;
    color: #64748b;
    font-size: 11px;
}

.groups {
    display: grid;
    grid-template-columns: repeat(2,1fr);
    gap: 18px;
}

.section {
    border-radius: 18px;
    overflow: hidden;
}

.section-header {
    padding: 18px 20px 16px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-bottom: 1px solid rgba(148,163,184,.12);
}

.section-title {
    font-size: 16px;
    font-weight: 700;
}

.section-info {
    color: #94a3b8;
    font-size: 11px;
    margin-top: 4px;
}

.section-counter {
    font-size: 11px;
    color: #93c5fd;
    padding: 5px 9px;
    border-radius: 20px;
    background: rgba(59,130,246,.10);
    border: 1px solid rgba(59,130,246,.20);
}

table {
    width: 100%;
    border-collapse: collapse;
}

th {
    text-align: left;
    color: #64748b;
    font-size: 10px;
    text-transform: uppercase;
    letter-spacing: .5px;
    font-weight: 600;
    padding: 12px 16px;
}

td {
    padding: 14px 16px;
    border-top: 1px solid rgba(148,163,184,.08);
    font-size: 13px;
}

tbody tr {
    transition: background .15s ease;
}

tbody tr:hover {
    background: rgba(255,255,255,.025);
}

.node-name {
    font-weight: 600;
}

.ip {
    color: #cbd5e1;
}

.status {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 4px 9px;
    border-radius: 100px;
    font-size: 10px;
    font-weight: bold;
}

.status-up {
    color: #4ade80;
    background: rgba(34,197,94,.10);
    border: 1px solid rgba(34,197,94,.25);
}

.status-down {
    color: #f87171;
    background: rgba(239,68,68,.10);
    border: 1px solid rgba(239,68,68,.25);
}

.status-protected {
    color: #c084fc;
    background: rgba(168,85,247,.10);
    border: 1px solid rgba(168,85,247,.25);
}

.status-segmented {
    color: #60a5fa;
    background: rgba(59,130,246,.10);
    border: 1px solid rgba(59,130,246,.25);
}

.status-isolated {
    color: #22d3ee;
    background: rgba(6,182,212,.10);
    border: 1px solid rgba(6,182,212,.25);
}

.latency-good {
    color: #86efac;
}

.latency-medium {
    color: #facc15;
}

.latency-high {
    color: #f87171;
}

.protected-section {
    margin-top: 18px;
    border-radius: 18px;
    overflow: hidden;
}

.protected-description {
    color: #94a3b8;
    font-size: 12px;
    line-height: 1.6;
    max-width: 900px;
}

.na {
    color: #64748b;
    font-style: italic;
}

.footer {
    margin-top: 22px;
    padding: 16px;
    text-align: center;
    color: #64748b;
    font-size: 11px;
}

@media (max-width: 1100px) {
    .cards {
        grid-template-columns: repeat(2,1fr);
    }
}

@media (max-width: 950px) {
    .groups {
        grid-template-columns: 1fr;
    }

    .header-content {
        flex-direction: column;
        align-items: flex-start;
    }

    .student {
        text-align: left;
    }
}

</style>
</head>

<body>

<div class="container">

<div class="header glass">

<div class="header-content">

<div>

<div class="brand-small">
NETCLOUD SECURE
</div>

<div class="title">
Monitoring Dashboard
</div>

<div class="subtitle">
5G / F5G Enterprise Fabric · Prometheus · gRPC · Zero Trust
</div>

{% if down_count == 0 %}

<div class="global-status global-ok">
<span class="dot"></span>
INFRASTRUCTURE OPERATIONAL
</div>

{% else %}

<div class="global-status global-alert">
<span class="dot"></span>
ATTENTION REQUIRED
</div>

{% endif %}

</div>

<div class="student">

<strong>Curso de Telecomunicaciones</strong><br>
Proyecto Final<br>
Fernando Ruiz<br>
Carné: 1990-19-7785

</div>

</div>
</div>


<div class="cards">

<div class="card glass">
<div class="card-label">Activos totales</div>
<div class="card-value">{{ total_assets }}</div>
<div class="card-detail">Infraestructura representada</div>
</div>

<div class="card glass">
<div class="card-label">Monitoreados</div>
<div class="card-value">{{ monitored }}</div>
<div class="card-detail">Con telemetría activa</div>
</div>

<div class="card glass">
<div class="card-label">Disponibles</div>
<div class="card-value">{{ up_count }}</div>
<div class="card-detail">Servicios operativos</div>
</div>

<div class="card glass">
<div class="card-label">Segmentados / Protegidos</div>
<div class="card-value">{{ protected_count }}</div>
<div class="card-detail">Sin sondeo ICMP directo</div>
</div>

<div class="card glass">
<div class="card-label">Latencia promedio</div>
<div class="card-value">{{ "%.3f"|format(avg_latency) }} ms</div>
<div class="card-detail">ICMP promedio</div>
</div>

</div>


<div class="groups">

{% for group_name, group_nodes in groups.items() %}

<div class="section glass">

<div class="section-header">

<div>
<div class="section-title">
{{ group_name }}
</div>

<div class="section-info">
Estado operacional en tiempo real
</div>
</div>

<div class="section-counter">
{{ group_nodes|selectattr("up")|list|length }}
/
{{ group_nodes|length }}
UP
</div>

</div>

<table>

<thead>
<tr>
<th>Nodo</th>
<th>Dirección IP</th>
<th>Estado</th>
<th>Latencia</th>
</tr>
</thead>

<tbody>

{% for node in group_nodes %}

<tr>

<td class="node-name">
{{ node.name }}
</td>

<td class="ip">
{{ node.ip }}
</td>

<td>

{% if node.up %}

<span class="status status-up">
<span class="dot"></span>
UP
</span>

{% else %}

<span class="status status-down">
<span class="dot"></span>
DOWN
</span>

{% endif %}

</td>

<td>

{% if not node.up %}

<span class="latency-high">
0.000 ms
</span>

{% elif node.latency < 1 %}

<span class="latency-good">
{{ "%.3f"|format(node.latency) }} ms
</span>

{% elif node.latency < 5 %}

<span class="latency-medium">
{{ "%.3f"|format(node.latency) }} ms
</span>

{% else %}

<span class="latency-high">
{{ "%.3f"|format(node.latency) }} ms
</span>

{% endif %}

</td>

</tr>

{% endfor %}

</tbody>
</table>

</div>

{% endfor %}

</div>


<div class="protected-section glass">

<div class="section-header">

<div>

<div class="section-title">
Activos Segmentados y Protegidos
</div>

<div class="protected-description">
Componentes pertenecientes a dominios aislados por políticas
Zero Trust, VXLAN, backend o acceso F5G. Estos activos no reciben
sondeo ICMP directo desde Prometheus para preservar la segmentación
y el principio de mínima exposición.
</div>

</div>

<div class="section-counter">
{{ protected_count }} ACTIVOS
</div>

</div>


<table>

<thead>
<tr>
<th>Nodo</th>
<th>Segmento</th>
<th>Clasificación</th>
<th>Motivo</th>
<th>Latencia</th>
</tr>
</thead>

<tbody>

{% for node in protected_nodes %}

<tr>

<td class="node-name">
{{ node.name }}
</td>

<td class="ip">
{{ node.segment }}
</td>

<td>

{% if node.state == "PROTECTED" %}

<span class="status status-protected">
<span class="dot"></span>
PROTECTED
</span>

{% elif node.state == "SEGMENTED" %}

<span class="status status-segmented">
<span class="dot"></span>
SEGMENTED
</span>

{% else %}

<span class="status status-isolated">
<span class="dot"></span>
ISOLATED
</span>

{% endif %}

</td>

<td>
{{ node.reason }}
</td>

<td class="na">
N/A
</td>

</tr>

{% endfor %}

</tbody>

</table>

</div>


<div class="footer">

NETCLOUD-SECURE 5G/F5G ENTERPRISE FABRIC

&nbsp; · &nbsp;

Prometheus Monitoring

&nbsp; · &nbsp;

Actualización automática cada 5 segundos

&nbsp; · &nbsp;

{{ updated }}

</div>

</div>

</body>
</html>
"""


def prometheus_query(metric):

    response = requests.get(
        f"{PROMETHEUS}/api/v1/query",
        params={"query": metric},
        timeout=3
    )

    return response.json()["data"]["result"]


@app.route("/")
def dashboard():

    status_results = prometheus_query(
        "netcloud_node_up"
    )

    latency_results = prometheus_query(
        "netcloud_latency_ms"
    )

    latency_map = {}

    for item in latency_results:

        latency_map[
            item["metric"]["node"]
        ] = float(
            item["value"][1]
        )

    node_map = {}

    for item in status_results:

        name = item["metric"]["node"]

        node_map[name] = {
            "name": name,
            "ip": item["metric"]["ip"],
            "up": float(item["value"][1]) == 1,
            "latency": latency_map.get(name, 0.0)
        }

    grouped_nodes = {}
    all_nodes = []

    for group, names in GROUPS.items():

        grouped_nodes[group] = []

        for name in names:

            if name in node_map:

                grouped_nodes[group].append(
                    node_map[name]
                )

                all_nodes.append(
                    node_map[name]
                )

    monitored = len(all_nodes)

    up_count = sum(
        1
        for node in all_nodes
        if node["up"]
    )

    down_count = monitored - up_count

    protected_count = len(
        PROTECTED_NODES
    )

    total_assets = (
        monitored +
        protected_count
    )

    active_latency = [
        node["latency"]
        for node in all_nodes
        if node["up"]
    ]

    avg_latency = (
        sum(active_latency)
        /
        len(active_latency)
        if active_latency
        else 0.0
    )

    return render_template_string(
        HTML,

        groups=grouped_nodes,

        protected_nodes=
            PROTECTED_NODES,

        monitored=
            monitored,

        up_count=
            up_count,

        down_count=
            down_count,

        protected_count=
            protected_count,

        total_assets=
            total_assets,

        avg_latency=
            avg_latency,

        updated=
            datetime.now().strftime(
                "%d/%m/%Y %H:%M:%S"
            )
    )


app.run(
    host="0.0.0.0",
    port=8080,
    debug=False
)
