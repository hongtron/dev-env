.PHONY: build

build:
	./generate-dockerfile > ./target/Dockerfile
	docker build -t hongtron/dev-env ./target/

push:
	docker push hongtron/dev-env:latest
