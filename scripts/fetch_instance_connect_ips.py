import json
import sys
import requests

def main():
    if len(sys.argv) != 2:
        print("Usage: python fetch_instance_connect_ips.py <region>")
        sys.exit(1)

    region = sys.argv[1]
    service = 'EC2_INSTANCE_CONNECT'
    url = 'https://ip-ranges.amazonaws.com/ip-ranges.json'

    try:
        response = requests.get(url)
        data = response.json()
        # Filter IP ranges by service and region and concatenate into a single string
        ips = ','.join(item['ip_prefix'] for item in data['prefixes'] if item['service'] == service and item['region'] == region)
        # Ensure output is a single string
        if ips:
            output = ips
        else:
            output = {"ips": ""}
        print(json.dumps(output))
    except Exception as e:
        print(f"Error fetching or parsing AWS IP ranges: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
