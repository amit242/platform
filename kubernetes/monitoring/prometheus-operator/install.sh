#! /bin/bash
helm upgrade --install prom-operator-r1 stable/prometheus-operator --version=5.12.4 \
--namespace monitoring \
--set prometheusOperator.createCustomResource=false \
-f values.yaml