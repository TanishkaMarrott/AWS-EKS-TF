import json
import sys
import requests

def main():
    if len(sys.argv) != 2:
        print("Usage: python fetch_instance_connect_ips.py <region>", file=sys.stderr)
        sys.exit(1)

    # The AWS region you want the IP ranges for
    region = sys.argv[1]
    service = 'AMAZON'

    # URL to the AWS IP ranges JSON file
    url = 'https://ip-ranges.amazonaws.com/ip-ranges.json'

    try:
        # Fetch the JSON data from AWS
        response = requests.get(url)
        data = response.json()
        # Filter IP ranges by service and region
        ips = [item['ip_prefix'] for item in data['prefixes'] if item['service'] == service and item['region'] == region]

        # Output the list of IPs as JSON
        output = {"ips": ips}
        print(json.dumps(output))

    except Exception as e:
        print(f"Error fetching or parsing AWS IP ranges: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
