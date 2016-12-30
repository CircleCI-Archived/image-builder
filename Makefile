SHELL := /bin/bash
IMAGE_REPO = circleci/build-image
SHA = $(shell git rev-parse --short HEAD)
VERSION = $(CIRCLE_BUILD_NUM)-$(SHA)
NO_CACHE =

define docker-push-with-retry
    for i in 1 2 3; do docker push $(1); if [ $$? -eq 0 ]; then exit 0; fi; echo "Retrying...."; done; exit 1;
endef

ifeq ($(no_cache), true)
    NO_CACHE = --no-cache
endif

### ubuntu-14.04-XXL
# This build image is used on circleci.com Ubuntu 14.04 fleet.
# This is the fattest image that we manage: many versions of various programming languages
# and services such as MySQL or Redis are installed.
###
build-ubuntu-14.04-XXL:
ifndef NO_CACHE
	docker-cache-shim pull ${IMAGE_REPO} || true
endif
	echo "Building Docker image ubuntu-14.04-XXL-$(VERSION)"
	docker build $(NO_CACHE) --build-arg IMAGE_TAG=ubuntu-14.04-XXL-$(VERSION) \
	-t $(IMAGE_REPO):ubuntu-14.04-XXL-$(VERSION) \
	-f targets/ubuntu-14.04-XXL/Dockerfile \
	.

push-ubuntu-14.04-XXL:
	docker-cache-shim push ${IMAGE_REPO}:ubuntu-14.04-XXL-$(VERSION)
	$(call docker-push-with-retry,$(IMAGE_REPO):ubuntu-14.04-XXL-$(VERSION))

dump-version-ubuntu-14.04-XXL:
	docker run --rm $(IMAGE_REPO):ubuntu-14.04-XXL-$(VERSION) sudo -H -i -u ubuntu /opt/circleci/bin/pkg-versions.sh | jq . > $(CIRCLE_ARTIFACTS)/versions-ubuntu-14.04-XXL.json; true
	curl -o versions.json.before https://circleci.com/docs/environments/trusty.json
	diff -uw versions.json.before $(CIRCLE_ARTIFACTS)/versions-ubuntu-14.04-XXL.json > $(CIRCLE_ARTIFACTS)/versions-ubuntu-14.04-XXL.diff; true

test-ubuntu-14.04-XXL:
	docker run -d -v ~/image-builder/tests:/home/ubuntu/tests -p 12345:22 --name ubuntu-14.04-XXL-test $(IMAGE_REPO):ubuntu-14.04-XXL-$(VERSION)
	sleep 10
	docker cp tests/insecure-ssh-key.pub ubuntu-14.04-XXL-test:/home/ubuntu/.ssh/authorized_keys
	#sudo lxc-attach -n $$(docker inspect --format "{{.Id}}" ubuntu-14.04-XXL-test) -- bash -c "chown ubuntu:ubuntu /home/ubuntu/.ssh/authorized_keys"
	docker exec ubuntu-14.04-XXL-test chown ubuntu:ubuntu /home/ubuntu/.ssh/authorized_keys
	chmod 600 tests/insecure-ssh-key; ssh -i tests/insecure-ssh-key -p 12345 ubuntu@localhost bats tests/unit/ubuntu-14.04-XXL

deploy-ubuntu-14.04-XXL:
	./docker-export $(IMAGE_REPO):ubuntu-14.04-XXL-$(VERSION) > build-image-ubuntu-14.04-XXL-$(VERSION).tar.gz
	aws s3 cp ./build-image-ubuntu-14.04-XXL-$(VERSION).tar.gz s3://circle-downloads/build-image-ubuntu-14.04-XXL-$(VERSION).tar.gz --acl public-read

ubuntu-14.04-XXL: build-ubuntu-14.04-XXL push-ubuntu-14.04-XXL dump-version-ubuntu-14.04-XXL test-ubuntu-14.04-XXL

### ubuntu-14.04-XXL-enterprise
# This build image is for CircleCI Enterprise customer. The image is very similar to ubuntu-14.04-XXL.
# The only difference is that this image has official Docker installed.
###
build-ubuntu-14.04-XXL-enterprise:
ifndef NO_CACHE
	docker-cache-shim pull ${IMAGE_REPO} || true
