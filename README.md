# k8s
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
#### Delete NATS deployment but keep namespace
```bash
make delete-mongodb-deploy-keep-ns
```
This command helps to keep PV (Persistent Volumes) used for database storage.  
If the configuration of the deployment itself does not change the next deployment will pick up the volumes and the data will persist between database restarts.


#### List NATS streams
```bash
make nats-stream-ls
```
