
The deployment consisted of two services with dockers, one for nodejs and one for react. Two load balancers
were deployed to send the requests to the services. The dns names for the load balancers were used for routing
the requests.

For simplicity, one VPC was used without any subnetting. Both services are publicly accesible.

The final url for the service:
http://reactlb-2088109173.us-east-1.elb.amazonaws.com


The building and testing process was run on EC2

sudo su
cd /
mkdir -p usr/src/app
chown -R ubuntu /usr/src/app

download a zip from github, extract and copy files.

Install docker
---------------
apt-get update
apt-get install ca-certificates curl gnupg lsb-release

Add Docker’s official GPG key:
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

set up the repository
 echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

apt-get install docker-compose-plugin
apt-get install docker-compose

verify
sudo docker run hello-world


Install npm
-----------
apt install npm
a screen comes up showing services using the old libraries
go ahead and restart them

for testing purposes
open ports 8080 and 3000 on the ec2


Build the docker images
-----------------------
cd /usr/src/app/backend
docker build -t node-image .

cd /usr/src/app/frontend
docker build -t dock-image .

test on ec2
-----------
docker-compose up -d
docker-compose down

note: for the communication to work, had to change the localhost settings in config files to the dns name for ec2.


register the images on AWS
--------------------------
services -> Elastic Container registry

create repository
visibility: private
name: docker-repo

uri of the repository
880651758906.dkr.ecr.us-east-1.amazonaws.com/docker-repo


create repository
visibility: private
name: noderepo

uri of the repository
880651758906.dkr.ecr.us-east-1.amazonaws.com/noderepo


login
-----
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 880651758906.dkr.ecr.us-east-1.amazonaws.com

tag and push the images
-----------------------
docker tag dock-image 880651758906.dkr.ecr.us-east-1.amazonaws.com/docker-repo
docker push 880651758906.dkr.ecr.us-east-1.amazonaws.com/docker-repo

docker tag node-image 880651758906.dkr.ecr.us-east-1.amazonaws.com/noderepo
docker push 880651758906.dkr.ecr.us-east-1.amazonaws.com/noderepo

find the docker image uri
-------------------------
in ECR
click on the repository name
it will show the docker images
copy uri for the latest image

880651758906.dkr.ecr.us-east-1.amazonaws.com/docker-repo:latest
880651758906.dkr.ecr.us-east-1.amazonaws.com/noderepo:latest

create a role for running containers
------------------------------------
in IAM

new role
aws service
use cases for other aws services
select elastic container service
elastic container service task
role name: ecs_role

gave following permissions:
AmazonEC2ContainerRegistryFullAccess	
AmazonECS_FullAccess
AmazonECSTaskExecutionRolePolicy


security groups
---------------
node-sg security group opens the ports 80 and 8080.
task1:-1524 security group opens the ports 80 and 3000.


setup cluster
-------------
in ECS

create cluster
cluster template: networking only
name: ecs-clust
do not create vpc

create tasks
------------
create a new task definition
launch type compatibility: fargate
task definition name: task1
task role: none
network mode: awsvpc
operating system family: linux
Task execution IAM role - select ecs_role
task memory and task cpu: pick the lowest levels
container definitions: 
  add container
  container name: cont1
  image: 880651758906.dkr.ecr.us-east-1.amazonaws.com/docker-repo:latest
  port mapping: 3000
  add
skip the mesh and other settings
create


create a new task definition
launch type compatibility: fargate
task definition name: nodetask
task role: none
network mode: awsvpc
operating system family: linux
Task execution IAM role - select ecs_role
task memory and task cpu: pick the lowest levels
container definitions: 
  add container
  container name: node-cont
  image: 880651758906.dkr.ecr.us-east-1.amazonaws.com/noderepo:latest
  port mapping: 8080
  add
skip the mesh and other settings
create


create services
----------------
click the cluster name
in the services tab
create service

