export SELENIUMDIR=${SELENIUMDIR}
docker build -t wiremock --build-arg SELENIUMDIR=${SELENIUMDIR} .
