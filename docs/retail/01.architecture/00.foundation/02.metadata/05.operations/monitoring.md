---
title: 元数据运维架构
taxonomy:
    category: docs
---

# 元数据运维架构

## 概述

本文档定义元数据管理系统的运维架构，包括监控、告警、部署和故障处理。

对应业务规格：[00.specs/00.foundation/02.metadata/05.governance/](../../../00.specs/00.foundation/02.metadata/05.governance/)

## 监控体系

### 监控架构

```
┌─────────────────────────────────────────────────────────────┐
│                      应用层监控                              │
│  - 应用指标 (Metrics)                                        │
│  - 分布式链路追踪 (Tracing)                                  │
│  - 日志聚合 (Logging)                                       │
├─────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐        │
│  │ Prometheus   │  │ Jaeger       │  │ ELK Stack    │        │
│  └──────────────┘  └──────────────┘  └──────────────┘        │
│                                                                  │
├─────────────────────────────────────────────────────────────┤
│                      中间件监控                               │
│  - MySQL 指标                                                 │
│  - Redis 指标                                                 │
│  - 消息队列指标                                               │
├─────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐        │
│  │ MySQL Exporter│  │ Redis Exporter│  │ MQ Exporter  │        │
│  └──────────────┘  └──────────────┘  └──────────────┘        │
│                                                                  │
├─────────────────────────────────────────────────────────────┤
│                      基础设施监控                             │
│  - 服务器指标                                                 │
│  - 网络指标                                                   │
│  - 容器指标                                                   │
└─────────────────────────────────────────────────────────────┘
```

### 应用指标

#### 性能指标

| 指标名称 | 类型 | 说明 | 目标值 |
|---------|------|------|-------|
| `metadata_request_duration` | Histogram | 请求响应时间 | P95 < 200ms |
| `metadata_request_rate` | Gauge | 请求速率 | - |
| `metadata_error_rate` | Gauge | 错误率 | < 0.1% |
| `metadata_cache_hit_rate` | Gauge | 缓存命中率 | > 80% |
| `metadata_db_query_duration` | Histogram | 数据库查询时间 | P95 < 50ms |

#### 业务指标

| 指标名称 | 类型 | 说明 |
|---------|------|------|
| `metadata_entity_count` | Gauge | 实体总数 |
| `metadata_field_count` | Gauge | 字段总数 |
| `metadata_attribute_count` | Gauge | 属性总数 |
| `metadata_active_releases` | Gauge | 活跃发布数 |
| `metadata_pending_approvals` | Gauge | 待审批数 |
| `metadata_custom_extensions` | Gauge | 租户自定义扩展数 |

#### 系统指标

| 指标名称 | 类型 | 说明 | 告警阈值 |
|---------|------|------|---------|
| `metadata_cpu_usage` | Gauge | CPU 使用率 | > 80% |
| `metadata_memory_usage` | Gauge | 内存使用率 | > 85% |
| `metadata_disk_usage` | Gauge | 磁盘使用率 | > 80% |
| `metadata_thread_count` | Gauge | 线程数 | > 500 |
| `metadata_gc_duration` | Histogram | GC 时间 | P95 > 1s |

### Prometheus 配置

**采集配置**：
```yaml
scrape_configs:
  - job_name: 'metadata-service'
    metrics_path: '/metrics'
    scrape_interval: 15s
    static_configs:
      - targets: ['metadata-service:8080']
    relabel_configs:
      - source_labels: [__address__]
        target_label: instance
        replacement: 'metadata-service'
```

**PromQL 查询**：
```promql
# 错误率
rate(metadata_http_requests_total{status=~"5.."}[5m]) / rate(metadata_http_requests_total[5m])

# P95 响应时间
histogram_quantile(0.95, rate(metadata_request_duration_seconds_bucket[5m]))

# 缓存命中率
metadata_cache_hits / (metadata_cache_hits + metadata_cache_misses)
```

### 链路追踪

**Jaeger 集成**：
```typescript
import { tracer } from 'jaeger-client'

interface MetadataService {
  async createEntity(data: EntityCreateInput): Promise<Entity> {
    const span = tracer.startSpan('MetadataService.createEntity')
    try {
      // 业务逻辑
      span.setTag('entity.code', data.code)
      span.setTag('entity.type', data.type)
      return result
    } catch (error) {
      span.setTag('error', error)
      throw error
    } finally {
      span.finish()
    }
  }
}
```

### 日志聚合

