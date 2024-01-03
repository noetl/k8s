# K8s
## Install MongoDB

#### Add MongoDB Helm repository
One time command which must be executed before the first MongoDB deployment  
```bash
make helm-repo-mongodb
```
#### Deploy MongoDB
```bash
make deploy-mongodb
```
Since the database instances created by mongodb operator, it is necessary to wait while the creation is over.
In other words, database is not available when command execution is complete. 

#### Delete MongoDB deployment
```bash
make delete-mongodb-deploy
```  

Before deleting the operator it is required to wait that MongoDB deploymnet is deleted.
Deletion of CRs just triggers the deleting process of MongoDB deploymnet. At the moment when CRs are deleted MongoDB deployment still exists.
That's why MongoDB operator cannot be removed immediately, it should finish MongoDB deployement deletion.

#### Delete MongoDB operator
```bash
make delete-mongodb-operator
```

#### Delete MongoDB operator but keep namespace
```bash
make delete-mongodb-operator-keep-ns
```
This command helps to keep PV (Persistent Volumes) used for database storage.  
If the configuration of the deployment itself does not change the next deployment will pick up the volumes and the data will persist between database restarts.


## Install NATS

#### Add NATS Helm repository
One time command which must be executed before the first NATS deployment  
```bash
make helm-repo-nats
```
#### Deploy NATS
```bash
make deploy-nats
```
#### Delete NATS deployment
```bash
make delete-nats-deploy
```


#### List NATS streams
```bash
make nats-stream-ls
```

## Install Postgres

#### Add Postgres operator Helm repository
One time command which must be executed before the first Postgres deployment  
```bash
make helm-repo-postgres-operator
```
#### Deploy Postgres
```bash
make deploy-postgres
```
Since the database instances created by postgres operator, it is necessary to wait while the creation is over.
In other words, database is not available when command execution is complete. 

_Complete CR reference is_ [here](https://github.com/zalando/postgres-operator/blob/master/manifests/complete-postgres-manifest.yaml)

#### Delete Postgres deployment
```bash
make delete-postgres-deploy
```
#### Delete Postgres operator
```bash
make delete-postgres-operator
```
#### View password for root
```bash
make postgres-password-show-root
```

### Tips*
#### Connect from inside of the cluster
```bash
kubectl run psql-client --rm --tty -i --restart='Never' --namespace default --image bitnami/postgresql -- bash

export PGSSLMODE=require
export PGPASSWORD=A....

psql -U postgres -h chat-postgres.postgres.svc.cluster.local -p 5432
```
#### Connect from local host
Install psql client
```bash
brew install libpq
```
Connect
```bash
psql -U postgres -h localhost -p 30432

```
