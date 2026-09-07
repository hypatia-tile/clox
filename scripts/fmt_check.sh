#!/usr/bin/env bash

clang-format --dry-run --Werror {src,test}/*
