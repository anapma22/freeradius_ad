#!/bin/bash
set -e
# Variáves de ambiente
export DOMAIN="DOMINIO.BR"
export DOMAIN_NAME="dominio.br"
export SIGLA_INSTITUICAO="DOMINIO"
export DNS1_IP="x.x.x.x"
export DC1="dcx.dominio.br"
export DNS2_IP="x.x.x.x"
export DC2="dcx.dominio.br"
export AD_PASSWORD="senha" # Após subir o container, remova essa linha.
export AD_USERNAME="user"

# *Alteções no /etc/raddb/mods-enabled/eap*
# Substituir "md5" por "ttls", linha 27: default_eap_type = ttls 
sed -i  '27s/md5/ttls/' /etc/raddb/mods-enabled/eap

# Adicionar as linhas 173 e 174: certdir = ${confdir}/certs e cadir = ${confdir}/certs
sed -i '/tls-config tls-common {/a\                certdir = ${confdir}/certs\n                cadir = ${confdir}/certs' /etc/raddb/mods-enabled/eap

# Descomentar, linha 252: radom_file = /dev/urandom 
sed -i '252s/#[[:space:]]radom_file = \/dev\/urandom/        radom_file = \/dev\/urandom/' /etc/raddb/mods-enabled/eap

# Descomentar, linha 263: fragment_size = 1024
sed -i '263s/#[[:space:]]fragment_size = 1024$/        fragment_size = 1024/' /etc/raddb/mods-enabled/eap

# Descomentar, linha 273: include_length = yes
sed -i '273s/#[[:space:]]include_length = yes$/        include_length = yes/' /etc/raddb/mods-enabled/eap

# Descomentar e mudar de "yes" para "no", linha 283: check_crl = no
sed -i '283s/#[[:space:]]check_crl = yes$/        check_crl = no/' /etc/raddb/mods-enabled/eap

# Substituir "md5" por "mschapv2", linha 605: default_eap_type = ttls 
sed -i  '605s/md5/mschapv2/' /etc/raddb/mods-enabled/eap

#Substituir "no" por "yes", linha 621: copy_request_to_tunnel = yes 
sed -i  '621s/no/yes/' /etc/raddb/mods-enabled/eap

#Substituir "no" por "yes", linha 644: use_tunneled_reply = yes
sed -i  '644s/no/yes/' /etc/raddb/mods-enabled/eap

#Substituir "no" por "yes", linha 745: copy_request_to_tunnel = yes 
sed -i  '745s/no/yes/' /etc/raddb/mods-enabled/eap

#Substituir "no" por "yes", linha 758: use_tunneled_reply = yes
sed -i  '758s/no/yes/' /etc/raddb/mods-enabled/eap


# *Alteração no /etc/raddb/sites-enabled/inner-tunnel*
# Adicionar a linha 49: auth_log
sed -i '/authorize {/a\        auth_log' /etc/raddb/sites-enabled/inner-tunnel

#Comentar -ldap, linha 158: #-ldap
sed -i  '158s/-ldap$/#-ldap/' /etc/raddb/sites-enabled/inner-tunnel

#Comentar a autenticação chap, linha 215 a 217
sed -i '215,217s/^/#/' /etc/raddb/sites-enabled/inner-tunnel

# Adicionar as linhas 287 a 289: preacct{ }
sed -i '/#  then update the inner-tunnel reply./a\preacct{\n\n}' /etc/raddb/sites-enabled/inner-tunnel

# Descomentar, linha 300: reply_log
sed -i '300s/#[[:space:]]reply_log$/        reply_log /' /etc/raddb/sites-enabled/inner-tunnel

#Comentar o if do post-auth, linha 334 a 359
sed -i '334,359s/^/#/' /etc/raddb/sites-enabled/inner-tunnel

# Adicionar a linha 370
sed -i '/ log failed authentications in SQL, too./a\        reply_log' /etc/raddb/sites-enabled/inner-tunnel

# Descomentar, linha 417: post_proxy_log
sed -i '417s/#[[:space:]]post_proxy_log$/        post_proxy_log/' /etc/raddb/sites-enabled/inner-tunnel

# Descomentar, linha 421: attr_filter.post-proxy
sed -i '421s/#[[:space:]]attr_filter.post-proxy$/        attr_filter.post-proxy/' /etc/raddb/sites-enabled/inner-tunnel

# Adicionar as linhas 422 a 424
sed -i '/attr_filter.post-proxy/a\        Post-Proxy-Type Fai{\n                detail\n        }' /etc/raddb/sites-enabled/inner-tunnel


