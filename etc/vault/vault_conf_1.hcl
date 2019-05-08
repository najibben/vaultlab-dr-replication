

listener "tcp" {
  #address          = "127.0.0.1:8200"
  address          = "192.168.2.13:8200"
  cluster_address  = "192.168.2.13:8201"
  tls_disable      = "true"
 
}

storage "consul" {
  address = "127.0.0.1:8500"
  path    = "vault"
}


api_addr = "http://192.168.2.13:8200"
cluster_addr = "https://192.168.2.13:8201"
plugin_directory = "/vagrant/plugins/"
ui = true