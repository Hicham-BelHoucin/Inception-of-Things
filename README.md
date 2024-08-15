# Inception-of-Things

The document you provided outlines a project focused on setting up Kubernetes environments using K3s and K3d, with Vagrant for virtualization. Here's a summary of what's required from you:

### **Mandatory Parts:**

1. **Part 1: K3s and Vagrant**
   - Set up two virtual machines using Vagrant with minimal resources (1 CPU, 512 or 1024 MB RAM).
   - Assign specific IPs to these machines and enable passwordless SSH access.
   - Install K3s on both machines: one in controller mode and the other in agent mode.
   - Use `kubectl` for management.

2. **Part 2: K3s and Three Simple Applications**
   - Set up a single virtual machine with K3s in server mode.
   - Deploy three web applications, accessible via different hostnames, on this machine.
   - Ensure one of the applications runs multiple replicas.

3. **Part 3: K3d and Argo CD**
   - Install K3d on a virtual machine (this involves using Docker).
   - Create two namespaces in Kubernetes: one for Argo CD and another for your application.
   - Set up continuous integration to automatically deploy an application from a GitHub repository using Argo CD.
   - The application should have two versions, which can be deployed via Argo CD.

### **Bonus Part (Optional):**
   - Install and configure GitLab within your cluster.
   - Integrate GitLab with your Kubernetes cluster and ensure it works with your setup from Part 3.

### **Submission:**
   - Organize your work into folders named `p1`, `p2`, and `p3` at the root of your repository.
   - If you do the bonus part, put it in a folder named `bonus`.

### **Evaluation:**
   - The project will be evaluated on your machine, and everything must be functional.
   - The bonus part will only be considered if the mandatory parts are completed perfectly.

In essence, you'll be working with virtualization, Kubernetes, and continuous integration tools, while ensuring proper organization and functionality of your setup.
