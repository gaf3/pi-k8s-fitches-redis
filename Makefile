MACHINE=$(shell uname -m)
IMAGE=pi-k8s-fitches-redis
VERSION=0.3
TAG=$(VERSION)-$(MACHINE)
PORT=6379
ACCOUNT=gaf3
NAMESPACE=fitches

ifeq ($(MACHINE),armv7l)
BASE=arm32v6/alpine:3.8
else
BASE=alpine:3.8
endif

.PHONY: build shell run push create update delete create-dev update-dev delete-dev

build:
	docker build . --build-arg BASE=$(BASE) -t $(ACCOUNT)/$(IMAGE):$(TAG)

shell: build
	docker run -it $(ACCOUNT)/$(IMAGE):$(TAG) sh

run: build
	docker run -it --rm -p 127.0.0.1:$(PORT):$(PORT) -h $(IMAGE) $(ACCOUNT)/$(IMAGE):$(TAG)

push: build
	docker push $(ACCOUNT)/$(IMAGE):$(TAG)

create:
	kubectl --context=pi-k8s create -f k8s/pi-k8s.yaml

update:
	kubectl --context=pi-k8s replace -f k8s/pi-k8s.yaml

delete:
	kubectl --context=pi-k8s delete -f k8s/pi-k8s.yaml

create-dev:
	kubectl --context=minikube create -f k8s/minikube.yaml

update-dev:
	kubectl --context=minikube replace -f k8s/minikube.yaml

delete-dev:
	kubectl --context=minikube delete -f k8s/minikube.yaml
