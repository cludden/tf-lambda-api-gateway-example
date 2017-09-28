# tf-lambda-api-gateway-example
example of using `terraform` to deploy a `node.js` lambda function behind an `AWS API Gateway`

## Installing
Prereqs:
- node v8+

```shell
# clone this repository
$ git clone https://github.com/cludden/tf-lambda-api-gateway.git

# install dependencies
$ cd tf-lambda-api-gateway && npm install
```

## Testing
Prereqs:
- node v8+

```shell
# run the test suite
$ npm run test
```

## Building
*Note: this project uses features from from Node 8, and as such requires a build step*

Prereqs:
- node v8+

```shell
# run webpack which runs transpilation/minification and generates an
# artifact for each lambda function in the ./dist directory
$ npm run build
```

## Deploying
Prereqs:
- Terraform v0.10+
- AWS account with high degree of privelages and credentials availabe in the environment

```shell
# change into the terraform directory
$ cd terraform

# create a new terraform environment
$ terraform env new dev

# install any missing plugins
$ terraform init

# run a plan
$ terraform plan -var env=dev
...
Plan: 13 to add, 0 to change, 0 to destroy.

# apply
$ terraform apply -var env=dev
...
Apply complete! Resources: 13 added, 0 changed, 0 destroyed.

Outputs:

url = https://<api_id>.execute-api.us-west-2.amazonaws.com/example_lambda_dev

# destroy when finished
$ terraform destroy -var env=dev
```

*Note: it can take a few minutes before the integrations become active*

## License
Copyright (c) 2017 Chris Ludden
Licensed under the [MIT License](LICENSE.md)
