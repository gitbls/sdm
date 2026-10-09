# Installing Content Management Systems with sdm

Content Management Systems (CMS) are used for blogging and other online publishing systems, such as hyper-local newspapers, etc.

sdm can install two different CMS systems: Ghost and WordPress. These two CMS systems are very popular and widely used. Both CMS systems can be self-hosted
and self-supported, or obtained from hosting services such as the Ghost Pro service for Ghost and Newspack for WordPress. There are many other providers for both available as well.

Of course, sdm has nothing to do with any commercial services. The sdm plugins can be used to create self-hosted private installations for testing, for example.

**NOTE:** These plugins have not had broad and in-depth testing, and do not harden the OS network configuration for internet exposure, thus are NOT recommended for production use accessible on the broad internet at this time. Your feedback is welcomed and appreciated on these plugins to help improve and harden them for such usage. 

More infromation about CMS in general and the two CMS systems:

* CMS overview &mdash; https://en.wikipedia.org/wiki/Content_management_system 
* Ghost &mdash; https://docs.ghost.org/
* WordPress &mdash; https://wordpress.org/documentation/

## sdm CMS Plugins

The remainder of this document covers the `ghost` and `wordpress` plugins.

### ghost

The ghost plugin installs and configures Ghost for operation. If the `mysql-hostname` argument is not provided, the plugin will install and configure mariadb SQL server as well.

```
sdm --runonly plugins --oklive --plugin ghost:"args for ghost plugin"
```

#### Arguments

