#!/bin/bash

for pattern in 'main.pdf' '*.aux' '*.bbl' '*.blg' '*.log' '*.out'; do
  find . -maxdepth 2 -iname "${pattern}" -print -delete
done
