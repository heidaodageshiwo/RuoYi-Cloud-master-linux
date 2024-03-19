#!/bin/sh

# 使用说明，用来提示输入参数
#部署时，首先 sh copy.sh
#等mysql启动成功后，需要使用navicat连接一下，要不然nacos起不来 ，或者是使用docker restart ruoyi-naocs && docker logs -f ruoyi-nacos
#
usage() {
	echo "Usage: sh 执行脚本.sh [port|base|modules|modulesrm|stop|rm]"
	echo "打包时需注意：gateway等模块需要添加nacos用户名密码等"
	echo " 每次删除时需要 dockre rmi image 镜像，否则都是之前的老镜像 "
	echo " 每次删除时需要 dockre rmi image 镜像，否则都是之前的老镜像 "
	echo " 每次删除时需要 dockre rmi image 镜像，否则都是之前的老镜像 "
	exit 1
}

# 开启所需端口
port(){
	firewall-cmd --add-port=80/tcp --permanent
	firewall-cmd --add-port=8080/tcp --permanent
	firewall-cmd --add-port=8848/tcp --permanent
	firewall-cmd --add-port=9848/tcp --permanent
	firewall-cmd --add-port=9849/tcp --permanent
	firewall-cmd --add-port=6379/tcp --permanent
	firewall-cmd --add-port=3306/tcp --permanent
	firewall-cmd --add-port=9100/tcp --permanent
	firewall-cmd --add-port=9200/tcp --permanent
	firewall-cmd --add-port=9201/tcp --permanent
	firewall-cmd --add-port=9202/tcp --permanent
	firewall-cmd --add-port=9203/tcp --permanent
	firewall-cmd --add-port=9300/tcp --permanent
	service firewalld restart
}

# 启动基础环境（必须）
base(){
	docker-compose up -d ruoyi-mysql ruoyi-redis
	sleep 30
	docker-compose up -d ruoyi-nacos
}

# 启动程序模块（必须）
modules(){
	docker-compose up -d ruoyi-nginx ruoyi-gateway ruoyi-auth ruoyi-modules-system
#	ruoyi-modules-file ruoyi-modules-job ruoyi-modules-gen
}
modulesrm(){
  docker-compose stop ruoyi-nginx ruoyi-gateway ruoyi-auth ruoyi-modules-system ruoyi-modules-file ruoyi-modules-job ruoyi-modules-gen  && docker-compose rm ruoyi-nginx ruoyi-gateway ruoyi-auth ruoyi-modules-system ruoyi-modules-file ruoyi-modules-job ruoyi-modules-gen
  docker rmi docker-ruoyi-modules-system:latest docker-ruoyi-modules-file:latest docker-ruoyi-modules-job:latest docker-ruoyi-modules-gen:latest docker-ruoyi-auth:latest docker-ruoyi-gateway:latest
#docker-ruoyi-modules-system   latest    94052af2c0d9   12 seconds ago   367MB
#docker-ruoyi-auth             latest    6c7bbc9a4655   12 seconds ago   350MB
#docker-ruoyi-gateway          latest    f58e5377288f   12 seconds ago   358MB

}
# 关闭所有环境/模块
stop(){
	docker-compose stop
}

# 删除所有环境/模块
rm(){
	docker-compose rm
}

# 根据输入参数，选择执行对应方法，不输入则执行使用说明
case "$1" in
"port")
	port
;;
"base")
	base
;;
"modules")
	modules
;;
"modulesrm")
	modulesrm
;;
"stop")
	stop
;;
"rm")
	rm
;;
*)
	usage
;;
esac
