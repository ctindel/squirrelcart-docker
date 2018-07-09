FROM debian:jessie

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
            exim4 \
            net-tools \
            curl \
            python-pip \
            vim && \
    pip install j2cli && \
    apt-get purge -y --auto-remove && rm -rf /var/lib/apt/lists/* 

# Debugging tools
#RUN apt-get update && apt-get install -y vim netcat

COPY conf /etc/exim4
COPY docker-entrypoint.sh /
# We need this so the exim software will send from an SES verified email 
COPY conf/email-addresses /etc/email-addresses
RUN chmod 755 /docker-entrypoint.sh
# Force all emails sent to come from sah@hoffman-house.com with username "Hoffman House"
RUN echo "* sah@hoffman-house.com Ffrs" >> /etc/exim4/conf.d/rewrite/31_exim4-config_rewriting && \
    chfn -f "Hoffman House" www-data

ENV SMTP_USERNAME= SMTP_PASSWORD= AWS_REGION= DC_RELAY_NETS=
EXPOSE 25
VOLUME ["/data/ses-relay"]
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/sbin/exim", "-DSPOOLDIR=/data/ses-relay/spool", "-bd", "-v"]
