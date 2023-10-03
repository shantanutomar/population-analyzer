# Population analyzer application
With the given set of data the application will analyze the data and provide the following information:
* List of all the states in a given country.
* Given a unique state code, the application will provide the persons living in that state.

## Tech stack
* Express JS(Node JS framework) with Typescript 
* Postgres - Database
* Postgis - Database extension for geospatial data
* Docker - Containerization
* Docker compose - Container orchestration
* Terraform - Infrastructure as code
* AWS - Cloud provider

## Storing geospatial data from S3 in the PostgreSQL database
* The geo spatial data is huge and the states and individuals are stored in different tables.
* The states are stored in the table `states` and the individuals are stored in the table `individuals`.
* In folder `dataFromS3` there are all the files(i.e. `geojson` and `csv`) which are downloaded from the S3 bucket.
* The huge `individuals.csv` file is split into smaller 25 files and stored in the folder `dataFromS3`.
* The script `scripts/data_dump.sql` is used to load the data from the files into the database.
* When running with `docker compose`, the script is run automatically and the data is loaded in the database initially when the container is created.
* The initial load of data takes around 1hr to complete.

## Open API specification
* The open API specification for the application can be found [here](https://app.swaggerhub.com/apis/shantanutomar/population-analyzer/1.0.0).

## How to run the application using docker compose in local machine
* Clone the [repository](git@github.com:shantanutomar/population-analyzer.git)
* Make sure you have docker and docker CLI installed in your local machine.
* Create a `.env` file in the root directory of the project and add the following environment variables.
```
PORT=3000
POSTGRES_DATABASE='postgres'
POSTGRES_USER='postgres'
POSTGRES_PASSWORD='password'
POSTGRES_HOST='db'
POSTGRES_PORT=5432
LOCAL_DB_PORT=5433
```
* Run `docker-compose up -d` in the root directory of the project.
* This will take some time to build the images and run the containers in the background. As the geospatial data is huge, it will take ¬1hr to load the data in the database.
* Verify in docker desktop that the container `population-analyzer` is up and running
and consist of 2 images `population-analyze-api` and `population-analyze-db`.
* Once the containers are up, the application can be run at `http://localhost:3000/`.

![Screenshot 2023-10-03 at 5.33.29 PM.png](https://ibb.co/3Yg16VS)

## Build docker images locally
* There are 2 docker files in the project each to build the image for the api and the database.
* To build the image for the api, run `docker build -t population-analyze-api -f Dockerfile-api .` in the root directory of the project.
* To build the image for the database, run `docker build -t population-analyze-db -f Dockerfile-db .` in the root directory of the project.

## Docker images in docker hub
* The docker images are also available in docker hub.
* The docker image for the `api` can be found [here](https://hub.docker.com/r/shantanutomar/population-analyze-api-repo).
* The docker image for the `database` can be found [here](https://hub.docker.com/r/shantanutomar/population-analyze-db-repo).


## Host the application in AWS
* The application can be hosted in AWS using terraform as IAAC.
* The `main.tf` file in the root directory of the project contains the terraform code to create the infrastructure in AWS.
* Create a `terraform.tfvars` file in the root directory of the project and add the following variables.
```
variable "aws-access-key" {
  type = string
  description = "Access key for AWS account"
}

variable "aws-secret-key" {
  type = string
  description = "Secret key for AWS account"
}

variable "aws-region" {
  type = string
  description = "Region to deploy to"
}

variable "postgres_password" {
  type = string
  description = "postgres password"
}

variable "postgres_database" {
  type = string
  description = "postgres password"
}
```
* Make sure you have terraform installed in your local machine and logged in to your AWS account
with correct AWS credentials.
* Run `terraform init` in the root directory of the project.
* Run `terraform apply` in the root directory of the project.
* This will create the infrastructure in AWS and deploy the application in AWS.