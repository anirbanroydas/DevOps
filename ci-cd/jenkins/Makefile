volume:
    docker volume create --driver=rexray --opt=size=8 --opt=volumeType=gp2 jenkins_data
build: volume
    docker-compose -p jenkins build
run:
    docker-compose -p jenkins up -d master
stop:
    docker-compose -p jenkins stop
clean:  stop
    docker-compose -p jenkins rm -f master
remove-volume: clean
    docker volume rm jenkins_data
clean-images:
    docker rmi `docker images -q -f "dangling=true"`