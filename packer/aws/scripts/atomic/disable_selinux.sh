#!/bin/bash -e

sed -i.bak 's/^SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
