[Additional Resources](#additional-resources)

# Hands on Workshop: Deploy and Monitor your Application with JFrog and Linkerd

This workshop will guide you through deploying the PetClinic application (cloud native version!) to your own Kubernetes cluster, after which you learn how to automate this deploy using JFrog Pipelines and finally, how to incorporate and use the Linkerd service mesh.

## Instructions

### Step 1: Sign up for required/recommended accounts

- #### GitHub Account (Admin access) [Sign up](https://github.com/signup)

During the course of this workshop, you will be need to have the ability to fork accounts and to set up a Personal Access Token to integrate with JFrog Pipelines.

- #### JFrog Platform Account 
Live workshop attendees: ***USE LINK PROVIDED DURING WORKSHOP***

Working through this on your own? Sign up for a JFrog Platform Account [here](https://bit.ly/MelissaWKSHP).

![Screen Shot 2022-03-24 at 5 50 19 AM](https://user-images.githubusercontent.com/116261/159910660-6090b18e-31ad-4b6d-88ac-06f76df2f309.png)

After you receive your credentials by email and on your first login, select the following to ensure you get access to all of the features we will be using:

![Screen Shot 2022-03-24 at 5 58 42 AM](https://user-images.githubusercontent.com/116261/159911604-a455eba7-fdbb-4962-bd3c-384b6ea48a79.png)

This is a free account! However, in order to utilize Pipelines, you will need to provide a credit card, but you will **NOT** be charged unless you choose to upgrade your account. It takes a few minutes for JFrop Pipelines to spin up, so please enter your card details now so it will be ready when you need it.

![Screen Shot 2022-03-29 at 3 08 38 PM](https://user-images.githubusercontent.com/116261/160889250-e4160911-1364-4480-8666-bb8707bb6c84.png)

![Screen Shot 2022-03-29 at 3 09 43 PM](https://user-images.githubusercontent.com/116261/160889052-d0ab292a-9868-4bbd-978a-8a5a6291fcf5.png)


- #### Civo Account (recommended for workshop)
Live workshop attendees: ***USE LINK PROVIDED DURING WORKSHOP OR BY EMAIL.***

Working through this on your own? Sign up for a JFrog Platform Account [here](https://www.civo.com/signup).

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

#### Step 4.1: Create a Personal Access Token

You will need to set up a personal access token in your GitHub account. Select ***Settings*** in the dropdown at the top right of your GitHub account web UI.

![Screen Shot 2022-03-29 at 3 37 08 PM](https://user-images.githubusercontent.com/116261/160889370-26e7770c-b305-4538-8793-42ee0f752c37.png)

In the left menu of your Profile page, scroll down and click ***Developer Settings***

![Screen Shot 2022-03-29 at 3 41 17 PM](https://user-images.githubusercontent.com/116261/160889855-baf66092-f54a-4d0a-b6fa-3a71163f3330.png)

Click ***Personal Access Tokens*** and then the ***Generate new token*** button.

![Screen Shot 2022-03-29 at 3 42 11 PM](https://user-images.githubusercontent.com/116261/160890153-6235e46b-26d2-485b-9e2e-ed131f5a8976.png)

Make sure the following scopes are selected:

* repo (all)
* admin:public_key (read, write)
* admin:repo_hook (read, write)

![Screen Shot 2022-03-29 at 3 48 42 PM](https://user-images.githubusercontent.com/116261/160890203-57a1e829-55e2-4382-89b4-6fa18b884904.png)

Click the ***Generate Token*** button and then copy the value somewhere for safekeeping. You'll need this in the next step.

#### Step 4.2: Create a GitHub Pipelines Integration

In your JFrog Platform instance, navigate to the Administration Module, expand the ***Pipelines*** menu and select ***Integrations***.

On the top right of the Integrations page, click the ***Add an Integration*** button. Name your integration ***MyRepo***.

![Screen Shot 2022-03-24 at 10 41 29 AM](https://user-images.githubusercontent.com/116261/160891357-a0d7637d-e001-4c89-a14b-b6a24208da8d.png)

#### Step 4.3: Create a Kubernetes Pipelines Integration

Create a Kubernetes Pipelines Integration in the same manner as the previous step. Name this integration ***MyCluster***.

The value in the kubeconfig field will need to be retrieved from your Civo cluster.

#### Step 4.4: Create an Artifactory Pipelines Integration

Name this integration ***MyArtifactory*** and click on the ***Get API Key*** to automatically set up your key.

#### Step 4.5: Create a Custom Runner Image to use in your Pipeline

Create Docker registries in your JFrog platform!

Use the linkerd/Dockerfile to build and push a custom image to your JFrog registry

#### Step 4.6: Set up a Pipeline Source

!!! Make sure your GitRepo resource is set correctly before creating the Pipeline Source !!!

Modify the spring-petclinic-cloud pipelines.yml file for your JFrog instance and GitHub fork.

Create the JFrog Pipeline Source.

#### Step 4.7 Run the pipeline!

Manually run the pipeline and begin your troubleshooting journey.

### Step 5: Modify pipeline to deploy Linkerd Control Plane
Make it smart
Use a custom runner!

### Step 6: Inject workloads & redeploy Petclinic
Take a look at metrics, etc

### Additional Resources
- [JFrog Docker Registry Documentation](https://www.jfrog.com/confluence/display/JFROG/Docker+Registry)
- [JFrog Pipelines Developer Guide](https://www.jfrog.com/confluence/display/JFROG/Pipelines+Developer+Guide)
- [Getting Started with Linkerd](https://linkerd.io/2.11/getting-started/)
- [Linkerd Documentation](https://linkerd.io/2.11/overview/)
