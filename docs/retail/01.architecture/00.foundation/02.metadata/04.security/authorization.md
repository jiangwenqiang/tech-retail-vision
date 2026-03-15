---
title: 元数据安全架构
taxonomy:
    category: docs
---

# 元数据安全架构

## 概述

本文档定义元数据管理系统的安全架构，包括认证、授权、数据隔离和审计日志。

对应业务规格：[00.specs/00.foundation/02.metadata/](../../../00.specs/00.foundation/02.metadata/)

## 安全架构分层

```
┌─────────────────────────────────────────────────────────────┐
│                      Presentation Layer                      │
│                    (API Gateway + UI)                        │
├─────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────────────────────────────────────────────┐     │
│  │              Authentication Layer                    │     │
│  │  - JWT Tokens                                       │     │
│  │  - OAuth 2.0                                        │     │
│  │  - Session Management                               │     │
│  └─────────────────────────────────────────────────────┘     │
│                                                                  │
│  ┌─────────────────────────────────────────────────────┐     │
│  │              Authorization Layer                     │     │
│  │  - RBAC (Role-Based Access Control)                 │     │
│  │  - ABAC (Attribute-Based Access Control)            │     │
│  │  - Permission Checks                                │     │
│  └─────────────────────────────────────────────────────┘     │
│                                                                  │
│  ┌─────────────────────────────────────────────────────┐     │
│  │              Data Isolation Layer                   │     │
│  │  - Tenant Isolation                                 │     │
│  │  - Row-Level Security                               │     │
│  │  - Field-Level Security                             │     │
│  └─────────────────────────────────────────────────────┘     │
│                                                                  │
└─────────────────────────────────────────────────────────────┘
```

## 认证机制

### 认证流程

```
┌─────────┐                ┌─────────────┐                ┌──────────┐
│ Client  │ ── 1. Login ──> │ Auth Server │ ── 2. Token ─> │ Client   │
└─────────┘                └─────────────┘                └──────────┘
                                                                  │
                                                                  │ 3. API Request + Token
                                                                  ▼
                                                           ┌─────────────┐
                                                           │ API Gateway │
                                                           └─────────────┘
                                                                  │
                                                                  │ 4. Validate Token
                                                                  ▼
                                                           ┌─────────────┐
                                                           │ Auth Server │
                                                           └─────────────┘
                                                                  │
                                                                  │ 5. User Info
                                                                  ▼
                                                           ┌─────────────┐
                                                           │ API Gateway │
                                                           └─────────────┘
                                                                  │
                                                                  │ 6. Forward + User Context
                                                                  ▼
                                                           ┌─────────────┐
                                                           │   Service    │
                                                           └─────────────┘
```

### JWT Token 结构

**Header**：
```json
{
  "alg": "RS256",
  "typ": "JWT",
  "kid": "key_2024_01"
}
```

**Payload**：
```json
{
  "sub": "user_123",
  "tenantId": "tenant_456",
  "roles": ["admin", "developer"],
  "permissions": [
    "metadata:entity:create",
    "metadata:field:read",
    "metadata:attribute:update"
  ],
  "iat": 1647345600,
  "exp": 1647432000,
  "jti": "jwt_id_abc123"
}
```

### Token 生命周期

| Token 类型 | 有效期 | 刷新策略 |
|-----------|-------|---------|
| Access Token | 1 小时 | 自动刷新 |
| Refresh Token | 30 天 | 需要用户交互 |
| ID Token | 1 小时 | 不刷新 |

## 授权机制

### RBAC 模型

**角色定义**：

```typescript
enum Role {
  // 平台角色
  PLATFORM_ADMIN = 'platform_admin',           // 平台管理员
  PLATFORM_ARCHITECT = 'platform_architect',   // 平台架构师
  PLATFORM_DEVELOPER = 'platform_developer',   // 平台开发者

  // 租户角色
  TENANT_ADMIN = 'tenant_admin',               // 租户管理员
  TENANT_DEVELOPER = 'tenant_developer',       // 租户开发者
  TENANT_USER = 'tenant_user'                  // 租户用户
}
```

**权限定义**：

```typescript
enum Permission {
  // Entity 权限
  METADATA_ENTITY_CREATE = 'metadata:entity:create',
  METADATA_ENTITY_READ = 'metadata:entity:read',
  METADATA_ENTITY_UPDATE = 'metadata:entity:update',
  METADATA_ENTITY_DELETE = 'metadata:entity:delete',

  // Field 权限
  METADATA_FIELD_CREATE = 'metadata:field:create',
  METADATA_FIELD_READ = 'metadata:field:read',
  METADATA_FIELD_UPDATE = 'metadata:field:update',
  METADATA_FIELD_DELETE = 'metadata:field:delete',

  // Attribute 权限
  METADATA_ATTRIBUTE_CREATE = 'metadata:attribute:create',
  METADATA_ATTRIBUTE_READ = 'metadata:attribute:read',
  METADATA_ATTRIBUTE_UPDATE = 'metadata:attribute:update',
  METADATA_ATTRIBUTE_DELETE = 'metadata:attribute:delete',

  // Release 权限
  METADATA_RELEASE_CREATE = 'metadata:release:create',
  METADATA_RELEASE_APPROVE = 'metadata:release:approve',
  METADATA_RELEASE_EXECUTE = 'metadata:release:execute',
  METADATA_RELEASE_ROLLBACK = 'metadata:release:rollback',

  // Tenant 权限
  METADATA_TENANT_CUSTOMIZE = 'metadata:tenant:customize',
  METADATA_TENANT_PROMOTE = 'metadata:tenant:promote'
}
```