**日志格式**：
```json
{
  "@timestamp": "2024-03-15T10:30:00Z",
  "level": "INFO",
  "service": "metadata-service",
  "environment": "production",
  "tenantId": "tenant_123",
  "userId": "user_456",
  "requestId": "req_abc123",
  "operation": "createEntity",
  "duration": 125,
  "status": "success",
  "entityId": "entity_789",
  "message": "Entity created successfully"
}
```

**Kibana 查询**：
```json
{
  "query": {
    "bool": {
      "must": [
        {"match": {"service": "metadata-service"}},
        {"range": {"@timestamp": {"gte": "now-1h"}}},
        {"match": {"level": "ERROR"}}
      ]
    }
  },
  "aggs": {
    "by_tenant": {
      "terms": {"field": "tenantId.keyword"}
    }
  }
}
```

## 告警配置

### 告警规则

```yaml
groups:
  - name: metadata_alerts
    interval: 30s
    rules:
      # P0 - 严重告警
      - alert: MetadataServiceDown
        expr: up{job="metadata-service"} == 0
        for: 1m
        labels:
          severity: critical
          priority: P0
        annotations:
          summary: "Metadata service is down"
          description: "Metadata service has been down for more than 1 minute"

      - alert: MetadataHighErrorRate
        expr: rate(metadata_http_requests_total{status=~"5.."}[5m]) / rate(metadata_http_requests_total[5m]) > 0.05
        for: 2m
        labels:
          severity: critical
          priority: P0
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value | humanizePercentage }} for last 5 minutes"

      # P1 - 高优先级告警
      - alert: MetadataHighLatency
        expr: histogram_quantile(0.95, rate(metadata_request_duration_seconds_bucket[5m])) > 0.5
        for: 5m
        labels:
          severity: warning
          priority: P1
        annotations:
          summary: "High latency detected"
          description: "P95 latency is {{ $value }}s for last 5 minutes"

      - alert: MetadataDatabaseSlow
        expr: histogram_quantile(0.95, rate(metadata_db_query_duration_seconds_bucket[5m])) > 0.1
        for: 5m
        labels:
          severity: warning
          priority: P1
        annotations:
          summary: "Database query slow"
          description: "P95 DB query time is {{ $value }}s for last 5 minutes"

      # P2 - 中优先级告警
      - alert: MetadataLowCacheHitRate
        expr: metadata_cache_hits / (metadata_cache_hits + metadata_cache_misses) < 0.7
        for: 10m
        labels:
          severity: info
          priority: P2
        annotations:
          summary: "Low cache hit rate"
          description: "Cache hit rate is {{ $value | humanizePercentage }} for last 10 minutes"

      - alert: MetadataHighMemoryUsage
        expr: metadata_memory_usage > 0.85
        for: 5m
        labels:
          severity: warning
          priority: P2
        annotations:
          summary: "High memory usage"
          description: "Memory usage is {{ $value | humanizePercentage }}"
```

### 告警通知

**AlertManager 配置**：
```yaml
receivers:
  - name: 'critical-alerts'
    webhook_configs:
      - url: 'https://api.slack.com/incoming/webhook'
        send_resolved: true
    email_configs:
      - to: 'ops-team@company.com'
        send_resolved: true

  - name: 'warning-alerts'
    webhook_configs:
      - url: 'https://api.slack.com/incoming/webhook'
        send_resolved: true

route:
  receiver: 'critical-alerts'
  group_by: ['alertname', 'cluster', 'service']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 12h
  routes:
    - match:
        severity: critical
      receiver: 'critical-alerts'
    - match:
        severity: warning
      receiver: 'warning-alerts'
```

## 部署架构

### 容器化部署

**Dockerfile**：
```dockerfile
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
EXPOSE 8080
CMD ["node", "dist/main.js"]
```

**Kubernetes Deployment**：
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: metadata-service
  labels:
    app: metadata-service
spec:
  replicas: 3
  selector:
    matchLabels:
      app: metadata-service
  template:
    metadata:
      labels:
        app: metadata-service
    spec:
      containers:
      - name: metadata-service
        image: metadata-service:latest
        ports:
        - containerPort: 8080
        env:
        - name: DB_HOST
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: host
        - name: REDIS_HOST
          valueFrom:
            configMapKeyRef:
              name: redis-config
              key: host
        resources:
          requests:
            memory: "512Mi"
            cpu: "500m"
          limits:
            memory: "1Gi"
            cpu: "1000m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
