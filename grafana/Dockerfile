FROM grafana/grafana:11.6.1

ADD --chown=grafana:root https://raw.githubusercontent.com/domainaware/parsedmarc/master/grafana/Grafana-DMARC_Reports.json /var/lib/grafana/dashboards/
RUN chmod 644 /etc/grafana/provisioning

COPY grafana-provisioning/ /etc/grafana/provisioning/
