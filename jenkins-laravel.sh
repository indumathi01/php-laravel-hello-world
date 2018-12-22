#!/bin/sh

#check command input
if [ "$#" -ne 2 ];
then
        echo "JENKINS LARAVEL PUSH"
        echo "--------------------"
        echo ""
        echo "Usage : ./jenkins-laravel.sh project-name"
        echo ""
        exit 1
fi

# Declare variables
currentdate=`date "+%Y-%m-%d"`
scriptpath="/var/bin/jenkins"
destination_project="$1"
destination_branch="master"

# Get configuration variables
source ${scriptpath}/config/laravel/${destination_project}.conf
echo "Pushing to $destination_branch .. "

item_rootdir="/var/lib/jenkins/workspace/php"
alert_email="alerts@yourdomain.com"
user_perm="uuser"
group_perm="nginx"
# STAGING
dest_user_staging="staginguser"
dest_host_staging="192.168.1.68"
dest_dir_staging="/usr/share/nginx/html/staging.yoursite.com"
# PRODUCTION
git_repo="https://github.com/indumathi01/php-laravel-hello-world.git"
dest_user_prod="produser"
dest_host_prod="0.0.0.0"
dest_dir_prod="/data/www/your-project"
dest_dir_root="/data/www/your-project"
gen_docs_prod="FALSE"
pre_prod="/home/prod-push/sfs"

################
# STAGING PUSH #
################
if [ "$destination_branch" == "master" ]
then
    destination_user="$dest_user_staging"
    destination_host="$dest_host_staging"
    destination_dir="$dest_dir_staging"
    # Push command over ssh
    ssh -l $destination_user $destination_host \
        "cd $destination_dir;\
        rm -rf composer.lock;\
        git reset --hard;\
        git fetch --all;\
        git checkout -f $destination_branch;\
        git reset --hard;\
        git fetch --all;\
        git pull origin $destination_branch;\
        /usr/local/bin/composer update --no-interaction --prefer-dist --optimize-autoloader;\
        php artisan clear-compiled;\
        php artisan migrate --force;\
        php artisan cache:clear;\
        php artisan route:clear;\
        php artisan view:clear;\
        php artisan config:clear;\
        php artisan config:cache;\
        npm i;\
        npm run dev;\
        php artisan config:clear;\
