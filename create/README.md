# Creating the Demo42 Queue Worker Environment

Creating the environment involves the following:

1. establishing the demo specific environment variables
1. creating the base Azure Resources

## Configure the Local Environment

- Edit [./env.sh](./env.sh) to represent your specific environment and resource names
- CD into this directory and apply the environment variables with [source](https://bash.cyberciti.biz/guide/Source_command)

  ```sh
  cd ./deploy/create
  source ./env.sh
  ```

## Create Base Azure Resources

[./azure-resources.md](./azure-resources.md)

## Initializing With Helm

[./helm.md](./helm.md)
