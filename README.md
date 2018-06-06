This is a dockerized version of the website hoffman-house.com.  It includes 
static web files which get served by nginx, as well as a dockerized image
of the squirrelcart e-commerce store software.

# Code Organization
* docker\*: Source for the various docker images that get built and deployed
* packer: Configs for building AMIs for the build server (based on CentOS) 
and the thin provisioning server (based on AtomicOS)
* static: Static HTML files for the main site.  
* tf: Terraform configs for deploying the site into AWS
* sc-admin.sh: The admin script that drives the build and deploy process

# Creating a build server
1. First you need to create an AMI to use a the build server
   1. ./sc-admin.sh build-ami
   1. Now you will have an AMI which you can launch from the AWS Console
   1. You will need to set the following tags for the route53 entries to be updated correctly (capitalization matters)
      1. Name:squirrel-build
      1. env:prod

# Building the docker images
1. SSH to that build server using ssh centos@squirrel-build.hoffman-house.com and clone the github repo into centos/src/squirrelcart-docker
1. cd src/squirrelcart-docker
1. ./sc-admin.sh build-docker
1. At this point, you can run the website locally using ./sc-admin.sh local-deploy
   1. You can ssh from your laptop to the build server with port forwarding, like ssh -L 8080:localhost:80 centos@squirrel-build.hoffman-house.com
   1. Point your web browser to http://localhost:8080 to see the website
1. ./sc-admin.sh push-docker (this pushes the docker images to an s3 bucket so our ec2 instance can load them later)

# Deploying the terraform Configuration
1. Terraform is responsible for setting up and instantiating the AWS infrastructure.  
It keeps it's state files in s3 and that's why we need to do the init.sh before every command.
1. cd tf
1. bash init.sh
1. terraform apply

# Notes about the AWS Configuration
1. The terraform config defines an auto scaling group of 1 node so that there 
will always be an instance running.  If the VM or the underlying physical host
dies the ASG will restart our VM.
1. You can ssh to this VM as the centos user, and become root using "sudo su -"
1. When that VM starts up, it runs a script to dynamically discover it's 
dynamically assigned IP address and public hostname and updates the route53 
entry so that the hostname will map to the new IP address.  To see the output
of this command run journalctl -u update_route53_mapping
1. Terraform defines an EBS volume which will be used to store the mysql
database as well as the SSL certs, but this volume is not tied to the ASG. 
So if the ec2 instance restarts or you manually reboot it, the mysql volume
will automatically reattach itself to the ec2 instance on boot up so you don't
lose any of your mysql data.  This happens in setup_storage.sh.  However, 
if you run a terraform destroy, it will delete this volume and you will lose
the data that was in that volume (we will automatically restore from the
latest backup when you start the ec2 servers up again).
1. We automatically take a backup of the squirrelcart site (uploaded images, etc) 
as well as the mysql database every 30 minutes and save this to s3.  This happens
in backup_squirrel.sh.  
1. When the machine boots it checks to see if we already have a letsencrypt SSL
key, and every Friday it checks to see if the cert needs to be updated (the certs
are only valid for 90 days).
1.  The backup and cert checker happen in a systemd service that gets launched
by a timer.  See in /etc/systemd/system for the config files.

