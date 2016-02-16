IMAGE_SCRATCH := circleci/build-image:scratch

IMAGE_BASE := circleci/build-image:base

IMAGE_DOTCOM := circleci/build-image:dotcom

IMAGE_ENTERPRISE := circleci/build-image:enterprise

default: dotcom enterprise

base:
	docker pull $(IMAGE_BASE) || true
	docker build -f Dockerfile.base -t $(IMAGE_SCRATCH) .
	docker push $(IMAGE_SCRATCH)
	docker tag $(IMAGE_SCRATCH) $(IMAGE_BASE)

dotcom: base
	docker pull $(IMAGE_DOTCOM) || true
	docker build -f Dockerfile.dotcom -t $(IMAGE_DOTCOM) .
	docker push $(IMAGE_DOTCOM)

enterprise: base
	docker pull $(IMAGE_ENTERPRISE) || true
	docker build -f Dockerfile.enterprise -t $(IMAGE_ENTERPRISE) .
	docker push $(IMAGE_ENTERPRISE)

deploy_dotcom:
	./docker-export $(IMAGE_DOTCOM) | aws s3 cp - s3://circle-downloads/trusty-beta-$(TAG).tar.gz --acl public-read
