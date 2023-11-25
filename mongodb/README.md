### Connect from the computer to MongoDB.
By default `chat-mongodb-0` should be primary.  
Connect to `chat-mongodb-0`
```
mongosh "mongodb://superuser:chatbackend12@localhost:30017/admin?ssl=false"
```
`chat-mongodb-1` is secondary.   
Connect to `chat-mongodb-1`
```
mongosh "mongodb://superuser:chatbackend12@localhost:31017/admin?ssl=false"
```

### Check MongoDB connection inside of Kubernetes
```
k exec -n mongodb -it chat-mongodb-0 -c mongod -- bash
mongosh "mongodb://superuser:chatbackend123@chat-mongodb-0.chat-mongodb-svc.mongodb.svc.cluster.local:27017/?replicaSet=chat-mongodb&ssl=false&readPreference=primary"
```


#### **Tips

Connect to Docker VM.

```
docker run -it --rm --privileged --pid=host alpine:edge nsenter -t 1 -m -u -n -i sh
```

Check persistent volumes inside of the Docker VM.
```
ls -al /var/lib/k8s-pvs/
```
