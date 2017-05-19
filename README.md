# WP Setup

This repo contains a simple bash script designed to help speed up local
WordPress development by leveraging the [WP-CLI](https://wp-cli.org) to perform
common setup instructions such as database creation, WordPress download,
installation & configuration, ready for development.

## How to use

Download the `script.sh` file, grant executable permissions and move to suitable
path:

```txt
curl -O https://raw.githubusercontent.com/harryfinn/wp-setup/master/script.sh
chmod +x script.sh
sudo mv script.sh /usr/local/bin/wp-setup
```

You can now run this tool by running the following command `wp-setup` within
a folder you wish to generate a WordPress instance within, ready for theme
development.

## TODO

- [ ] Add error handling for WP-CLI commands
- [ ] Add option to use WP Skeleton repo as theme default Setup
- [ ] Investigate option(s) of use in deployments (might be best kept as a
  separate repo/tool)
