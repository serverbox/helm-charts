#!/usr/bin/env python3
import urllib3
import json
import os
import time
import logging

logFormat='%(asctime)s %(levelname)s:%(message)s'
timeStamps='%Y-%m-%d %H:%M:%S'
logging.basicConfig(format=logFormat, datefmt=timeStamps)
#logging.basicConfig(format=logFormat, datefmt=timeStamps, level=logging.INFO)

with open('/run/secrets/kubernetes.io/serviceaccount/token', 'r') as file:
authToken = file.read().replace('\n', '')

with open('/run/secrets/kubernetes.io/serviceaccount/namespace', 'r') as file:
namespace = file.read().replace('\n', '')

http = urllib3.PoolManager(
cert_reqs='CERT_REQUIRED',
ca_certs='/run/secrets/kubernetes.io/serviceaccount/ca.crt')

httpB = urllib3.PoolManager(
cert_reqs='CERT_REQUIRED',
ca_certs='/run/secrets/kubernetes.io/serviceaccount/ca.crt')

authHeader = { 'Authorization': 'Bearer {}'.format(authToken)}
while True:
containerJSON = json.loads(http.request('GET', 'https://kubernetes.default.svc.cluster.local/api/v1/namespaces/{}/pods'.format(namespace), headers=authHeader).data.decode('utf-8'))
for container in containerJSON['items']:
containerName = container['metadata']['name']
try:
  for thisState in container['status']['containerStatuses']:
    if 'waiting' in thisState['state']:
      logging.warning('{} is waitning in state {}'.format(containerName,thisState['state']['waiting']['reason']))
      if thisState['state']['waiting']['reason'] == 'CrashLoopBackOff':
        logging.warning('Deleting {} : CrashLoopBackOff'.format(containerName))
        deleted = http.request('DELETE', 'https://kubernetes.default.svc.cluster.local/api/v1/namespaces/{}/pods/{}'.format(namespace,containerName), headers=authHeader)
except:
  logging.warning('{} has no status'.format(containerName))
logging.info('Sleeping for 60s')
time.sleep(int(60))
