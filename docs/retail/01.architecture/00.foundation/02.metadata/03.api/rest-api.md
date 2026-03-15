---
title: 元数据 API 层架构 - REST API
taxonomy:
    category: docs
---

# 元数据 API 层架构 - REST API

## 概述

本文档定义元数据管理系统的 REST API 规范，包括端点定义、请求/响应格式、错误处理和认证授权。

对应业务规格：[00.specs/00.foundation/02.metadata/](../../../00.specs/00.foundation/02.metadata/)

## API 基础规范

### 基础 URL

```
生产环境: https://api.retail.com/metadata/v1
测试环境: https://api-test.retail.com/metadata/v1
```

### 通用请求头

```http
Content-Type: application/json
Authorization: Bearer {access_token}
X-Tenant-ID: {tenant_id}
X-Request-ID: {unique_request_id}
```

### 通用响应头

```http
Content-Type: application/json
X-Request-ID: {unique_request_id}
X-Rate-Limit-Remaining: {remaining_requests}
X-Rate-Limit-Reset: {reset_timestamp}
```

### 响应格式

**成功响应**：
```json
{
  "success": true,
  "data": { /* 业务数据 */ },
  "meta": {
    "requestId": "req_123abc",
    "timestamp": "2024-03-15T10:30:00Z"
  }
}
```

**错误响应**：
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": [
      {
        "field": "code",
        "message": "Entity code already exists"
      }
    ]
  },
  "meta": {
    "requestId": "req_123abc",
    "timestamp": "2024-03-15T10:30:00Z"
  }
}
```

## API 端点定义

### Entity API

#### 创建实体

```http
POST /entities
```

**请求体**：
```json
{
  "code": "Product",
  "name": "产品",
  "namePlural": "产品",
  "type": "Base",
  "iconClass": "fa-product",
  "color": "#3366ff",
  "customizable": true,
  "layoutsEnabled": true,
  "tabEnabled": true,
  "aclEnabled": true,
  "importable": true,
  "options": {}
}
```

**响应**：`201 Created`
```json
{
  "success": true,
  "data": {
    "id": "entity_123",
    "code": "Product",
    "name": "产品",
    "namePlural": "产品",
    "type": "Base",
    "version": 1,
    "isActive": true,
    "createdAt": "2024-03-15T10:30:00Z",
    "createdBy": {
      "id": "user_123",
      "name": "Admin User"
    }
  }
}
```

#### 更新实体

```http
PUT /entities/{entityId}
```

**请求体**：
```json
{
  "name": "产品（更新）",
  "description": "产品实体描述"
}
```

**响应**：`200 OK`

#### 删除实体

```http
DELETE /entities/{entityId}
```

**响应**：`204 No Content`

#### 获取实体详情

```http
GET /entities/{entityId}
```

**响应**：`200 OK`
```json
{
  "success": true,
  "data": {
    "id": "entity_123",
    "code": "Product",
    "name": "产品",
    "type": "Base",
    "fields": [
      {
        "id": "field_1",
        "code": "name",
        "name": "产品名称",
        "fieldType": "varchar",
        "required": true
      }
    ],
    "attributes": [],
    "version": 5,
    "createdAt": "2024-03-15T10:30:00Z"
  }
}
```

#### 列出实体

```http
GET /entities?page=1&pageSize=20&type=Base&isActive=true
```

**查询参数**：
- `page`: 页码（默认 1）
- `pageSize`: 每页大小（默认 20，最大 100）
- `type`: 实体类型过滤
- `isActive`: 是否生效
- `sort`: 排序字段（如 `createdAt:desc`）

**响应**：`200 OK`
```json
{
  "success": true,
  "data": {
    "items": [...],
    "total": 100,
    "page": 1,
    "pageSize": 20,
    "totalPages": 5
  }
}
```

### Field API

#### 创建字段

```http
POST /entities/{entityId}/fields
```

**请求体**：
```json
{
  "code": "price",
  "name": "价格",
  "fieldType": "decimal",
  "required": true,
  "params": {
    "precision": 10,
    "scale": 2
  },
  "defaultValue": 0.00
}
```

**响应**：`201 Created`

#### 批量创建字段

```http
POST /entities/{entityId}/fields/batch
```

**请求体**：
```json
{
  "fields": [
    {
      "code": "name",
      "name": "名称",
      "fieldType": "varchar",
      "params": {
        "maxLength": 255
      }
    },
    {
      "code": "description",
      "name": "描述",
      "fieldType": "text"
    }
  ]
}
```

**响应**：`201 Created`
```json
{
  "success": true,
  "data": {
    "created": [
      {"id": "field_1", "code": "name"},
      {"id": "field_2", "code": "description"}
    ],
    "failed": []
  }
}
```

#### 更新字段

```http
PUT /fields/{fieldId}
```

#### 删除字段

```http
DELETE /fields/{fieldId}
```

### Attribute API

#### 创建属性

```http
POST /entities/{entityId}/attributes
```

**请求体**：
```json
{
  "code": "brand",
  "name": "品牌",
  "attributeType": "varchar",
  "required": false,
  "isMultilang": false
}
```

#### 获取实体属性

```http
GET /entities/{entityId}/attributes
```

### Client Config API

#### 更新客户端配置

```http
PUT /entities/{entityId}/client-config
```

**请求体**：
```json
{
  "controller": "controllers/record",
  "views": {
    "list": "views/record/list",
    "detail": "views/record/detail"
  },
  "recordViews": {
    "list": "views/record/panels/list",
    "detail": "views/record/panels/detail"
  }
}
```

#### 获取客户端配置

```http
GET /entities/{entityId}/client-config
```

### Version API

#### 获取版本历史

```http
GET /entities/{entityId}/versions
```

**响应**：`200 OK`
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "version": 5,
        "operation": "UPDATE",
        "comment": "更新实体名称",
        "createdAt": "2024-03-15T10:30:00Z",
        "createdBy": {
          "id": "user_123",
          "name": "Admin User"
        }
      },
      {
        "version": 4,
        "operation": "UPDATE",
        "comment": "添加新字段",
        "createdAt": "2024-03-14T15:20:00Z",
        "createdBy": {
          "id": "user_456",
          "name": "Developer"
        }
      }
    ],
    "total": 5
  }
}
```

