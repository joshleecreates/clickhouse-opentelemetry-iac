grafana:
  plugins:
    - vertamedia-clickhouse-datasource
opentelemetry-collector:
  config:
    exporters:
      clickhouse:
        endpoint: "clickhouse://${clickhouse_url}:9000"
        database: otel
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
