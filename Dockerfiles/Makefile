.PHONY: help version build buildongithubactions pushtodockerhub pushtoawsecr test down cleandocker

VERSION_PHP        := $(VERSION_PHP)
VERSION_PHP_MINOR  := $(shell cut -d '.' -f 1 <<< $(VERSION_PHP)).$(shell cut -d '.' -f 2 <<< $(VERSION_PHP))
VERSION_PHP_MAJOR  := $(shell cut -d '.' -f 1 <<< $(VERSION_PHP))
VERSION_NGINX          := $(VERSION_NGINX)
VERSION_OS             := $(VERSION_OS)
VERSION                := $(VERSION_PHP)-fpm-$(VERSION_OS)-nginx-$(VERSION_NGINX)
IS_LATEST              := $(IS_LATEST)

GIT_COMMIT_HASH  := $(shell git rev-parse --short HEAD)
AWS_REGION       := $(AWS_REGION)
AWS_ACCOUNT_ID   := $(AWS_ACCOUNT_ID)

NAME_VENDOR      := moneymatch
NAME_PROJECT     := nginx-php-fpm
NAME_IMAGE_REPO  := $(NAME_VENDOR)/$(NAME_PROJECT)
REPO_HOST_AWS    := ${REPO_HOST}
TAG_REPO_URI_AWS := ${TAG_REPO_URI_AWS}

VERSION_LARAVEL      := $(VERSION_LARAVEL)
NAME_PROJECT_LARAVEL := laravel-$(VERSION_LARAVEL)
NAME_PROJECT_LARAVEL_BITNAMI := laravel-bitnami-$(VERSION_LARAVEL)

help:
	@ echo 'Welcome to Makefile of moneymatch/nginx-php-fpm'
	@ echo
	@ echo 'Usage: make [command]'
	@ echo
	@ echo 'Available Commands:'
	@ echo '  version          check version info'
	@ echo '  build            build base docker image'
	@ echo '  release          release docker images to Docker Hub and AWS ECR Public'
	@ echo '  test             test using docker-compose up'
	@ echo '  down     	       docker-compose down'
	@ echo

version:
	@ echo '====================================================================='
	@ echo '====================================================================='
	@ echo '{'
	@ echo '  "GIT_COMMIT_HASH":       "$(GIT_COMMIT_HASH)",'
	@ echo '  "VERSION_PHP":       	   "$(VERSION_PHP)"'
	@ echo '  "VERSION_PHP_MINOR":     "$(VERSION_PHP_MINOR)"'
	@ echo '  "VERSION_PHP_MAJOR":     "$(VERSION_PHP_MAJOR)"'
	@ echo '  "VERSION_NGINX":         "$(VERSION_NGINX)"'
	@ echo '  "VERSION_OS":            "$(VERSION_OS)"'
	@ echo '  "VERSION":               "$(VERSION)"'
	@ echo '  "NAME_IMAGE_REPO":       "$(NAME_IMAGE_REPO)"'
	@ echo '  "TAG_REPO_URI_AWS":      "$(TAG_REPO_URI_AWS)"'
	@ echo '  "VERSION_LARAVEL":       "$(VERSION_LARAVEL)"'
	@ echo '  "NAME_PROJECT_LARAVEL":  "$(NAME_PROJECT_LARAVEL)"'
	@ echo '}'
	@ echo '====================================================================='
	@ echo '====================================================================='

build: version
	@ echo '====================================================================='
	@ echo '[] Building base image...'
	@ echo '====================================================================='

ifeq ($(IS_LATEST),true)
	echo 'IS_LATEST=true'

	time docker build \
	--cache-from "$(NAME_IMAGE_REPO):latest" \
	--build-arg BUILDKIT_INLINE_CACHE=1	\
	-f $(VERSION_OS)/Dockerfile-$(VERSION) \
	-t $(NAME_IMAGE_REPO):$(VERSION) \
	-t $(NAME_IMAGE_REPO):latest .
