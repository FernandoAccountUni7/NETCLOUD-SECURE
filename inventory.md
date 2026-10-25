# Inventario de nodos - NETCLOUD-SECURE

Autor: Fernando Ruiz  
Carné: 1990-19-7785  
Curso: Telecomunicaciones  
Proyecto Final: NETCLOUD-SECURE 5G/F5G Enterprise Fabric

## Fabric EVPN/VXLAN
- SPINE-01
- SPINE-02
- LEAF-01
- LEAF-02
- HOST-A
- HOST-B

## Automatización
- AUTOMATION

## 5G
- 5G-CORE
- gNodeB-UE

## NFV
- VNF-FIREWALL
- VNF-FIREWALL-BACKUP
- VNF-LOADBALANCER
- BACKEND-1
- BACKEND-2
- DATA-SERVER
- THROUGHPUT-SERVER

## F5G
- F5G-OLT
- ONU-1
- ONU-2

## Zero Trust y Seguridad
- ZTNA-GATEWAY
- ZTNA-SERVER
- SECURITY-TEST

## Telemetría y Monitoreo
- MONITORING-SERVER
- TELEMETRY-GRPC
- TELEMETRY-COLLECTOR
- PROMETHEUS-DASHBOARD

## Infraestructura de interconexión
- MGMT-SW
- MGMT-SW-2
- NFV-TRANSIT-SW
- Cloud1

## Notas
Documento preparado por Fernando Ruiz, Carné 1990-19-7785, como parte del Proyecto Final del curso de Telecomunicaciones.

Los switches Ethernet integrados de GNS3 no poseen configuraciones CLI exportables en este proyecto, por lo que se documentan en este inventario pero no cuentan con una carpeta propia de configuración.

Cloud1 funciona como enlace entre la topología GNS3 y la interfaz Host-Only utilizada para acceder a los servicios de monitoreo desde el equipo anfitrión. No posee scripts o archivos de configuración equivalentes a un router o servidor.

Las claves privadas de Open5GS no se incluyen en este paquete por seguridad. Las credenciales de laboratorio presentes en los scripts fueron reemplazadas por valores CHANGE_ME_* antes de generar el entregable.
