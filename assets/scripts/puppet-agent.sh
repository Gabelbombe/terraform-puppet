#!/usr/bin/env bash -ex
export PATH=$PATH:/opt/puppetlabs/bin
puppet agent -t --server=${server_name} --environment=${control_environment}
