

VERSION=0.0.1
IMAGE_NAME=test_containers

 .PHONY: clear_dev_env
clear_dev_env:
		rm -Rf .venv

 .PHONY: create_dev_env
create_dev_env:
		python3 -m venv .venv
		.venv/bin/pip install pip pep8 docker deepdiff pylint autopep8

 .PHONY: lintcreate_dev_env
lint:
		pylint test_containers.py

format:
		autopep8 --in-place --aggressive --recursive .

tests:
		python -m unittest discover  -p '*_test.py'

verify:  lint format tests

create_container:
		docker build . -t osvaldopina/$(IMAGE_NAME):latest -t osvaldopina/$(IMAGE_NAME):$(VERSION)

verify_inside_container:
		docker run -t \
			-v /var/run/docker.sock:/var/run/docker.sock \
			-v $(shell pwd):/opt/build/ \
			-e HTTPSERVERVOLUME=$(shell pwd)/httpservervolume \
			osvaldopina/$(IMAGE_NAME):latest \
			sh -c "cd /opt/build && make verify"

exec_test_inside_container_script:
		docker run \
			-v $(shell pwd)/testsConfig/test_execScript_config.json:/app/config.json \
			-v $(shell pwd)/testsConfig/execScriptTest.py:/app/execScriptTest.py \
			-v /var/run/docker.sock:/var/run/docker.sock \
		    -e HTTPSERVERVOLUME=$(shell pwd)/httpservervolume \
			-t osvaldopina/$(IMAGE_NAME):latest

exec_test_inside_container_container:
		docker run \
			-v $(shell pwd)/testsConfig/test_execContainer_config.json:/app/config.json \
			-v /var/run/docker.sock:/var/run/docker.sock \
		    -e HTTPSERVERVOLUME=$(shell pwd)/httpservervolume \
			-t osvaldopina/$(IMAGE_NAME):latest

build: create_container verify_inside_container exec_test_inside_container_script exec_test_inside_container_container

push: build
		docker push --all-tags osvaldopina/$(IMAGE_NAME)
  