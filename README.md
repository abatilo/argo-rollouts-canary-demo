# argo-rollouts-canary-demo

This project is designed to be an end to end minimal demo for how to do canary
deployments with argo rollouts.

**More documentation needed. Still a WIP**

## Getting started

There's a `Makefile` that wraps `asdf-vm` for you to install everything.

```
⇒  make help
help                           View help information
bootstrap                      Perform all bootstrapping to start your project
clean                          Delete local dev environment
up                             Run a local dev environment
deploy                         Perform a deployment with a new version
```

## Create your local environment

Type `make up` which will install all the necessary tools to do the demo. This
will create a local `kind` cluster and install the `argo-rollouts` project for
you. This will also build our micro applications that are under `./cmd` and
deploy them into the cluster.

## Perform an automatic rollout

In another terminal, run the following command to get real time updates:

```
kubectl argo rollouts get rollout pingserver --watch
```

Then type `make deploy` which will initiate a new Rollout for you that will trigger
integration tests between every batch of pods being rolled out.

## Testing automatic rollback

Type `make rollback` to demonstrate a deployment where we have automatic
rollback. The integration tests will fail and then the canary deployment will
be stopped.
