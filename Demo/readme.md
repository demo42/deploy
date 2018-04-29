# A list of saved commands I use during demos

## Presets
- A set of env vars used for each demo
    ```sh
    # Replace these values for your configuration
    # I've left our values in, as we use this for our demos, providing some examples
    export KEYVAULT=stevelaskv
    # the secret name referenced within keyvault
    export GIT_TOKEN_NAME=stevelasker-git-access-token
    # where just the registry name is required
    export ACR_NAME=jengademos
    # fully qualified url of the registry. 
    # This is where your registry would be
    # Accounts for registries in dogfood or other clouds like .gov, Germany and China
    export REGISTRY_NAME=$ACR_NAME.azurecr.io/
    ```
- Setting the default registry, so each az acr command doesn't need to include `-r`
    ```sh
    az configure --defaults acr=$ACR_NAME
    ```
- Listing builds
    While running the demo, I typically keep a terminal tab open with this command continually running.
    ```sh
    watch -n1 az acr build-task list-builds
    ```
