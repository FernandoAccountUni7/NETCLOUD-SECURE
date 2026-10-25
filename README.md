# NETCLOUD-SECURE 5G/F5G Enterprise Fabric

Autor: Fernando Ruiz  
Carné: 1990-19-7785  
Curso: Telecomunicaciones  
Proyecto Final

## Descripción

NETCLOUD-SECURE es una arquitectura empresarial simulada en GNS3 que integra tecnologías de Data Center, redes móviles 5G, acceso F5G, virtualización de funciones de red, seguridad Zero Trust, telemetría gRPC, monitoreo con Prometheus y automatización de infraestructura.

El proyecto fue diseñado para demostrar una infraestructura moderna, segmentada, automatizada, observable y resiliente, utilizando tecnologías de networking y seguridad aplicadas en una topología empresarial.

## Componentes principales

### Fabric BGP EVPN/VXLAN
La red principal utiliza una arquitectura Spine-Leaf formada por:

- SPINE-01
- SPINE-02
- LEAF-01
- LEAF-02
- HOST-A
- HOST-B

Se utiliza BGP EVPN como plano de control y VXLAN para la extensión de conectividad de Capa 2 mediante el VNI 10010.

Los dos Spine funcionan como Route Reflectors y los Leaf mantienen redundancia de conectividad hacia ambos Spine.

### Automatización

El nodo AUTOMATION utiliza Python, Netmiko, Paramiko y Jinja2 para realizar tareas de administración y validación de la infraestructura.

Entre los scripts incluidos se encuentran:

- inventory.py
- automate_fabric.py
- test_all_leaves.py
- backup_status.py
- show_inventory.py

Las credenciales reales utilizadas durante el laboratorio fueron reemplazadas por valores CHANGE_ME_* en esta copia destinada a documentación y entrega.

## Red 5G

El entorno 5G está compuesto por:

- 5G-CORE
- gNodeB-UE

El núcleo utiliza Open5GS y el acceso radio se simula mediante UERANSIM.

La configuración incluye un UE registrado mediante el PLMN de laboratorio y permite el establecimiento de una sesión PDU para transportar tráfico entre la red 5G y los servicios empresariales.

Durante las pruebas se obtuvo conectividad extremo a extremo con una latencia promedio aproximada de 2.177 ms, inferior al objetivo de 10 ms establecido para el proyecto.

También se realizaron pruebas de rendimiento mediante iperf3, obteniendo aproximadamente 67.4 Mbps en transmisión y 66.5 Mbps en recepción.

## NFV

La infraestructura NFV incluye:

- VNF-FIREWALL
- VNF-FIREWALL-BACKUP
- VNF-LOADBALANCER
- BACKEND-1
- BACKEND-2
- DATA-SERVER
- THROUGHPUT-SERVER

El firewall principal proporciona enrutamiento y filtrado entre las redes 5G y de servicios.

Existe un firewall de respaldo que implementa un mecanismo automático de failover. Durante las pruebas realizadas, el cambio al firewall secundario se completó aproximadamente en 3 segundos.

El balanceador utiliza HAProxy para distribuir tráfico entre BACKEND-1 y BACKEND-2.

## F5G

El entorno F5G está formado por:

- F5G-OLT
- ONU-1
- ONU-2

Se simula una red de acceso óptico con asignación dinámica de ancho de banda y perfiles diferenciados para los dispositivos ONU.

## Zero Trust y Seguridad

La arquitectura de seguridad incluye:

- ZTNA-GATEWAY
- ZTNA-SERVER
- SECURITY-TEST

El gateway implementa políticas de acceso basadas en autorización explícita.

El tráfico no autorizado es descartado y registrado para su análisis.

Se realizaron pruebas mediante escaneo de puertos y simulación de exfiltración de información, verificando que los accesos no autorizados fueran bloqueados.

También se implementaron mecanismos de mitigación contra tráfico malicioso y comportamiento similar a ataques DDoS, manteniendo conectividad para los dispositivos autorizados.

## Telemetría gRPC

La plataforma de telemetría está formada por:

- TELEMETRY-GRPC
- TELEMETRY-COLLECTOR

El servidor transmite métricas de infraestructura mediante gRPC y el collector almacena los eventos recibidos.

La solución permite detectar cambios de disponibilidad en los nodos de la infraestructura.

## Monitoreo

Los nodos de monitoreo son:

- MONITORING-SERVER
- PROMETHEUS-DASHBOARD

Prometheus recolecta métricas de disponibilidad y latencia de los principales componentes de la red.

También se desarrolló un dashboard web para visualizar:

