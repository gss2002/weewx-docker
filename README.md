docker build --build-arg TIMESTAMP=$(date +%s) --progress=plain . -t weewx:latest
