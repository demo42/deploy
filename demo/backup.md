- Demo presets
    export TAG=dev1

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
