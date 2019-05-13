
# vaultlab-replication

## What is this?

This Vagrantfile will spin up six Ubuntu  VMs: 

* 2 Vault+prem servers in HA (with Consul client)
* 2 Consul servers

The Vault+prem servers each use a Consul storage backend. The goal is to simulate a basic 2-cluster replication setup of Vault (1+1 Vault servers in HA & 1 Consul server per cluster).

Vagrant will spin up the VMs, provision them, and start up both Vault and Consul. It will also join the client nodes to their respective Consul server. 

For logs:

* Vault: LOG="/vagrant/logs/vault_${HOSTNAME}.log"
* Consul: LOG="/vagrant/logs/consul_${HOSTNAME}.log"

## Pre-req

On host machine, make sure you have set the "pkg" folder with your favourites binaries , actually this folder is in .gitignore to avoid any human errors and publish the enterprise binaries.



## Spin up VMs

Run `vagrant up` and then ssh into the `vault_leader01` and `vault_leader02` to initialize Vault and then set up replication in the dc1. To initialize vault you can find the vault-init.py script in the /scripts folder and you can set up the -key-shares and -key-threshold number by tunning the python script

`vault_secondary01` and `vault_secondary02` are the nodes in dc2. To initialize vault you can find the vault-init.py script in the /scripts folder.

 follow https://www.vaultproject.io/guides/replication.html to set up replication.

## Coming soon...

Plan to add: 
* script to more quickly set up replication