name             'TheCheftacularCookbook'
maintainer       'SocialCentiv'
maintainer_email 'louis@socialcentiv.com'
license          'All Rights Reserved'
description      'Installs and configures various environments'
version          '1.0.1'

depends 'ohai'
depends 'build-essential'
depends 'nginx'
depends 'rvm'
depends 'redisio'
depends 'sidekiq'
depends 'haproxy'
depends 'apt'
depends 'rabbitmq'
depends 'jenkins'
#depends 'jenkins-chef-dsl'
depends 'postfix'
depends 'nodejs'
depends 'sensu'
depends 'uchiwa'
depends 'graphite'
depends 'grafana', '< 2.0.0'
depends 'java'
depends 'elasticsearch'
depends 'sudo'
depends 'logstash'
depends 'graylog2'
depends 'database', '< 3.0.0'
depends 'mongodb'
depends 'graylog'
depends 'htpasswd'
depends 'backup'
depends 'rackspacecloud'
depends 'simple_iptables'
#WP cookbooks
depends 'mysql', '< 6.0.0'
depends 'mysql-chef_gem', '< 1.0.0'
depends 'apache2', '< 3.0.0'
depends 'wordpress'

#BI Cookbooks
depends 'pentaho'
depends 'tomcat'

#Rails cookbooks
depends 'application_ruby'

#depends 'rails_application'

supports 'amazon'
supports 'debian'
supports 'ubuntu'
