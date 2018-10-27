IMAGE=pi-k8s-fitches-redis
VERSION=0.1
PORT=6379
ACCOUNT=gaf3
NAMESPACE=fitches

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
	kubectl --context=minikube -n $(NAMESPACE) create -f k8s/local.yaml

update-local: push
	kubectl --context=minikube -n $(NAMESPACE) replace -f k8s/local.yaml

delete-local:
	kubectl --context=minikube -n $(NAMESPACE) delete -f k8s/local.yaml