else
	echo 'IS_LATEST=false or unknown'

	time docker build \
	--cache-from "$(NAME_IMAGE_REPO):$(VERSION)" \
	--build-arg BUILDKIT_INLINE_CACHE=1	\
	-f $(VERSION_OS)/Dockerfile-$(VERSION) \
	-t $(NAME_IMAGE_REPO):$(VERSION) .
endif

	docker images

release: version cleandocker
	@ echo '====================================================================='
	@ echo '====================================================================='
	@ echo '[] Building images and push to Docker Hub & AWS ECR Public...'

	@ echo '[] Login AWS ECR Public...'
	aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin ${REPO_HOST_AWS}

	@ echo '[] Login Docker Hub...'
	cat ~/.docker/dhtoken.txt | docker login -u dwchiang --password-stdin

	@ echo '[] Check Docker environment...'
	docker version
	docker buildx ls

	docker buildx ls
	docker buildx create --name buildnginxphpfpm
	docker buildx use buildnginxphpfpm
	docker buildx inspect --bootstrap

ifeq ($(IS_LATEST),true)
	echo 'IS_LATEST=true'

	docker buildx build --progress=plain --push --platform=linux/amd64,linux/arm64 -f $(VERSION_OS)/Dockerfile-$(VERSION) -t $(NAME_IMAGE_REPO):latest -t $(NAME_IMAGE_REPO):$(VERSION) -t $(TAG_REPO_URI_AWS):latest -t $(TAG_REPO_URI_AWS):$(VERSION) .
else
	echo 'IS_LATEST=false or unknown'

	docker buildx build --progress=plain --push --platform=linux/amd64,linux/arm64 -f $(VERSION_OS)/Dockerfile-$(VERSION) -t $(NAME_IMAGE_REPO):$(VERSION) -t $(TAG_REPO_URI_AWS):$(VERSION) .
endif

	docker buildx stop
	docker buildx rm buildnginxphpfpm

	docker images

	@ echo '====================================================================='
	@ echo '====================================================================='

	sleep 15

releaseDockerHub: version cleandocker
	@ echo '====================================================================='
	@ echo '====================================================================='
	@ echo '[] Building images and push to Docker Hub ...'

	@ echo '[] Login Docker Hub...'
	cat ~/.docker/dhtoken.txt | docker login -u dwchiang --password-stdin

	@ echo '[] Check Docker environment...'
	docker version
	docker buildx ls

	docker buildx ls
	docker buildx create --name buildnginxphpfpm
	docker buildx use buildnginxphpfpm
	docker buildx inspect --bootstrap

ifeq ($(IS_LATEST),true)
	echo 'IS_LATEST=true'

	docker buildx build --progress=plain --push --platform=linux/amd64,linux/arm64 -f $(VERSION_OS)/Dockerfile-$(VERSION) -t $(NAME_IMAGE_REPO):latest -t $(NAME_IMAGE_REPO):$(VERSION) .
else
	echo 'IS_LATEST=false or unknown'

	docker buildx build --progress=plain --push --platform=linux/amd64,linux/arm64 -f $(VERSION_OS)/Dockerfile-$(VERSION) -t $(NAME_IMAGE_REPO):$(VERSION) .
endif

	docker buildx stop
	docker buildx rm buildnginxphpfpm

	docker images

	@ echo '====================================================================='
	@ echo '====================================================================='

	sleep 15

### not yet review below this line -----------------------------------------------------

buildongithubactions: version
	@ echo '[] Building image on GitHub Actions and push to Docker Hub...'

	@ echo '[] Building image on GitHub Actions and push to AWS ECR Public...'
	aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws

ifeq ($(IS_LATEST),true)
	echo 'IS_LATEST=true'

	time docker buildx build \
	--push \
	--platform=linux/amd64,linux/arm64 \
	-f $(VERSION_OS)/Dockerfile-$(VERSION) \
	-t $(NAME_IMAGE_REPO):latest \
	-t $(NAME_IMAGE_REPO):$(VERSION) \
	-t $(TAG_REPO_URI_AWS):latest \
	-t $(TAG_REPO_URI_AWS):$(VERSION) .