### 角色-权限映射

**平台管理员**：
```json
{
  "role": "platform_admin",
  "permissions": [
    "metadata:*:*"
  ]
}
```

**平台架构师**：
```json
{
  "role": "platform_architect",
  "permissions": [
    "metadata:entity:*",
    "metadata:field:*",
    "metadata:attribute:*",
    "metadata:release:approve",
    "metadata:tenant:promote"
  ]
}
```

**租户管理员**：
```json
{
  "role": "tenant_admin",
  "permissions": [
    "metadata:entity:read",
    "metadata:field:*",
    "metadata:attribute:*",
    "metadata:tenant:customize"
  ]
}
```

### 权限检查流程

```typescript
interface AuthorizationService {
  // 检查权限
  hasPermission(
    userId: string,
    permission: string,
    resource?: Resource
  ): Promise<boolean>

  // 批量检查权限
  hasPermissions(
    userId: string,
    permissions: string[]
  ): Promise<Record<string, boolean>>

  // 检查资源所有权
  isOwner(
    userId: string,
    resourceType: string,
    resourceId: string
  ): Promise<boolean>

  // 获取用户权限
  getUserPermissions(userId: string): Promise<Permission[]>
}
```

### 资源级权限

**Entity 级别**：
```typescript
interface EntityPermission {
  entityId: string
  canCreate: boolean
  canRead: boolean
  canUpdate: boolean
  canDelete: boolean
  canCustomize: boolean
}
```

**Field 级别**：
```typescript
interface FieldPermission {
  fieldId: string
  canRead: boolean
  canWrite: boolean
  canDelete: boolean
}
```

## 多租户数据隔离

### 租户隔离策略

```
┌─────────────────────────────────────────────────────────────┐
│                      应用层                                  │
├─────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. 租户上下文注入                                             │
│     - 从 Token 中提取 tenantId                                │
│     - 设置 ThreadLocal 上下文                                 │
│                                                                 │
│  2. 查询过滤                                                   │
│     - 自动添加 tenant_id 过滤条件                              │
│     - 防止跨租户数据访问                                       │
│                                                                 │
│  3. 写入验证                                                   │
│     - 验证写入操作的租户归属                                   │
│     - 防止数据写入错误的租户                                   │
│                                                                 │
└─────────────────────────────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                      数据层                                  │
├─────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. 表设计                                                     │
│     - 所有表包含 tenant_id 字段（除系统表）                    │
│     - 唯一索引包含 tenant_id                                  │
│                                                                 │
│  2. Row-Level Security (RLS)                                  │
│     - 数据库级别 RLS 策略                                     │
│     - 自动过滤 tenant_id                                      │
│                                                                 │
│  3. 连接池隔离（可选）                                        │
│     - 为不同租户使用不同连接池                                │
│     - 防止租户间资源竞争                                      │
│                                                                 │
└─────────────────────────────────────────────────────────────┘
```

### 租户上下文

```typescript
interface TenantContext {
  tenantId: string
  tenantType: 'PLATFORM' | 'STANDARD' | 'TRIAL'
  userId: string
  userRoles: Role[]
  permissions: Permission[]
  isolationLevel: 'STRICT' | 'MODERATE' | 'RELAXED'
}

class TenantContextManager {
  // 设置租户上下文
  setContext(context: TenantContext): void

  // 获取当前租户上下文
  getContext(): TenantContext

  // 清除租户上下文
  clearContext(): void

  // 在租户上下文中执行操作
  executeWithContext<T>(
    context: TenantContext,
    fn: () => Promise<T>
  ): Promise<T>
}
```

### 数据隔离实现

**查询过滤**：
```typescript
class TenantAwareRepository {
  async findByID(id: string): Promise<Entity> {
    const context = TenantContextManager.getContext()
    const result = await this.db.query(
      'SELECT * FROM metadata_entity WHERE id = ? AND tenant_id = ? AND yn = "N"',
      [id, context.tenantId]
    )
    return result
  }

  async findAll(filter: Filter): Promise<Entity[]> {
    const context = TenantContextManager.getContext()
    const query = this.buildQuery(filter)
    query.andWhere('tenant_id', context.tenantId)
    query.andWhere('yn', 'N')
    return this.db.execute(query)
  }
}
```

