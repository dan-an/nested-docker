FROM tmaier/docker-compose:19.03

RUN apk add bash
RUN mkdir app

RUN cd app
WORKDIR /app

ENTRYPOINT ["/bin/bash", "docker-entrypoint.sh"]
