#!/usr/bin/env bash

# Author: Barry Qu
# Date: 2019-06-18
# Email: Qujianjun@mtc.hkex


# Global parameters
# ==================================================================================

# Sudo password
user_passwd=
python3_path="/usr/local/python3/"
# Echo styles

red='\033[31m'
green='\033[32m'
yellow='\033[33m'
blue='\033[34m'
plain='\033[0m'
twinkle='\033[5m'
bold='\033[1m'


# Directories

FDB_PATH="./.database/FDB/"
FDB_BACKUP_PATH="./.database/FDB_BACKUP/"
DFL_INPUT="./workspace/input/DFL/"
FCF_FORTIGATE="./workspace/input/FCF/fortigate/"
FCF_JUNIPER="./workspace/input/FCF/juniper/"
FCF_FIERPOWER="./workspace/input/FCF/fierpower"
FRF_PATH="./workspace/input/FRF/"
FRL_PATH="./workspace/output/FRL/"
DFL_OUTPUT="./workspace/output/DFL/"
FSR_PATH="./workspace/output/FSR/"


# Print the log and version of FRMS
# ==================================================================================
print_log(){
	clear
	echo -e ${green}"    __________  __  ________"${plain}
	echo -e ${green}"   / ____/ __ \\/  |/  / ___/"${plain}
	echo -e ${green}"  / /_  / /_/ / /|_/ /\\__ \\\\"${plain}
	echo -e ${green}" / __/ / _, _/ /  / /___/ /"${plain}
	echo -e ${green}"/_/   /_/ |_/_/  /_//____/"${plain}  ${blue}version: 0.1${plain}
	echo
	echo Welcome to FRMS, this script will help you build a running environment for FRMS.
	echo ==================================================================================
	echo
}


print_successful_log(){
	clear
	echo -e ${green}"    __________  __  ________"${plain}
	echo -e ${green}"   / ____/ __ \\/  |/  / ___/"${plain}
	echo -e ${green}"  / /_  / /_/ / /|_/ /\\__ \\\\"${plain}
	echo -e ${green}" / __/ / _, _/ /  / /___/ /"${plain}
	echo -e ${green}"/_/   /_/ |_/_/  /_//____/"${plain}  ${blue}version: 0.1${plain}
	echo
	echo ==================================================================================
    echo -e ${green}"All done! Now you can use FRMS to your heart's content. Enjoy your work!"${plain}
    echo
}


# Confirmation of system user identity
# ==================================================================================

check_user () {
	typeset -u user_choice
	read -p "Are you sure you want to build the environment now?(Y/N): " user_choice

	while [[ ${user_choice} != "Y" && ${user_choice} != "N" ]]
	do
    	read -p "Incorrect input, please try again(Y/N): " user_choice
	done

	if [[ ${user_choice} == "N" ]];then
		echo Thanks for using FRMS, see you!
		exit 1
	fi

	if [[ $EUID -ne 0 ]];then
	    echo -e ${bold}${red}[Tips] You are not the root, please enter your password to enable sudo permissions.${plain}
	    PRINT=`stty -g`
		stty -echo
	    read -p 'Enter your password: ' user_passwd
	    stty ${PRINT}
		echo
	    echo ${user_passwd} |sudo -S cat /etc/passwd >/dev/null 2>&1
	    if [[ $? -eq 1 ]];then
	    	echo -e ${red}You are not in the sudoers file, or the passowrd is incorrect.${plain} 
			echo -e ${red}And FRMS will now quit!${plain}
	    	exit 1
	    fi
	fi
}


# Create directories
# ==================================================================================

make_dirs() {
	dirs=($FDB_PATH $FDB_BACKUP_PATH $DFL_INPUT $FCF_FORTIGATE $FCF_JUNIPER $FCF_FIERPOWER \
		  $FRF_PATH $FRL_PATH $DFL_OUTPUT $FSR_PATH)
	for index in ${!dirs[@]};do
		mkdir -p ${dirs[$index]}
	done
}


# Install dependency packages
# ==================================================================================

