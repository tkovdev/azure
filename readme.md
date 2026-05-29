# Project Overview
This is a monorepo containing all terraform specs for all azure resources. Each RG is self-contained within the `infra/` folder and will have its own `main.tf`, `variables.tf`, & `outputs.tf`. This allows the developer to separate `terraform apply` per concern and provides a reliable way to track changes per RG.

`modules` contains reusable components to standardize terraform apply on any/all resources that may be needed for `infra/` or future implementations.

```
- infra/ <- all azure resources (separate terraform states per folder)
-- core/ <- azure backbone
- modules/ <- terraform modules
```
# How to Setup
## Prereqs
- install Terraform CLI

## Steps
- create a new SP in Azure (app registration)
- apply `Contributor` role to the SP under `Subscriptions`->`your_subscription`->`Access Control (IAM)`
- create a new ClientSecret for the SP
- add the ClientSecrete & ClientId to the `.env`


## Setting variables
- copy the required fields into a new file called `.env` under the root folder of this repo
```
    TF_VAR_azure_client_id="<app_id>"
    TF_VAR_azure_client_secret="<password>"
    TF_VAR_azure_subscription_id="<subscripton_id>"
    TF_VAR_azure_tenant_id="<tenant_id>"
```
- run <code>export $(cat .env | xargs)</code> to set the env vars for the terminal session (rather than setting permanently)
- to check vars were set correctly, run <code>printenv</code>

## Running TF
Navigate to a given `infra/` folder and run:
- <code>terraform plan</code>
- <code>terraform apply</code>
- <code>terraform destroy</code> (if needed)