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

    aws.keypair_name = "#{ENV['AWS_KEYPAIR_NAME']}"
    override.ssh.private_key_path = "#{ENV['AWS_KEYPAIR_PATH']}"

    aws.region = ENV['AWS_REGION'] or 'us-east-1'

    aws.tags {
        Name= 'CircleCI Image Builder'
    }

    # Ubuntu 14.04.2 LTS hvm-ssd: http://cloud-images.ubuntu.com/trusty/20150803/
    aws.region_config "ap-northeast-1", :ami => "ami-bc43ffbc"
    aws.region_config "ap-southeast-1", :ami => "ami-18c2ce4a"
    aws.region_config "ap-southeast-2", :ami => "ami-5b82c261"
    aws.region_config "eu-central-1", :ami => "ami-f4c2c6e9"
    aws.region_config "eu-west-1", :ami => "ami-bacf99cd"
    aws.region_config "sa-east-1", :ami => "ami-add158b0"
    aws.region_config "us-east-1", :ami => "ami-89b414e2"
    aws.region_config "us-west-1", :ami => "ami-81b946c5"
    aws.region_config "us-west-2", :ami => "ami-c39990f3"

    override.ssh.username = "ubuntu"

    config.vm.box = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"
  end

  config.vm.provision "shell", inline: <<-SHELL
    sudo apt-get update
    sudo apt-get install -qq lxc cgroup-lite unzip tmux awscli

    # Install Packer
    curl -sSL -o /tmp/packer.zip https://dl.bintray.com/mitchellh/packer/packer_0.8.2_linux_amd64.zip
    unzip -f -d /usr/bin /tmp/packer.zip

    # Install packer-lxc-builder
    curl -sSL -o /usr/bin/packer-builder-lxc https://s3.amazonaws.com/circle-downloads/packer-builder-lxc-0.0.1
    chmod +x /usr/bin/packer-builder-lxc
  SHELL
end
