# Node.js CI/CD Pipeline on AWS using Terraform, Ansible, Jenkins, and Docker
This project is for learning purposes only.

This project demonstrates how to set up a complete CI/CD pipeline for a Node.js application on AWS using several DevOps tools and services. The project includes infrastructure provisioning with Terraform, configuration management with Ansible, continuous integration and deployment with Jenkins, and containerization using Docker.

## Project Structure

The project is organized into the following directory structure:

## 📁 Project Structure

```bash
.
├── infrstructure_using_terraform
│   ├── amidata.tf
│   ├── backend.tf
│   ├── compute_resources.tf
│   ├── Jenkinsfile
│   ├── main.tf
│   ├── network
│   │   ├── internetgw.tf
│   │   ├── natgateway.tf
│   │   ├── output.tf
│   │   ├── routetables.tf
│   │   ├── subnets.tf
│   │   ├── variables.tf
│   │   └── vpc.tf
│   ├── output.tf
│   ├── README.md
│   ├── secrets.tf
│   ├── securitygroups.tf
│   └── variables.tf
├── Jenkinsfile
└── simple_nodejs_application
    ├── ansible.cfg
    ├── deploy_node_app.yml
    ├── dockerfile
    ├── host_vars
    │   └── node_app.yml
    ├── inventory
    └── nodeapp
        ├── app.js
        └── package.json
```
### Directories and Their Roles:
- **infrastructure_using_terraform**: Contains Terraform files that define and provision the AWS infrastructure (VPC, EC2, Security Groups, NAT Gateway, and more).
- **simple_nodejs_application**: Contains the Node.js application along with Ansible playbooks for deploying the application to EC2 instances.
- **Jenkinsfile**: Defines the pipeline for Jenkins, including stages for building and deploying the application.

## Setup Instructions

### Step 1: Set up AWS Infrastructure with Terraform

1. Clone the repository.
2. Navigate to the `infrastructure_using_terraform` directory.
3. Initialize Terraform:

   ```bash
   terraform init
Apply the Terraform configuration to provision the required AWS resources:

   ```bash
   terraform apply --vars-file=dev.tfvars
   ```
This will create:
1-VPC with subnets.
2-EC2 instances (public and private).
3-NAT Gateway for outbound internet access from private instances.
4-Security groups, route tables, and internet gateway for networking.

### Step 2: Set up Jenkins Pipeline

# Jenkins Pipeline for Node.js Application Deployment

This repository contains a CI/CD pipeline for deploying a containerized Node.js application to a private AWS EC2 instance through a bastion host.

## Pipeline Overview

The Jenkins pipeline automates the process of:
1. Cloning the repository
2. Copying application files to a bastion host
3. Transferring files to a private EC2 instance
4. Building a Docker image on the EC2 instance
5. Deploying the application as a Docker container
6. Verifying the deployment

## Prerequisites

- Jenkins server with the following plugins:
  - Git plugin
  - SSH Agent plugin
  - Credentials plugin
- AWS infrastructure:
  - A private EC2 instance (not directly accessible from the internet)
  - A bastion host (with public access)
- Docker installed on:
  - Jenkins server (optional)
  - The private EC2 instance
- SSH keys that allow:
  - Jenkins to connect to the bastion host
  - The bastion host to connect to the private EC2 instance

## Configuration

### Jenkins Credentials

1. Create an SSH credential in Jenkins:
   - Go to **Jenkins Dashboard** → **Manage Jenkins** → **Credentials** → **System** → **Global credentials**
   - Add a new SSH private key credential with ID: `ssh-to-access-the-private-ec2`
   - The private key should be authorized for both the bastion host and the private EC2 instance

### Environment Variables

Set up the following environment variables in Jenkins:

| Variable | Description |
|----------|-------------|
| `EC2_PRIVATE_IP` | Private IP address of the EC2 instance |
| `BASTION_HOST_IP` | Public IP address of the bastion host |
| `APP_NAME` | Name of your application (used for container naming) |
| `GIT_REPO` | Git repository URL containing your application code |

These can be configured at either:
- **Global level**: In Jenkins system configuration
- **Job level**: In the specific pipeline job configuration
- **Jenkinsfile**: Already using default values for some parameters

### Jenkinsfile Explanation:

## Deployment Architecture

```
┌─────────────┐     ┌──────────────┐     ┌───────────────────┐
│             │     │              │     │                   │
│   Jenkins   ├────►│  Bastion     ├────►│  Private EC2      │
│   Server    │     │  Host        │     │  Instance         │
│             │     │  (Public IP) │     │  (Private IP)     │
└─────────────┘     └──────────────┘     └───────────────────┘
                                                  │
                                                  ▼
                                         ┌───────────────────┐
                                         │  Docker           │
                                         │  Container        │
                                         │  (Node.js App)    │
                                         └───────────────────┘
```

## How It Works

1. **Clone Repository**: The pipeline starts by cleaning the workspace and cloning the Git repository containing the Node.js application code.

2. **Copy Files to Bastion Host**: The application files are copied to a deployment directory on the bastion host using SCP.

3. **Deploy to EC2**: From the bastion host, the files are copied to the private EC2 instance, where:
   - A Docker image is built from the Dockerfile
   - Any existing container with the same name is stopped and removed
   - A new container is started with the appropriate port mapping
   - Old Docker images are pruned to save disk space

4. **Verify Deployment**: The pipeline checks if the container is running successfully on the EC2 instance.

## Security Considerations

- SSH keys are managed securely through Jenkins credentials
- StrictHostKeyChecking is disabled for automation purposes
- The private EC2 instance is not directly accessible from the internet
- Communication happens through the bastion host

## Troubleshooting

### Common Issues

1. **SSH Connection Failures**:
   - Ensure the SSH private key is correctly added to Jenkins credentials
   - Verify the EC2 and bastion host security groups allow SSH traffic
   - Check that the SSH user (default: ubuntu) is correct for your instances

2. **Docker Build Failures**:
   - Verify Docker is installed on the EC2 instance
   - Ensure the EC2 user has permissions to run Docker commands
   - Check if the Dockerfile is valid and present in the repository

3. **Container Not Starting**:
   - Check if port 3000 is already in use on the EC2 instance
   - Examine Docker logs: `docker logs [APP_NAME]`
   - Verify the Node.js application starts correctly

## Customization

- **Change ports**: Modify the `CONTAINER_PORT` and `HOST_PORT` variables in the environment section
- **Use a different branch**: Update the git branch parameter in the Clone Repository stage
- **Add notifications**: Implement notification logic in the post sections (Slack, email, etc.)
- **Adjust resource limits**: Add Docker resource constraints to the run command

## Contributing

Please reach out to me if you have any advice. This is for learning purposes only.

