<div id="top"></div>

## Getting Started

### Requirements 
* git
* docker
* docker-compose

### Ways to setup drupal application LOCALLY
<p>
    <li><a href="#dockercompose">Docker-Compose</a></li>
    <li><a href="#docker">Docker</a></li>
</p>

<br></br>

## DockerCompose

1. Clone the repo
   ```sh
   git clone https://github.com/abila98/drupal_project.git
   ```
2. Create a .env file and change the values accordingly.
   ```
   MYSQL_ROOT_PASSWORD=<< root_password>>
   MYSQL_DATABASE=<< drupal_database_name >>
   MYSQL_USER=<< sql_username >>
   MYSQL_PASSWORD=<< sql_password >>
   ```

3. Setting up application
   
   There are two ways to setup the applcation on your local.
      
     a. Building docker image of the code from your local i.e code inside docroot. 
        Just run the docker-compose command.
   
     b. Pulling an existing docker image from repo.
        In the docker-compose.yaml file, comment the build line in mydrupal and uncomment the image line and change the tag name accordingly before running the docker-compose command.
      
   Command :
   ```
   docker-compose up -d
   ```

4. View the application on http://localhost:80

<br></br>

### Debugging Issues
  ```
  docker exec -it mysql bash
  ```
  ```
  docker exec -it drupal bash
  ```
  
<br></br>
## Docker
  Create network
  ```
  docker network create drupal_network
  ```
  Run mysql container
  ```
  docker run -d --name drupal_mysql --network drupal_network -v Users/abila.saravanabhavan/Srijan/Drupal/drupal_database:/var/lib/mysql -p 3306:3306 mysql/mysql-server:latest
  ```
  Note down the root password generated after executing the below command.
  ```
  docker logs drupal_mysql 2>&1 | grep GENERATED
  ```
  Entering mysql container
  ```
  docker exec -it drupal_mysql bash
  ```
  Changing root password
  ```
  mysql -u root -p
  ALTER USER 'root'@'localhost' IDENTIFIED BY '[password]';
  ```
  Creating database 'drupal' and user 'username'
  ```
  CREATE DATABASE drupal;
  CREATE USER 'username'@'localhost' IDENTIFIED BY 'password'; 
  GRANT ALL PRIVILEGES ON *.* TO 'username'@'localhost' WITH GRANT OPTION; 
  CREATE USER 'username'@'%' IDENTIFIED BY 'password'; 
  GRANT ALL PRIVILEGES ON *.* TO 'username'@'%' WITH GRANT OPTION; 
  FLUSH PRIVILEGES;
  ```
  Run drupal container
  ```
  docker run --name drupal_app --network drupal_network -p 80:80 -d abila98/mydrupal:1.0
  ```
  <br></br>

## Note
  Deployment of drupal application on kubernetes and helm can be found here.
  https://github.com/abila98/drupal_deploy
  
  <br></br>
## References

  Need to add
<p align="right">(<a href="#top">back to top</a>)</p>


