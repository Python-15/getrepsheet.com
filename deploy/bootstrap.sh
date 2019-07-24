#!/usr/bin/env bash

export USER=user
export HOST=host

scp nginx.conf $USER@$HOST:
scp nginx.service $USER@$HOST:
scp www_* $USER@$HOST:
scp setup.sh $USER@$HOST:
