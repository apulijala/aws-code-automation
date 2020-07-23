#!/bin/bash
sudo kill -9 $(forever list | grep "server.js" | awk '{print $6}')
