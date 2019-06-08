
## Basic commands
Some notes from reading docker reference pages and this tutorial:

[LearnCode.academy - Docker container
tutorial](https://www.youtube.com/watch?v=K6WER0oI-qs)



## Docker runtime

Take any image, create a container, then start the container
docker run <image>

### Start a container
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
Dockerfile example.  Tutorial has a nginx.conf file.

`FROM ...` Import a base configuration template

`RUN ...` shell commands to run when building the container

`ADD ...` push a file or directory name 

```
FROM nginx
RUN mkdir /etc/nginx/logs && touch /etc/nginx/logs/static.log
ADD .nginx.conf /etc/nginx/conf.d/default.conf
ADD /src /www
EXPOSE 80
CMD nginx
```

### Run the build script
Place a file named Dockerfile in the target directory.
"." is recursively added to the docker container
-f /path is used to point to a filesystem
-t specifices a repo to store the docker image

`docker build -f /path/to/Dockerfile .`

### Upload image
Upload your image to a docker repository.

`docker push <repo-name>/<image-name>`

Once its pushed, on any other machine you can run it.

From here you can log into your server and run your docker image.

Docker image hosts can be docker.io or private for example.

