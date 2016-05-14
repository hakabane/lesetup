# lesetup
letsencrypt setup and renew helper scripts for gentoo linux and apache server

## goals
I was hosting SSL enabled sites with around 20 different subdomains with a wildcard certificat. I decided to switch to letsencrypt because I was bored to add my certificate as a certification authority on every new device I use. But with letsencrypt there is no support for wildcard certificate so I hacked these scripts to help the creation and renew of all my certificates.

## dependencies
Require https://github.com/diafygi/acme-tiny which can be installed from np-hardass-overlay
```
layman -o https://git.io/xnmB -f -a np-hardass-overlay
layman -s np-hardass-overlay
emerge app-crypt/acme-tiny
```

## setup
Clone and copy files
```
git clone https://github.com/hakabane/lesetup.git
mkdir -p /var/lib/letsencrypt
mkdir -p /var/www/localhost/acme-challenge
cp -a lerenew.sh lesetup.sh /var/lib/letsencrypt
cp -a cron.monthly/lerenew.sh /etc/cron.monthly/lerenew.sh
```

Add this alias to apache default port 80 vhost
```
alias /.well-known/acme-challenge/ /var/www/localhost/acme-challenge/ 

<Directory /var/www/localhost/acme-challenge/> 
     		AllowOverride None 
     		Require all granted
</Directory>
```

If a HTTP to HTTPS rewrite rule is set, do not rewrite acme-challenge URL
```
RewriteEngine on
RewriteCond %{REQUEST_URI} !^/.well-known/acme-challenge
RewriteCond %{SERVER_PORT} !^443$
RewriteRule ^/(.*) https://%{HTTP_HOST}/$1 [NC,R=301,L]
```

Restart apache server
```
/etc/init.d/apache2 restart
```

## usage
Generate a new certificate for foobar.com
```
cd /var/lib/letsencrypt
./lesetup.sh foobar.com
```
If no error occured it will output the SSL variables to update in related apache vhost file
```
SSLCertificateFile /var/lib/letsencrypt/foobar.com.pem
SSLCertificateKeyFile /var/lib/letsencrypt/foobar.com.key

vhost file : /etc/apache2/vhosts.d/foobar.com_443.conf
```

Update the related vhost file and restart apache server
```
/etc/init.d/apache2 restart
```

Done ! You just setup a proper certificate which will be automatically renewed each month.
