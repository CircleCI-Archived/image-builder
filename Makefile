SHELL := /bin/bash
IMAGE_REPO = truelayer/build-image
SHA = $(shell git rev-parse --short HEAD)
VERSION = $(CIRCLE_BUILD_NUM)-$(SHA)
NO_CACHE =

ifeq ($(no_cache), true)
    NO_CACHE = --no-cache
endif

build-ubuntu-14.04-enterprise-minimal:
	# docker-cache-shim pull ${IMAGE_REPO}
	echo "Building Docker image ubuntu-14.04-enterprise-minimal-$(VERSION)"
	docker build $(NO_CACHE) --build-arg IMAGE_TAG=ubuntu-14.04-enterprise-minimal-$(VERSION) \
	-t $(IMAGE_REPO):ubuntu-14.04-enterprise-minimal-$(VERSION) \
	-f targets/ubuntu-14.04-enterprise-minimal/Dockerfile \
	.

deploy-ubuntu-14.04-enterprise-minimal:
	./docker-export $(IMAGE_REPO):ubuntu-14.04-enterprise-minimal-$(VERSION) > build-image-ubuntu-14.04-enterprise-minimal-$(VERSION).tar.gz
	aws s3 cp ./build-image-ubuntu-14.04-enterprise-minimal-$(VERSION).tar.gz ${ASSETS_BUCKET}/ubuntu-14.04-enterprise-minimal-$(VERSION).tar.gz --acl public-read

ubuntu-14.04-enterprise-minimal: build-ubuntu-14.04-enterprise-minimal
