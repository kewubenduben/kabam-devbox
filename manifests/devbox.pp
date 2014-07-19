Exec {
  path => [
    '/usr/local/bin',
    '/opt/local/bin',
    '/usr/bin',
    '/usr/sbin',
    '/bin',
    '/sbin'],
  logoutput => true,
}

include base_system
include base_monimus
include secure_system

sruser{static: user => static, }

monimus_user{'sandy': user => "sandy",}
monimus_user{'tbudiman': user => "tbudiman",}

base_redis{'base-redis':}
sr_redis{'master_redis':}

include base-mongo
replicated_single_mongo{'replica':}

elasticsearch{'main_es': version => "1.2.2",}
elasticsearch_plugin{'elasticsearch-mapper-attachments':
  plugin_path => 'elasticsearch/elasticsearch-mapper-attachments/2.0.0.RC1',
  require => Elasticsearch['main_es'],
}
elasticsearch_plugin{'elasticsearch-river-mongodb':
  plugin_path => 'com.github.richardwilly98.elasticsearch/elasticsearch-river-mongodb/2.0.0',
  require => Elasticsearch['main_es'],
}
elasticsearch_plugin{'elasticsearch-lang-javascript':
  plugin_path => 'elasticsearch/elasticsearch-lang-javascript/2.0.0.RC1',
  require => Elasticsearch['main_es'],
}
elasticsearch_plugin{'elasticsearch-head':
  plugin_path => 'mobz/elasticsearch-head',
  require => Elasticsearch['main_es'],
}

exec { "es_registration":
  command  => "curl -XPUT http://localhost:9200/_river",
  logoutput => true,
  timeout => 1800,
  require => [Elasticsearch['main_es'], Elasticsearch_plugin['elasticsearch-river-mongodb']],
}

include nodejs
nodeapp{'showdme': app_name => "showdme", require => Class['nodejs'],}
nodejs_module{'pm2': module => 'pm2',require => [Class['nodejs']],}
nodejs_module{'grunt-cli': module => 'grunt-cli',require => [Class['nodejs']],}
#nodejs_module{'bower': module => 'bower',require => [Class['nodejs']],}
nodejs_module{'istanbul': module => 'istanbul',require => [Class['nodejs']],}
nodejs_module{'node-dev': module => 'node-dev',require => [Class['nodejs']],}
nodejs_module{'node-inspector': module => 'node-inspector',require => [Class['nodejs']],}
nodejs_module{'jshint': module => 'jshint',require => [Class['nodejs']],}
nodejs_module{'yo': module => 'yo',require => [Class['nodejs']],}
nodejs_module{'bower': module => 'bower@1.3.2',require => [Class['nodejs']],}

include ejabberd

class { 'ssh::server':
  storeconfigs_enabled => false,
  options => {
    'AllowTcpForwarding'     => 'yes',
    'PasswordAuthentication' => 'no',
    'PermitRootLogin'        => 'no',
    'Port'                   => [22, 22202],
  },
}


########################### FIREWALL ###########################
include firewall
Firewall {
    notify  => Exec["persist-firewall"],
    require => Exec["purge default firewall"],
}
$ipv4_file = $operatingsystem ? {
  /(debian|Ubuntu)/  => '/etc/iptables/rules.v4',
  /(RedHat|CentOS)/ => '/etc/sysconfig/iptables',
}

exec { "purge default firewall":
  command => "/sbin/iptables -F && /sbin/iptables-save > $ipv4_file && /sbin/service iptables restart",
  onlyif  => "/usr/bin/test `/bin/grep \"Firewall configuration written by\" $ipv4_file | /usr/bin/wc -l` -gt 0",
  user    => 'root',
}

/* Make the firewall persistent */
exec { "persist-firewall":
  command     => "/bin/echo \"# This file is managed by puppet. Do not modify manually.\" > $ipv4_file && /sbin/iptables-save >> $ipv4_file", 
  refreshonly => true,
  user        => 'root',
}

/* purge anything not managed by puppet */
resources { 'firewall':
  purge => true,
}

# firewall { "001 accept all icmp requests":
#   proto => 'icmp',
#   jump  => 'accept',
# }

firewall { '001 INPUT allow loopback':
  iniface => 'lo',
  chain  => 'INPUT',
  action   => 'accept',
}

firewall { '001 OUTPUT allow loopback':
  outiface => 'lo',
  chain  => 'OUTPUT',
  action   => 'accept',
}

firewall { '003 INPUT allow related and established':
  chain => 'INPUT',
  state => ['RELATED', 'ESTABLISHED'],
  action  => 'accept',
  proto => 'all'
}

firewall { '003 OUTPUT allow related and established':
  chain => 'OUTPUT',
  state => ['RELATED', 'ESTABLISHED'],
  action  => 'accept',
  proto => 'all',
}

firewall {'011 ssh for local_network_1':
  source => '10.0.0.0/8',
  proto  => 'all',
  action  => 'accept'
}

firewall {'011 ssh for local_network_2':
  source => '192.168.0.0/16',
  proto  => 'all',
  action => 'accept'
}

firewall {'996 INPUT Log': 
  chain => 'INPUT',
  log_level => 4,
  log_prefix => 'DROP_AFW_INPUT',
  jump => 'LOG'
}

firewall {'997 OUTPUT Log': 
  chain => 'OUTPUT',
  log_level => 4,
  log_prefix => 'DROP_AFW_INPUT',
  jump => 'LOG'
}

firewall { "998 deny all other requests":
  action  => 'drop',
  proto  => 'all',
}

firewall { "999 deny all other requests":
  chain  => 'FORWARD',
  action  => 'drop',
  proto  => 'all',
}

firewallchain { 'root:filter:IPv4':
  ensure  => present,
}

firewall {'1100 root user':  
  chain => 'OUTPUT',
  state => ['NEW'],
  uid => '0',
  jump => 'root'
}

###### MONGO ######
firewall {'100 mongodb for local_network_2':
  source => '192.168.0.0/16',
  dport => '27017',
  proto => 'tcp',
  action => 'accept',
}

firewallchain { 'mongodb:filter:IPv4':
  ensure  => present,
}

firewall {'1100 mongodb user':  
  chain => 'OUTPUT',
  state => ['NEW'],
  uid => '106',
  jump => 'mongodb'
}
###### MONGO ######
########################### FIREWALL ###########################
