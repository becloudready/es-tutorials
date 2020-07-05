sudo dnf install java-11-openjdk-devel -y
sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
cat <<EOF>> /etc/yum.repos.d/elasticsearch.repo
[elasticsearch-7.x]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF
sudo dnf install elasticsearch -y
sudo systemctl enable elasticsearch.service --now
curl -X GET "localhost:9200/"
# Edit the es config file to make it accessible 

#/etc/elasticsearch/elasticsearch.yml
# network.host: 0
sed -i 's/#network.host: 192.168.0.1/network.host: 0/' /etc/elasticsearch/elasticsearch.yml
sed -i 's/#discovery.seed_hosts: \[\"host1\", \"host2\"\]/discovery.seed_hosts: \[\"127.0.0.1\"]/' /etc/elasticsearch/elasticsearch.yml
systemctl restart elasticsearch