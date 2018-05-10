up:
	mkdir -p webs/$(DOMAIN)
	touch webs/$(DOMAIN)/index.html
	COMPOSE_PROJECT_NAME=$(DOMAIN) docker-compose up -d --build

down:
	COMPOSE_PROJECT_NAME=$(DOMAIN) docker-compose down

destroy:
	COMPOSE_PROJECT_NAME=$(DOMAIN) docker-compose down -v

restart:
	COMPOSE_PROJECT_NAME=$(DOMAIN) docker-compose restart

sh:
	docker exec -ti $(DOMAIN)_nginx sh

backup:
	mkdir -p backups
	docker exec -ti $(DOMAIN)_nginx tar -zcvf /tmp/code.tar.gz /code
	docker cp $(DOMAIN)_nginx:/tmp/code.tar.gz backups/$(DOMAIN).tar.gz
	docker exec -ti $(DOMAIN)_nginx rm -rf /tmp/code.tar.gz

recover:
	docker cp backups/$(DOMAIN).tar.gz $(DOMAIN)_nginx:/tmp/code.tar.gz
	docker exec -ti $(DOMAIN)_nginx sh -c 'rm -rf /code/* && tar -zxvf /tmp/code.tar.gz --strip-components=1 -C /code && rm /tmp/code.tar.gz'

nginx-proxy-start:
	docker run -d --restart=always --net=host -p 80:80 -p 443:443 -v $(dir $(abspath $(lastword $(MAKEFILE_LIST))))certs:/etc/nginx/certs:ro -v /var/run/docker.sock:/tmp/docker.sock:ro jwilder/nginx-proxy

nginx-proxy-stop:
	docker rm $$(docker stop $$(docker ps -a -q --filter ancestor=jwilder/nginx-proxy --format="{{.ID}}"))

nginx-proxy-restart:
	-make nginx-proxy-stop
	make nginx-proxy-start

docker-install-ubuntu:
	apt-get update
	apt-get install -y apt-transport-https ca-certificates curl software-properties-common
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
	apt-key fingerprint 0EBFCD88
	add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $$(lsb_release -cs) stable"
	apt-get update
	apt-get install -y docker-ce
	curl -L https://github.com/docker/compose/releases/download/1.18.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
	chmod +x /usr/local/bin/docker-compose

test-clean:
	DOMAIN=one.example.com make destroy
	DOMAIN=two.example.com make destroy

test-setup:
	DOMAIN=one.example.com make up
	DOMAIN=two.example.com make up
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout certs/one.example.com.key -out certs/one.example.com.crt -subj "/CN=one.example.com"
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout certs/two.example.com.key -out certs/two.example.com.crt -subj "/CN=two.example.com"
	sleep 10

test:
	bats ./tests.bats

test-run:
	make test-clean
	make test-setup
	make test