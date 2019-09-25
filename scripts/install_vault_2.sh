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

if [ ${CONSUL_NODE} = "dr" ]; then
    echo "Starting Consul client agent for ${CONSUL_NODE}..."
    /usr/local/bin/consul members &>/dev/null || {
    /usr/local/bin/consul agent -config-dir=/vagrant/etc/consul.d/client5.json  >${LOG} &  
    sleep 10

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
  sudo /usr/local/bin/vault server -log-level=trace -config /vagrant/etc/vault/vault_conf_5.hcl  &> ${LOG} &
  echo vault started
  sleep 5

  sudo apt install -y jq
  initResult2=$(VAULT_ADDR=http://192.168.2.121:8200 vault operator init -format json -key-shares 1 -key-threshold 1)
  unsealKey5=$(echo -n $initResult2 | jq -r '.unseal_keys_b64[0]')
  rootToken5=$(echo -n $initResult2 | jq -r '.root_token')
  echo -n $unsealKey5 > unsealKey5
  echo -n $rootToken5 > rootToken5

  
  echo -n $unsealKey5  2>&1 | tee /vagrant/SomeKey2.txt
  echo -n $rootToken5  2>&1 | tee /vagrant/SomeToken2.txt

  VAULT_ADDR=http://192.168.2.121:8200 vault operator unseal `cat unsealKey5`
  VAULT_ADDR=http://192.168.2.121:8200 vault login `cat rootToken5`
  DR_TOKEN=$(cat /vagrant/SomeDR.txt)
  VAULT_TOKEN=$(cat rootToken5) vault write sys/replication/dr/secondary/enable token=${DR_TOKEN}

grep VAULT_ADDR ~/.bash_profile || {
  echo export VAULT_ADDR=http://${IP}:8200 | sudo tee -a ~/.bash_profile
  }
  
fi