#*Alteração no /etc/raddb/sites-enabled/default*
# Descomentar, linha 317: auth_log
sed -i '317s/#[[:space:]]/  /' /etc/raddb/sites-enabled/default

# Descomentar, linha 732: reply_log
sed -i '732s/#[[:space:]]/  /' /etc/raddb/sites-enabled/default


#*Alteração no /etc/raddb/mods-enabled/mschap*
# Descomentar, linha 19 e mudar de no para yes: use_mppe = yes
sed -i  '19s/^#[[:space:]]use_mppe = no$/        use_mppe = yes/' /etc/raddb/mods-enabled/mschap

# Descomentar, linha 24: require_encryption = yes
sed -i '24s/#[[:space:]]/  /' /etc/raddb/mods-enabled/mschap

# Adicionar a linha 30
sed -i '/require_strong = yes/a\        with_ntdomain_hack = yes' /etc/raddb/mods-enabled/mschap

# Alterar a localização do binário ntlm: /usr/bin/ntlm_auth
sed -i '59s/path\/to/usr\/bin/' /etc/raddb/mods-enabled/mschap
# Adicionar a flag --domain=$DOMAIN no binário do ntlm
sed -i "59s/}\"/} --domain=$DOMAIN\"/" /etc/raddb/mods-enabled/mschap #não sei se a ordem desse parâmetro importa
# Descomentar, linha 59
sed -i '59s/^#[[:space:]]ntlm_auth/        ntlm_auth/' /etc/raddb/mods-enabled/mschap


#*Alteração no /etc/raddb/mods-enabled/ntlm_auth*
# Alterar a localização do binário ntlm: /usr/bin/ntlm_auth
sed -i '11s/path\/to/usr\/bin/' /etc/raddb/mods-enabled/ntlm_auth
# Alterar a flag MYDOMAIN
sed -i "11s/MYDOMAIN/$DOMAIN/" /etc/raddb/mods-enabled/ntlm_auth

# Adicionar o usuário do radiusd ao grupo wbpriv
usermod -a -G wbpriv radiusd


# Configurações do clients.conf 
echo "client federacao { " >> /etc/raddb/clients.conf
echo "    ipaddr = federacao.dominio.br" >> /etc/raddb/clients.conf
echo "    secret = testing123" >> /etc/raddb/clients.conf
echo "}" >> /etc/raddb/clients.conf

# Configurações do proxy.conf 
# home_server
echo "home_server federacao {" >> /etc/raddb/proxy.conf
echo "    type = auth" >> /etc/raddb/proxy.conf
echo "    ipaddr = federacao.dominio.br" >> /etc/raddb/proxy.conf
echo "    port = 1812" >> /etc/raddb/proxy.conf
echo "    secret = testing123" >> /etc/raddb/proxy.conf
echo "    response_window = 20" >> /etc/raddb/proxy.conf
echo "    zombie_period = 40" >> /etc/raddb/proxy.conf
echo "    revive_interval = 120" >> /etc/raddb/proxy.conf
echo "    status_check = status-server" >> /etc/raddb/proxy.conf
echo "    check_interval = 30" >> /etc/raddb/proxy.conf
echo "    check_timeout = 4" >> /etc/raddb/proxy.conf
echo "    num_answers_to_alive = 3" >> /etc/raddb/proxy.conf
echo "    max_outstanding = 65536" >> /etc/raddb/proxy.conf
echo "    coa {" >> /etc/raddb/proxy.conf
echo "        irt = 2" >> /etc/raddb/proxy.conf
echo "        mrt = 16" >> /etc/raddb/proxy.conf
echo "        mrc = 5" >> /etc/raddb/proxy.conf
echo "        mrd = 30" >> /etc/raddb/proxy.conf
echo "    }" >> /etc/raddb/proxy.conf
echo "    limit {" >> /etc/raddb/proxy.conf
echo "        max_connections = 16" >> /etc/raddb/proxy.conf
echo "        max_requests = 0" >> /etc/raddb/proxy.conf
echo "        lifetime = 0" >> /etc/raddb/proxy.conf
echo "        idle_timeout = 0" >> /etc/raddb/proxy.conf
echo "    }" >> /etc/raddb/proxy.conf
echo "}" >> /etc/raddb/proxy.conf

# home_server_pool
echo "home_server_pool federacao {" >> /etc/raddb/proxy.conf
echo "    type = fail-over" >> /etc/raddb/proxy.conf
echo "    home_server = federacao" >> /etc/raddb/proxy.conf
echo "}" >> /etc/raddb/proxy.conf