else
	echo 'IS_LATEST=false or unknown'

	time docker buildx build \
	--push \
	--platform=linux/amd64,linux/arm64 \
	-f $(VERSION_OS)/Dockerfile-$(VERSION) \
	-t $(NAME_IMAGE_REPO):$(VERSION) \
	-t $(TAG_REPO_URI_AWS):$(VERSION) .
endif

	@ echo '[] Finished build image on GitHub Actions...'

pushtoawsecr: build
	@ echo '[] Login AWS ECR ...'
	# Phased out AWS CLI v1
	# aws ecr get-login --no-include-email --region $(AWS_REGION) | /bin/bash

	# Required: AWS CLI v2
	aws ecr get-login-password --region $(AWS_REGION) | docker login --username AWS --password-stdin $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com

	# docker tag $(NAME_IMAGE_REPO):latest $(TAG_REPO_URI_AWS):latest
	# docker tag $(NAME_IMAGE_REPO):latest $(TAG_REPO_URI_AWS):$(VERSION)

	@ echo '[] Pushing to AWS ECR ...'
	# docker push $(TAG_REPO_URI_AWS):$(VERSION)

test:
	docker-compose -f docker-compose-$(VERSION_LARAVEL)-laravel.yml up -d database cache app

	@ echo 'Ready!'
	@ echo ''
	@ echo 'MySQL: expose port:'
	@ echo '  localhost:33062'
	@ echo ''
	@ echo 'Redis: expose port:'
	@ echo '  localhost:63792'
	@ echo ''
	@ echo 'Open your browser and test at: '
	@ echo '  +----------------------------------------------------------+'
	@ echo '  |  http://localhost:8082/                                  |'
	@ echo '  +----------------------------------------------------------+'
	@ echo ''

testbitnami:
	docker-compose -f docker-compose-$(VERSION_LARAVEL)-laravel-bitnami.yml up -d database cache app

	@ echo 'Ready!'
	@ echo ''
	@ echo 'MySQL: expose port:'
	@ echo '  localhost:33062'
	@ echo ''
	@ echo 'Redis: expose port:'
	@ echo '  localhost:63792'
	@ echo ''
	@ echo 'Open your browser and test at: '
	@ echo '  +----------------------------------------------------------+'
	@ echo '  |  http://localhost:8082/                                  |'
	@ echo '  +----------------------------------------------------------+'
	@ echo ''


seedlaravel:
	@ echo '[] Seeding in your laravel container... (please `make test` first)'

	docker-compose -f docker-compose-$(VERSION_LARAVEL)-laravel.yml exec app php artisan migrate
	docker-compose -f docker-compose-$(VERSION_LARAVEL)-laravel.yml exec app php artisan db:seed

down:
	docker-compose -f docker-compose-$(VERSION_LARAVEL)-laravel.yml down

downbitnami:
	docker-compose -f docker-compose-$(VERSION_LARAVEL)-laravel-bitnami.yml down

clean:
	docker-compose -f docker-compose-$(VERSION_LARAVEL)-laravel.yml down -v --rmi local --remove-orphans
	docker image prune -f
	docker images

cleanbitnami:
	docker-compose -f docker-compose-$(VERSION_LARAVEL)-laravel-bitnami.yml down -v --rmi local --remove-orphans
	docker image prune -f
	docker images

cleanEcrUntagged:
#@ echo '[] Login AWS ECR Public...'
#aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws

	$(eval IMAGES_TO_DELETE := $(shell aws ecr-public list-images --region us-east-1 --repository-name '$(NAME_PROJECT)' --filter "tagStatus=UNTAGGED" --query 'imageIds[*]' --output json))
	echo $(IMAGES_TO_DELETE)
#aws ecr-public batch-delete-image --region us-east-1 --repository-name $(NAME_PROJECT) --image-ids "$(IMAGES_TO_DELETE)" || true
	
cleandocker:	
	docker container prune --force
	docker image prune --all --force
	docker system prune --force
	docker system df