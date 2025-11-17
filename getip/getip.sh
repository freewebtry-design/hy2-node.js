#!/usr/bin/env bash
# -*- coding: utf-8 -*-


## How to get public IP address of the host

## There are several ways to get the public IP address
## Not all of them are not working inside GFW

## Here are some of the ways

## `curl -s --max-time 10 https://api.ipify.org`  --> ok outside GFW, but not inside

## `curl -s --max-time 10 https://ipinfo.io/ip`  --> ok both inside and outside GFW, for ipv4 addr
## `curl -s --max-time 10 https://v6.ipinfo.io/ip`  --> ok both inside and outside GFW, for ipv6 addr

## `curl -s --max-time 10 https://checkip.amazonaws.com/`  --> ok both inside and outside GFW, for ipv4 addr



