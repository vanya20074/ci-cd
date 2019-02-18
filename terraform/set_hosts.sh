#!/bin/bash

echo '127.0.0.1 localhost' > /etc/hosts
echo `jq -r .modules[0].resources'."aws_instance.be"'.primary.attributes.public_ip terraform.tfstate` `jq -r .modules[0].resources'."aws_instance.be"'.primary.attributes'."tags.Name"' terraform.tfstate` >> /etc/hosts
echo `jq -r .modules[0].resources'."aws_instance.mysql"'.primary.attributes.public_ip terraform.tfstate` `jq -r .modules[0].resources'."aws_instance.mysql"'.primary.attributes'."tags.Name"' terraform.tfstate` >> /etc/hosts

