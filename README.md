# Basic CircleCI Image Builder

*Very alpha stage -- meant to demo how to build CircleCI compatible containers
for use in CircleCI Enterprise.  We love feedback - please reach out and we
will make you successful*

This repo demos creation of custom CircleCI Enterprise containers using
[Packer](https://packer.io/) and [Vagrant](https://www.vagrantup.com).

For purposes of illustration, we build a Trusty container containing a number
of technologies, e.g. Docker, java, ruby, python, postgres, mongo, and mysql,
etc.  You may view the individual installers in `scripts/` folder.

## Builder a container

You can build an image locally with Vagrant and VirtualBox - or spin up an EC2
instance to perform the build.

To build a new container

```bash
# If using virtualbox -- slow
$ vagrant up --provider=virtualbox
# or if using AWS
$ vagrant plugin install vagrant-aws
$ AWS_ACCESS_KEY_ID=... \
    AWS_SECRET_ACCESS_KEY=... \
    AWS_SSH_KEYPAIR_NAME=... \
    AWS_SSH_KEYPAIR_PATH=... \
    AWS_REGION=us-east-1 \
    vagrant up --provider=aws

$ # Move to actually building
$ vagrant ssh
$ tmux new # optional - but it's nice building in background
$ cd /vagrant; sudo packer build packer.json
$ # Once finished, you should get `container.tar.gz` container file
$ # Upload it to S3 (or a web server) to start using for CircleCI containers
$ # awscli is already installed on container
```

Testing on a `m4.large`, building a container takes ~15-20 minutes.

*TODO* Better document the aws parameters


## How to tweak

The installation scripts are found in `scripts/` directory.  Python/Ruby/NodeJS
files allow ability to install multiple versions - you can edit the file to
install the versions you need.

You can add new modules for frameworks/tools you use.  You can activate the module and set the execution order by inserting it into `build.sh` `MODULES` array.


## General Repo TODOs:

* Better error reporting and isolation between scripts, and general repo hygiene
* Ability to install multiple java and php versions
* Document how to use ansible
* Document the difference with CircleCI.com container
