# A list of saved commands I use during demos

## Presets
- A set of env vars used for each demo
    
    Common Environment Variables
    ```sh
    # Replace these values for your configuration
    # I've left our values in, as we use this for our demos, providing some examples
    export ACR_NAME=jengademos
    export RESOURCE_GROUP=$ACR_NAME
    # fully qualified url of the registry. 
    # This is where your registry would be
    # Accounts for registries in dogfood or other clouds like .gov, Germany and China
    export REGISTRY_NAME=${ACR_NAME}.azurecr.io/ 
    export AKV_NAME=$ACR_NAME-vault # name of the keyvault
    export GIT_TOKEN_NAME=stevelasker-git-access-token # keyvault secret name
    ```
- Demo presets
    export TAG=dev1

- Setting the default registry, so each az acr command doesn't need to include `-r`
    ```sh
    az configure --defaults acr=$ACR_NAME
    ```

## ACR Snippets
- Listing builds
    While running the demo, I typically keep a terminal tab open with this command continually running.
    ```sh
    watch -n1 az acr build-task list-builds
    ```

- Running a build
    ```sh
    az acr build-task run -n demo42quotesapi
    ```
## Developing Locally
- Get your db connection string 

    ```sh
    export CONNECTIONSTRING=$(az keyvault secret show \
                                --vault-name $AKV_NAME \
                                --name demo42-quotes-sql-connectionstring-eastus \
                                --query value -o tsv)
    ```
- Local builds
    ```sh
    docker-compose build \
    --build-arg REGISTRY_NAME=$REGISTRY_NAME
    docker-compose up
    open http://localhost
    ```

- Cleanup null images
    ```sh
    docker rmi $(docker images --quiet --filter "dangling=true")
    ```

- Get AKS Credentials
    ```sh
    # EastUS
    az aks get-credentials -g acrdemoaks -n acrdemoeus
    # West Europe
    az aks get-credentials -g acrdemoaksweu -n acrdemoweu
    ```
- Browsing the AKS Cluster - Kube Dashboard

  I typically leave this in it's own tab

    ```sh
    # EastUS
    az aks browse -g acrdemoaks -n acrdemoeus
    # West Europe
    az aks browse -g acrdemoaksweu -n acrdemoweu
    ```

# Demo: Unique Tagging 
1. Start with a stable deployment
1. Bump replicas of the website to 4
    - open `deploy/templates/webapp.yaml`
        ```yaml
        spec: 
        replicas: 4
        ```
1. Update `web\src\webui\pages\About.cshtml` with the following snippet to change the color
    ```html
    @page
    @model AboutModel
    <style type="text/css">
        body {
            background-color: red;
        }
    </style>
    ```
1. browse the kubernetes dashboard
1. Navigate to pods: http://127.0.0.1:8001/#!/pod?namespace=default
1. Click the name of a Web pod
1. Copy the full image:tag as we'll replace that exact tag with a different version
1. Re-tag the dev image you just made

    - `docker tag $REGISTRY_NAME/demo42/web:dev1` [pasted value]
    - `docker push `[pasted value]
1. Back in the Kubernetes portal, kill one of the running pods

# Base Image Updates - AKS OS & Framework Patching

1.  View the About page
    -   Notice the Base **Image Version** and the **Image Built Date**
1.  Rebuild the base image
    - Run the script `web/src/baseImage/updateBaseImages.sh`
    - Watch the build-tasks `watch -n1 az acr build-task list-builds`
# Alternative Demos

## Using CLI to get POD info
- Get the current image:tag
    ```sh
    kubectl get pods
    # node one of the web pods
    kubectl describe pods/web-64b4c9fc6-574sw
    ```