#### 获取版本快照

```http
GET /entities/{entityId}/versions/{version}
```

#### 版本对比

```http
GET /entities/{entityId}/versions/compare?from=4&to=5
```

**响应**：`200 OK`
```json
{
  "success": true,
  "data": {
    "changes": [
      {
        "field": "name",
        "oldValue": "Product",
        "newValue": "产品",
        "type": "field_changed"
      },
      {
        "field": "fields",
        "changeType": "added",
        "item": {
          "code": "newField",
          "name": "New Field"
        }
      }
    ]
  }
}
```

#### 回滚到版本

```http
POST /entities/{entityId}/rollback
```

**请求体**：
```json
{
  "targetVersion": 4,
  "comment": "回滚到错误修复前的版本"
}
```

### Validation API

#### 验证元数据

```http
POST /metadata/validate
```

**请求体**：
```json
{
  "objectType": "ENTITY",
  "data": {
    "code": "Product",
    "name": "产品",
    "type": "Base"
  }
}
```

**响应**：`200 OK`
```json
{
  "success": true,
  "data": {
    "valid": true,
    "warnings": [],
    "errors": []
  }
}
```

#### 兼容性检查

```http
POST /metadata/validate/compatibility
```

**请求体**：
```json
{
  "changes": [
    {
      "objectType": "FIELD",
      "operation": "DELETE",
      "objectId": "field_123"
    }
  ],
  "baselineVersion": "v1.2.0"
}
```

**响应**：`200 OK`
```json
{
  "success": true,
  "data": {
    "compatible": false,
    "issues": [
      {
        "severity": "ERROR",
        "code": "FIELD_IN_USE",
        "message": "Field is used in layout",
        "affectedObjects": [
          {
            "type": "LAYOUT",
            "id": "layout_456"
          }
        ]
      }
    ]
  }
}
```

### Release API

#### 创建发布请求

```http
POST /releases
```

**请求体**：
```json
{
  "name": "Release v1.3.0",
  "description": "新增产品分类功能",
  "changes": [
    {
      "objectType": "ENTITY",
      "objectId": "entity_123",
      "operation": "UPDATE"
    }
  ],
  "canary": {
    "enabled": true,
    "tenantIds": ["tenant_test_1", "tenant_test_2"]
  }
}
```

#### 审批发布

```http
POST /releases/{releaseId}/approve
```

**请求体**：
```json
{
  "decision": "APPROVE",
  "comment": "验证通过，批准发布"
}
```

#### 执行发布

```http
POST /releases/{releaseId}/execute
```

#### 回滚发布

