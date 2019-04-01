# Starting from base image
FROM python:3.7-stretch

# Install dependencies via pip
COPY repo /repo
WORKDIR /repo
RUN pip install -r requirements.txt
RUN pip install junit2html
RUN pip install xunitmerge
RUN pip install awscli

COPY scripts /scripts
RUN chmod -R +x /scripts

CMD "/scripts/entrypoint.sh"
