components:
  frontendProxy:
    service:
      type: LoadBalancer
grafana:
  plugins:
    - vertamedia-clickhouse-datasource
    - grafana-opensearch-datasource
  datasources:
    datasources-altinity.yaml:
      apiVersion: 1
      datasources:
        - name: Altinity
          uid: webstore-altinity
          type: vertamedia-clickhouse-datasource
          url: "http://${clickhouse_url}:8123"
          editable: true
          isDefault: false
          basicAuth: true
          basicAuthUser: ${clickhouse_username}
          basicAuthPassword: ${clickhouse_password}
opentelemetry-collector:
  config:
    exporters:
      clickhouse:
        endpoint: "http://${clickhouse_url}:8123"
        database: otel
        create_schema: true
        cluster_name: "dev"
        username: ${clickhouse_username}
        password: ${clickhouse_password}
        logs_table_name: otel_logs
        traces_table_name: otel_traces
        metrics_table_name: otel_metrics
        timeout: 5s
        retry_on_failure:
          enabled: true
          initial_interval: 5s
          max_interval: 30s
          max_elapsed_time: 300s
    service:
      pipelines:
        logs:
          exporters:
            - debug
            - clickhouse
        metrics:
          exporters:
            - otlphttp/prometheus
            - clickhouse
        traces:
          exporters:
            - otlp
            - debug
            - spanmetrics
            - clickhouse
