#!/bin/bash
# panda机械臂的服务端，用于与工作站通讯，并接受工作站的命令，调用本包内的其他脚本/命令，来实现对panda机械臂的加解锁、重启ros controller的效果
#2020/08/09   zzu-wgk  first-release
#2022/03/01   zzu-wgk  version 1.1

#如果模式为"-s"，就代表是刚启动，要运行roscore
#注意，方括号后面要有一个空格才行，否则报错
# == 双等号前后都要有一个空格，否则恒成立
#变量赋值的时候，需要和等号挨着，不能有空格
panda_state=1
#${0} ${1}  ${2} ...是系统保留的变量，分别代表了当前脚本本身的名称、执行命令后缀的第一个参数、第二个参数、第三个参数...
robot_ip="${2}"
source /opt/ros/melodic/setup.bash
export ROS_PACKAGE_PATH=~/catkin_ws/src:/opt/ros/melodic/share
#设置本机hostname
export ROS_HOSTNAME=zzu-desktop

if [ -z  "${2}" ]; then
	echo "未指定robot_ip"
	echo "默认指定为192.168.10.1"
	robot_ip="192.168.10.1"
fi

#接收-s指令，解锁机械臂，启动/重启ros_controller
if [ "${1}" == "-s" ] ; then
	#解锁机械臂，让左侧panda_state=右侧，可以保证右侧执行完之后再接着执行后续的命令（有的不行）
	panda_state=$(python3 ~/catkin_ws/src/panda_server/scripts/unlock.py)
	echo "Panda_unlocked"
	#获取controller的pid进程号,awk '{print $2}'代表将语句按照空格划分，并返回和打印出第二部分非空格的字符
	controller_pid=$(ps -aux | grep "roslaunch panda_server panda_ros_controllers.launch" | grep "/usr/bin/python" | awk '{print $2}')
	echo "$controller_pid"
	#判断进程号是不是为null
	if [ -z "$controller_pid" ]; then
		#controller_pid为零（未运行）
		
		#启动运行，加上&代表另开一个窗口，在后台执行它
		
		`roslaunch panda_server panda_ros_controllers.launch robot_ip:="$robot_ip"`
		echo "启动controller"
	else
		#controller_pid为非零（已运行）
		#杀掉进程	
		kill $controller_pid
		echo "Kill $controller_pid"
		#不断循环查询controller_pid，直到ros_controller进程完全退出之后（controller_pid为0成立）
		until [ -z "$controller_pid" ]
		do
		  controller_pid=$(ps -aux | grep "roslaunch panda_server panda_ros_controllers.launch" | grep "/usr/bin/python" | awk '{print $2}')
		done
		echo "done"
		#ros_controller进程完全退出之后，在后台重启ros_controller
		output=$(roslaunch panda_server panda_ros_controllers.launch robot_ip:="$robot_ip")
		
		echo "re-Started"
	fi

fi
#接受-sd指令，关闭shutdown关闭机械臂
if [ "${1}" == "-sd" ]; then
	#获取controller的pid进程号,awk '{print $2}'代表将语句按照空格划分，并返回和打印出第二部分非空格的字符
	controller_pid=$(ps -aux | grep "roslaunch panda_server panda_ros_controllers.launch" | grep "/usr/bin/python" | awk '{print $2}')
	echo "$controller_pid"
	#判断进程号是不是为null
	if [ -z "$controller_pid" ]; then
		#controller_pid为零（未运行）
		echo "moveit controller已停止"
	else
		#controller_pid为非零（已运行）
		#杀掉进程	
		kill $controller_pid
		echo "Kill $controller_pid"
		#不断循环查询controller_pid，直到ros_controller进程完全退出之后（controller_pid为0成立）
		until [ -z "$controller_pid" ]
		do
		  controller_pid=$(ps -aux | grep "roslaunch panda_server panda_ros_controllers.launch" | grep "/usr/bin/python" | awk '{print $2}')
		done
		echo "done"
	fi


	$(python3 ~/catkin_ws/src/panda_server/scripts/lock.py)

fi

#接受-k指令，关闭ros controller
if [ "${1}" == "-k" ]; then
	#获取controller的pid进程号,awk '{print $2}'代表将语句按照空格划分，并返回和打印出第二部分非空格的字符
	controller_pid=$(ps -aux | grep "roslaunch panda_server panda_ros_controllers.launch" | grep "/usr/bin/python" | awk '{print $2}')
	echo "$controller_pid"
	#判断进程号是不是为null
	if [ -z "$controller_pid" ]; then
		#controller_pid为零（未运行）
		echo "moveit controller已停止"
	else
		#controller_pid为非零（已运行）
		#杀掉进程	
		kill $controller_pid
		echo "Kill $controller_pid"
		#不断循环查询controller_pid，直到ros_controller进程完全退出之后（controller_pid为0成立）
		until [ -z "$controller_pid" ]
		do
		  controller_pid=$(ps -aux | grep "roslaunch panda_server panda_ros_controllers.launch" | grep "/usr/bin/python" | awk '{print $2}')
		done
		echo "done"
	fi

fi




