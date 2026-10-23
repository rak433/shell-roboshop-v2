#!/bin/bash
app_name=payment

source ./common.sh
check_user

app_setup
python_setup
systemd_setup

restart
total_time