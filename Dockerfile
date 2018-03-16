FROM perl:5.26

EXPOSE 3000

RUN cpanm Mojolicious Mouse YAML

WORKDIR /app

COPY . ./

CMD morbo ti4p.pl
