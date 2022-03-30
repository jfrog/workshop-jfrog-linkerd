# Hands on Workshop: DEPLOY AND MONITOR YOUR APPLICATION WITH JFROG AND LINKERD

## Instructions

### Step 1: Sign up for required/recommended accounts

- #### GitHub Account (Admin access) [Sign up](https://github.com/signup)

During the course of this workshop, you will be need to have the ability to fork accounts and to set up a Personal Access Token to integrate with JFrog Pipelines.

- #### JFrog Platform Account 
Live workshop attendees: ***USE LINK PROVIDED DURING WORKSHOP***

When signing up for the JFrog Platform Cloud Free Tier, it is recommended that you select **AWS** and the **US West 2 (Oregon)** region for this workshop.

![Screen Shot 2022-03-24 at 5 50 19 AM](https://user-images.githubusercontent.com/116261/159910660-6090b18e-31ad-4b6d-88ac-06f76df2f309.png)

After you receive your credentials by email and on your first login, select the following to ensure you get access to all of the features we will be using:

![Screen Shot 2022-03-24 at 5 58 42 AM](https://user-images.githubusercontent.com/116261/159911604-a455eba7-fdbb-4962-bd3c-384b6ea48a79.png)

This is a free account! However, in order to utilize Pipelines, you will need to provide a credit card, but you will **NOT** be charged unless you choose to upgrade your account. It takes a few minutes for JFrop Pipelines to spin up, so please enter your card details now so it will be ready when you need it.

![Screen Shot 2022-03-29 at 3 08 38 PM](https://user-images.githubusercontent.com/116261/160889250-e4160911-1364-4480-8666-bb8707bb6c84.png)

![Screen Shot 2022-03-29 at 3 09 43 PM](https://user-images.githubusercontent.com/116261/160889052-d0ab292a-9868-4bbd-978a-8a5a6291fcf5.png)


- #### Civo Account (recommended for workshop)
Live workshop attendees: ***USE LINK PROVIDED DURING WORKSHOP OR BY EMAIL.***

If you are attending a live workshop event, you will be provided access to a temporary account with $250 credit that does not require a credit card. This account will be used to create the Kubernetes cluster that will be used during the workshop for deployments. The Civo account is not required, but recommended unless you already have a separate Kubernetes cluster you would like to use.

Once you sign up for Civo, create a new cluster. Name your cluster whatever you like, choose "Medium" size, and keep the rest of the default settings.

![Screen Shot 2022-03-28 at 7 45 45 PM](https://user-images.githubusercontent.com/116261/160516006-75377e8c-a220-4c43-8708-2f39142df520.png)


### Step 2: Install required/recommended prerequisites

- #### [Install Docker Desktop](https://www.docker.com/products/docker-desktop/) or your tool of choice for pushing/pulling container images

- #### [Install Helm](https://helm.sh/docs/intro/install/) 3 or greater on your system (not required, but recommended for direct deployments or local troubleshooting)

### Step 3: Sanity test deploy of PetClinic to Kubernetes

You will need to define your target Docker registry. For now, we will use the Kubernetes images provided in the ***springcommunity*** org on Docker Hub.

```bash
export REPOSITORY_PREFIX=springcommunity
```

Create the ```spring-petclinic``` namespace and the various Kubernetes services that will be used by the deployments.

```bash
kubectl apply -f spring-petclinic-cloud/k8s/init-namespace
kubectl apply -f spring-petclinic-cloud/k8s/init-services
```

Verify the services are available:
```
✗ kubectl get svc -n spring-petclinic
NAME                TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)             AGE
api-gateway         LoadBalancer   10.7.250.24    <pending>     80:32675/TCP        36s
customers-service   ClusterIP      10.7.245.64    <none>        8080/TCP            36s
vets-service        ClusterIP      10.7.245.150   <none>        8080/TCP            36s
visits-service      ClusterIP      10.7.251.227   <none>        8080/TCP            35s
```

Deploy the required databases with helm:
```
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install vets-db-mysql bitnami/mysql --namespace spring-petclinic --version 8.8.8 --set auth.database=service_instance_db
helm install visits-db-mysql bitnami/mysql --namespace spring-petclinic  --version 8.8.8 --set auth.database=service_instance_db
helm install customers-db-mysql bitnami/mysql --namespace spring-petclinic  --version 8.8.8 --set auth.database=service_instance_db
```

Deploy the application:
```
./scripts/deployToKubernetes.sh
```

Verify the pods are deployed:
```
✗ kubectl get pods -n spring-petclinic 
NAME                                 READY   STATUS    RESTARTS   AGE
api-gateway-585fff448f-q45jc         1/1     Running   0          4m20s
customers-db-mysql-0                 1/1     Running   0          11m
customers-service-5d7d686654-kpcmx   1/1     Running   0          4m19s
vets-db-mysql-0                      1/1     Running   0          11m
vets-service-85cb8677df-l5xpj        1/1     Running   0          4m2s
visits-db-mysql-0                    1/1     Running   0          11m
visits-service-654fffbcc7-zj2jw      1/1     Running   0          4m2s
```

Get the ```EXTERNAL-IP``` of the API Gateway:
```
✗ kubectl get svc -n spring-petclinic api-gateway 
NAME          TYPE           CLUSTER-IP    EXTERNAL-IP      PORT(S)        AGE
api-gateway   LoadBalancer   10.7.250.24   34.1.2.22   80:32675/TCP   18m
```

Browse to that IP in your browser to confirm the application is running.

### Step 4: Create deployment pipeline in JFrog Pipelines

#### Step 4.1: Set up GitHub Integration




Try it!
### Step 5: Modify pipeline to deploy Linkerd Control Plane
Make it smart
Use a custom runner?
### Step 6: Inject workloads & redeploy Petclinic
Take a look at metrics, etc
### Step 7: Use a private Docker registry
