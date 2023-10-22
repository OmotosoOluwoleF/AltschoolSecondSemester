#!/bin/bash

# Deploying the Master node
echo "Deploying Master node..."
vagrant up master

# Deploying the Slave node
echo "Deploying Slave node..."
vagrant up slave

# Enable SSH key-based authentication
echo "Configuring SSH key-based authentication..."
vagrant ssh master -c "ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa"
vagrant ssh master -c "ssh-copy-id vagrant@192.168.56.22"

# Testing SSH connection
echo "Testing SSH connection..."
vagrant ssh master -c "ssh vagrant@192.168.56.22"
echo "SSH connection successful!"

echo "Deployment complete!"
