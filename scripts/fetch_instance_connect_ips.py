import json
import sys
import requests

def fetch_instance_connect_ips(region):
    service = 'EC2_INSTANCE_CONNECT'
    url = 'https://ip-ranges.amazonaws.com/ip-ranges.json'
    
    try:
        response = requests.get(url)
        data = response.json()
        ips = [item['ip_prefix'] for item in data['prefixes']
               if item['service'] == service and item['region'] == region]
        return ips
    except Exception as e:
        print(f"Error fetching or processing data: {str(e)}", file=sys.stderr)
        sys.exit(1)

def main():
    if len(sys.argv) != 2:
        print("Usage: python3 fetch_instance_connect_ips.py <region>", file=sys.stderr)
        sys.exit(1)
    
    region = sys.argv[1]
    ips = fetch_instance_connect_ips(region)
    print(json.dumps({"ips": ips}))

if __name__ == "__main__":
    main()
