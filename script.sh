#!/bin/bash

colour_red=$'\e[1;31m'
colour_green=$'\e[1;32m'
colour_blue=$'\e[1;34m'
colour_end=$'\e[0m'

echo "========================================"
echo "WordPress Setup Installer"
echo "========================================"

wp_check=$(wp --version)

if [[ $wp_check == *"command not found" ]]; then
  echo "${colour_red}Unable to run WP CLI - Please ensure this is installed prior to using WP-Setup${colour_end}"
  exit
else
  read -p "Site Name: " sitename
  read -p "Site URL: " siteurl
  read -p "Admin Email: " adminemail
  read -p "Database Name: " dbname
  read -p "Database Username: " dbuser
  read -p "Database password: " dbpass
  read -p "Ready to run the installer? [y/n]: " run

  if [ "$run" != "y" ]; then
    exit
  else
    echo ""
    echo "Starting install using $wp_check ${colour_blue}0%${colour_end}"

    {
      wp core download
    } &> /dev/null

    echo "Wordpress downloaded successfully   ${colour_blue}25%${colour_end}"

    {
      wp core config --dbname=$dbname --dbuser=$dbuser --dbpass=$dbpass

      password=$(LC_CTYPE=C tr -dc A-Za-z0-9_\!\@\#\$\%\^\&\*\(\)-+= < /dev/urandom | head -c 12)
      echo $password | pbcopy

      wp db drop --yes
      wp db create
      wp core install --url="$siteurl" --title="$sitename" --admin_user="super.user" --admin_password="$password" --admin_email="$adminemail"
    } &> /dev/null

    echo "WordPress installed successfully    ${colour_blue}50%${colour_end}"

    {
      wp option update blog_public 0

      wp post delete $(wp post list --post_type=page --posts_per_page=1 --post_status=publish --pagename="sample-page" --field=ID)
      wp post create --post_type=page --post_title=Homepage --post_status=publish --post_author=$(wp user get super.user --field=ID)

      wp option update show_on_front 'page'
      wp option update page_on_front $(wp post list --post_type=page --post_status=publish --posts_per_page=1 --pagename=homepage --field=ID --format=ids)

      wp menu create "Main Navigation"
      wp menu item add-post main-navigation $(wp post list --post_type=page --posts_per_page=1 --post_status=publish --pagename="homepage" --field=ID --format=ids)

      wp rewrite structure '/%postname%/'
      wp rewrite flush
    } &> /dev/null

    echo "WordPress configuration completed   ${colour_blue}75%${colour_end}"

    {
      wp plugin delete akismet
      wp plugin delete hello

      rm -rf ./wp-content/themes/twenty*

      theme_name="${sitename}-theme" | iconv -t ascii//TRANSLIT | sed -E s/[^a-zA-Z0-9]+/-/g | sed -E s/^-+\|-+$//g | tr A-Z a-z
      theme_location="${PWD}/wp-content/themes/$theme_name"

      mkdir $theme_location
    } &> /dev/null

    echo "WordPress tidy up completed         ${colour_blue}100%${colour_end}"
    echo ""

    echo "========================================================================="
    echo "Installation is complete. Your username & password are listed below."
    echo ""
    echo "Username: ${colour_green}super.user${colour_end}"
    echo "Password: ${colour_green}$password${colour_end}"
    echo ""
    echo "Your WordPress site is now ready for a theme within:"
    echo "${colour_green}$theme_location${colour_end}"
    echo ""
    echo "========================================================================="
  fi
fi
