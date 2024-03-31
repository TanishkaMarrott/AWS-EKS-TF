import json
import requests
import sys

def fetch_instance_connect_ips(region):
    # URL to fetch the AWS IP ranges JSON
    url = "https://ip-ranges.amazonaws.com/ip-ranges.json"

    # Make a GET request to fetch the data
    response = requests.get(url)
    ip_ranges = response.json()

    # Filter for EC2 Instance Connect IPs in the specified region
    # Note: Adjust the "service" and "region" as necessary
    service = 'AMAZON'
    ips = [prefix["ip_prefix"] for prefix in ip_ranges["prefixes"] if prefix["service"] == service and prefix["region"] == region]

    return {"ips": ips}

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python fetch_instance_connect_ips.py <region>")
        sys.exit(1)

    region = sys.argv[1]
    ips = fetch_instance_connect_ips(region)

    # The script outputs the IPs in the expected format for Terraform's external data source
    print(json.dumps(ips))
