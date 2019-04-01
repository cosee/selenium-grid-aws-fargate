FROM rodolpheche/wiremock

COPY mockserver /home/wiremock

EXPOSE 8080

ENTRYPOINT [ "java", "-jar", "/var/wiremock/lib/wiremock-standalone.jar", "--verbose", "--local-response-templating" ]
