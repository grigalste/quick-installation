# Quick installation of applications and connectors
    Usage: install.sh [OPTIONS]
      -app | --app                          - application name (example, humhub, redmine, nextcloud?);
      -version | --version | -ver           - application version;
      -url_connect | --url_connect | -uc    - the URL of the connector;
      -ds_version | --ds_version | -dsv     - DS version;
      -domain | --domain | -d               - domain name;
      -email | --email | -e                 - e-mail address;
      -http | --http                        - using the http protocol.

## Example
### Clone the repository to the /app folder:
    git clone --depth=1 https://github.com/ivanovalste/quick-installation /app && cd /app
### Installing the HUMHUB application specifying the domain and email address:
	bash install.sh -app humhub -domain domain.name -email example@example.com
### Installing the Redmine application, setting the DS version and the HTTP protocol:
    bash install.sh -app redmine -ds_version 7.5.1 -http true
### Other examples
    bash install.sh -app humhub -version 1.13.2 -ds_version 7.5.1 -url_connect https://github.com/ONLYOFFICE/onlyoffice-humhub/releases/download/v3.1.0/onlyoffice.zip
    bash install.sh -app humhub -domain domain.name -email example@example.com -http true
