import requests
import sys
import json

def fetch_ec2_instance_connect_ips(region):
    # URL to the AWS IP ranges JSON file
    url = "https://ip-ranges.amazonaws.com/ip-ranges.json"
    response = requests.get(url)
    ip_ranges = response.json()

    # Filter for EC2 Instance Connect service in the specified region
    ec2_connect_ips = [
        prefix["ip_prefix"] for prefix in ip_ranges["prefixes"]
        if prefix["service"] == "EC2_INSTANCE_CONNECT" and prefix["region"] == region
    ]

    return ec2_connect_ips

if __name__ == "__main__":
    region = sys.argv[1] if len(sys.argv) > 1 else "ap-northeast-1"
    ips = fetch_ec2_instance_connect_ips(region)
    # Print the IP addresses in JSON format
    print(json.dumps({"ips": ips}))
