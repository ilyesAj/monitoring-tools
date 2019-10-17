# monitoring-tools
A Monitoring Dashboard by Prometheus + Grafana with docker
grafana+promethues

# Presentation :
# Architecture: 
## General architecture 
![image](https://img.linuxfr.org/img/68747470733a2f2f70726f6d6574686575732e696f2f6173736574732f6172636869746563747572652e737667/architecture.svg)
## Specific architecture



![9b115d69f87870c67f1c8ae23e89948f.png](https://github.com/ilyesAj/monitoring-tools/blob/master/_resources/59d77dc9c3284c9cb563ff2629d331ce.png)



# Prerequisites :

- The machine have to be connected to internet
- Docker
- docker-Compose
- Firewalld
- OS : Centos 7

# Deploying Services
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
##  config 
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
