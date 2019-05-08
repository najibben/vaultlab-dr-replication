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
  sudo consul kv delete -recurse vault

  #delete old token if present
  [ -f /root/.vault-token ] && sudo rm /root/.vault-token


  #start vault
  sudo cp  /vagrant/etc/consul.d/client.json  /etc/consul.d/
  #sudo /usr/local/bin/vault server  -log-level=trace -config /vagrant/etc/vault/vault_conf.hcl  -dev -dev-listen-address=${IP}:8200   &> ${LOG} &
  sudo /usr/local/bin/vault server  -config /vagrant/etc/vault/vault_conf.hcl  &> ${LOG} &
  echo vault started
  sleep 3 


elif [ ${CONSUL_NODE} = "leader02" ]; then
    echo "Starting Consul client agent for ${CONSUL_NODE}..."
    /usr/local/bin/consul members &>/dev/null || {
    /usr/local/bin/consul agent -config-dir=/vagrant/etc/consul.d/client2.json  >${LOG} &  
    }

  #lets kill past instance
  sudo killall vault &>/dev/null

  #lets delete old consul storage
  sudo consul kv delete -recurse vault

  #delete old token if present
  [ -f /root/.vault-token ] && sudo rm /root/.vault-token


  #start vault
  sudo cp  /vagrant/etc/consul.d/client.json  /etc/consul.d/
  #sudo /usr/local/bin/vault server  -log-level=trace -config /vagrant/etc/vault/vault_conf.hcl  -dev -dev-listen-address=${IP}:8200   &> ${LOG} &
  sudo /usr/local/bin/vault server  -config /vagrant/etc/vault/vault_conf_1.hcl  &> ${LOG} &
  echo vault started
  sleep 3 



#if [[ "${HOSTNAME}" =~ "leader" ]] ; then


  #echo "vault token:"
  #cat /root/.vault-token
  #echo -e "\nvault token is on /root/.vault-token"
  
  # enable secret KV version 1
  #sudo VAULT_ADDR="http://${IP}:8200" vault secrets enable -version=1 kv
  
  #grep VAULT_TOKEN ~/.bash_profile || {
  #  echo export VAULT_TOKEN=\`cat /root/.vault-token\` | sudo tee -a ~/.bash_profile
  #}

  #grep VAULT_ADDR ~/.bash_profile || {
  #  echo export VAULT_ADDR=http://${IP}:8200 | sudo tee -a ~/.bash_profile
  #}
  


fi