endif
	echo "Building Docker image ubuntu-14.04-XXL-enterprise-$(VERSION)"
	docker build $(NO_CACHE) --build-arg IMAGE_TAG=ubuntu-14.04-XXL-enterprise-$(VERSION) \
	-t $(IMAGE_REPO):ubuntu-14.04-XXL-enterprise-$(VERSION) \
	-f targets/ubuntu-14.04-XXL-enterprise/Dockerfile \
	.

push-ubuntu-14.04-XXL-enterprise:
	docker-cache-shim push ${IMAGE_REPO}:ubuntu-14.04-XXL-enterprise-$(VERSION)
	$(call docker-push-with-retry,$(IMAGE_REPO):ubuntu-14.04-XXL-enterprise-$(VERSION))

dump-version-ubuntu-14.04-XXL-enterprise:
	docker run $(IMAGE_REPO):ubuntu-14.04-XXL-enterprise-$(VERSION) sudo -H -i -u ubuntu /opt/circleci/bin/pkg-versions.sh | jq . > $(CIRCLE_ARTIFACTS)/versions-ubuntu-14.04-XXL-enterprise.json; true
	curl -o versions.json.before https://circleci.com/docs/environments/trusty.json
	diff -uw versions.json.before $(CIRCLE_ARTIFACTS)/versions-enterprise.json > $(CIRCLE_ARTIFACTS)/versions-ubuntu-14.04-XXL-enterprise.diff; true

test-ubuntu-14.04-XXL-enterprise:
	exit 0

deploy-ubuntu-14.04-XXL-enterprise:
	./docker-export $(IMAGE_REPO):ubuntu-14.04-XXL-enterprise-$(VERSION) > build-image-ubuntu-14.04-XXL-enterprise-$(VERSION).tar.gz
	./scripts/release-LXC-container ubuntu-14.04-XXL-enterprise-$(VERSION) ./build-image-ubuntu-14.04-XXL-enterprise-$(VERSION).tar.gz

ubuntu-14.04-XXL-enterprise: build-ubuntu-14.04-XXL-enterprise push-ubuntu-14.04-XXL-enterprise dump-version-ubuntu-14.04-XXL-enterprise

### ubuntu-14.04-XL
# This image is designed to be used on Picard, our alpha build environment with network services
# provided through the docker composing mechanism.
# The images matches the content of Ubuntu 14.04 XXL except network services.
###
build-ubuntu-14.04-XL:
ifndef NO_CACHE
	docker-cache-shim pull ${IMAGE_REPO} || true
endif
	echo "Building Docker image ubuntu-14.04-XL-$(VERSION)"
	docker build $(NO_CACHE) --build-arg IMAGE_TAG=ubuntu-14.04-XL-$(VERSION) \
	-t $(IMAGE_REPO):ubuntu-14.04-XL-$(VERSION) \
	-f targets/ubuntu-14.04-XL/Dockerfile \
	.

push-ubuntu-14.04-XL:
	docker-cache-shim push ${IMAGE_REPO}:ubuntu-14.04-XL-$(VERSION)
	$(call docker-push-with-retry,$(IMAGE_REPO):ubuntu-14.04-XL-$(VERSION))

dump-version-ubuntu-14.04-XL:
	docker run $(IMAGE_REPO):ubuntu-14.04-XL-$(VERSION) sudo -H -i -u ubuntu /opt/circleci/bin/pkg-versions.sh | jq . > $(CIRCLE_ARTIFACTS)/versions-ubuntu-14.04-XL.json; true
	curl -o versions.json.before https://circleci.com/docs/environments/trusty.json
	diff -uw versions.json.before $(CIRCLE_ARTIFACTS)/versions-ubuntu-14.04-XL.json > $(CIRCLE_ARTIFACTS)/versions-ubuntu-14.04-XL.diff; true

test-ubuntu-14.04-XL:
	docker run -w /home/ubuntu -v ~/image-builder/tests:/home/ubuntu/tests --name ubuntu-14.04-XL-test  $(IMAGE_REPO):ubuntu-14.04-XL-$(VERSION) bash -l -c "bats /home/ubuntu/tests/unit/ubuntu-14.04-XL"

deploy-ubuntu-14.04-XL:
	exit 0

ubuntu-14.04-XL: build-ubuntu-14.04-XL push-ubuntu-14.04-XL dump-version-ubuntu-14.04-XL test-ubuntu-14.04-XL