install_packages() {
	echo
	echo ==================================================================================
	echo -e ${green}Start installing dependency packages...${plain}
	echo ==================================================================================
	echo
	if [ $user_passwd = "" ];then
		cd ./packages/rpms/
		rpm -Uvh --nodeps --force ./*.rpm
		if [ $? -eq 0 ];then
			echo
			echo ==================================================================================
			echo -e ${green}Congratulations! All dependency packages was installed!${plain}
			echo ==================================================================================
			echo
		else
			echo
			echo ==================================================================================
			echo -e ${red}Sorry! It looks like some dependency package failed to install!${plain}
			exit 1
		fi
	else
		cd ./packages/rpms/
		echo ${user_passwd} |sudo -S rpm -Uvh --nodeps --force ./*.rpm
	fi
	echo
	echo ==================================================================================
	echo -e ${green}All dependency packages was installed.${plain}
	echo ==================================================================================
	echo
}


# Install Python 3.6.8
# ==================================================================================

install_python3() {
	echo
	echo ==================================================================================
	echo -e ${green}Start compiling and installing Python3.6.8${plain}
	echo ==================================================================================
	echo
	if [ $user_passwd = "" ];then
		if [ ! -d ${python3_path} ];then
	    	mkdir ${python3_path}
	    else
	    	python3_path="/usr/local/python3.6/"
	    	mkdir ${python3_path}
		fi
		cd ../python/
		tar -zxvf Python-3.6.8.tgz
		cd ./Python-3.6.8/
		./configure --prefix=${python3_path} \
		&& make -j4 && make install \
		&& ln -s ${python3_path}bin/python3.6 /usr/bin/python3 \
		&& ln -s ${python3_path}bin/pip3.6 /usr/bin/pip3 \
		&& cd ../ && rm -rf Python-3.6.8/
	else
		if [ ! -d ${python3_path} ];then
	    	echo ${user_passwd} |sudo -S mkdir ${python3_path}
	    else
	    	python3_path="/usr/local/python3.6/"
	    	echo ${user_passwd} |sudo -S mkdir ${python3_path}
		fi
		cd ../python/
		tar -zxvf Python-3.6.8.tgz
		cd ./Python-3.6.8/
		echo ${user_passwd} |sudo -S ./configure --prefix=${python3_path} \
		&& echo ${user_passwd} |sudo -S make -j4 && echo ${user_passwd} |sudo -S make install \
		&& echo ${user_passwd} |sudo -S ln -s ${python3_path}bin/python3.6 /usr/bin/python3 \
		&& echo ${user_passwd} |sudo -S ln -s ${python3_path}bin/pip3.6 /usr/bin/pip3 \
		&& cd ../ && echo ${user_passwd} |sudo -S rm -rf Python-3.6.8/
	fi
	python_version=`python3 --version`
	if [ "$python_version" = "Python 3.6.8" ];then
		echo
		echo ==================================================================================
    	echo -e ${green}Congratulations! Python 3.6.8 was installed successfully!${plain}
    	echo ==================================================================================
		echo
    else
    	echo
		echo ==================================================================================
    	echo -e ${red}Sorry! It looks like Python failed to install!${plain}
    	exit 1
	fi
}


# Install some necessary modules for python3.6.8
# ==================================================================================

install_module_python3() {
	echo
	echo ==================================================================================
	echo -e ${green}Start installing the necessary modules for python3.6.8${plain}
	echo ==================================================================================
	echo
	cd ./modules/
	modlues=`ls`
	if [ $user_passwd = "" ];then
		pip3 install ./*.whl
	else
		echo -e ${user_passwd} |sudo -S pip3 install ./*.whl
	fi
	echo
	echo ==================================================================================
	echo -e ${green}All the  modules was installed successfully!${plain}
	echo ==================================================================================
	echo
}


# Main program
# ==================================================================================

main() {
	print_log \
	&& check_user \
	&& make_dirs \
	&& install_packages \
	&& install_python3 \
	&& install_module_python3 \
	&& print_successful_log
}


# Start automation installation
# ==================================================================================
main