#!/usr/bin/env bash
# 1. 拉代码到 /var/www/weibo
# 2. 执行 bash deploy.sh

set -ex

# 系统设置
apt-get install -y curl ufw
ufw allow 22
ufw allow 80
ufw allow 443
ufw allow 465
ufw default deny incoming
ufw default allow outgoing
ufw status verbose
ufw -f enable

# redis 需要 ipv6
sysctl -w net.ipv6.conf.all.disable_ipv6=0
# 安装过程中选择默认选项，这样不会弹出 libssl 确认框
export DEBIAN_FRONTEND=noninteractive
# 装依赖
apt-get install -y git supervisor nginx python3-pip mysql-server redis-server apache2-utils
#apt-get install -y git supervisor nginx python3-pip mysql-server apache2-utils
pip3 install jinja2 flask gevent gunicorn pymysql flask_sqlalchemy flask_mail marrow.mailer redis Celery
#pip3 install jinja2 flask gevent gunicorn pymysql flask_sqlalchemy flask_mail marrow.mailer

# 删除测试用户和测试数据库
# 删除测试用户和测试数据库并限制关闭公网访问
mysql -u root -p112358 -e "DELETE FROM mysql.user WHERE User='';"
mysql -u root -p112358 -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
mysql -u root -p112358 -e "DROP DATABASE IF EXISTS test;"
mysql -u root -p112358 -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
# 设置密码并切换成密码验证
mysql -u root -p112358 -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '112358';"

# 删掉 nginx default 设置
rm -f /etc/nginx/sites-enabled/default
rm -f /etc/nginx/sites-available/default
# 不要在 sites-available 里面放任何东西
cp /var/www/weibo/weibo.nginx /etc/nginx/sites-enabled/weibo
chmod -R o+rwx /var/www/weibo

cp weibo.service /etc/systemd/system/weibo.service
#cp weibo-message-queue.service /etc/systemd/system/weibo-message-queue.service


# 初始化
cd /var/www/weibo
python3 reset.py

# 重启服务器
systemctl daemon-reload
systemctl restart weibo
#systemctl restart weibo-message-queue
systemctl restart nginx

echo 'succsss'
echo 'ip'
hostname -I
curl http://localhost



# nginx

#server {
#    listen 80;
#
#    location /static {
#        alias /var/www/weibo/demo_app/static;
#    }
#
#    location / {
#        proxy_pass http://localhost:3000;
#    }
#}

