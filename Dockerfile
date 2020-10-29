FROM debian

WORKDIR /srv

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt install slapd ldap-utils ca-certificates -y

RUN rm -rf /etc/ldap/slapd.d && mkdir /etc/ldap/slapd.d /srv/ldap/o=niif,c=hu -p

COPY config.ldif /tmp/config.ldif

RUN R=$(ip a show dev eth0 |perl -n -e'/inet \d+\.\d+\.(\d+)\.(\d+)/ && print (($1*256+$2)%900+100)'); sed -i -E "s/^(olcSyncrepl: rid=)XXX(.*)/\1$(printf %03d $((RANDOM%900+100)))\2/" /tmp/config.ldif

RUN slapadd -n 0 -F /etc/ldap/slapd.d -l /tmp/config.ldif && chown openldap:openldap /etc/ldap/slapd.d /srv/ldap/o=niif,c=hu -R

CMD [ "/usr/sbin/slapd","-d1","-h","ldap:/// ldapi:///","-g","openldap","-u","openldap","-F","/etc/ldap/slapd.d" ]

EXPOSE 389
