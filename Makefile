.PHONY: build

build:
	docker build -t hongtron/dev-env .

push:
	docker push hongtron/dev-env:latest
