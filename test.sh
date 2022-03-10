#!/bin/bash
source /opt/ros/melodic/setup.bash
source ~/catkin_ws/devel/setup.bash
export ROS_PACKAGE_PATH=~/catkin_ws/src:/opt/ros/melodic/share
#设置本机hostname
export ROS_HOSTNAME=zzu-desktop
export ROS_MASTER_URI=http://localhost:11311
export DISPLAY=:0.0
roslaunch kinect2_bridge kinect2_bridge.launch publish_tf:=true 
