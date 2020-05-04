.PHONY: build

update:
	git submodule update --recursive --remote

build:
	./generate-dockerfile > ./artifacts/Dockerfile
	docker build -t hongtron/dev-env ./artifacts/

push:
	docker push hongtron/dev-env:latest
