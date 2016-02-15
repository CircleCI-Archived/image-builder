IMAGE_COMMON := circleci/build-image:common

IMAGE_DOTCOM := circleci/build-image:dotcom

IMAGE_ENTERPRISE := circleci/build-image:enterprise

default: dotcom

pull:
	docker pull circleci/build-image:scratch || true

common: pull
	docker build -f Dockerfile.common -t $(IMAGE_COMMON) .

dotcom: common
	docker build -f Dockerfile.dotcom -t $(IMAGE_DOTCOM) .

enterprise: common
	    docker build -f Dockerfile.enterprise -t $(IMAGE_ENTERPRISE) .
