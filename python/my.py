#!/usr/bin/env python

'''
Created on 12 de jan de 2016

This python script is able to open a \t separated file with a bunch of server, address and ports and creates a command to connect to this server enabling the SSH Tunnel port

Improvements: Put all parameters per server in the file

@author: munozdanilo
'''
from subprocess import call
import sys

DEFAULT_SSH_PORT = 22
DEFAULT_USER = 'root' 
LOCAL_PORT = 8181
REMOTE_TUNNEL_IP = '127.0.0.1'
REMOTE_TUNNEL_PORT = 80

CONFIG_FILE = 'servers.conf'

class Server():
    def __init__(self, name, ip, port = DEFAULT_SSH_PORT):
        self.name = name
        self.ip = ip
        self.port = port
        self.user = DEFAULT_USER
        self.remote_tunnel_ip = REMOTE_TUNNEL_IP
        self.remote_tunnel_port = REMOTE_TUNNEL_PORT
    
customers = []

with open(CONFIG_FILE, 'r') as f:
    for line in f:
        
        if line.startswith('#'):
            continue
        
        line = line.replace('\t\t', '\t').replace('\t\t', '\t').replace('\n', '')
        s = line.split('\t')
        
        server = Server(s[0], s[1])
        
        if len(s) > 2: 
            server.port = int(s[2])
            
        customers.append(server)

customers.sort(key=lambda x: x.name)

print 'Choose the desired customer:'
 
for i, c in enumerate(customers):
    print '\t%02d - %s' % (i + 1, c.name)    
    
try:    
    read = raw_input('> ')
except KeyboardInterrupt:
    print("\nCanceled!")
    sys.exit(1)    

if not read.isdigit():
    print 'Invalid option'
    sys.exit(-1)
    
read = int(read) - 1

if read < 0 or read >= len(customers):
    print 'Invalid option... Exiting...'
    sys.exit(-1)
        
customer = customers[read]  
print 'Selected server: %s' % customer.name
    
#SSH
command = 'ssh -p %s root@%s' % (customer.port, customer.ip)

if customer.remote_tunnel_ip:
    command += ' -L %s:%s:%s' % (LOCAL_PORT, customer.remote_tunnel_ip, customer.remote_tunnel_port) 


try:    
    print command
    call(command, shell=True)
except KeyboardInterrupt:
    print("\nCanceled!")
    sys.exit(1)    