* **db-name** &mdash; Database name [D:ghost]
* **db-password** &mdash; Password for the ghost database [D:StrongPass123!]
* **ghost-dir** &mdash; [D:/var/www/ghost]
* **ghost-url** &mdash; [D:http://localhost]
* **ghost-user** &mdash; Username of an existing user to use for ghost installation. The user must already exist
* **mysql-hostname** &mdash; Hostname of mysql server. If not specified, mariadb will be installed and configured on the local system. Specify `localhost` to use an already-installed mariadb on the current system.
* **mysql-root-password** &mdash; Required. Password for the user specified by `mysql-root-user`
* **mysql-root-user** &mdash; Username of the mysql root user [D:root]
* **nodever** &mdash; Version of nodejs to install [D:22]
* **retain-script** &mdash; Retain the configuration script `<ghost-user>-ghost-configure`. This is deleted by default

Mail-sending configuration arguments. See the <a href="https://docs.ghost.org/config#mail">Ghost documentation</a> for details

* **mail-from** &mdash; From address for email sent by ghost
* **mail-host** &mdash; Mail host for email sent by ghost
* **mail-port** &mdash; Port for sending email
* **mail-transport** &mdash; Email transport to use [D:smtp]
* **mail-secure** &mdash;  Specifies whether the mail connection should use TLS. [D:false]. If true, TLS will be enabled, typically used with port 465
* **mail-ignoretls** &mdash; If false [D:false], Ghost will try to upgrade to a secure TLS connection via STARTTLS if the mail server supports it. If true, Ghost forces plain text communication and disables TLS usage or STARTTLS upgrades entirely (useful only if `mail-secure` is also false)
* **mail-requiretls** &mdash; If true [D:false], forces the mail sending to use a secure TLS connection
* **mail-auth-user** &mdash; defines the username or email address used to authenticate with your SMTP server
* **mail-auth-password** &mdash; defines the password for `mail-auth-user` on your SMTP server

#### Examples

Values identified in all UPPER-CASE are values that you need to provide.

* `--plugin ghost:"ghost-dir=/var/www/ghost|ghost-user=USER|mysql-root-password=SQLROOTPWD|mysql-root-user=root|db-name=myghost|db-password=DBPWD|mail-from=root@MYDOM.COM|mail-host=MAIL.MYDOM.COM|mail-port=25|mail-transport=smtp|mail-secure=false|mail-ignoretls=true|mail-requiretls=false|mail-auth-user=SMTPMAILUSER|mail-auth-password=SMTPMAILPWD|ghost-url=http://HOSTNAME.MYDOM.COM"` &mdash; Fully configure ghost on the current system. mariadb will also be installed.
* `--plugin ghost:"mysql-hostname=MYSQLHOST.MYDOM.COM|ghost-dir=/var/www/ghost|ghost-user=USER|mysql-root-password=SQLROOTPWD|mysql-root-user=sdm|db-name=ghost|db-password=DBPASSWD|mail-from=root@MYDOM.COM|mail-host=MAIL.MYDOM.COM|mail-port=25|mail-transport=smtp|mail-secure=false|mail-ignoretls=true|mail-requiretls=false|mail-auth-user=root|mail-auth-password=SMTPMAILPWD|ghost-url=http://HOSTNAME.MYDOM.COM"` &mdash; Install and configure ghost on the current system using mariadb on remote host MYSQLHOST.MYDOM.COM


#### Notes

mariadb seems to have issues with using dbuser `root` when the database is remote. If your mariadb server is on a separate system from ghost AND you configured mariadb using sdm's `mariadb` plugin, then provide `mysql-root-user=sdm`. The `mariadb` plugin creates this automatically using the provided `mysql-root-password`.

## wordpress

The wordpress plugin installs and configures WordPress for operation.

Unlike the ghost plugin, the wordpress plugin can be run on on an unbooted system (e.g., during customization or burning), but the SQL database configuration requires a running system. If the wordpress plugin is run on an unbooted system, the plugin will detail the database configuration you must do after the system is booted, and prior to starting the WordPress configuration.

Additionally, if you want WordPress to send email, email must be configured before starting the WordPress configuration. sdm's `postfix` plugin is one way of configuring email.

#### Arguments

* **mysql-dbname** &mdash; SQL database name [D:wordpress]
* **mysql-hostname** &mdash; Hostname for SQL database. If specified, `mysql-user` and `mysql-password` must be provided as well. If `mysql-hostname` is not specified, mariadb SQL server will be installed locally and configured. If `mysql-hostname` is provided the SQL database must have the root password configured.
* **mysql-password** &mdash; Password for the wordpress database. If not specified, `mysql-root-password` will be used
* **mysql-user** &mdash; Wordpress database user [D:wordpress]
* **mysql-root-user** &mdash; SQL database root user [D:root]
* **mysql-root-password** &mdash; SQL database root password. Required
* **server-name** &mdash; Server name [D:wordpress]. Servername for Apache2 configuration
* **wpsql** &mdash; Specifies a mysql command file to use instead of the default generated command file
* **wptar** &mdash; Wordpress install tarfile, downloaded from wordpress.org. If not specified, the specified `wpversion` of wordpress will be downloaded
* **www-port** &mdash;Listen port for wordpress site [D:80]
* **wpversion** &mdash; The specific wordpress version to install [D:latest]

#### Examples

* `--plugin wordpress:"mysql-root-password=abc"` &mdash; Install the latest version of WordPress on the current system. Also install mariadb
* `--plugin wordpress:"mysql-password=xyz|mysql-user=wordpress|mysql-root-password=abc|server-name=HOSTNAME.MYDOM|wptar=/path/to/latest.tar.gz"` &mdash; Install the version of WordPress in `/path/to/latest.tar.gz`, which is a .tar.gz file downloaded from WordPress. Also install mariadb
* `--plugin wordpress:"mysql-root-password=abc|server-name=HOSTNAME.MYDOM|mysql-hostname=MYSQLHOST.MYDOM"` &mdash; Install the latest version of WordPress and configure it to use mariadb on the host MYSQLHOST.MYDOM
* `--plugin wordpress:"mysql-root-password=abc|www-port=8080"` &mdash; Install the latest version of WordPress on the current system. Also install mariadb. WordPress will be accessed on port 8080.


## Installation videos

Both videos were performed on a Pi5 RasPiOS Trixie.

* Ghost &mdash; TBD
* WordPress &mdash; TBD
