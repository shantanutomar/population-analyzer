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
* The initial data load takes around approx 4hr to complete which loads 5 Million records.

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

![Screenshot 2023-10-03 at 5.33.29 PM.png](https://i.ibb.co/wr5yG8p/Screenshot-2023-10-03-at-5-33-29-PM.png)

## Build docker images locally
* There are 2 docker files in the project each to build the image for the api and the database.
* To build the image for the api, run `docker build -t population-analyze-api -f Dockerfile-api .` in the root directory of the project.
* To build the image for the database, run `docker build -t population-analyze-db -f Dockerfile-db .` in the root directory of the project.

## Docker images in docker hub
* The docker images are also available in docker hub.
* The docker image for the `api` can be found [here](https://hub.docker.com/r/shantanutomar/population-analyze-api-repo).
* The docker image for the `database` can be found [here](https://hub.docker.com/r/shantanutomar/population-analyze-db-repo).


## Deploy the application in AWS
### Pre-requisites
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

### Steps to deploy the ECR repos and upload images
* At first the images for the api and the database needs to be uploaded to the ECR repos.
* Below code `main.tf` file in the root directory of the project 
contains the terraform code to create the ECR repos.
```
#Configure the AWS ECR Provider for API
resource "aws_ecr_repository" "population-analyzer-api-repo" {
  name = "population-analyzer-api-repo"
}

#Configure the AWS ECR Provider for DB
resource "aws_ecr_repository" "population-analyzer-db-repo" {
  name = "population-analyzer-db-repo"
}
```
* Leaving above code, comment out the rest of the code in the `main.tf` file.
* Run `terraform init` in the root directory of the project.
* Run `terraform apply` in the root directory of the project.
* This will create the ECR repos in AWS.
* Follow the steps on AWS console to upload the images to the ECR repos using `View push commands`.

### Steps to deploy the rest of the infrastructure in AWS.
* Once the images are uploaded to the ECR repos, uncomment all the code in the `main.tf` file.
* Run `terraform apply` in the root directory of the project.
* This will create the rest of the infrastructure in AWS.

## Future improvements
* Performance improvement - The application can be improved to provide better performance.
Right now, the API is not performant enough to handle large data. For example, if we try to get the list 
of individuals living in Rajasthan(one of the heavily populated) it takes approx `7sec`. There are already indexes created on the tables on geometry 
columns but still the performance is not good enough. The performance can be improved by using the following techniques:
    * Using `materialized views` - The materialized views can be used to store the results of the queries and 
    then the results can be fetched from the materialized views instead of querying the tables directly.
    * Using `caching` - Redis cache can be implemented. The results of the queries can be cached and then the results can be fetched from the cache.
    * Using `sharding` - The data can be sharded and stored in different databases and then the results can be fetched from the different databases.
* Sequelize - Sequelize can be used as ORM to interact with the database instead of using raw queries. This will make the code more readable and maintainable.
* Unit + Integration tests - Unit tests can be written for the application.
* Security - The application can be made more secure by using the following techniques:
    * Using `JWT` - JWT can be used for authentication and authorization.