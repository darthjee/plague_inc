PROJECT?=plague_inc
IMAGE?=$(PROJECT)
BASE_VERSION?=0.1.0
BASE_IMAGE?=$(DOCKER_ID_USER)/$(PROJECT)-base
PUSH_IMAGE=$(DOCKER_ID_USER)/$(PROJECT)
DOCKER_FILE_BASE=Dockerfile.$(PROJECT)-base

all:
	@echo "Usage:"
	@echo "  make build\n    Build docker image for $(PROJECT)"
	@echo "  make build-base\n    Build base docker image for $(PROJECT)"
	@echo "  make push-base\n    Pushes base docker image for $(PROJECT) to dockerhub"

build-base:
	docker tag $(BASE_IMAGE):latest $(BASE_IMAGE):cached; \
	docker rmi $(BASE_IMAGE):latest; \
	docker build -f $(DOCKER_FILE_BASE) . -t $(BASE_IMAGE):latest -t $(BASE_IMAGE):$(BASE_VERSION); \
	if (docker images | grep $(BASE_IMAGE) | grep cached); then \
	  docker rmi $(BASE_IMAGE):cached; \
	fi \

push-base:
	make build-base
	docker push $(BASE_IMAGE)
	docker push $(BASE_IMAGE):$(BASE_VERSION)

build:
	docker build -f Dockerfile.$(PROJECT) . -t $(IMAGE) -t $(PUSH_IMAGE) -t $(PUSH_IMAGE):$(BASE_VERSION)

push:
	make build
	docker push $(PUSH_IMAGE)
	docker push $(PUSH_IMAGE):$(BASE_VERSION)

build-heroku:
	docker build -f Dockerfile.web . -t registry.heroku.com/$(PROJECT)/web

release:
	heroku container:push --recursive web
	heroku container:release web