```

### 滚动更新

**更新策略**：
```yaml
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
```

**金丝雀发布**：
```yaml
apiVersion: flagger.app/v1beta1
kind: Canary
metadata:
  name: metadata-service
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: metadata-service
  service:
    port: 8080
  analysis:
    interval: 1m
    threshold: 5
    maxWeight: 50
    stepWeight: 10
    metrics:
    - name: request-success-rate
      thresholdRange:
        min: 99
      interval: 1m
    - name: request-duration
      thresholdRange:
        max: 500
      interval: 1m
```

## 故障处理

### 故障等级

| 等级 | 描述 | 响应时间 | 解决时间 |
|-----|------|---------|---------|
| P0 | 核心功能不可用 | 15 分钟 | 2 小时 |
| P1 | 性能严重下降 | 1 小时 | 4 小时 |
| P2 | 单功能受限 | 4 小时 | 1 工作日 |
| P3 | 优化建议 | 2 工作日 | 1 周 |

### 故障处理流程

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  故障检测   │ -> │  故障响应   │ -> │  故障恢复   │
└─────────────┘    └─────────────┘    └─────────────┘
       │                  │                  │
       ▼                  ▼                  ▼
  监控告警            告警分级            执行修复
  用户报告            响应团队            验证恢复
  自动检测            问题定位            事后分析
                      临时方案            改进措施
```

### 常见故障处理

#### 数据库连接池耗尽

**现象**：
- 大量 `Connection timeout` 错误
- 应用响应缓慢

**处理步骤**：
1. 检查连接池配置
2. 分析慢查询，优化 SQL
3. 增加连接池大小
4. 考虑数据库扩容

#### 缓存穿透

**现象**：
- 大量请求未命中缓存
- 数据库压力增大

**处理步骤**：
1. 分析缓存未命中原因
2. 优化缓存键设计
3. 实施布隆过滤器
4. 增加缓存预热

#### 内存泄漏

**现象**：
- 内存使用持续增长
- 频繁 GC，性能下降

**处理步骤**：
1. 生成堆转储（Heap Dump）
2. 分析内存占用
3. 定位泄漏对象
4. 修复代码，重新部署

## 备份与恢复

### 备份策略

**数据库备份**：
```bash
# 每日全量备份
0 2 * * * mysqldump --single-transaction --routines --triggers \
  --all-databases | gzip > /backup/metadata-full-$(date +\%Y\%m\%d).sql.gz

# 每小时增量备份
0 * * * * mysqldump --single-transaction --where="updated_at >= DATE_SUB(NOW(), INTERVAL 1 HOUR)" \
  metadata_entity metadata_field metadata_attribute | \
  gzip > /backup/metadata-incremental-$(date +\%Y\%m\%d\%H).sql.gz
```

**配置备份**：
```bash
# 备份配置文件
rsync -avz /etc/metadata-service/ /backup/config/

# 备份 Redis 配置
redis-cli --rdb /backup/redis/dump-$(date +\%Y\%m\%d).rdb
```

### 恢复流程

**数据库恢复**：
```bash
# 停止应用
kubectl scale deployment metadata-service --replicas=0

# 恢复数据库
gunzip < /backup/metadata-full-20240315.sql.gz | mysql

# 验证数据
mysql -e "SELECT COUNT(*) FROM metadata_entity WHERE yn = 'N'"

# 启动应用
kubectl scale deployment metadata-service --replicas=3

# 验证服务
curl http://metadata-service:8080/health
```

## 运维自动化

### CI/CD 流程

```yaml
# .github/workflows/deploy.yml
name: Deploy Metadata Service

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Build Docker image
        run: docker build -t metadata-service:${{ github.sha }} .
      - name: Run tests
        run: npm test
      - name: Push to registry
        run: docker push metadata-service:${{ github.sha }}

  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to production
        run: |
          kubectl set image deployment/metadata-service \
            metadata-service=metadata-service:${{ github.sha }}
      - name: Verify deployment
        run: |
          kubectl rollout status deployment/metadata-service
          curl -f http://metadata-service/health || exit 1
```

### 健康检查

**健康检查端点**：
```typescript
app.get('/health', (req, res) => {
  const health = {
    status: 'healthy',
    timestamp: new Date().toISOString(),
    checks: {
      database: checkDatabase(),
      redis: checkRedis(),
      disk: checkDisk()
    }
  }

  const allHealthy = Object.values(health.checks).every(c => c.status === 'healthy')
  res.status(allHealthy ? 200 : 503).json(health)
})
```

## 相关文档

- 存储层架构：[../01.storage/](../01.storage/)
- 服务层架构：[../02.services/](../02.services/)
- API 层架构：[../03.api/](../03.api/)
- 安全架构：[../04.security/](../04.security/)
