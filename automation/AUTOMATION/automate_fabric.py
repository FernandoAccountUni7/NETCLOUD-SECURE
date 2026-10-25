from netmiko import ConnectHandler
from jinja2 import Template
from inventory import devices

descriptions = {
    "LEAF-01": "CONFIGURED-BY-AUTOMATION-LEAF01",
    "LEAF-02": "CONFIGURED-BY-AUTOMATION-LEAF02"
}

template = Template(
    'vtysh -c "configure terminal" -c "interface lo" '
    '-c "description {{ description }}" -c "end" -c "write memory"'
)

for device in devices:
    print(f"\nConectando a {device['name']}...")

    connection = ConnectHandler(
        device_type=device["device_type"],
        host=device["host"],
        username=device["username"],
        password=device["password"]
    )

    command = template.render(
        description=descriptions[device["name"]]
    )

    print(connection.send_command(command))
    print(f"Configuracion aplicada correctamente en {device['name']}")

    connection.disconnect()
