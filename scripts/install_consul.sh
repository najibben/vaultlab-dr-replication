#!/usr/bin/env bash
set -x

IFACE=`route -n | awk '$1 == "192.168.2.0" {print $8;exit}'`
CIDR=`ip addr show ${IFACE} | awk '$2 ~ "192.168.2" {print $2}'`
IP=${CIDR%%/24}

if [ -d /vagrant ]; then
  mkdir -p /vagrant/logs
  LOG="/vagrant/logs/consul_${HOSTNAME}.log"
else
  LOG="consul.log"
fi


PKG="wget unzip"
which ${PKG} &>/dev/null || {
  export DEBIAN_FRONTEND=noninteractive
  apt-get update
  apt-get install -y ${PKG}
}

# check consul binary
[ -f /usr/local/bin/consul ] &>/dev/null || {
    pushd /usr/local/bin
    [ -f consul_1.2.2_linux_amd64.zip ] || {
        sudo wget -q https://releases.hashicorp.com/consul/1.2.2/consul_1.2.2_linux_amd64.zip
    }
    sudo unzip consul_1.2.2_linux_amd64.zip
    sudo chmod +x consul
    popd
}

# check consul-template binary
[ -f /usr/local/bin/consul-template ] &>/dev/null || {
    pushd /usr/local/bin
    [ -f consul-template_0.19.5_linux_amd64.zip ] || {
        sudo wget -q https://releases.hashicorp.com/consul-template/0.19.5/consul-template_0.19.5_linux_amd64.zip
    }
    sudo unzip consul-template_0.19.5_linux_amd64.zip
    sudo chmod +x consul-template
    popd
}

# check envconsul binary
[ -f /usr/local/bin/envconsul ] &>/dev/null || {
    pushd /usr/local/bin
    [ -f envconsul_0.7.3_linux_amd64.zip ] || {
        sudo wget -q https://releases.hashicorp.com/envconsul/0.7.3/envconsul_0.7.3_linux_amd64.zip
    }
    sudo unzip envconsul_0.7.3_linux_amd64.zip
    sudo chmod +x envconsul
    popd
}

AGENT_CONFIG="-config-dir=/etc/consul.d -enable-script-checks=true"
sudo mkdir -p /etc/consul.d
# check for consul hostname or travis => server
#if [[ "${HOSTNAME}" =~ "consul" ]] || [ "${TRAVIS}" == "true" ]; then
if [ ${CONSUL_NODE} = "consul" ]; then
  #echo server
	#/usr/bin/consul members 2>/dev/null || {
		echo "Starting Consul cluster ..."
        sudo /usr/local/bin/consul agent -server -ui -client=0.0.0.0 -bind=${IP} -config-file=/vagrant/etc/consul.d/server.json >${LOG} &
        sleep 10
	#}

elif [ ${CONSUL_NODE} = "secondconsul" ]; then
#elif [[ "${HOSTNAME}" =~ "secondconsul" ]] || [ "${TRAVIS}" == "true" ]; then
  #echo server

	#/usr/bin/consul members 2>/dev/null || {
		echo "Starting Consul cluster ..."
        sudo /usr/local/bin/consul agent -server -ui -client=0.0.0.0 -bind=${IP} -config-file=/vagrant/etc/consul.d/server_2.json >${LOG} &
        sleep 10
	#}  


elif [ ${CONSUL_NODE} = "thirdconsul" ]; then
#elif [[ "${HOSTNAME}" =~ "secondconsul" ]] || [ "${TRAVIS}" == "true" ]; then
  #echo server

	#/usr/bin/consul members 2>/dev/null || {
		echo "Starting Consul cluster ..."
        sudo /usr/local/bin/consul agent -server -ui -client=0.0.0.0 -bind=${IP} -config-file=/vagrant/etc/consul.d/server_3.json >${LOG} &
        sleep 10
	#}  
fi

