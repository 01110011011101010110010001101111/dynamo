## CAI Data Model

Each resource in the CAI data model is scoped either at the user or organization level. For user scoping, a user can only see resources they own. For org level scoping,
users can see any resource that belongs to their organization. The user's organization and user ID are automatically included in request headers by KAS Direct. If absent, these values default to "default".
The default scoping for most resources is user, although there are some exceptions to this. To enforce org level scoping change
the `RESOURCE_SCOPE` env var in `.env`.

### Deployments

#### 1. Cluster
All clusters are required to have org level scoping. A cluster doesn't refer to a physical K8s cluster, but rather a logical cluster. It is used to provide
some separation and organization of deployments. Currently, all deployments will run on the `dynamo` namespace. Each organization must include a cluster named default because the CLI defaults to this cluster during deployment commands.

#### 2. Deployments
Deployments are user level scoped. The `deployment` entity is used to keep track of the deployment status, K8s namespace, and other metadata. A `deployment` has
1 to n `deployment_revision`'s. Each deployment always has 1 active deployment revisions.


#### 3. Deployment Revisions
Deployment revisions are user level scoped. Each revision is owned by exactly 1 `deployment`. The `deployment_revision` is used to keep track of the history of a deployment. Each `deployment_revision` can have 1 to n `deployment_target`'s.
Each revision is marked as either active or inactive. An active deployment revision indicates that its associated targets are currently running in Kubernetes, while an inactive revision refers to terminated targets, serving primarily as historical records.

#### 4. Deployment Targets
Deployment targets are user level scoped. Each target is owned by exactly 1 `deployment` and 1 `deployment_revision`. Each `deployment_target` corresponds to a single Dynamo NIM instance running in Kubernetes. These entities are used when sending requests to DMS to create
any required CRDs. They keep track of important information such as the Dynamo NIM tag which we want to build and deploy.


### Dynamo NIMs
All Dynamo NIMs should be user scoped by default. You can set the scope to "org" by setting the RESOURCE_SCOPE environment variable to "organization".

##### 1. Dynamo NIM
This is the overarching resource that is used to keep track of a complete Dynamo NIM. The Dynamo NIM resource functions similarly to a Docker repository. For a Dynamo NIM tag formatted as `<name>:<tag>`, this resource represents the `<name>` portion.
A `dynamo_nim` resource has 1 to n `dynamo_nim_version`'s.


##### 1. Dynamo NIM Version
This is corresponds to the specific Dynamo NIM. Given a dynamo nim tag of the form `<name>:<tag>`, this resource corresponds to the `<tag>` portion. A `dynamo_nim_version`
resource is owned by 1 `dynamo_nim`.
