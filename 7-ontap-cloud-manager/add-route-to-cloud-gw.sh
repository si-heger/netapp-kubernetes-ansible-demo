#!/bin/sh

sudo route add -net 172.16.0.0 netmask 255.255.0.0 gw 172.20.218.11 metric 1024 ens160
