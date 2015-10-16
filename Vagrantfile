# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box_check_update = false

  config.vm.provider :virtualbox do |vb|
      #config.vm.box = "ubuntu/trusty64"

  end

  config.vm.provider :aws do |aws, override|
    aws.access_key_id = "#{ENV['AWS_ACCESS_KEY_ID']}"
    aws.secret_access_key = "#{ENV['AWS_SECRET_ACCESS_KEY']}"

    aws.keypair_name = "#{ENV['AWS_SSH_KEYPAIR_NAME']}"
    override.ssh.private_key_path = "#{ENV['AWS_SSH_KEYPAIR_PATH']}"

    aws.region = ENV['AWS_REGION'] or 'us-east-1'

    aws.tags {
        Name= 'CircleCI Image Builder'
    }

    # Ubuntu 14.04.3 LTS hvm-ssd: http://cloud-images.ubuntu.com/trusty/current/
    aws.region_config "ap-northeast-1", :ami => "ami-b23051b2"
    aws.region_config "ap-southeast-1", :ami => "ami-aa3c2cf8"
    aws.region_config "ap-southeast-2", :ami => "ami-21b0fb1b"
    aws.region_config "eu-central-1", :ami => "ami-08a1ac15"
    aws.region_config "eu-west-1", :ami => "ami-63a19214"
    aws.region_config "sa-east-1", :ami => "ami-43d6475e"
    aws.region_config "us-east-1", :ami => "ami-f3752196"
    aws.region_config "us-west-1", :ami => "ami-d7bf7f93"
    aws.region_config "us-west-2", :ami => "ami-0820c13b"

    override.ssh.username = "ubuntu"

    config.vm.box = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"
  end

  config.vm.provision "shell", inline: <<-SHELL
    sudo apt-get update
    sudo apt-get install -qq lxc cgroup-lite unzip tmux awscli

    # Install Packer
    curl -sSL -o /tmp/packer.zip https://dl.bintray.com/mitchellh/packer/packer_0.8.2_linux_amd64.zip
    unzip -o -d /usr/bin /tmp/packer.zip

    # Install packer-lxc-builder
    curl -sSL -o /usr/bin/packer-builder-lxc https://s3.amazonaws.com/circle-downloads/packer-builder-lxc-0.0.1
    chmod +x /usr/bin/packer-builder-lxc
  SHELL
end
