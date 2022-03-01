# Dotnet Test App

## Creating the Repo

```powershell
dotnet new console -o dotnet-test
```

## Adding Local Docker Registry

[Official Docker Registry Doc](https://docs.docker.com/registry/)

```powershell
# on K3S-server, start registry
docker run -d -p 5000:5000 --name registry registry:2

# anywhere, tag and push to the registry
docker image tag dotnet-test k3s-server:5000/dotnet-test
docker push k3s-server:5000/dotnet-test
```

## Adding Helm

```powershell
helm create test

helm install -f .\test\values.yaml test .\test
```