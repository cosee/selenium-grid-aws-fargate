export FRONTENDDIR=${FRONTENDDIR}
docker build -t frontend . --build-arg FRONTENDDIR=${FRONTENDDIR}
