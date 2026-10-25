from inventory import devices

for device in devices:
    print(device["name"], "-", device["host"])
