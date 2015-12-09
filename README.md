# Basic CircleCI Image Builder

This demos a process to build CircleCI compatible containers for use in CircleCI Enterprise.
We love feedback - please reach out!

The repo uses Docker for building containers.  The instructions assumes basic familiarity with
Docker. [Docker docs](https://docs.docker.com/) is a good resource to get started

# 1. Building a container

There are multiple workflow for building a container, and it depends on the level of customizations:

## Building a container image with minor tweak, e.g. adding a new package, python version

If you want to tweak containers to simply add new package or new customizations, you can
use our published containers as your base.

For doing so, you can create a Dockerfile with the appropriate customizations:

```
FROM circleci/build-image:prototype-latest

# You can use some basic tools, using the `circleci-install` helper function
# for tools, CircleCI supports
RUN circleci-install ruby 2.2.1
RUN circleci-install scala

# You can add custom files
ADD my-custom-root-ca.crt /usr/local/share/ca-certificates/my-custom-root-ca.crt
RUN update-ca-certificates
```

And then you can build it as you would typically do (i.e. `docker build -t my-container:0.3 .`).

With this workflow, you will be basing your container on CircleCI published container image,
speeding up creation process.  When CircleCI publishes new container image, you can rebuild
your image and Docker will pick up the latest published version.

**TODO**: Document available base image and document them

## Building a container with substantial changes

If you need to customize the image by starting from a clean slate, and/or
require significant changes, e.g. different MySQL version, or MariaDB rather
than MySQL, then the recommended path is to fork the repo and apply your
changes, then build the Docker image.

Please note, that this repo uses `circleci/ubuntu-server` as the base image.
It uses the official Ubuntu Server image (rather than Ubuntu Core, the default
ubuntu in DockerHub), tweaks slightly so Upstart can work with Docker.

It's recommended that you fork this repo rather than start from scratch for the following benefits:

* Ensure that CircleCI specific required customizations (e.g. xvfb) is correctly applied
* Have a mechanism to pick up later tweaks and improvements by merging the repo - rather than merging them manually later
* Reuse the custom provisioning framework that we are building to ease installation
* Have a mechanism to push your changes/tweaks back to us

## Super advanced mode: Using Chef/Ansible/etc

If you have a significant infrastructure using custom provisioners, e.g.
Chef/Ansible/SaltStack, please reach out to us private.  The exact instructions
are beyond the scope of this documentation.

In a very high level, we would recommend using [Packer](https://www.packer.io)
and [Packer's Docker Builder](https://www.packer.io/docs/builders/docker.html).

# 2. Testing the container

So you built the container successfully!  Congrats.  How can you test it?

You can use the common Docker techniques for launching a container and connecting to it.

The workflow, I adopt is the following:

```bash
host $ # build the image and name it `example-image`
host $ docker build -t example-image .
[...]
host $ # Start it - but enable ssh and mount a sample test project
host $ docker run -d \
      -p 22 -v ~/.ssh/id_rsa.pub:/home/ubuntu/.ssh/authorized_keys \ # To allow for ssh
      -v hello-world-project:/home/ubuntu/hello-world-project \ # mount a sample project
      --name example-image-tester \
      example-image
5b43b9fd24dd046a389dc2bbc2e84925c011910cfdd2de6cf638dd245f074831
host $ # Now ssh into the container.  This depends whether you are using Docker natively or through docker-machine
host $ # With native docker
host $ CONTAINER_SSH_PORT=$(docker inspect --format='{{(index (index .NetworkSettings.Ports "22/tcp") 0).HostPort}}')
host $ # If using docker-machine, need to connect to the docker-machine ip address
host $ CONTAINER_SSH_HOST=$(docker-machine ip default) # or set to 127.0.0.1 if using Docker natively on a Linux box
host $
host $ ssh -o StrictHostKeyChecking=no -p $CONTAINER_SSH_PORT ubuntu@${CONTAINER_SSH_HOST}
docker $
docker $ # now you are in Docker and the build - run any tests you need
docker $ cd example-image-test
docker $ # Run any custom test steps you need, e.g. for a node project it will be
docker $ npm install
docker $ npm test
docker $
docker $ $ also can run any sanity checks, e.g. ensure postgres is running
ubuntu@22b220709b03:~$ psql
psql (9.4.5)
Type "help" for help.

ubuntu=# ;; psql is running
ubuntu=# ;; psql is running
ubuntu-# \quit
```

# 3. Hooking up CircleCI to use the container

*TODO*: WIP
