.PHONY: build

update:
	git submodule update --recursive --remote

build:
	./generate && docker build -t hongtron/dev-env ./artifacts/

push:
	docker push hongtron/dev-env:latest
