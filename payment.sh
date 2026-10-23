#!/bin/bash
app_name=payment

source ./common.sh
check_user

app_setup
payment_setup
systemd_setup

restart
total_time