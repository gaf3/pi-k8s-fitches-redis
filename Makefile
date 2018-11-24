IMAGE=pi-k8s-fitches-redis
VERSION=0.3
PORT=6379
ACCOUNT=gaf3
NAMESPACE=fitches

pull:
	docker pull $(ACCOUNT)/$(IMAGE)login 

build:
	docker build . -t $(ACCOUNT)/$(IMAGE):$(VERSION)

shell: build
	docker run -it $(ACCOUNT)/$(IMAGE):$(VERSION) sh

run: build
	docker run -it --rm -p $(PORT):$(PORT) -h $(IMAGE) $(ACCOUNT)/$(IMAGE):$(VERSION)

push: build
	docker push $(ACCOUNT)/$(IMAGE):$(VERSION)

create:
	kubectl create -f k8s/pi-k8s.yaml

update:
	kubectl replace -f k8s/pi-k8s.yaml

delete:
	kubectl delete -f k8s/pi-k8s.yaml