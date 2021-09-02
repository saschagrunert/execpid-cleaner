.PHONY:	build push all all-build all-push-images all-push push-manifest

REGISTRY ?= quay.io/crio
IMAGE = $(REGISTRY)/execpid-cleaner

TAG ?= $(shell git describe --tags --always --dirty)
IMAGE_VERSION ?= v0.2.0

ARCH ?= amd64
ALL_ARCH = amd64 arm arm64 ppc64le s390x

QEMUVERSION=5.2.0-2

# This option is for running docker manifest command
export DOCKER_CLI_EXPERIMENTAL := enabled

SUDO=$(if $(filter 0,$(shell id -u)),,sudo)

build:
	# Fix possible issues with the local umask
	umask 0022

	# Enable execution of multi-architecture containers
	docker run --rm --privileged multiarch/qemu-user-static:$(QEMUVERSION) --reset -p yes
	docker buildx version
	BUILDER=$(shell docker buildx create --use)
	docker buildx build \
		--pull \
		--load \
		--platform linux/$(ARCH) \
		-t $(IMAGE)-$(ARCH):$(IMAGE_VERSION) \
		-t $(IMAGE)-$(ARCH):$(TAG) \
		-t $(IMAGE)-$(ARCH):latest \
		.
	docker buildx rm $$BUILDER

push: build
	docker push $(IMAGE)-$(ARCH):$(IMAGE_VERSION)
	docker push $(IMAGE)-$(ARCH):$(TAG)
	docker push $(IMAGE)-$(ARCH):latest

sub-build-%:
	$(MAKE) ARCH=$* build

all-build: $(addprefix sub-build-,$(ALL_ARCH))

sub-push-image-%:
	$(MAKE) ARCH=$* push

all-push-images: $(addprefix sub-push-image-,$(ALL_ARCH))

all-push: all-push-images push-manifest

push-manifest:
	docker manifest create --amend $(IMAGE):$(IMAGE_VERSION) $(shell echo $(ALL_ARCH) | sed -e "s~[^ ]*~$(IMAGE)\-&:$(IMAGE_VERSION)~g")
	@for arch in $(ALL_ARCH); do docker manifest annotate --arch $${arch} ${IMAGE}:${IMAGE_VERSION} ${IMAGE}-$${arch}:${IMAGE_VERSION}; done
	docker manifest push --purge ${IMAGE}:${IMAGE_VERSION}

all: all-push
