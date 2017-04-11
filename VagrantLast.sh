#!/usr/bin/env bash

echo "Access with root!"
sudo su
echo

echo "Add repos ZendServer"
echo '' >> /etc/apt/sources.list
echo '# Freddie 20170123' >> /etc/apt/sources.list
echo 'deb http://repos.zend.com/zend-server/9.0/deb_apache2.4 server non-free' >> /etc/apt/sources.list
wget http://repos.zend.com/zend.key -O- | apt-key add -
echo

echo "Sustem update"
aptitude update
echo

echo "Install Zend server PHP 7.0"
aptitude -y install zend-server-php-7.0
echo

echo "Create site in Apache: /etc/apache2/sites-available/##NAME_VM##.conf"
echo '<VirtualHost *:80>
#ZEND-{B35D9A8E6C515B9E2CDD2FD9736070BF}
Include "/usr/local/zend/etc/sites.d/zend-default-vhost-80.conf"
#ZEND-{B35D9A8E6C515B9E2CDD2FD9736070BF}
    ServerName ##NAME_VM##.freddie.dev
    ServerAdmin fredy.mendivelso@placetopay.com
    DocumentRoot /var/www

    <Directory /var/www>
            DirectoryIndex index.php index.html
            Options Indexes FollowSymLinks
            AllowOverride All
            <IfVersion >= 2.4>
                Require all granted
            </IfVersion>
            <IfVersion < 2.4>
                Order allow,deny
                Allow from all
            </IfVersion>
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet

#ZEND-{DD87CFA438FDB62F189CF9485CCB5F20}
IncludeOptional "/usr/local/zend/etc/sites.d/globals-*.conf"
IncludeOptional "/usr/local/zend/etc/sites.d/vhost_*.conf"
#ZEND-{DD87CFA438FDB62F189CF9485CCB5F20}' > /etc/apache2/sites-available/##NAME_VM##.conf
echo

echo "Create site SSL in Apache: /etc/apache2/sites-available/##NAME_VM##-ssl.conf"
echo '<IfModule mod_ssl.c>
        <VirtualHost _default_:443>
                ServerName ##NAME_VM##.freddie.dev
                ServerAdmin fredy.mendivelso@placetopay.com
                DocumentRoot /var/www

                ErrorLog ${APACHE_LOG_DIR}/error.log
                CustomLog ${APACHE_LOG_DIR}/access.log combined

                SSLEngine on
                SSLCertificateFile      /var/www/ssl/server-cert.pem
                SSLCertificateKeyFile   /var/www/ssl/server-cert.key
                SSLCertificateChainFile /var/www/ssl/server-cert-intermediate.pem

                #SSLCACertificatePath /etc/ssl/certs/
                SSLCACertificateFile /usr/cnf/certificates/server-ca-chain.pem

                #SSLCARevocationPath /etc/apache2/ssl.crl/
                #SSLCARevocationFile /etc/apache2/ssl.crl/ca-bundle.crl


                <FilesMatch "\.(cgi|shtml|phtml|php)$">
                                SSLOptions +StdEnvVars
                </FilesMatch>
                <Directory /usr/lib/cgi-bin>
                                SSLOptions +StdEnvVars
                </Directory>

                BrowserMatch "MSIE [2-6]" \
                                nokeepalive ssl-unclean-shutdown \
                                downgrade-1.0 force-response-1.0
                # MSIE 7 and newer should be able to use keepalive
                BrowserMatch "MSIE [17-9]" ssl-unclean-shutdown

                <Directory /var/www>
                    DirectoryIndex index.php index.html
                    AllowOverride All
                </Directory>

                SSLSessionCacheTimeout 1

                <Location ~ "/?(.*)/secure">
                    LogLevel info ssl:debug
                    SSLOptions +StdEnvVars
                    SSLVerifyClient optional
                    SSLVerifyDepth 2
                </Location>

        </VirtualHost>
</IfModule>' > /etc/apache2/sites-available/##NAME_VM##-ssl.conf
echo

echo "Changes permission"
chmod 770 /etc/apache2/sites-available/##NAME_VM##.conf
chmod 770 /etc/apache2/sites-available/##NAME_VM##-ssl.conf
echo

echo "Changes owners"
chown vagrant:www-data /etc/apache2/sites-available/##NAME_VM##.conf
chown vagrant:www-data /etc/apache2/sites-available/##NAME_VM##-ssl.conf
echo

echo "Disable default sites"
a2dissite 000-default.conf
a2dissite default-ssl.conf
echo

echo "Enable to site"
a2ensite ##NAME_VM##.conf
a2ensite ##NAME_VM##-ssl.conf
service apache2 reload
echo

echo "Finish"