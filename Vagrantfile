# -*- mode: ruby -*-
# vi: set ft=ruby :
 
Vagrant.configure(2) do |config|
  config.vm.box = "allthingscloud/go-counter-demo"
  config.vm.provision "shell", path:"scripts/install_consul.sh"
 
  
  config.vm.define "consul" do |c1|
    c1.vm.hostname = "consul"
    c1.vm.network "private_network", ip: "192.168.2.11"
    c1.vm.provision "shell", path:"scripts/install_consul.sh",
    env: {"CONSUL_NODE" => "consul"}
  end
 
  config.vm.define "secondconsul" do |c2|
    c2.vm.hostname = "secondconsul"
    c2.vm.network "private_network", ip: "192.168.2.10"
    c2.vm.provision "shell", path:"scripts/install_consul.sh",
    env: { "CONSUL_NODE" => "secondconsul"}
  end

  config.vm.define "thirdconsul" do |c3|
    c3.vm.hostname = "thirdconsul"
    c3.vm.network "private_network", ip: "192.168.2.120"
    c3.vm.provision "shell", path:"scripts/install_consul.sh",
    env: { "CONSUL_NODE" => "thirdconsul"}
  end

 
  config.vm.define "leader01" do |l1|
    l1.vm.hostname = "leader01"
    l1.vm.network "private_network", ip: "192.168.2.14"
    l1.vm.network "forwarded_port", guest: 8500, host: 1236
    l1.vm.network "forwarded_port", guest: 8200, host: 1237
    l1.vm.network "forwarded_port", guest: 8201, host: 1238
    l1.vm.provision "shell", path:"scripts/install_vault.sh", env: { "CONSUL_NODE" => "leader01",
          "VAULT_ADDR" => "http://192.168.2.14:8200"}
end

config.vm.define "leader02" do |l2|
  l2.vm.hostname = "leader02"
  l2.vm.network "private_network", ip: "192.168.2.13"
  l2.vm.network "forwarded_port", guest: 8201, host: 1239
  #l2.vm.provision :shell, :path => "scripts/install_vault_1.sh"
  l2.vm.provision "shell", path:"scripts/install_vault.sh" , env: { "CONSUL_NODE" => "leader02",
         "VAULT_ADDR" => "http://192.168.2.13:8200"}
end

config.vm.define "secondary01" do |s1|
  s1.vm.hostname = "secondary01"
  s1.vm.network "private_network", ip: "192.168.2.16"
  s1.vm.network "forwarded_port", guest: 8500, host: 1240
  s1.vm.network "forwarded_port", guest: 8200, host: 1241
  s1.vm.network "forwarded_port", guest: 8201, host: 1242
  s1.vm.provision "shell", path:"scripts/install_vault_1.sh", env: { "CONSUL_NODE" => "secondary01",
       "VAULT_ADDR" => "http://192.168.2.16:8200"}
end

config.vm.define "secondary02" do |s2|
s2.vm.hostname = "secondary02"
s2.vm.network "private_network", ip: "192.168.2.15"
s2.vm.network "forwarded_port", guest: 8201, host: 1243
s2.vm.provision :shell, :path => "scripts/install_vault_1.sh", env: { "CONSUL_NODE" => "secondary02",
       "VAULT_ADDR" => "http://192.168.2.15:8200"}
end

config.vm.define "dr" do |s3|
  s3.vm.hostname = "dr"
  s3.vm.network "private_network", ip: "192.168.2.121"
  s3.vm.network "forwarded_port", guest: 8500, host: 1244
  s3.vm.network "forwarded_port", guest: 8200, host: 1245
  s3.vm.network "forwarded_port", guest: 8201, host: 1246
  s3.vm.provision :shell, :path => "scripts/install_vault_2.sh", env: { "CONSUL_NODE" => "dr",
         "VAULT_ADDR" => "http://192.168.2.121:8200"}
  end

end




