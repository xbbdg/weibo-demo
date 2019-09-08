#!/usr/bin/env bash
# 1. 拉代码到 /var/www/weibo
# 2. 执行 bash deploy.sh

set -ex

# go

rm -f /etc/nginx/sites-enabled/*
rm -f /var/www/weibo/log.txt
cd /var/www/weibo
git pull
bash deploy.sh