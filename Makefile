
NATS_DIR=nats
MONGODB_DIR=mongodb

#[NATS]###################################################################
.PHONY: helm-repo-nats deploy-nats delete-nats-deploy nats-stream-ls

helm-repo-nats:
	@echo "Adding NATS Helm repo..."
	helm repo add nats https://nats-io.github.io/k8s/helm/charts/
	helm repo update

deploy-nats:
	@echo "Deploying NTAS..."
	kubectl config use-context docker-desktop
	helm install nats nats/nats --version=1.1.5 --values $(NATS_DIR)/values.yaml --namespace nats --create-namespace --wait
	kubectl apply -f https://github.com/nats-io/nack/releases/download/v0.14.0/crds.yml
	helm install nack nats/nack --version=0.25.0 --set jetstream.nats.url=nats://nats:4222 --namespace nats --wait
	@echo "NATS_URL=nats://localhost:32222"
	nats stream ls -s nats://localhost:32222


delete-nats-deploy:
	@echo "Deleting NTAS deployment..."
	kubectl config use-context docker-desktop
	helm uninstall nack --namespace nats --wait
	kubectl delete -f https://github.com/nats-io/nack/releases/download/v0.14.0/crds.yml
	helm uninstall nats --namespace nats --wait
	kubectl delete namespace nats

nats-stream-ls:
	nats stream ls -s nats://localhost:32222


#[MONGODB]###################################################################
.PHONY: helm-repo-mongodb deploy-mongodb delete-mongodb-deploy delete-mongodb-deploy-keep-ns

helm-repo-mongodb:
	@echo "Adding MonogDB Helm repo..."
	helm repo add mongodb https://mongodb.github.io/helm-charts
	helm repo update

deploy-mongodb:
	@echo "Deploying MonogDB..."
	kubectl config use-context docker-desktop
	helm install community-operator mongodb/community-operator --version=0.8.3 --namespace mongodb --create-namespace --wait
	kubectl apply -f $(MONGODB_DIR)/cr.yaml --namespace mongodb
	kubectl apply -f $(MONGODB_DIR)/service.yaml --namespace mongodb
	@echo 'MongoDB Primary: mongosh "mongodb://superuser:chatbackend123@localhost:30017/admin?ssl=false"'
	@echo 'MongoDB Secondary: mongosh "mongodb://superuser:chatbackend123@localhost:31017/admin?ssl=false"'

delete-mongodb-deploy:
	@echo "Deleting MonogDB deployment..."
	kubectl config use-context docker-desktop
	kubectl delete -f $(MONGODB_DIR)/cr.yaml --namespace mongodb
	kubectl delete -f $(MONGODB_DIR)/service.yaml --namespace mongodb
	helm uninstall community-operator --namespace mongodb --wait
	kubectl delete namespace mongodb

delete-mongodb-deploy-keep-ns:
	@echo "Deleting MonogDB deployment..."
	kubectl config use-context docker-desktop
	kubectl delete -f $(MONGODB_DIR)/cr.yaml --namespace mongodb
	kubectl delete -f $(MONGODB_DIR)/service.yaml --namespace mongodb
	helm uninstall community-operator --namespace mongodb --wait
