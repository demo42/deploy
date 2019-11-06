# A list of saved commands I use during demos

## Links

- http://jengajenkins.eastus.cloudapp.azure.com
- http://demo42-helloworld.eastus.cloudapp.azure.com/
- http://demo42.eastus.cloudapp.azure.com/
- http://demo42.westeurope.cloudapp.azure.com/

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

- Setting the default registry, so each az acr command doesn't need to include `-r`

    ```sh
    az configure --defaults acr=$ACR_NAME
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

# Demo Snippets

- Listing builds
    While running the demo, I typically keep a terminal tab open with this command continually running.

    ```sh
    watch -n1 az acr build-task list-builds
    ```

## Demo: Docker build

- local build

    ```sh
    docker build -t web:uniqueid12345 -f ./src/WebUI/Dockerfile .
    ```

- local run

    ```sh
    open http://localhost:8001; \
    docker run -it --rm -p 8001:80 web:uniqueid12345
    ```

## Demo: ACR Build

- Inner-loop build

    ```sh
    az acr build -t web:{{.Build.ID} -f src/WebUI/Dockerfile .
    ctrl + c
    ```

- list the active builds

    ```sh
    watch -n1 az acr build-task list-builds
    ```

- reconnect to the log

    ```sh
    az acr build-task logs
    ```

    review the dependencies

- Build-Task Create

    ```sh
    az acr build-task create \
    -n demo42web \
    --cpu 2 \
    -t demo42/web:{{.Build.ID}} \
    -f ./src/WebUI/Dockerfile \
    --build-arg REGISTRY_NAME=$REGISTRY_NAME \
    --secret-build-arg=secureThing=dontLook \
    --context https://github.com/demo42/web \
    --branch completedish \
    --git-access-token $(az keyvault secret show \
                            --vault-name $AKV_NAME \
                            --name $GIT_TOKEN_NAME \
                            --query value -o tsv) 
    ```

- commit a change, trigger a build  
  change `web\pages\about.cshtml`

- `git commit/push`

- Listing builds

    ```sh
    watch -n1 az acr build-task list-builds
    ```

## Demo: Container Unit Testing

-  Review Unit Tests

    - Open `web/test/demo42tests/indexTests.cs`
    - Open  `web/test/demo42tests/baseImageTests.cs`
    - Open `web/src/WebUI/Dockerfile`
    - `web/src/WebUI/Dockerfile` Enable tests

    ```sh
    az acr build -f src/WebUI/Dockerfile --no-push true .
    ```

## Demo: Base Image Updates - AKS OS & Framework Patching

1.  View the About page
    -   Notice the background color
1.  Update the base image
    - Github - update aspnetcore-runtime
    - Open the dockerfile
    - Change the color
    - Watch the build-tasks `watch -n1 az acr build-task list-builds`


## Demo: Unique Tagging 
- Start with a stable deployment
- Scale replicas of the website to 2
- Get the current tag
    - Navigate to pods: http://127.0.0.1:8001/#!/pod?namespace=default
    -   Click the name of a Web pod
    - Copy tag
- Push a "minor change" for a "fix" with the same tag
- Update the color in `web\src\webui\pages\About.cshtml`

    ```html
    @page
    @model AboutModel
    <style type="text/css">
        body {
            background-color: red;
    ```
- Build the image, using `acr build`
    ```sh
    az acr build \
        -f src/WebUI/Dockerfile \
         -t demo42/web:TAG .
    ```

- Kill a pod, to force a re-instance
- Navigate to pods: http://127.0.0.1:8001/#!/pod?namespace=default
- Kill one of the **web**  pods

# Alternative Demos

## Using CLI to get POD info
- Get the current image:tag
    ```sh
    kubectl get pods
    # node one of the web pods
    kubectl describe pods/web-64b4c9fc6-574sw
    ```
