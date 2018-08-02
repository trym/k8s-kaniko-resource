# k8s-kaniko-resource

Concourse resource for building docker images with kaniko directly on a kubernetes cluster.

> __Work In Progress__  
> Currently requires google cloud storage bucket for intermediate storage.

## Usage

### Source Configuration

| Property             | Required   | Description                                                                                                                                                     |
|----------------------|------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `k8s_cluster_url`    | *Required* | URL to Kubernetes Master API service                                                                                                                            |
| `k8s_cluster_ca`     | *Optional* | Base64 encoded PEM. Required if `k8s_cluster_url` is https.                                                                                                     |
| `k8s_token`          | *Optional* | Bearer k8s_token for Kubernetes.  This, 'k8s_token_path' or `k8s_admin_key`/`k8s_admin_cert` are required if `k8s_cluster_url` is https.                        |
| `k8s_token_path`     | *Optional* | Path to file containing the bearer k8s_token for Kubernetes.  This, 'k8s_token' or `k8s_admin_key`/`k8s_admin_cert` are required if `k8s_cluster_url` is https. |
| `k8s_admin_key`      | *Optional* | Base64 encoded PEM. Required if `k8s_cluster_url` is https and no `k8s_token` or 'k8s_token_path' is provided.                                                  |
| `k8s_admin_cert`     | *Optional* | Base64 encoded PEM. Required if `k8s_cluster_url` is https and no `k8s_token` or 'k8s_token_path' is provided.                                                  |
| `gcloud_credentials` | *Required* | Base64 encoded json gcloud credentials                                                                                                                          |
| `gcloud_bucket`      | *Required* | Name of GCS bucket to use for build contexts                                                                                                                    |

### Behavior

#### `check`: Not supported
#### `in`: Not Supported
#### `out`: Build and push docker image

### Parameters

| Parameter       | Required / default | Description                                                                           |
|-----------------|--------------------|---------------------------------------------------------------------------------------|
| `image_name`    | *Required*         | Name of the docker image (e.g. my/image)                                              |
| `registry`      | *Required*         | The docker registry to push image to                                                  |
| `tag_file`      | *Required*         | File containing the tag to use for docker image                                       |
| `build_context` | "."                | Path to docker build context                                                          |
| `dockerfile`    | "Dockerfile"       | Path to Dockerfile, relative to build context                                         |
| `start_timeout` | "300"              | How many seconds to wait for build pod to start, e.g. waiting for available resources |
| `build_timeout` | "600"              | Number of seconds the build is allowed to run                                         |


## Development

### Run tests

```bash
docker build -t k8s-kaniko-resource .
docker run \
  --rm \
  --env K8S_CLUSTER_URL="..." \
  --env K8S_CLUSTER_CA="..." \
  --env K8S_TOKEN="..." \
  --env GCLOUD_CREDENTIALS="..." \
  --env GCLOUD_BUCKET="..." \
  --env BUILD_ID=local \
  --env BUILD_TEAM_NAME=main \
  -v "$PWD/.:/opt/resource" \
  -it \
  k8s-kaniko-resource -c 'assets/out test/source < <(envsubst < test/payload.json)'
```
