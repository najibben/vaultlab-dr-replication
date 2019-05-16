#!/usr/bin/env bash

IFACE=`route -n | awk '$1 == "192.168.2.0" {print $8}'`
CIDR=`ip addr show ${IFACE} | awk '$2 ~ "192.168.2" {print $2}'`
IP=${CIDR%%/24}


if [ -d /vagrant ]; then
  LOG="/vagrant/logs/vault_${HOSTNAME}.log"
else
  LOG="vault.log"
fi

which vault &>/dev/null || {
    echo "Determining Vault version to install ..."

    # Vault is expected to be present in /vagrant/pkg
    # Naming convention is vault-enterprise_1.2.2+prem_linux_amd64

    vault_package_file=`ls /vagrant/pkg/vault-enterprise_*+prem_linux_amd64.zip | sort -r | head -1`

    if [ -f "${vault_package_file}" ]; then
        echo "Installing Vault"
        pushd /tmp
        unzip ${vault_package_file}
        sudo chmod +x vault
        sudo mv vault /usr/local/bin/vault

    else
        echo No vault package found....exiting.
        exit 1
    fi
}

if [ ${CONSUL_NODE} = "leader01" ]; then
  
  echo "Starting Consul client agent for ${CONSUL_NODE}..."
	
    /usr/local/bin/consul members &>/dev/null || {
    /usr/local/bin/consul agent -config-dir=/vagrant/etc/consul.d/client.json  >${LOG} &  
    }
 
  #lets kill past instance
  sudo killall vault &>/dev/null

  #lets delete old consul storage
  #sudo consul kv delete -recurse vault

  #delete old token if present
  #[ -f /root/.vault-token ] && sudo rm /root/.vault-token


  #start vault
  sudo cp  /vagrant/etc/consul.d/client.json  /etc/consul.d/
  #sudo /usr/local/bin/vault server  -log-level=trace -config /vagrant/etc/vault/vault_conf.hcl  -dev -dev-listen-address=${IP}:8200   &> ${LOG} &
  sudo /usr/local/bin/vault server  -config /vagrant/etc/vault/vault_conf.hcl  &> ${LOG} &
  echo vault started
  sleep 5

  sudo apt install -y jq
  initResult=$(VAULT_ADDR=http://192.168.2.14:8200 vault operator init -format json -key-shares 1 -key-threshold 1)
  unsealKey1=$(echo -n $initResult | jq -r '.unseal_keys_b64[0]')
  rootToken1=$(echo -n $initResult | jq -r '.root_token')
  echo -n $unsealKey1 > unsealKey1
  echo -n $rootToken1 > rootToken1

  #echo -n $unsealKey1  2>&1 | tee ~/SomeFile.txt
  echo -n $unsealKey1  2>&1 | tee /vagrant/SomeKey.txt
  echo -n $rootToken1  2>&1 | tee /vagrant/SomeToken.txt

  VAULT_ADDR=http://192.168.2.14:8200 vault operator unseal `cat unsealKey1`
  VAULT_ADDR=http://192.168.2.14:8200 vault login `cat rootToken1`
  
  grep VAULT_TOKEN ~/.bash_profile || {
  echo export VAULT_TOKEN=`cat rootToken1` | sudo tee -a ~/.bash_profile
  }

  grep VAULT_ADDR ~/.bash_profile || {
  echo export VAULT_ADDR=http://${IP}:8200 | sudo tee -a ~/.bash_profile
  }

  VAULT_ADDR=http://192.168.2.14:8200 vault write -f sys/replication/primary/enable
  sleep 5s

  secondaryToken=$(vault write -field wrapping_token sys/replication/primary/secondary-token id=najib)
  echo -n $secondaryToken > secondaryToken

  #echo -n $unsealKey1  2>&1 | tee ~/SomeFile.txt
  echo -n $secondaryToken  2>&1 | tee /vagrant/SomeJWT.txt
  sleep 5s


elif [ ${CONSUL_NODE} = "leader02" ]; then
    echo "Starting Consul client agent for ${CONSUL_NODE}..."
    /usr/local/bin/consul members &>/dev/null || {
    /usr/local/bin/consul agent -config-dir=/vagrant/etc/consul.d/client2.json  >${LOG} &  
    }

  #lets kill past instance
  sudo killall vault &>/dev/null

  #lets delete old consul storage
  #sudo consul kv delete -recurse vault

  #delete old token if present
  #[ -f /root/.vault-token ] && sudo rm /root/.vault-token


  #start vault
  sudo cp  /vagrant/etc/consul.d/client.json  /etc/consul.d/
  #sudo /usr/local/bin/vault server  -log-level=trace -config /vagrant/etc/vault/vault_conf.hcl  -dev -dev-listen-address=${IP}:8200   &> ${LOG} &
  sudo /usr/local/bin/vault server  -config /vagrant/etc/vault/vault_conf_1.hcl  &> ${LOG} &
  echo vault started
  #sleep 3 
  sleep 5

  #sudo apt-get update
  #sudo apt-get install -y python-requests
  sudo apt install -y jq
  unsealKey2=$(cat /vagrant/SomeKey.txt)
  echo -n $unsealKey2 > unsealKey2

  VAULT_ADDR=http://192.168.2.13:8200 vault operator unseal `cat unsealKey2`

  #login `cat rootToken1`
  
  rootToken2=$(cat /vagrant/SomeToken.txt)
  echo -n $rootToken2 > rootToken2

  #enable secret KV version 1
  #sudo VAULT_ADDR="http://${IP}:8200" vault secrets enable -version=1 kv
  grep VAULT_TOKEN ~/.bash_profile || {
  echo export VAULT_TOKEN=`cat rootToken2` | sudo tee -a ~/.bash_profile
  }

  grep VAULT_ADDR ~/.bash_profile || {
  echo export VAULT_ADDR=http://${IP}:8200 | sudo tee -a ~/.bash_profile
  }


fi
