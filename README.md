# Inception-of-Things

This project is focused on setting up Kubernetes environments using K3s and K3d with Vagrant for virtualization. The project is divided into three main parts, with an optional bonus part. Below are the instructions and configurations required for each part.

## Prerequisites

Before starting, ensure you have the following installed on your system:

- [Vagrant](https://www.vagrantup.com/downloads) (version 2 or later)
- [VirtualBox](https://www.virtualbox.org/)
- [Docker](https://www.docker.com/get-started) (for Part 3)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) (for managing Kubernetes clusters)
- Internet connection to download the required dependencies

## What You Should Know Before Starting

- [Docker Swarm](https://medium.com/@aaloktrivedi/automating-scaling-application-infrastructure-with-docker-swarm-and-aws-197e7cb326f9)
- [Using Kubernetes to deploy a 3-tier containerized application infrastructure](https://medium.com/@aaloktrivedi/using-kubernetes-to-deploy-a-3-tier-containerized-application-infrastructure-9fbbbbc85ff6#id_token=eyJhbGciOiJSUzI1NiIsImtpZCI6ImQyZDQ0NGNmOGM1ZTNhZTgzODZkNjZhMTNhMzE2OTc2YWEzNjk5OTEiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiIyMTYyOTYwMzU4MzQtazFrNnFlMDYwczJ0cDJhMmphbTRsamRjbXMwMHN0dGcuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJhdWQiOiIyMTYyOTYwMzU4MzQtazFrNnFlMDYwczJ0cDJhMmphbTRsamRjbXMwMHN0dGcuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMTIwODAwODU4ODEwMTQyNzc0MzUiLCJlbWFpbCI6Im91YmFrcmltbzcwQGdtYWlsLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJuYmYiOjE3MjQxMzg1MTYsIm5hbWUiOiJoaWNoYW0gYmVsaG91Y2luIiwicGljdHVyZSI6Imh0dHBzOi8vbGgzLmdvb2dsZXVzZXJjb250ZW50LmNvbS9hL0FDZzhvY0lfUmp6RlF6UTkxUTRsVHJXei1oUGVKLThRTnpvcU9mQjRVWHZBSmxPOGxrZVE3VEE9czk2LWMiLCJnaXZlbl9uYW1lIjoiaGljaGFtIiwiZmFtaWx5X25hbWUiOiJiZWxob3VjaW4iLCJpYXQiOjE3MjQxMzg4MTYsImV4cCI6MTcyNDE0MjQxNiwianRpIjoiY2UxMDMwNGVhYWZhZDE5NTkyZDJlNTM2YmZhMDQwZTY4ODRlZmM1MiJ9.Yk8hcood3o6ZOysRHKnwD4XW3uTT7Kcx1-yFqlZbdyFVOk-R1n56_EZSMTdVqSfOcI4dOgQVTYYDXuHb9S_JaUhHGIdEoX0mU175KCvOG-9-n8_KQFjblAppvLRLjeXNmICPu6Y8UpzYihdOfwYFwlObF1rsE44m-191HvDMkLhqi6Puae-RG0ed3oJtT6Fr4U6zxttMuCQvdC6pEBO43MJ3jGLjdBqn2FuoRRgb6mkrqRLXDeVVchjiaU9BIK4ZFCO_4iZkvKKLIjaBRJCdvmsftueYwqh-SBzHzYuhJB2-GSwahExm_MGL10Z3Hf8anmXbkJOOslDa2O5kOrip-w)

### How Does Vagrant Work?

Vagrant works by automating the creation and management of virtual machines (VMs) in a consistent and reproducible manner. It uses a simple configuration file called a `Vagrantfile` to define the VM settings, such as the base operating system, network configurations, and provisioning scripts. With Vagrant, you can easily spin up, configure, and destroy VMs with a few commands, making it a powerful tool for development environments, testing, and deployment.

## How does Kubernetes work?

Kubernetes is an open-source container orchestration platform that automates the deployment, scaling, and management of containerized applications. It provides a platform for running and managing containerized workloads across a cluster of machines. Kubernetes abstracts the underlying infrastructure and provides a consistent API for deploying, scaling, and managing applications, making it easier to build, deploy, and scale applications in a cloud-native environment.

## Directory Structure

```
└── 📁Inception-of-Things
    └── 📁p1
        └── 📁confs
            └── server.yml
        └── 📁scripts
            └── script.sh
        └── Vagrantfile
    └── 📁p2
        └── 📁confs
            server.yml
        └── 📁scripts
            └── server-set-up.sh
            └── script.sh
        └── Vagrantfile
    └── 📁p3
        └── 📁confs
            server.yml
        └── 📁scripts
            └── server-set-up.sh
            └── script.sh
        └── Vagrantfile
    └── 📁bonus
         └── 📁confs
               server.yml
         └── 📁scripts
               └── server-set-up.sh
               └── script.sh
         └── Vagrantfile
    └── .gitignore
    └── README.md
```

## Mandatory Parts

### Part 1: K3s and Vagrant

#### Overview

In this part, you'll set up two virtual machines using Vagrant, with minimal resources. The first machine will act as the K3s server (controller mode), and the second will act as an agent (worker node). You'll use `kubectl` to manage the cluster.

#### Steps

1. **Vagrant Configuration**:

   - Create a Vagrant configuration file that defines two VMs: `hbel_houS` and `hbel_houSW`.
   - Assign specific IPs (`192.168.56.110` and `192.168.56.111` respectively).
   - Enable passwordless SSH access between the VMs.

2. **Install K3s**:

   - On `hbel_houS`, install K3s in server mode with a custom configuration.
   - On `hbel_houSW`, install K3s in agent mode and join it to the K3s cluster managed by `hbel_houS`.

3. **Resource Allocation**:

   - Allocate 1 CPU and 1024 MB of RAM to each VM.

4. **Use `kubectl`**:
   - Use `kubectl` to manage the cluster, deploy resources, and verify the setup.

#### Vagrantfile Example

```ruby
# Vagrant configuration for Part 1
Vagrant.configure("2") do |config|
  # Server VM
  config.vm.define "hbel_houS" do |hbel_houS|
    hbel_houS.vm.box = "ubuntu/focal64"
    hbel_houS.vm.network :private_network, ip: "192.168.56.110"
    hbel_houS.vm.hostname = "hbel-houS"
    hbel_houS.vm.synced_folder "./shared", "/vagrant_shared"
    hbel_houS.vm.provision "shell", inline: <<-SHELL
      sudo apt-get update
      export IPV4=192.168.56.110
      curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable servicelb --flannel-backend=wireguard-native --disable traefik --node-ip $IPV4 --cluster-cidr 10.42.0.0/16 --service-cidr 10.43.0.0/16" sh -
      cp /var/lib/rancher/k3s/server/node-token /vagrant_shared/
      sudo chmod 644 /etc/rancher/k3s/k3s.yaml
    SHELL
    hbel_houS.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = "1"
    end
  end

  # Agent VM
  config.vm.define "hbel_houSW" do |hbel_houSW|
    hbel_houSW.vm.box = "ubuntu/focal64"
    hbel_houSW.vm.network :private_network, ip: "192.168.56.111"
    hbel_houSW.vm.synced_folder "./shared", "/vagrant_shared"
    hbel_houSW.vm.hostname = "hbel-houSW"
    hbel_houSW.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = "1"
    end
  end
end
```

### Part 2: K3s and Three Simple Applications

#### Overview

This part involves setting up a single VM with K3s in server mode and deploying three simple web applications. Each application will be accessible via different hostnames, with one running multiple replicas.

#### Steps

1. **Set Up K3s Server**:

   - Use Vagrant to create a VM and install K3s in server mode.

2. **Deploy Applications**:
   - Deploy three web applications to the K3s cluster.
   - Ensure that each application is accessible via a different hostname (using services and ingress).
   - Configure one of the applications to run multiple replicas.

Here's a README file that explains each line of the provided Kubernetes Ingress YAML configuration:

# File Content

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
spec:
  rules:
    - host: app1.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: app1-service
                port:
                  number: 80
    - host: app2.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: app2-service
                port:
                  number: 80
    # Default backend for unspecified hosts
    - http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: app3-service
                port:
                  number: 80
```

## Explanation

##### `apiVersion: networking.k8s.io/v1`

This specifies the version of the Kubernetes API that you are using. The `networking.k8s.io/v1` API version is for networking-related resources like Ingress.

##### `kind: Ingress`

This defines the type of Kubernetes object. In this case, it is an `Ingress`, which manages external access to services within a Kubernetes cluster, typically via HTTP.

##### `metadata:`

The `metadata` section contains data that helps uniquely identify the object within the Kubernetes cluster.

##### `name: app-ingress`

The `name` field assigns a unique name to this Ingress resource. In this case, it's called `app-ingress`.

##### `spec:`

The `spec` section describes the desired state of the Ingress resource, including the rules for how traffic should be routed to the services within the cluster.

##### `rules:`

The `rules` section defines how incoming requests are routed to different services within the cluster based on the hostname and path.

##### `- host: app1.com`

This rule applies to HTTP requests with the hostname `app1.com`.

##### `http:`

This specifies that the rule applies to HTTP traffic.

##### `paths:`

Defines the URL paths that should be matched by this rule.

##### `- path: /`

This rule matches any path that starts with `/`. The `/` path is the root path, meaning it will match all incoming requests for the specified host.

##### `pathType: Prefix`

The `pathType` specifies how the path is matched. `Prefix` means that the URL path must start with the specified value (in this case, `/`).

##### `backend:`

The `backend` section defines the service within the Kubernetes cluster to which the traffic should be forwarded.

##### `service:`

This specifies the Kubernetes service that will handle the traffic.

##### `name: app1-service`

The `name` field specifies the name of the service that the traffic should be routed to. In this case, traffic for `app1.com` will be routed to `app1-service`.

##### `port:`

Specifies the port on which the service is listening.

##### `number: 80`

This defines the port number on which the service is exposed. The traffic for `app1.com` will be forwarded to port `80` on `app1-service`.

##### `- host: app2.com`

This rule applies to HTTP requests with the hostname `app2.com` and follows the same structure as the rule for `app1.com`, routing traffic to `app2-service` on port `80`.

##### `# Default backend for unspecified hosts`

This comment indicates that the next rule is a fallback or default rule that will handle any requests that don't match the specified hosts (`app1.com` or `app2.com`).

##### `- http:`

Specifies that the rule applies to HTTP traffic.

##### `paths:`

Defines the URL paths that should be matched by this rule.

##### `- path: /`

Matches any path that starts with `/`.

##### `pathType: Prefix`

Indicates that the URL path must start with the specified value (in this case, `/`).

##### `backend:`

Defines the service within the Kubernetes cluster to which the traffic should be forwarded.

##### `service:`

Specifies the Kubernetes service that will handle the traffic.

##### `name: app3-service`

Traffic that doesn't match the `app1.com` or `app2.com` hosts will be routed to `app3-service`.

##### `port:`

Specifies the port on which the service is listening.

##### `number: 80`

Defines the port number on which the service is exposed. The traffic will be forwarded to port `80` on `app3-service`.

### Part 3: K3d and Argo CD

#### Overview

In this part, you'll install K3d (a lightweight Kubernetes distribution for Docker) on a VM, set up Argo CD, and configure continuous integration to deploy an application from a GitHub repository.

## k3s vs k3d: What is the difference?

Both k3s and k3d are lightweight tools that allow you to deploy and run Kubernetes on your local machine with less operational effort compared to deploying k8s.

k3d is a wrapper of k3s but one of the apparent differences is that k3s deploys a virtual machine-based Kubernetes cluster while k3d deploys Docker-based k3s Kubernetes clusters.

Also, k3s does not provide prompt support for multiple clusters. To create multiple k3s clusters, you need to manually configure additional virtual machines or nodes. k3d on the other is specifically created to set up highly available, multiple k3s clusters without demanding more resources.

By leveraging Docker containers, k3d offers a more scalable version of k3s which might make it preferable to the standard k3s.

Another difference is in their use cases. Even though it is lightweight, k3s is designed to be easily deployable in production environments which makes it one of the most favorite options for simulating Kubernetes for production-level workloads in local environments. k3d, however, is more suitable for use in even smaller environments like Raspberry Pi, IoT, and Edge devices.

k3d appears to be a more flexible and improved version of k3s even though their features and usage are similar. Choosing one of the two will depend on your preferences, considering the facts we've provided so far.

#### Steps

1. **Install K3d**:

   - Set up a VM using Vagrant and install Docker.
   - Install K3d on the VM to create a lightweight Kubernetes cluster.

2. **Set Up Argo CD**:

   - Create two namespaces in Kubernetes: one for Argo CD and another for your application.
   - Install Argo CD and set up continuous integration for automatic deployment from GitHub.

3. **Deploy Application**:
   - Deploy an application with two versions, managed via Argo CD.

### Bonus Part (Optional): GitLab Integration

#### Overview

As a bonus, you'll install GitLab within your cluster and integrate it with your Kubernetes setup from Part 3.

#### Steps

1. **Install GitLab**:

   - Install and configure GitLab within your Kubernetes cluster.

2. **Integrate with Kubernetes**:
   - Ensure GitLab can deploy applications to your Kubernetes cluster, leveraging your Argo CD setup.

## Directory Structure

Organize your work into the following folders:

- `p1`: Contains all files and configurations for Part 1.
- `p2`: Contains all files and configurations for Part 2.
- `p3`: Contains all files and configurations for Part 3.
- `bonus`: (Optional) Contains files and configurations for the bonus part.

## Questions and Answers

### 1. What is the primary goal of the Inception-of-Things project?

The primary goal of the project is to deepen knowledge of Kubernetes by using K3s and K3d, set up a personal virtual machine using Vagrant, and manage lightweight Kubernetes clusters with K3s.

### 2. Can you explain the difference between K3s and K3d?

K3s is a lightweight Kubernetes distribution designed for resource-constrained environments. K3d is a wrapper around K3s that allows running K3s clusters inside Docker containers.

### 3. How did you set up the virtual machines using Vagrant, and what are their configurations?

Two virtual machines were set up using Vagrant: `Server` and `ServerWorker`. Both have 1 CPU and 512-1024 MB of RAM. The `Server` runs K3s in controller mode, and the `ServerWorker` runs K3s in agent mode.

### 4. What is the role of Ingress in K3s, and how did you configure it?

Ingress manages external access to services within the cluster. It was configured to route traffic to three different web applications based on the host header in the request.

### 5. What applications did you deploy in your K3s cluster, and how did you manage them?

Three web applications were deployed, each accessible based on the host header provided in the HTTP request. The second application has three replicas.

### 6. What is Argo CD, and how did you implement it in this project?

Argo CD is a GitOps continuous delivery tool for Kubernetes. It was used to automate the deployment of an application to the Kubernetes cluster, synchronizing the cluster state with a public GitHub repository.

### 7. How did you handle the deployment of multiple application versions in your project?

Multiple application versions were managed using Docker tags (v1 and v2). Argo CD updated the application version based on changes in the GitHub repository.

### 8. What challenges did you face while setting up GitLab in the bonus part, and how did you overcome them?

Challenges included integrating GitLab with the Kubernetes cluster. This was overcome by setting up GitLab in a dedicated namespace and using Helm for management.

### 9. Can you describe the directory structure of your project and its purpose?

The directory structure is organized into folders `p1`, `p2`, and `p3` for the mandatory parts, and `bonus` for the optional part, each containing necessary configuration files and scripts.

### 10. What did you learn from this project, and how can these skills be applied in real-world scenarios?

The project enhanced my understanding of Kubernetes, Vagrant, and continuous integration tools like Argo CD. These skills are applicable in cloud-native applications, DevOps practices, and managing infrastructure as code.

## Running the VMs

To start the VMs, navigate to the directory containing the `Vagrantfile` for each part and run:

```bash
vagrant up
```

This will start the VMs and apply the necessary configurations.

## Accessing the VMs

Use the following commands to access the VMs via SSH:

```bash
vagrant ssh hbel_houS  # For Part 1 VM1
vagrant ssh hbel_houSW  # For Part 1 VM2
# Additional VMs can be accessed similarly based on their configuration.
```

## Shutting Down and Destroying the VMs

To stop the VMs:

```bash
vagrant halt
```

To completely remove the VMs:

```bash
vagrant destroy
```

## Conclusion

This project covers the essentials of setting up Kubernetes environments using K3s and K3d, with a focus on virtualization, application deployment, and continuous integration. The bonus part adds advanced GitLab integration for a comprehensive DevOps pipeline.
