# Docker image name (change as needed)
IMAGE_NAME=my-ibm-mq-mtls
IMAGE_TAG=latest

# Build the Docker image
.PHONY: docker-build
docker-build:
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .

# Tag the Docker image (example: for pushing to a registry)
.PHONY: docker-tag
docker-tag:
	docker tag $(IMAGE_NAME):$(IMAGE_TAG) your-registry/$(IMAGE_NAME):$(IMAGE_TAG)

# Push the Docker image to a registry (uncomment and edit as needed)
#.PHONY: docker-push
#docker-push:
#	docker push your-registry/$(IMAGE_NAME):$(IMAGE_TAG)