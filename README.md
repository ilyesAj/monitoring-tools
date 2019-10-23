# monitoring-tools
A Monitoring Dashboard by Prometheus + Grafana with docker
grafana+promethues

# Presentation :
# Architecture: 
## General architecture 
![image](https://img.linuxfr.org/img/68747470733a2f2f70726f6d6574686575732e696f2f6173736574732f6172636869746563747572652e737667/architecture.svg)
## Specific architecture



![9b115d69f87870c67f1c8ae23e89948f.png](https://github.com/ilyesAj/monitoring-tools/blob/master/_resources/59d77dc9c3284c9cb563ff2629d331ce.png)

TODO adding node-exporter
# Deploying Services

## Prerequisites :

- The machine have to be connected to internet
- Docker
- docker-Compose
- Firewalld
- OS : Centos 7

## Running services
````sh
git clone https://github.com/ilyesAj/monitoring-tools.git
cd monitoring-tools
sudo docker-compose up -d
# verifying services
sudo docker ps
# monitoring services
sudo docker logs -f [name_service]
````
##  configuring Services 
### Default config 
Prometheus will now be reachable :
- locally on http://localhost:9020/ 
- distantly on a virtual host prom.local.com

grafana will now be reachable only remotly on graph.local.com
### verifying services 
try `netstat -lnpt ` to verify if our services are listening 
normally we have 3 open ports :

![5efbe42747f87a1afbfa74b319d5e5bf.png](https://github.com/ilyesAj/monitoring-tools/blob/master/_resources/7b3c13b3d7a1439297ddfa88d782715d.png)

- 80/443 : For distant access managed by Nginx
- 9020 : For accessing Prometheus locally

### Troubleshoot 
if you can't access to the services remotly , you have to verify your firewall 
````sh
sudo firewall-cmd --list-services
#expected : http https 
# granting access on the firewall
sudo firewall-cmd --add-service=https --permanent
sudo firewall-cmd --add-service=http --permanent
# expected: success
sudo firewall-cmd --reload
# expected: success
# verifying if the virtual host is working 
curl -v --resolve graph.local.com:80:8.8.2.8 graph.local.com/graph
# 8.8.2.8 is the IP Address of your remote machine
# syntax : curl -v --resolve Domain:port:IP URL
!-- if you try curl IP_Machine (without DNS Resolve) it won`t work , it will be blocked  by Nginx --!
````
If your working on AWS or GCP you have to verify your INGRESS rules on firewall , you have to allow HTTP/HTTPS ports 
# Creating Data for monitoring 
## Implementing node-exporter without docker 
node-exporter is Prometheus exporter for hardware and OS metrics

* node-exporter is available on a docker container but not recommanded .If you're interrested in implementing it with docker , uncomment the node-exporter section 

````sh
# For centos RHEL
sudo curl -Lo /etc/yum.repos.d/_copr_ibotty-prometheus-exporters.repo https://copr.fedorainfracloud.org/coprs/ibotty/prometheus-exporters/repo/epel-7/ibotty-prometheus-exporters-epel-7.repo
sudo yum install node_exporter -y
sudo systemctl enable --now node_exporter
# note that if you implement node-exporter without docker , you will face a problem with networking container => host 
# Possible solution (not tested )  :https://stackoverflow.com/questions/24319662/from-inside-of-a-docker-container-how-do-i-connect-to-the-localhost-of-the-mach  
# for other Linux systems refer to : https://devopscube.com/monitor-linux-servers-prometheus-node-exporter/
````
If node-exporter is installed correctly you will see metrics using Curl command `curl localhost:9100/metrics`

## Implementing node-exporter with docker 
in docker compose uncomment node-exporter service 

## Attaching node-exporter to Prometheus

for inter-communication beween containers we can access from a container to another via : `name_container:exposed_port` 
in our case we exposed node-exporter to 9100 with a name kernel-monitor and then we attached the two components together with prometheus config file : 
````yml
--- 
scrape_configs: 
  - 
    job_name: node_exporter_metrics
    scrape_interval: 5s
    static_configs: 
      - 
        targets: 
          - "kernel_monitor:9100"
````
we forced prometheus to work with this configuration by creating a ` link between /config/prometheus.yml and /etc/prometherus/prometheus.yml `
refer to docker compose -> prometheus service -> volumes 

## Attaching Prometheus to grafana

# references 
- https://medium.com/htc-research-engineering-blog/build-a-monitoring-dashboard-by-prometheus-grafana-741a7d949ec2
- https://journaldunadminlinux.fr/tutoriel-decouverte-de-prometheus-et-grafana/
- https://prometheus.io/docs/visualization/grafana/
- https://hub.docker.com/r/prom/prometheus
- https://kjanshair.github.io/2018/02/20/prometheus-monitoring/
- https://prometheus.io/docs/guides/node-exporter/
- https://github.com/stefanprodan/dockprom
- https://javaetmoi.com/2019/03/dashboard-grafana-docker/
- https://grafana.com/docs/http_api/dashboard/
- https://travis-ci.org/vegasbrianc/prometheus