**数据库 RLS 策略**：
```sql
-- 创建 RLS 策略
CREATE POLICY tenant_isolation_policy ON metadata_entity
  USING (tenant_id = current_setting('app.current_tenant_id')::varchar)
  WITH CHECK (tenant_id = current_setting('app.current_tenant_id')::varchar);

-- 启用 RLS
ALTER TABLE metadata_entity ENABLE ROW LEVEL SECURITY;

-- 应用策略
ALTER TABLE metadata_entity DROP POLICY IF EXISTS tenant_isolation_policy;
CREATE POLICY tenant_isolation_policy ON metadata_entity
  FOR ALL
  USING (tenant_id = current_setting('app.current_tenant_id')::varchar);
```

## 审计日志

### 审计事件类型

```typescript
enum AuditEventType {
  // 认证事件
  AUTH_LOGIN = 'auth.login',
  AUTH_LOGOUT = 'auth.logout',
  AUTH_FAILED = 'auth.failed',

  // 授权事件
  AUTHZ_GRANTED = 'authz.granted',
  AUTHZ_REVOKED = 'authz.revoked',
  AUTHZ_CHECK_FAILED = 'authz.check_failed',

  // 元数据操作
  METADATA_CREATE = 'metadata.create',
  METADATA_UPDATE = 'metadata.update',
  METADATA_DELETE = 'metadata.delete',
  METADATA_READ = 'metadata.read',

  // 发布操作
  RELEASE_CREATE = 'release.create',
  RELEASE_APPROVE = 'release.approve',
  RELEASE_EXECUTE = 'release.execute',
  RELEASE_ROLLBACK = 'release.rollback',

  // 租户操作
  TENANT_CUSTOMIZE = 'tenant.customize',
  TENANT_PROMOTE = 'tenant.promote'
}
```

### 审计日志格式

```typescript
interface AuditLog {
  id: string
  eventType: AuditEventType
  timestamp: Date
  tenantId: string
  userId: string
  userAgent: string
  ipAddress: string
  requestId: string

  // 资源信息
  resourceType: string
  resourceId: string
  resourceName: string

  // 操作信息
  operation: string
  changes: Change[]
  result: 'SUCCESS' | 'FAILURE'
  errorMessage?: string

  // 额外信息
  metadata: Record<string, any>
}

interface Change {
  field: string
  oldValue: any
  newValue: any
  changeType: 'CREATED' | 'UPDATED' | 'DELETED'
}
```

### 审计日志存储

**表结构**：
```sql
CREATE TABLE `audit_log` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `event_type` VARCHAR(100) NOT NULL,
  `timestamp` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tenant_id` VARCHAR(100) NOT NULL,
  `user_id` BIGINT NOT NULL,
  `user_agent` VARCHAR(500),
  `ip_address` VARCHAR(45),
  `request_id` VARCHAR(100),
  `resource_type` VARCHAR(50),
  `resource_id` VARCHAR(100),
  `resource_name` VARCHAR(255),
  `operation` VARCHAR(50),
  `changes_json` JSON,
  `result` VARCHAR(20),
  `error_message` TEXT,
  `metadata_json` JSON,
  PRIMARY KEY (`id`),
  KEY `idx_audit_log_tenant` (`tenant_id`),
  KEY `idx_audit_log_user` (`user_id`),
  KEY `idx_audit_log_timestamp` (`timestamp`),
  KEY `idx_audit_log_resource` (`resource_type`, `resource_id`),
  KEY `idx_audit_log_event_type` (`event_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='审计日志表';
```

### 审计日志查询 API

```http
POST /audit-logs/search
```

**请求体**：
```json
{
  "filters": {
    "eventType": ["metadata.create", "metadata.update"],
    "tenantId": "tenant_123",
    "userId": "user_456",
    "resourceType": "ENTITY",
    "from": "2024-03-01T00:00:00Z",
    "to": "2024-03-15T23:59:59Z"
  },
  "pagination": {
    "page": 1,
    "pageSize": 50
  },
  "sort": {
    "field": "timestamp",
    "order": "desc"
  }
}
```

## 安全最佳实践

### 输入验证

1. **类型验证**：验证输入数据类型
2. **长度限制**：限制字符串长度
3. **格式验证**：验证日期、邮箱等格式
4. **SQL 注入防护**：使用参数化查询
5. **XSS 防护**：转义输出内容

### 敏感数据处理

1. **加密存储**：敏感字段加密存储
2. **脱敏输出**：日志和响应中脱敏敏感信息
3. **传输加密**：使用 HTTPS/TLS
4. **密钥管理**：使用密钥管理服务（KMS）

### 权限最小化

1. **默认拒绝**：默认拒绝所有访问
2. **最小权限**：授予最小必要权限
3. **临时权限**：支持临时权限提升
4. **定期审查**：定期审查和清理权限

### 安全监控

1. **异常检测**：检测异常访问模式
2. **告警机制**：及时告警安全事件
3. **日志分析**：分析日志发现安全问题
4. **渗透测试**：定期进行安全测试

## 相关文档

- 存储层架构：[../01.storage/](../01.storage/)
- 服务层架构：[../02.services/](../02.services/)
- API 层架构：[../03.api/](../03.api/)
- 运维架构：[../05.operations/](../05.operations/)
