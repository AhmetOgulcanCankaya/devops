### Identify the tools and learn how to use them.
*There is no such thing as The Best Tools.*

https://digital.ai/periodic-table-of-devops-tools - Check It!!

Build Automation and Continuous Integration

* AT
  * Java - ant,maven,gradle
  * JS - npm,gulp
  * Unix based systems - Make
  * Building virtual machine images and containers - Packer
* CI
  * Jenkins - open source fork of hudson | builds,tests,deploys widely used | Java servlet based
  * TravisCI - open source | built around Github integration | executes builds in clean VMs
  * Bamboo - enterprised by Atlassian

### Configuration Management

* Ansible - open source | declarative configuration,tool determines what is necessery for the declaration | YAML configuration files | No control server needed,but Ansible tower is available but not required | Does not need agents, just python and ssh
* Puppet - declarative configuration | manage state through a UI | Custom modules use Puppet DSL | Uses a control server and has agents on clients
* Chef - Procedural configuration, write scripts or steps to make the machine come to the desired state | Agent/server based | You have to learn Domain Specific Language
* Salt - Declarative configuration | Agent/server (minions/master) - but can support agentless | Uses YAML | Has support for event-driven automation

### Virtualization and Containerization

* VT
  * VMs has an entire OS built into them.
  * VMWare ESX | Microsoft Hyper-V | Citrix XenServer
* CT
  * Only simulates the OS in a very thin, light way
  * Docker 
They are portable.

### Monitoring

{ELK,Beats-ElasticSearch-LogStash-Kibana}

Infrastructure Monitoring
CPU,RAM monitoring

APM Application Performance Monitoring
Response times,logs

IMT
Sensoo - replacement of nagios | Server/Agent arch | Agents push data to an AMQP broker
NewRelic - SaaS solution | SaaS + Agent | Good for APM too
APMT
AppDynamics - Presents data in a dashboard | Server/agent | Code level diagnostics

* Orchestration Tools
  * _Automatically scale up and down at event or action_
  * Docker-swarm - Dockers native OrcTool | for Docker containers
  * Kubernetes - open source | uses a orc. server | manages apps across multiple hosts
  * Zookeeper - open source by Apache Foundation | can work alogside Kubernetes
  * Terraform - combines orc. with IaC | works well with Ansible | Integrates with Kubernetes













