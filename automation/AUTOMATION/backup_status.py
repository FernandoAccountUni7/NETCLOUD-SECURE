from netmiko import ConnectHandler
from inventory import devices
from datetime import datetime

commands = {
    "bgp": 'vtysh -c "show bgp ipv4 unicast summary"',
    "evpn": 'vtysh -c "show bgp l2vpn evpn"',
    "vni": 'vtysh -c "show evpn vni"'
}

timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")

for device in devices:
    print(f"\nConectando a {device['name']}...")

    connection = ConnectHandler(
        device_type=device["device_type"],
        host=device["host"],
        username=device["username"],
        password=device["password"]
    )

    filename = f"/opt/netcloud/{device['name']}_backup_{timestamp}.txt"

    with open(filename, "w") as file:
        file.write(f"===== {device['name']} =====\n\n")

        for section, command in commands.items():
            output = connection.send_command(command)

            file.write(f"===== {section.upper()} =====\n")
            file.write(output)
            file.write("\n\n")

    connection.disconnect()

    print(f"Respaldo generado: {filename}")
