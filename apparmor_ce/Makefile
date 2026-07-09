IMAGE_NAME=label_et_la_bete_apparmor
CONTAINER_NAME=label_bete_aa

.PHONY: build run stop clean logs shell

build:
	docker build -t $(IMAGE_NAME):latest .

run:
	docker run -d \
		--name $(CONTAINER_NAME) \
		--privileged \
		--security-opt apparmor=unconfined \
		-p 2223:22 \
		$(IMAGE_NAME):latest
	@echo ""
	@echo "=============================================="
	@echo " Challenge pret !"
	@echo " ssh -p 2223 player@localhost  (pass: player)"
	@echo "=============================================="

stop:
	docker stop $(CONTAINER_NAME) 2>/dev/null || true
	docker rm $(CONTAINER_NAME) 2>/dev/null || true

logs:
	docker logs -f $(CONTAINER_NAME)

shell:
	docker exec -it $(CONTAINER_NAME) /bin/bash

aa-status:
	docker exec $(CONTAINER_NAME) aa-status

clean: stop
	docker rmi $(IMAGE_NAME):latest 2>/dev/null || true
