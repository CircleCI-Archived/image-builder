SHELL := /bin/bash
IMAGE_REPO = truelayer/build-image
SHA = $(shell git rev-parse --short HEAD)
VERSION = $(CIRCLE_BUILD_NUM)-$(SHA)
NO_CACHE =

# define docker-push-with-retry
#     for i in 1 2 3; do docker push $(1); if [ $$? -eq 0 ]; then exit 0; fi; echo "Retrying...."; done; exit 1;
# endef

ifeq ($(no_cache), true)
    NO_CACHE = --no-cache
endif

### ubuntu-14.04-enterprise
# This is the standard ubuntu-14.04 image for use on enterprise. It is similar to the 14.04-enterprise image,
# but has fewer things installed to make installing CCIE faster.
###
# build-ubuntu-14.04-enterprise:
# 	docker-cache-shim pull ${IMAGE_REPO}
# 	echo "Building Docker image ubuntu-14.04-enterprise-$(VERSION)"
# 	docker build $(NO_CACHE) --build-arg IMAGE_TAG=ubuntu-14.04-enterprise-$(VERSION) \
# 	-t $(IMAGE_REPO):ubuntu-14.04-enterprise-$(VERSION) \
# 	-f targets/ubuntu-14.04-enterprise/Dockerfile \
# 	.

# push-ubuntu-14.04-enterprise:
# 	docker-cache-shim push ${IMAGE_REPO}:ubuntu-14.04-enterprise-$(VERSION)
# 	$(call docker-push-with-retry,$(IMAGE_REPO):ubuntu-14.04-enterprise-$(VERSION))

# dump-version-ubuntu-14.04-enterprise:
# 	docker run $(IMAGE_REPO):ubuntu-14.04-enterprise-$(VERSION) sudo -H -i -u ubuntu /opt/circleci/bin/pkg-versions.sh | jq . > $(CIRCLE_ARTIFACTS)/versions-ubuntu-14.04-enterprise.json; true
# 	curl -o versions.json.before https://circleci.com/docs/environments/trusty.json
# 	diff -uw versions.json.before $(CIRCLE_ARTIFACTS)/versions-enterprise.json > $(CIRCLE_ARTIFACTS)/versions-ubuntu-14.04-enterprise.diff; true

# test-ubuntu-14.04-enterprise:
# 	exit 0

# deploy-ubuntu-14.04-enterprise:
# 	./docker-export $(IMAGE_REPO):ubuntu-14.04-enterprise-$(VERSION) > build-image-ubuntu-14.04-enterprise-$(VERSION).tar.gz
# 	aws s3 cp ./build-image-ubuntu-14.04-enterprise-$(VERSION).tar.gz s3://circleci-enterprise-assets-us-east-1/containers/circleci-trusty-container-$(VERSION).tar.gz --acl public-read

# ubuntu-14.04-enterprise: build-ubuntu-14.04-enterprise push-ubuntu-14.04-enterprise dump-version-ubuntu-14.04-enterprise


build-ubuntu-14.04-enterprise-minimal:
	# docker-cache-shim pull ${IMAGE_REPO}
	echo "Building Docker image ubuntu-14.04-enterprise-minimal-$(VERSION)"
	docker build $(NO_CACHE) --build-arg IMAGE_TAG=ubuntu-14.04-enterprise-minimal-$(VERSION) \
	-t $(IMAGE_REPO):ubuntu-14.04-enterprise-minimal-$(VERSION) \
	-f targets/ubuntu-14.04-enterprise-minimal/Dockerfile \
	.

ubuntu-14.04-enterprise-minimal: build-ubuntu-14.04-enterprise-minimal