### ubuntu-14.04-enterprise
# This is the standard ubuntu-14.04 image for use on enterprise. It is similar to the 14.04-enterprise image,
# but has fewer things installed to make installing CCIE faster.
###
build-ubuntu-14.04-enterprise:
ifndef NO_CACHE
	docker-cache-shim pull ${IMAGE_REPO}
endif
	echo "Building Docker image ubuntu-14.04-enterprise-$(VERSION)"
	docker build $(NO_CACHE) --build-arg IMAGE_TAG=ubuntu-14.04-enterprise-$(VERSION) \
	-t $(IMAGE_REPO):ubuntu-14.04-enterprise-$(VERSION) \
	-f targets/ubuntu-14.04-enterprise/Dockerfile \
	.

push-ubuntu-14.04-enterprise:
	docker-cache-shim push ${IMAGE_REPO}:ubuntu-14.04-enterprise-$(VERSION)
	$(call docker-push-with-retry,$(IMAGE_REPO):ubuntu-14.04-enterprise-$(VERSION))

dump-version-ubuntu-14.04-enterprise:
	docker run $(IMAGE_REPO):ubuntu-14.04-enterprise-$(VERSION) sudo -H -i -u ubuntu /opt/circleci/bin/pkg-versions.sh | jq . > $(CIRCLE_ARTIFACTS)/versions-ubuntu-14.04-enterprise.json; true
	curl -o versions.json.before https://circleci.com/docs/environments/trusty.json
	diff -uw versions.json.before $(CIRCLE_ARTIFACTS)/versions-enterprise.json > $(CIRCLE_ARTIFACTS)/versions-ubuntu-14.04-enterprise.diff; true

test-ubuntu-14.04-enterprise:
	exit 0

deploy-ubuntu-14.04-enterprise:
	./docker-export $(IMAGE_REPO):ubuntu-14.04-enterprise-$(VERSION) > build-image-ubuntu-14.04-enterprise-$(VERSION).tar.gz
	./scripts/release-LXC-container ubuntu-14.04-enterprise-$(VERSION) ./build-image-ubuntu-14.04-enterprise-$(VERSION).tar.gz

ubuntu-14.04-enterprise: build-ubuntu-14.04-enterprise push-ubuntu-14.04-enterprise dump-version-ubuntu-14.04-enterprise

### ubuntu-14.04-XXL-upstart
# This image behaves like a VM, with upstart being PID 1. Actions default to running as root
# and services (e.g. postgres, redis) are allowed without requiring to use another images.
# The images matches the content of Ubuntu 14.04 XXL.
###
build-ubuntu-14.04-XXL-upstart:
	echo "Building Docker image ubuntu-14.04-XXL-upstart-$(VERSION)"
	docker build $(NO_CACHE) --build-arg IMAGE_TAG=ubuntu-14.04-XXL-upstart-$(VERSION) \
	-t $(IMAGE_REPO):ubuntu-14.04-XXL-upstart-$(VERSION) \
	-f targets/ubuntu-14.04-XXL-upstart/Dockerfile \
	.

push-ubuntu-14.04-XXL-upstart:
	$(call docker-push-with-retry,$(IMAGE_REPO):ubuntu-14.04-XXL-upstart-$(VERSION))

dump-version-ubuntu-14.04-XXL-upstart:
	docker run $(IMAGE_REPO):ubuntu-14.04-XXL-upstart-$(VERSION) sudo -H -i -u ubuntu /opt/circleci/bin/pkg-versions.sh | jq . > $(CIRCLE_ARTIFACTS)/versions-ubuntu-14.04-XXL-upstart.json; true
	curl -o versions.json.before https://circleci.com/docs/environments/trusty.json
	diff -uw versions.json.before $(CIRCLE_ARTIFACTS)/versions-ubuntu-14.04-XXL-upstart.json > $(CIRCLE_ARTIFACTS)/versions-ubuntu-14.04-XXL-upstart.diff; true

test-ubuntu-14.04-XXL-upstart:
	# Tests are done when building ubuntu-14.04-XXL base image
	exit 0

deploy-ubuntu-14.04-XXL-upstart:
	exit 0

ubuntu-14.04-XXL-upstart: build-ubuntu-14.04-XXL-upstart push-ubuntu-14.04-XXL-upstart dump-version-ubuntu-14.04-XXL-upstart test-ubuntu-14.04-XXL-upstart