launch type: fargate
operating system family: linux
task definition: select task1
revision: latest
platform version: latest  (this is the fargate version)
cluster: ecs-clust
service name: reactdock
service type: replica is the only option
number of tasks: 1
minimum healthy percent: 0   (to force redeployment for cicd, to be changed after testing)
maximum percent: 200
deployment circuit breaker: disabled
deployment type: rolling update
enable ecs managed tags is enabled - leave it that way
propogate tags from: do not propagate
cluster vpc: select the one with 172..
subnets: us east 1 a
security group: edit
  select existing security group
  task1:-1524
auto assign public ip: enabled
health check grace period:   100000 (seconds, only turns on after selecting a load balancer type)
load balancer type: application
service IAm role - created automatically with AWSServiceRoleForECS permission
since we dont have an existing load balancer, create one using the link and come back
choose reactlb
container to load balance
  shows cont1:3000:3000
  click the button add to load balancer
    production listener port: 80:http
    target group name: reactgp
service auto scaling: do not adjust the service's desirec count is selected
create service
view service
tasks will show here. we have a running task already

load balancer
click create under application load balancer
name: reactlb
internet facing
ip address type: ipv4
vpc: it lists the 172.. one
availability zones
us-east-1a  (subnet automatically picked up)
us-east-1b  (subnet automatically picked up)
security group: select task1:-1524   (take out the default one)
listener http:80
forward to:  need to create the target group
  create target group and come back
  select reactgp 
create load balancer

target group
type: ip addresses
target group name: reactgp
http:80
address type: ipv4
vpc: it lists the 172.. one
protocol version: http1
register targets
  network: it lists the 172.. one
  ipv4 addresses: it shows 172.31.0.  without the last part. leave as is
  ports: 80
ip targets will be added dynamically when they are created, so no selection here
create target group


create one more service for the node backend

launch type: fargate
operating system family: linux
task definition: select nodetask
revision: latest
platform version: latest  (this is the fargate version)
cluster: ecs-clust
service name: nodedock
service type: replica is the only option
number of tasks: 1
minimum healthy percent: 0   (to force redeployment for cicd, to be changed after testing)
maximum percent: 200
deployment circuit breaker: disabled
deployment type: rolling update
enable ecs managed tags is enabled - leave it that way
propogate tags from: do not propagate
cluster vpc: select the one with 172..
subnets: us east 1 a
security group: edit
  select create new security group
  node-sg
  add a custom tcp rule for 8080
  save
auto assign public ip: enabled
health check grace period:   100000 (seconds, only turns on after selecting a load balancer type)
load balancer type: application
service IAm role - created automatically with AWSServiceRoleForECS permission
since we dont have an existing load balancer, create one using the link and come back
choose nodelb
container to load balance
  shows node-cont:8080:8080
  click the button add to load balancer
    production listener port: 80:http
    target group name: nodegp
service auto scaling: do not adjust the service's desirec count is selected
create service
view service
tasks will show here. we have a running task already


load balancer
click create under application load balancer
name: nodelb
internet facing
ip address type: ipv4
vpc: it lists the 172.. one
availability zones
us-east-1a  (subnet automatically picked up)
us-east-1b  (subnet automatically picked up)
security group: select node-sg   (take out the default one)
listener http:80
forward to:  need to create the target group
  create target group and come back
  select nodegp 
create load balancer

target group
type: ip addresses
target group name: nodegp
http:80
address type: ipv4
vpc: it lists the 172.. one
protocol version: http1
register targets
  network: it lists the 172.. one
  ipv4 addresses: it shows 172.31.0.  without the last part. leave as is
  ports: 80
ip targets will be added dynamically when they are created, so no selection here
create target group


get the dns names for the load balancers

reactlb-2088109173.us-east-1.elb.amazonaws.com
nodelb-2016202280.us-east-1.elb.amazonaws.com


change the two config files:

backend/config.js 
    CORS_ORIGIN: 'http://reactlb-2088109173.us-east-1.elb.amazonaws.com'

frontend/src/config.js
export const API_URL = 'http://nodelb-2016202280.us-east-1.elb.amazonaws.com'


rebuild and redploy the images
in the cluster
go under the tasks tab
stop the two running tasks
the services will autimatically provision new tasks.

once the tasks are running, try the following url:

http://reactlb-2088109173.us-east-1.elb.amazonaws.com


