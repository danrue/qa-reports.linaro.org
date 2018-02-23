#!/usr/bin/env python3

import json
import os
import sys

os.system(terraform pull)

#state = json.loads(sys.stdin.read())

#import pprint; pprint.pprint(state)

#for module in state['modules']:
#    for resource_name, resource in module['resources'].items():
#        if "aws_instance" in resource_name:
#            print('{} {}'.format(resource['primary']['attributes']['public_ip'], resource_name))

