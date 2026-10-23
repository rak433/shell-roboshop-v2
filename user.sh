#!/bin/bash

source ./common.sh
check_user

app_setup
nodejs_setup
systemd_setup

restart
total_time