- Estado global de infraestructura
- Dispositivos disponibles
- Dispositivos protegidos
- Latencia
- Estado de componentes
- Eventos de disponibilidad

El dashboard permite observar en tiempo real la transición de un dispositivo entre estados UP, DOWN y recuperación.

## Endpoints

Los VPCS exportados son:

- HOST-A: 192.168.10.10/24
- HOST-B: 192.168.10.20/24
- DATA-SERVER: 10.60.0.2/24, gateway 10.60.0.1

## Infraestructura de interconexión

La topología también utiliza:

- MGMT-SW
- MGMT-SW-2
- NFV-TRANSIT-SW
- Cloud1

Los switches Ethernet integrados de GNS3 no poseen configuraciones CLI exportables, por lo que se documentan pero no cuentan con carpetas individuales dentro de este paquete.

Cloud1 permite enlazar la topología con la interfaz Host-Only del entorno de virtualización y facilita el acceso desde el equipo anfitrión hacia los servicios del proyecto, principalmente el dashboard de monitoreo.

## Pruebas realizadas

Durante el desarrollo se comprobaron, entre otras:

- Conectividad VXLAN entre HOST-A y HOST-B
- Operación BGP EVPN
- Automatización mediante Netmiko
- Registro del UE en el núcleo 5G
- Establecimiento de sesión PDU
- Rendimiento mediante iperf3
- Latencia 5G inferior a 10 ms
- Balanceo de carga mediante HAProxy
- Failover del firewall NFV
- Funcionamiento de F5G
- Bloqueo de escaneo de puertos
- Bloqueo de intentos de exfiltración
- Mitigación de tráfico malicioso
- Redundancia ante fallo de un Spine
- Streaming de telemetría gRPC
- Recolección de métricas Prometheus
- Detección de caída y recuperación de dispositivos

## Estructura del paquete

- fabric/: configuraciones de Spine y Leaf
- automation/: scripts de automatización
- endpoints/: configuraciones de VPCS
- 5g/: Open5GS y UERANSIM
- nfv/: firewall, firewall backup, load balancer, backends y pruebas de rendimiento
- f5g/: OLT y ONU
- security/: Zero Trust y nodo de pruebas
- telemetry/: servidor gRPC y collector
- monitoring/: monitoreo, SIEM, Prometheus y dashboard
- inventory.md: inventario de nodos del proyecto

## Seguridad del repositorio

Las claves privadas de Open5GS fueron excluidas deliberadamente del paquete.

Las credenciales utilizadas durante el laboratorio fueron reemplazadas por valores CHANGE_ME_*.

Este repositorio corresponde a un entorno académico y de simulación y no debe interpretarse como una configuración lista para producción.

## Autor

Fernando Ruiz  
Carné: 1990-19-7785  
Curso: Telecomunicaciones  
Proyecto Final

---

## Imágenes Docker y manifiestos de contenedores

El repositorio incluye los Dockerfiles utilizados para construir las imágenes personalizadas empleadas por los diferentes componentes del proyecto NETCLOUD-SECURE.

Los Dockerfiles se encuentran en la carpeta:

`docker/`

Imágenes documentadas:

- netcloud-5g-core
- netcloud-backend
- netcloud-f5g
- netcloud-frr
- netcloud-grpc
- netcloud-iperf
- netcloud-monitoring
- netcloud-prometheus
- netcloud-security-test
- netcloud-ueransim
- netcloud-vnf-firewall
- netcloud-vnf-lb
- netcloud-ztna

Estos archivos permiten documentar las dependencias y el proceso de construcción de los contenedores utilizados dentro de la topología GNS3.

## Automatización y plantillas Jinja2

La automatización implementada en NETCLOUD-SECURE fue desarrollada mediante scripts en Python utilizando principalmente la librería Netmiko para establecer conexiones SSH con los dispositivos del Fabric, ejecutar tareas de configuración y obtener información operativa de manera centralizada.

El script `automate_fabric.py` utiliza además la librería Jinja2 mediante la clase `Template`. La plantilla se encuentra embebida directamente dentro del código Python y permite generar dinámicamente los comandos de configuración correspondientes a cada dispositivo administrado.

Por esta razón, el proyecto utiliza Jinja2 como parte del proceso de automatización, aunque no se emplearon archivos de plantilla externos con extensiones `.j2`, `.jinja` o `.jinja2`.

Los componentes de automatización utilizados pueden consultarse principalmente en las carpetas `automation/` y `fabric/`, donde se encuentran los scripts Python, archivos de inventario y configuraciones persistentes de los dispositivos.
