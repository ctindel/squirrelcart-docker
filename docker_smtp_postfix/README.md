awsmail-docker
==============

Postfix server configured to send mail to amazon.  Just add keys.

Usage
-----

Create the curent docker host as a mail relay host

     docker run -d --name mail -p 25:25 -e ID=myid -e KEY=mykey FROM=me@mydomain.com deweysasser/awsmail

Setup a relay container for an e.g. jenkins container to use

     docker run -d --name mail -e ID=myid -e KEY=mykey FROM=me@mydomain.com deweysasser/awsmail
     docker run -d --link mail:mail -p 8080:8080 jenkins


Environment
-----------

The following environment variables are used at runtime to configure postfix.

* ID -- AWS SES ID
* KEY -- AWS SES KEY
* FROM -- (optional) rewrite email as from this email address if there
    is no FROM address.  Note that the default address of
    "root@example.com" will be rejected by SES in development mode.
* NETWORKS -- (optional) networks for which to relay mail.  Defaults to
	 all RFC 1918 non-routable networks.
* HOSTNAME -- (recommended, optional) host name to use for this POSTFIX
	 server.  Defaults to the docker hostname.  Note that if this
	 is not a valid domain, Amazon will bounce the email.
* SES_ENDPOINT -- (defaults to endpoing for us-east-1) Name of Amazon
	     SES enpoint



Troubleshooting
---------------

AWS is picky about mail it receives.  

* It requires that the sending hostname be valid (RFC1123 2.1)

The following must all be verified addresses (or SES must be in production mode):

* The envelope "FROM" address
* The envelope "TO" address
* The in-text email addresses