```http
POST /releases/{releaseId}/rollback
```

**请求体**：
```json
{
  "reason": "性能下降，需要回滚",
  "rollbackToVersion": "v1.2.0"
}
```

### Promotion API

#### 创建提升请求

```http
POST /promotions
```

**请求体**：
```json
{
  "tenantId": "tenant_123",
  "changeIds": ["change_1", "change_2"],
  "reason": "通用性较强的扩展，建议提升到基线"
}
```

#### 评估提升请求

```http
POST /promotions/{promotionId}/evaluate
```

**响应**：`200 OK`
```json
{
  "success": true,
  "data": {
    "promotionId": "promo_123",
    "evaluation": {
      "generalization": "HIGH",
      "complexity": "MEDIUM",
      "conflicts": [],
      "recommendations": [
        "重命名自定义字段前缀 x_ 为标准字段名",
        "更新文档和示例"
      ]
    },
    "canPromote": true
  }
}
```

## 错误码定义

| 错误码 | HTTP 状态 | 说明 |
|--------|----------|------|
| `VALIDATION_ERROR` | 400 | 输入验证失败 |
| `COMPATIBILITY_ERROR` | 409 | 兼容性冲突 |
| `CONFLICT_ERROR` | 409 | 资源冲突 |
| `VERSION_ERROR` | 409 | 版本冲突 |
| `PERMISSION_ERROR` | 403 | 权限不足 |
| `NOT_FOUND_ERROR` | 404 | 资源不存在 |
| `RATE_LIMIT_ERROR` | 429 | 请求频率超限 |
| `INTERNAL_ERROR` | 500 | 服务器内部错误 |

## 限流策略

### 默认限流

- **读取操作**：1000 请求/分钟
- **写入操作**：100 请求/分钟
- **批量操作**：10 请求/分钟

### 限流响应

```http
HTTP/1.1 429 Too Many Requests
X-Rate-Limit-Limit: 100
X-Rate-Limit-Remaining: 0
X-Rate-Limit-Reset: 1647345600

{
  "success": false,
  "error": {
    "code": "RATE_LIMIT_ERROR",
    "message": "Rate limit exceeded",
    "details": {
      "limit": 100,
      "resetAt": "2024-03-15T11:00:00Z"
    }
  }
}
```

## 分页规范

### 游标分页（推荐）

**请求**：
```http
GET /entities?pageSize=20&cursor=eyJpZCI6ImVudGl0eV8xMjMifQ==
```

**响应**：
```json
{
  "success": true,
  "data": {
    "items": [...],
    "nextCursor": "eyJpZCI6ImVudGl0eV8xMjQifQ==",
    "hasMore": true
  }
}
```

### 偏移分页

**请求**：
```http
GET /entities?page=1&pageSize=20
```

**响应**：
```json
{
  "success": true,
  "data": {
    "items": [...],
    "total": 100,
    "page": 1,
    "pageSize": 20,
    "totalPages": 5
  }
}
```

## 批量操作

### 批量创建

```http
POST /entities/batch
```

**请求体**：
```json
{
  "items": [
    {"code": "Entity1", "name": "实体1"},
    {"code": "Entity2", "name": "实体2"}
  ]
}
```

**响应**：
```json
{
  "success": true,
  "data": {
    "created": [
      {"id": "entity_1", "code": "Entity1"},
      {"id": "entity_2", "code": "Entity2"}
    ],
    "failed": []
  }
}
```

### 批量更新

```http
PUT /entities/batch
```

### 批量删除

```http
DELETE /entities/batch
```

**请求体**：
```json
{
  "ids": ["entity_1", "entity_2"]
}
```

## Webhooks

### Webhook 配置

```http
POST /webhooks
```

**请求体**：
```json
{
  "url": "https://customer.com/webhooks/metadata",
  "events": [
    "entity.created",
    "entity.updated",
    "field.created"
  ],
  "secret": "webhook_secret_key",
  "isActive": true
}
```

### Webhook 事件格式

```json
{
  "eventId": "evt_123abc",
  "eventType": "entity.created",
  "timestamp": "2024-03-15T10:30:00Z",
  "data": {
    "entity": {
      "id": "entity_123",
      "code": "Product",
      "name": "产品"
    }
  },
  "signature": "sha256=..."
}
```

## 相关文档

- 服务层架构：[../02.services/](../02.services/)
- 安全架构：[../04.security/](../04.security/)
- GraphQL API：[./graphql-api.md](./graphql-api.md)
