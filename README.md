# CircleCI Image Builder

`image-builder` is a repo that CircleCI is using to build various build images. This repo
is also for customers of CircleCI Enterprise to build custom build images.

The repo uses Docker for building containers.  The instructions assumes basic familiarity with
Docker. [Docker docs](https://docs.docker.com/) is a good resource to get started

The following are brief explanations of build images that CircleCI builds by using image-builder.

### Ubuntu 14.04 Enterprise

**Description**

This image is used as the default Trusty image on new installations of [CircleCI Enterprise](https://circleci.com/enterprise/). If you launch your builders with our `init-trusty-builder` script, or use the docker based installation, this is the default image you use.

**Docker image tag**

`circleci/build-image:ubuntu-14.04-enterprise-<VERSION>`

### Ubuntu 14.04 XXL

**Description**

This image is used to provide Ubuntu Trusty build container support on [circleci.com](https://circleci.com). The image is the fattest image: many versions of popular programming languages as well as services are pre-installed.

**List of installed software**

https://circleci.com/docs/build-image-trusty/

**Docker image tag**

`circleci/build-image:ubuntu-14.04-XXL-<VERSION>`

### Ubuntu 14.04 XXL Enterprise

**Description**

This image is maintained for customers of [CircleCI Enterprise](https://circleci.com/enterprise/). The image is very similar to Ubuntu 14.04 XXL image but one difference: vanilla Docker is preinstalled in the image while patched version of Docker is installed in Ubuntu 14.04 XXL. This is because customers of CircleCI Enterprise can run build containers in privileged mode.

**List of installed software**

https://circleci.com/docs/build-image-trusty/

Note: only Docker version is different. We install the latest version of Docker.

**Docker image tag**

`circleci/build-image:ubuntu-14.04-XXL-enterprise-<VERSION>`

### Ubuntu 14.04 XL

**Description**

This image is the slimmer version of Ubuntu 14.04 XXL build image. The same versions of languages and tools as Ubuntu 14.04 XXL are pre-installed but services such as PostgreSQL
or Redis aren't installed. The build image is designed to be used with network services provided through the docker composing mechanism.

**List of installed software**

https://circleci.com/docs/environments/ubuntu-14.04-XL.json

**Docker image tag**

`circleci/build-image:ubuntu-14.04-XL-<VERSION>`

### Ubuntu 14.04 XXL-upstart

**Description**

This image behaves like a VM, with upstart being PID 1. Actions default to running as root
and services (e.g. postgres, redis) are allowed without requiring to use another images.
The images matches the content of Ubuntu 14.04 XXL.

**List of installed software**

https://circleci.com/docs/environments/ubuntu-14.04-XXL-upstart.json

**Docker image tag**

`circleci/build-image:ubuntu-14.04-XXL-upstart-<VERSION>`

# Building custom image

This section is written for customers of [CircleCI Enterprise](https://circleci.com/enterprise/) who wants to build a custom image by using image-builder. Although Enterprise customers can use any tools in the wild to build a custom image, we highly recommend to using image-builder. This makes sure that Enterprise customers run builds on build images that CircleCI has a better support.

## Building a container

There are multiple workflow for building a container, and it depends on the level of customizations:

### Building a container image with minor tweak, e.g. adding a new package, python version

If you want to tweak containers to simply add new package or new customizations, you can
use our published containers as your base.

For doing so, you can create a Dockerfile with the appropriate customizations:

```
FROM circleci/build-image:latest

# You can use some basic tools, using the `circleci-install` helper function
# for tools, CircleCI supports
RUN circleci-install ruby 2.2.1
RUN circleci-install scala

# You can add custom files
ADD my-custom-root-ca.crt /usr/local/share/ca-certificates/my-custom-root-ca.crt
RUN update-ca-certificates
```

And then you can build it as you would typically do (i.e. `docker build -t my-container:0.3 .`).

Another common tweak is removing packages/tools that you don't use. For example, if you don't have
Android projects, you should remove the lines that install Android SDKs from the Dockerfile.
We encourage you to install only what you need because having a smaller container image will give you many benefits such as faster container start up time.

With this workflow, you will be basing your container on CircleCI published container image,
speeding up creation process.  When CircleCI publishes new container image, you can rebuild
your image and Docker will pick up the latest published version.

### Building a container with substantial changes

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

**Please note, our infrastructure currently assumes that `mysql` and `postgres` are installed. Even if you do not use them, please include them in your image**

### Super advanced mode: Using Chef/Ansible/etc

If you have a significant infrastructure using custom provisioners, e.g.
Chef/Ansible/SaltStack, please reach out to us private.  The exact instructions
are beyond the scope of this documentation.

In a very high level, we would recommend using [Packer](https://www.packer.io)
and [Packer's Docker Builder](https://www.packer.io/docs/builders/docker.html).

## Testing the container

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
host $ CONTAINER_SSH_PORT=$(docker inspect --format='{{(index (index .NetworkSettings.Ports "22/tcp") 0).HostPort}}' example-image-tester)
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
## Hooking up CircleCI to use the container

Once you gain confidence in the image you just created, you can start pushing it to new builds.
You must configure CircleCI Enterprise builders to point to the container
image.  You can do so, by passing additional environment variable in your
launch configuration: `CIRCLE_CONTAINER_IMAGE_URI`.

Currently, builders can only support public http or S3 uris (e.g.
`https://example.com/container_0.0.1.tar.gz` or
`s3://example/container_0.0.1.tar.gz`.  Future releases will support docker
URIs (e.g. `docker://acme-org/circleci-test-image:0.0.1`).  For the timebeing,
we suggest exporting the container and uploading it to S3.

Assuming you have the official aws-cli client, you can export the container and
upload it to a bucket of your choice.  Ideally, it's located in the same region
as the builders, and you can reuse the bucket that got created for the CCIE installation
':

(_note: this uses the included `docker-export`, which is different than `docker export`_)
```bash
$ ./docker-export example-image > example-image_0.0.1.tar.gz
$ aws s3 cp ./example-image_0.0.1.tar.gz s3://circleci-enterprise-bucket/containers/example-image_0.0.1.tar.gz
```

Once uploaded, attempt to start a new builder configured with
`CIRCLE_CONTAINER_IMAGE_URI=s3://circleci-enterprise-bucket/containers/example-image_0.0.1.tar.gz`.
Try running new builds on it.  Once it's all good, update the AutoScalingGroup
Launch configuration to use the environment variable as well.
