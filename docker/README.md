
## Basic commands
Place a file named Dockerfile in the target directory.
"." is recursively added to the docker container
-f /path is used to point to a filesystem
-t specifices a repo to store the docker image
`docker build -f /path/to/Dockerfile .`


## Docker runtime

Take any image, create a container, then start the container
docker run <image>

Start a container
`docker start <name -or- id>`

### Stop a container
`docker stop <name -or- id>`
	
### List running containers
`docker ps`

### List running and stopped containers
`docker ps -a`

### Delete a container
`docker rm <name -or- id>`

### youtube example
suggestion:  update hosts file to refer to docker vms

### Port forward docker vm port 80 to host 8080
`docker run -p 8080:80 tutum/hello-world`

### Name a docker container
`docker run -d --name web1 -p 8080:80 tutum/hello-world`

### Build a docker container