# Realms
echo "realm NULL {" >> /etc/raddb/proxy.conf
echo "}" >> /etc/raddb/proxy.conf

echo "realm DEFAULT {" >> /etc/raddb/proxy.conf
echo "        auth_pool = federacao" >> /etc/raddb/proxy.conf
echo "        nostrip" >> /etc/raddb/proxy.conf
echo "}" >> /etc/raddb/proxy.conf


echo "realm $DOMAIN_NAME {" >> /etc/raddb/proxy.conf 
echo "    auth_pool = my_auth_failover" >> /etc/raddb/proxy.conf
echo "    secret = testing123" >> /etc/raddb/proxy.conf
echo "}" >> /etc/raddb/proxy.conf


#*Mudanças no SAMBA*
# Alterar o workgroup
sed -i "7s/SAMBA/$SIGLA_INSTITUICAO/" /etc/samba/smb.conf

# Alterar o tipo de segurança
sed -i "8s/user/ads/" /etc/samba/smb.conf

# Não coloquei a linha do password server
# Inserir o realm na linha 9
sed -i "/security/a\        realm = $DOMAIN_NAME" /etc/samba/smb.conf

# Inserir o realm na linha 10
sed -i "/realm/a\        winbind use default domain = no" /etc/samba/smb.conf


#*Alteração do kerberos*
# Inserir o includedir do sss
sed -i "/includedir/a\includedir \/var\/lib\/sss\/pubconf\/krb5.include.d\/" /etc/krb5.conf

# Inserir o dns_lookup
sed -i "/dns_/a\ dns_lookup_kdc = false" /etc/krb5.conf

# Comentar default_ccache_name
sed -i "19s/default_ccache_name/#default_ccache_name/" /etc/krb5.conf

# Inserir o default_realm
sed -i "/default_c/a\ default_realm = $DOMAIN" /etc/krb5.conf

# Inserir [realm]
sed -i "/realms/a\ $DOMAIN = {\n kdc = $DC1\n admin_server = $DOMAIN_NAME\n default_domain = $DOMAIN_NAME\n }" /etc/krb5.conf
 
# Inserir o [domain]
sed -i "/domain_/a\ $DOMAIN_NAME = $DOMAIN\n .$DOMAIN_NAME = $DOMAIN\n\n" /etc/krb5.conf

# Inserir o [kdc]
echo "profile = /var/kerberos/krb5kdc/kdc.conf" >> /etc/krb5.conf
echo "[appdefaults]" >> /etc/krb5.conf
echo " pam = {" >> /etc/krb5.conf
echo " debug = false" >> /etc/krb5.conf
echo " ticket_lifetime = 36000" >> /etc/krb5.conf
echo " renew_lifetime = 36000" >> /etc/krb5.conf
echo " forwardable = true" >> /etc/krb5.conf
echo " krb4_convert = false" >> /etc/krb5.conf
echo "}" >> /etc/krb5.conf

# SSSD
echo [sssd] >> /etc/sssd/sssd.conf
echo domains = $DOMAIN_NAME >> /etc/sssd/sssd.conf
echo config_file_version = 2 >> /etc/sssd/sssd.conf
echo services = nss, pam >> /etc/sssd/sssd.conf
echo [domain/$DOMAIN_NAME] >> /etc/sssd/sssd.conf
echo ad_domain = $DOMAIN_NAME >> /etc/sssd/sssd.conf
echo krb5_realm = $DOMAIN >> /etc/sssd/sssd.conf
echo realmd_tags = manages-system joined-with-samba >> /etc/sssd/sssd.conf
echo cache_credentials = True >> /etc/sssd/sssd.conf
echo id_provider = ad >> /etc/sssd/sssd.conf
echo krb5_store_password_if_offline = True >> /etc/sssd/sssd.conf
echo default_shell = /bin/bash >> /etc/sssd/sssd.conf
echo ldap_id_mapping = True >> /etc/sssd/sssd.conf
echo use_fully_qualified_names = False >> /etc/sssd/sssd.conf
echo fallback_homedir = /home/%u >> /etc/sssd/sssd.conf
echo access_provider = simple >> /etc/sssd/sssd.conf

# Ticket do kerberos
echo "$AD_PASSWORD" | kinit -V "$AD_USERNAME"@"$DOMAIN"

# Inserindo no domínio
net ads join -U "$AD_USERNAME"%"$AD_PASSWORD"

mkdir -p /data/conf /data/run /data/logs
chmod 711 /data/conf /data/run /data/logs

# Executar o supervisor
/usr/bin/supervisord -c /etc/supervisord.conf
