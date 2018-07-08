FROM perl:5.26

EXPOSE 3000

RUN cpanm Mojolicious Mouse YAML Hash::MD5

WORKDIR /app

COPY . ./

CMD morbo ti4p.pl
