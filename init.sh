HOSTSFILE=/etc/hosts
grep -q "127.0.0.1 monimus.com" "$HOSTSFILE" || echo "127.0.0.1 monimus.com" >> "$HOSTSFILE"

# wget http://apt.puppetlabs.com/puppetlabs-release-trusty.deb
# dpkg -i puppetlabs-release-trusty.deb

apt-get update
apt-get install -y puppet
