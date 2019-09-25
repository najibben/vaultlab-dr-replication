storage "consul" {
  address = "127.0.0.1:8500"
  path    = "vault"
}

listener "tcp" {
  #address          = "127.0.0.1:8200"
  address          = "192.168.2.14:8200"
  cluster_address  = "192.168.2.14:8201"
  tls_disable      = "true"
  
}



api_addr = "http://192.168.2.14:8200"
cluster_addr = "https://192.168.2.14:8201"
plugin_directory = "/vagrant/plugins/"
disable_performance_standby = true
ui = true