IMAGE_COMMON := circleci/build-image:scratch

IMAGE_DOTCOM := circleci/build-image:dotcom

IMAGE_ENTERPRISE := circleci/build-image:enterprise

default: dotcom enterprise

pull:
	docker pull circleci/build-image:scratch || true

common: pull
	docker build -f Dockerfile.common -t $(IMAGE_COMMON) .
	docker push $(IMAGE_COMMON)

dotcom: common
	docker build -f Dockerfile.dotcom -t $(IMAGE_DOTCOM) .
	docker push $(IMAGE_DOTCOM)

enterprise: common
	docker build -f Dockerfile.enterprise -t $(IMAGE_ENTERPRISE) .
	docker push $(IMAGE_ENTERPRISE)
