import json
import sys
import requests

# Check for correct usage
if len(sys.argv) != 2:
    print("Usage: python fetch_instance_connect_ips.py <region>")
    sys.exit(1)

# The AWS region you want the IP ranges for
region = sys.argv[1]
service = 'EC2_INSTANCE_CONNECT'

# URL to the AWS IP ranges JSON file
url = 'https://ip-ranges.amazonaws.com/ip-ranges.json'

try:
    # Fetch the JSON data from AWS
    response = requests.get(url)
    ip_ranges = response.json()

    # Filter IP ranges by service and region
    ips = [prefix['ip_prefix'] for prefix in ip_ranges['prefixes'] if prefix['service'] == service and prefix['region'] == region]

    # Join the IP addresses into a single string separated by commas
    ip_string = ','.join(ips)

    # Output the result as JSON with IPs as a single string
    print(json.dumps({"ips": ip_string}))

except Exception as e:
    print(f"Error fetching or parsing AWS IP ranges: {str(e)}")
    sys.exit(1)
