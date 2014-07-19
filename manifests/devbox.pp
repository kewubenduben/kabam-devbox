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
  command   => "curl -XPUT http://localhost:9200/_river",
  logoutput => true,
  timeout     => 1800,
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
    'AllowTcpForwarding' => 'yes',
    'PasswordAuthentication' => 'no',
    'PermitRootLogin'        => 'no',
    'Port'                   => [22, 22202],
  },
}

resources { "firewall":
  purge => true
}
include firewall
firewall { '001 accept all':
  proto => 'all',
  action => 'accept'
}
firewall { '002 accept related established rules':
  proto => 'all',
  state => ['RELATED', 'ESTABLISHED'],
}

firewall {'011 ssh for local_network_1':
  source => '10.0.0.0/8',
  proto   => 'all',
  action  => 'accept'
}
firewall {'011 ssh for local_network_2':
  source => '192.168.0.0/16',
  proto   => 'all',
  action => 'accept'
}

firewall { '999 drop all':
  proto   => 'all',
  action  => 'drop',
  before  => undef,
}
firewall {'998 INPUT Log': 
  chain => 'INPUT',
  log_level => 4,
  log_prefix => 'DROP_AFW_INPUT',
  jump => 'LOG'
}
firewall {'998 OUTPUT Log': 
  chain => 'OUTPUT',
  log_level => 4,
  log_prefix => 'DROP_AFW_INPUT',
  jump => 'LOG'
}
