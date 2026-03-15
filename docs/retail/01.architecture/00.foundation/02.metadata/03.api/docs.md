---
title: 元数据 API 层架构
taxonomy:
    category: docs
---

# 元数据 API 层架构

## 概述

API 层架构定义元数据管理系统的对外接口规范，包括 REST API 和 GraphQL API，负责请求处理、响应格式化和错误处理。

## 子域目录

1. [REST API 规范](./rest-api.md)
   - API 基础规范
   - 端点定义（Entity、Field、Attribute、Client Config、Version、Validation、Release、Promotion）
   - 错误码定义
   - 限流策略
   - 分页规范
   - 批量操作
   - Webhooks

## API 架构

```
┌─────────────────────────────────────────────────────────────┐
│                      API Gateway                             │
│                  (Rate Limiting, Auth)                       │
├─────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐        │
│  │ REST API     │  │ GraphQL API  │  │ Webhooks     │        │
│  └──────────────┘  └──────────────┘  └──────────────┘        │
│                                                                  │
├─────────────────────────────────────────────────────────────┤
│                        Service Layer                          │
│                                                                  │
│  MetadataService | ValidationService | GovernanceService      │
│                                                                  │
└─────────────────────────────────────────────────────────────┘
```

## API 类别

### 元数据操作 API
- Entity API - 实体管理
- Field API - 字段管理
- Attribute API - 属性管理
- Client Config API - 客户端配置管理

### 版本管理 API
- Version API - 版本历史和快照
- Compare API - 版本对比
- Rollback API - 版本回滚

### 验证 API
- Validation API - 元数据验证
- Compatibility API - 兼容性检查
- Conflict API - 冲突检测

### 发布管理 API
- Release API - 发布请求和执行
- Approval API - 审批流程
- Promotion API - 提升到基线

## 基础规范

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

### 限流策略
- **读取操作**：1000 请求/分钟
- **写入操作**：100 请求/分钟
- **批量操作**：10 请求/分钟

## 相关文档

- 服务层架构：[../02.services/](../02.services/)
- 安全架构：[../04.security/](../04.security/)
