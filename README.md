
# vaultlab-replication

## What is this?

This Vagrantfile will spin up six Ubuntu  VMs: 

* 2 Vault+prem servers in HA (with Consul client)
* 3 Consul servers

The Vault+prem servers each use a Consul storage backend. The goal is to simulate a basic 2-cluster replication setup of Vault (1+1 Vault servers in HA & 1 Consul server per cluster). 

it will add addtional cluster for Disaster Recovery

Vagrant will spin up the VMs, provision them, and start up both Vault and Consul. It will also join the client nodes to their respective Consul server. 

For logs:

* Vault: LOG="/vagrant/logs/vault_${HOSTNAME}.log"
* Consul: LOG="/vagrant/logs/consul_${HOSTNAME}.log"

## Pre-req

On host machine, create the "pkg" folder under `~/vaultlab-replication/` path with your favourite `prem` binaries , actually this folder is in .gitignore.



## Spin up VMs

Run `vagrant up` and then ssh into the `leader01` and `leader02` servers are initialized and unsealed in dc1.

`secondary01` and `secondary02` are the nodes in dc2. servers are initialized and unsealed in dc2

`vault_dr` is the node in dc3

## Topology 

* DC1 is the performance replication primary
* DC2 is the performance replication secondary and DR primary
* DC3 is the DR secondary of DC2

# Binary

you will need to add a custom binary in the /pkg folder.

## Performance replication is already configured :

```
 vagrant@leader01:~$ sudo su -
root@leader01:~# vault read sys/replication/performance/status
Key                     Value
---                     -----
cluster_id              46165c32-7c98-b9b0-a806-6fe0065cfaac
known_secondaries       [najib]
last_reindex_epoch      0
last_wal                31
merkle_root             0f25f67c979985e9ea75e079f635431f0ea01304
mode                    primary
primary_cluster_addr    n/a
state                   running

```

```
vagrant@leader02:~$ sudo su -
root@leader02:~# vault read sys/replication/performance/status
Key                     Value
---                     -----
cluster_id              46165c32-7c98-b9b0-a806-6fe0065cfaac
known_secondaries       [najib]
last_reindex_epoch      0
last_wal                31
merkle_root             0f25f67c979985e9ea75e079f635431f0ea01304
mode                    primary
primary_cluster_addr    n/a
state                   running
```

```
vagrant@secondary01:~$ sudo su -
root@secondary01:~# vault read sys/replication/performance/status
Key                            Value
---                            -----
cluster_id                     46165c32-7c98-b9b0-a806-6fe0065cfaac
known_primary_cluster_addrs    [https://192.168.2.14:8201 https://192.168.2.13:8201]
last_reindex_epoch             1557997819
last_remote_wal                0
merkle_root                    0f25f67c979985e9ea75e079f635431f0ea01304
mode                           secondary
primary_cluster_addr           https://192.168.2.14:8201
secondary_id                   najib
state                          stream-wals
```

```
vagrant@secondary02:~$ sudo su -
root@secondary02:~# vault read sys/replication/performance/status
Key                            Value
---                            -----
cluster_id                     46165c32-7c98-b9b0-a806-6fe0065cfaac
known_primary_cluster_addrs    [https://192.168.2.14:8201 https://192.168.2.13:8201]
last_reindex_epoch             1557997819
last_remote_wal                0
merkle_root                    0f25f67c979985e9ea75e079f635431f0ea01304
mode                           secondary
primary_cluster_addr           https://192.168.2.14:8201
secondary_id                   najib
state                          stream-wals
```