# Hw3 Datastore

## Google Cloud Platform -> Create New Project

## Datastore -> Datastore mode -> Create Database

## IAM & Admin -> Service Accounts
There is a default, Click KEYS -> ADD KEYS -> CREATE NEW KEYS -> JSON, will auto download

## Change TaskServlet.java Line 69’s Route to myself, but gonna have a bug
```
HTTP ERROR 500 com.google.cloud.datastore.DatastoreException:
no matching index found. recommended index is: - kind: Task
properties: - name: done - name: created direction: desc
```

## Need to comment out Line 206, it will run, like this
```
All task entities in ascending order of creation time: Not Finished Task
```

## But we need to add some task, comment out Line 87, will create new task.
```
All task entities in ascending order of creation time:
created time: Fri Apr 16 19:51:05 CST 2021 ; done: false
Not Finished Task
created time: Fri Apr 16 19:51:05 CST 2021 ; description: Learn Cloud Datastore Query
```

## Fix bug
Install Google Cloud SDK Finished
```
gcloud init 
```
Install Datastore Emulator
```
gcloud components install cloud-datastore-emulator
```
Run Server
```
cmd: gcloud beta emulators datastore start
```
Now I need to set variables
```
gcloud beta emulators datastore env-init > set_vars.cmd && set_vars.cmd
```
Local test, In TaskServlet.java
``` JAVA
// Line 43
private Datastore datastore = DatastoreOptions.newBuilder()
	.setHost("http://localhost:8081")
	.setProjectId("gae-hw3-project")
	.build()
	.getService();
// Line 47
private KeyFactory keyFactory = datastore.newKeyFactory().
	setKind("Task");
```
Comment out Line 85, 88, bug will fixed, like this:
```
All task entities in ascending order of creation time:
created time: Fri Apr 16 19:51:05 CST 2021 ; done: false
created time: Fri Apr 16 19:51:06 CST 2021 ; done: false
Not Finished Task
created time: Fri Apr 16 19:51:06 CST 2021 ; description: Learn Cloud Datastore Query
created time: Fri Apr 16 19:51:05 CST 2021 ; description: Learn Cloud Datastore Query
```

Generate file will be locate at:
```
C:\Users\rhy3h\AppData\Roaming\gcloud\emulators\datastore\WEB-INF\index.yaml
```
Now Deploying the index file
```
gcloud app deploy index.yaml
```
Datastore -> Indexes, will like this
 
## Undo Action, to make sure server is ok
Local test, In TaskServlet.java
``` JAVA
// Line 43:
private Datastore datastore;
// Line 47:
private KeyFactory keyFactory;
```

## [TaskServlet](https://rhy3h-gae.appspot.com/#TaskServlet)
Comment out Line 85, 88, like this:
```
All task entities in ascending order of creation time:
created time: Fri Apr 16 19:51:05 CST 2021 ; done: false
created time: Fri Apr 16 19:51:06 CST 2021 ; done: false
created time: Fri Apr 16 19:56:10 CST 2021 ; done: false
Not Finished Task
created time: Fri Apr 16 19:56:10 CST 2021 ; done: false
created time: Fri Apr 16 19:51:06 CST 2021 ; description: Learn Cloud Datastore Query
created time: Fri Apr 16 19:51:05 CST 2021 ; description: Learn Cloud Datastore Query
```