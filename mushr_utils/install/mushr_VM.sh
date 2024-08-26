#!/bin/bash
pushd `dirname $0`

# Detect OS 
export MUSHR_OS_TYPE="$(uname -s)"

# Are we in the right place to be running this?
if [[ ! -f mushr_install.bash ]]; then
  echo Wrong directory! Change directory to the one containing mushr_install.bash
  exit 1
fi
export MUSHR_INSTALL_PATH=$(pwd)

sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
sudo apt-get update
sudo apt-get install -y curl
curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -

# Reset to specific hardware
export MUSHR_OS_TYPE="$(uname -i)"

# Robot specific settings
echo Running robot specific commands

# Setup docker base image and mushr self start service
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
sudo apt-get -y update
sudo apt-get -y install ca-certificates curl gnupg lsb-release pip sublime-text htop


pip3 install vcstool

# Pull repos
export MUSHR_WS_PATH=$(echo $MUSHR_INSTALL_PATH | sed 's:/catkin_ws.*::')
cd $MUSHR_WS_PATH/catkin_ws/src/ && vcs import < mushr/base-repos.yaml && vcs import < mushr/nav-repos.yaml


for ignored_package in push_button_utils ydlidar; do
    touch $MUSHR_WS_PATH/catkin_ws/src/mushr/mushr_hardware/${ignored_package}/CATKIN_IGNORE
done

popd

sudo apt-get update

sudo apt-get install SOFTWARE-PROPERTIES-COMMON -y

# Install docker deps for mushr_install 
sudo apt-get update -y \
    && apt-get install keyboard-configuration apt-utils gnupg2 curl -y \
    && apt-get update -y

# Download bags required for localization assignment
source $MUSHR_WS_PATH/catkin_ws/devel/setup.bash && source $MUSHR_WS_PATH/catkin_ws/src/mushr478/localization/scripts/download_bags.sh

# ======================= BEGIN ROS Noetic ===================================
# Setup software sources from packages.ros.org
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu focal main" > /etc/apt/sources.list.d/ros-latest.list'

# Setup keys
sudo apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

# Update package index
sudo apt-get update

# Install ROS libraries
sudo apt-get install ros-noetic-desktop -y

# Auto source ROS on terminal startup
sudo echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc

# Source it for this terminal
sudo source /opt/ros/noetic/setup.bash

# Install rosdep
sudo apt-get install python3-rosdep -y

# Initialize rosdep
sudo rosdep init

# Update rosdep
sudo rosdep update
# ===================== END ROS Noetic =======================================

# ===================== BEGIN dependencies ===================================

# Install git, tkinter, wget, g++, vim, tmux, networking stuff, apt-add-repository
sudo apt-get install -y git-all python3-tk wget g++ vim tmux net-tools iputils-ping software-properties-common

# Install vcstool, pip
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
sudo apt-key adv --keyserver hkp://pool.sks-keyservers.net --recv-key 0xAB17C654
sudo apt-get update
sudo apt-get install -y python3-vcstool python3-pip

# Install extra ROS packages
sudo apt-get install -y ros-noetic-ackermann-msgs ros-noetic-map-server ros-noetic-urg-node ros-noetic-robot-state-publisher ros-noetic-xacro ros-noetic-joy ros-noetic-ddynamic-reconfigure ros-noetic-fake-localization ros-noetic-gmapping ros-noetic-rosbridge-suite ros-noetic-sbpl ros-noetic-plogjuggler-ros ros-noetic-realsense2-description

# Install catkin tools
sudo wget http://packages.ros.org/ros.key -O - | apt-key add -
sudo apt-get update
sudo apt-get install -y python3-catkin-tools

pip3 install empy
pip3 install networkx
pip3 install catkin-tools ## because apparently python3-catkin-tools != catkin-tools?
sudo apt-get install -y qtbase5-dev ros-noetic-pybind11-catkin

# Auto source this workspace on terminal startup
sudo echo "source ~/catkin_ws/devel/setup.bash" >> ~/.bashrc

# Install rangelibc
cd /home/mushr/catkin_ws/src/range_libc/pywrapper
sudo python3 setup.py install
cd /home/mushr/catkin_ws/src
sudo rm -rf range_libc

# Create default RVIZ setup
mkdir /home/mushr/.rviz
cp /home/mushr/catkin_ws/src/mushr/mushr_utils/rviz/default.rviz ~/.rviz/

# ===================== END   dependencies ===================================
