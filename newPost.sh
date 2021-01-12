#!/bin/bash
date_str=$(date --iso-8601)
read -p "post name: " post_name
hugo new posts/$date_str-$post_name.md
