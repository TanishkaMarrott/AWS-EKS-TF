import requests
import sys
import json

def fetch_ec2_instance_connect_ips(region):
    """
    Fetches the EC2 Instance Connect IP ranges for the specified AWS region.
    """
    # URL to the AWS IP ranges JSON file
    url = "https://ip-ranges.amazonaws.com/ip-ranges.json"
    # Make a request to the URL and parse the JSON response
    response = requests.get(url)
    ip_ranges = response.json()

    # Filter for EC2 Instance Connect service in the specified region and extract IP prefixes
    ec2_connect_ips = [
        prefix["ip_prefix"] for prefix in ip_ranges["prefixes"]
        if prefix["service"] == "EC2_INSTANCE_CONNECT" and prefix["region"] == region
    ]

    return ec2_connect_ips

if __name__ == "__main__":
    # Determine the region from the command-line arguments, defaulting to 'ap-northeast-1'
    region = sys.argv[1] if len(sys.argv) > 1 else "ap-northeast-1"
    # Fetch the EC2 Instance Connect IP ranges for the specified region
    ips = fetch_ec2_instance_connect_ips(region)
    # Convert the list of IP addresses into a JSON object with a single string value,
    # concatenating the IPs with a comma. This ensures compatibility with Terraform's expectations.
    print(json.dumps({"ips": ",".join(ips)}))
