# Terragrunt 101

## Installation

```shell
wget https://github.com/gruntwork-io/terragrunt/releases/download/v0.46.3/terragrunt_linux_amd64
mv terragrunt_linux_amd64 terragrunt
chmod u+x terragrunt
sudo mv terragrunt /usr/bin/terragrunt
terragrunt --version
```

## Setup

## Hello World

``` shell
cd src/dev
terragrunt init
terragrunt apply
terragrunt destroy
```
