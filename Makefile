.PHONY: build

build: update
	./generate && docker build -t hongtron/dev-env ./artifacts/

push:
	docker push hongtron/dev-env:latest

update:
	git submodule init
	git submodule update --recursive --remote
