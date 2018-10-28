IMAGE=pi-k8s-fitches-redis
VERSION=0.2
PORT=6379
ACCOUNT=gaf3
NAMESPACE=fitches
LOCAL=minikube
PRODUCTION=pi-k8s

pull:
	docker pull $(ACCOUNT)/$(IMAGE)

build:
	docker build . -t $(ACCOUNT)/$(IMAGE):$(VERSION)

shell: build
	docker run -it $(ACCOUNT)/$(IMAGE):$(VERSION) sh

run: build
	docker run -it --rm -p $(PORT):$(PORT) -h $(IMAGE) $(ACCOUNT)/$(IMAGE):$(VERSION)

push: build
	docker push $(ACCOUNT)/$(IMAGE):$(VERSION)

create-local: push
	kubectl --context=$(LOCAL) -n $(NAMESPACE) create -f k8s/local.yaml

update-local: push
	kubectl --context=$(LOCAL) -n $(NAMESPACE) replace -f k8s/local.yaml

delete-local:
	kubectl --context=$(LOCAL) -n $(NAMESPACE) delete -f k8s/local.yaml

create: push
	kubectl --context=$(PRODUCTION) -n $(NAMESPACE) create -f k8s/production.yaml

update: push
	kubectl --context=$(PRODUCTION) -n $(NAMESPACE) replace -f k8s/production.yaml

delete:
	kubectl --context=$(PRODUCTION) -n $(NAMESPACE) delete -f k8s/production.yaml
