# pts-webapp
People Transportation System, Backend Application Ruby Codebase

Backend that orchestrates various services and renders the front end dashboard for operator and employer.

## Install

### Clone the repository

```shell
git clone git@github.com:Mahindra-Logistics/pts-webapp.git
cd project
```

### Check your Ruby version

```shell
ruby -v
```

The ouput should start with something like `ruby 2.5.1`

If not, install the right ruby version using [rbenv](https://github.com/rbenv/rbenv) (it could take a while):

```shell
rbenv install 2.5.1
```

### Install dependencies

Using [Bundler](https://github.com/bundler/bundler) and [Yarn](https://github.com/yarnpkg/yarn):

```shell
bundle && yarn
```

### Set environment variables Locally


### Initialize the database

```shell
rails db:create db:migrate db:seed
```

### Run Locally

```shell
rails s
```
## Build and deploy on specific ENV

### Build and upload image to ECS Repo

Using Jenkin job

### Set environment variables For Env

Update Jenkin job for specific Env parameters

### Deploy on specific env

Using Jenkin Job

## Author
MOOVE-Rider iOS app code is owned and maintained by [Mahindra Logistics](https://github.com/Mahindra-Logistics)

## License
Copyright (C) 2017-2019 [Mahindra Logistics](https://github.com/Mahindra-Logistics)



## Test ENV Setup

```bash
sudo su
docker stop $(sudo docker ps)
eval $(aws ecr get-login --no-include-email)
aws s3 cp s3://moove-db-dump/moove-init2.sql /tmp/
docker-compose up -d --force-recreate --build
sleep 30
#cat /tmp/moove-init.sql | docker exec -i $(sudo docker ps -q --filter publish=3306) /usr/bin/mysql -u root --password=root moove_test
#cat /tmp/moove-init.sql | sudo docker-compose exec mysql /usr/bin/mysql -u root --password=root moove_test 
docker-compose exec -T mysql mysql -u root --password=root moove_test < /tmp/moove-init2.sql
docker-compose exec web bundle exec rake db:migrate
docker-compose exec web bundle exec rake spec
docker-compose exec web bundle exec rake cucumber
docker-compose exec web bundle exec rake tests:coverage
docker-compose exec web bundle exec rake tests:performance
sudo docker-compose down -v
sudo docker stop $(sudo docker ps)




docker exec -i 94d916f21e26 /usr/bin/mysql -u root --password=root moove_test

docker exec -it $(sudo docker ps -q --filter publish=3306) /bin/bash
