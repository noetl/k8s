
NATS_DIR=nats
MONGODB_DIR=mongodb

define get_postgres_password
$(shell kubectl get secret postgres.chat-postgres.credentials.postgresql.acid.zalan.do -n postgres -o 'jsonpath={.data.password}' | base64 -d)
endef
PGPASSWORD=$(call get_postgres_password)

###[NATS]###
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


###[MONGODB]###
.PHONY: helm-repo-mongodb deploy-mongodb delete-mongodb-deploy delete-mongodb-operator delete-mongodb-operator-keep-ns

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

delete-mongodb-operator:
	@echo "Deleting MonogDB operator..."
	kubectl config use-context docker-desktop
	helm uninstall community-operator --namespace mongodb --wait
	kubectl delete namespace mongodb

delete-mongodb-operator-keep-ns:
	@echo "Deleting MonogDB operator..."
	kubectl config use-context docker-desktop
	helm uninstall community-operator --namespace mongodb --wait


###[Postgres]###
.PHONY: helm-repo-postgres-operator deploy-postgres

helm-repo-postgres-operator:
	@echo "Adding Postgres operator Helm repo..."
	helm repo add postgres-operator-charts https://opensource.zalando.com/postgres-operator/charts/postgres-operator

deploy-postgres:
	@echo "Deploying Postgres..."
	kubectl config use-context docker-desktop
	helm install postgres-operator postgres-operator-charts/postgres-operator --version=1.10.1 --namespace postgres --create-namespace --wait
	kubectl apply -f postgres/cr.yaml
	kubectl apply -f postgres/service.yaml
	@echo "Please run the following command for exporting `tput bold`PGPASSWORD`tput sgr0` and `tput bold`PGSSLMODE`tput sgr0`:"
	@echo "`tput bold`eval \"\044(make postgres-password-export-postgres)\"`tput sgr0`" 
	@echo "Connection can be established with the following parameters:"
	@echo "`tput bold`psql -U postgres -h localhost -p 30432`tput sgr0`"


delete-postgres-deploy:
	@echo "Deleting Postgres deployment..."
	kubectl config use-context docker-desktop
	kubectl delete -f postgres/service.yaml
	kubectl delete -f postgres/cr.yaml

delete-postgres-operator:
	@echo "Deleting Postgres operator..."
	kubectl config use-context docker-desktop
	helm uninstall postgres-operator --namespace postgres --wait
	kubectl delete namespace postgres

.PHONY: postgres-password-show-root postgres-password-export-postgres

postgres-password-show-root:
	@echo "root password:"
	@(kubectl get secret root.chat-postgres.credentials.postgresql.acid.zalan.do -n postgres -o 'jsonpath={.data.password}' | base64 -d)
 
postgres-password-export-postgres:
	# Non-encrypted connections are rejected by default, so set the SSL mode to require:
	@echo export PGSSLMODE=require
	@echo export PGPASSWORD=$(PGPASSWORD)
