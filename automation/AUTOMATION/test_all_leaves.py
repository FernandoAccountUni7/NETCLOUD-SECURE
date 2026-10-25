from netmiko import ConnectHandler
from inventory import devices

for device in devices:
    print(f"\nConectando a {device['name']}...")

    connection = ConnectHandler(
        device_type=device["device_type"],
        host=device["host"],
        username=device["username"],
        password=device["password"]
    )

    output = connection.send_command(
        'vtysh -c "show bgp ipv4 unicast summary"'
    )

    print(output)

    connection.disconnect()
