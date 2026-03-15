---
title: 元数据服务层架构
taxonomy:
    category: docs
---

# 元数据服务层架构

## 概述

元数据服务层提供元数据管理的核心业务逻辑，对外暴露统一的服务接口。本文档定义服务层的架构设计、接口定义和实现规范。

对应业务规格：[00.specs/00.foundation/02.metadata/05.governance/](../../../00.specs/00.foundation/02.metadata/05.governance/)

## 服务层架构

```
┌─────────────────────────────────────────────────────────────┐
│                        API Gateway                           │
├─────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐        │
│  │ REST API     │  │ GraphQL API  │  │ Webhooks     │        │
│  └──────────────┘  └──────────────┘  └──────────────┘        │
│                                                                  │
├─────────────────────────────────────────────────────────────┤
│                        Service Layer                          │
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐        │
│  │ Metadata     │  │ Validation   │  │ Governance   │        │
│  │ Service      │  │ Service      │  │ Service      │        │
│  └──────────────┘  └──────────────┘  └──────────────┘        │
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐        │
│  │ Version      │  │ Cache        │  │ Event        │        │
│  │ Service      │  │ Service      │  │ Service      │        │
│  └──────────────┘  └──────────────┘  └──────────────┘        │
│                                                                  │
├─────────────────────────────────────────────────────────────┤
│                        Repository Layer                       │
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐        │
│  │ Entity       │  │ Field        │  │ Attribute    │        │
│  │ Repository   │  │ Repository   │  │ Repository   │        │
│  └──────────────┘  └──────────────┘  └──────────────┘        │
│                                                                  │
└─────────────────────────────────────────────────────────────┘
```

## 核心服务定义

### 1. MetadataService - 元数据核心服务

提供元数据的 CRUD 操作和生命周期管理。

#### 接口定义

```typescript
interface MetadataService {
  // Entity 管理
  createEntity(data: EntityCreateInput): Promise<Entity>
  updateEntity(id: string, data: EntityUpdateInput): Promise<Entity>
  deleteEntity(id: string): Promise<void>
  getEntity(id: string): Promise<Entity>
  listEntities(filter: EntityFilter): Promise<Entity[]>

  // Field 管理
  createField(entityId: string, data: FieldCreateInput): Promise<Field>
  updateField(id: string, data: FieldUpdateInput): Promise<Field>
  deleteField(id: string): Promise<void>
  getFieldsByEntity(entityId: string): Promise<Field[]>

  // Attribute 管理
  createAttribute(entityId: string, data: AttributeCreateInput): Promise<Attribute>
  updateAttribute(id: string, data: AttributeUpdateInput): Promise<Attribute>
  deleteAttribute(id: string): Promise<void>
  getAttributesByEntity(entityId: string): Promise<Attribute[]>

  // Client 配置管理
  updateClientConfig(scope: ClientScope, config: ClientConfig): Promise<void>
  getClientConfig(scope: ClientScope): Promise<ClientConfig>
}
```

#### 实现要点

1. **事务管理**：跨实体的操作使用数据库事务
2. **版本控制**：每次修改自动创建版本快照
3. **缓存策略**：元数据读取使用多级缓存
4. **权限检查**：操作前验证用户权限

### 2. ValidationService - 验证服务

提供元数据契约验证和兼容性检查。

#### 接口定义

```typescript
interface ValidationService {
  // 契约验证
  validateFieldType(fieldType: string, params: Record<string, any>): ValidationResult
  validateFieldConstraints(field: Field): ValidationResult
  validateRelations(entity: Entity): ValidationResult

  // 兼容性验证
  validateCompatibility(
    changes: MetadataChange[],
    baselineVersion: string
  ): CompatibilityResult

  // 冲突检测
  detectConflicts(
    tenantChanges: MetadataChange[],
    baselineChanges: MetadataChange[]
  ): Conflict[]
}
```

#### 验证规则

**字段类型契约验证**：
1. 检查参数是否在字段类型的参数白名单中
2. 验证参数值类型和范围
3. 验证条件表达式语法

**关系验证**：
1. 验证外键实体存在性
2. 检查循环依赖
3. 验证关系类型兼容性

**兼容性验证**：
1. 检查删除字段是否被引用
2. 验证字段类型变更影响
3. 检查约束变更兼容性

### 3. GovernanceService - 治理服务

提供元数据生命周期治理功能。

#### 接口定义

```typescript
interface GovernanceService {
  // 版本管理
  createVersion(objectType: string, objectId: string): Promise<Version>
  getVersionHistory(objectType: string, objectId: string): Promise<Version[]>
  rollbackToVersion(objectType: string, objectId: string, version: number): Promise<void>

  // 发布管理
  requestRelease(changeIds: string[]): Promise<ReleaseRequest>
  approveRelease(requestId: string, decision: ApprovalDecision): Promise<void>
  executeRelease(releaseId: string): Promise<ReleaseResult>
  rollbackRelease(releaseId: string): Promise<void>

  // 提升管理
  requestPromotion(tenantId: string, changeIds: string[]): Promise<PromotionRequest>
  evaluatePromotion(requestId: string): Promise<PromotionEvaluation>
  integrateToBaseline(requestId: string, integration: PromotionIntegration): Promise<void>
}
```

#### 发布流程

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ 创建发布请求 │ -> │ 审批流程    │ -> │ 灰度发布    │
└─────────────┘    └─────────────┘    └─────────────┘
       │                  │                  │
       ▼                  ▼                  ▼
  变更清单           技术审核           小范围验证
  影响评估           业务审核           监控指标
  版本快照           决策记录           问题检测
                           │
                           ▼
                    ┌─────────────┐
                    │ 全量发布    │
                    └─────────────┘
                           │
                           ▼
                    发布公告
                    文档更新
                    版本标记
```

### 4. VersionService - 版本服务

提供版本管理和快照功能。

#### 接口定义

```typescript
interface VersionService {
  // 快照管理
  createSnapshot(objectType: string, objectId: string): Promise<Snapshot>
  getSnapshot(objectType: string, objectId: string, version: number): Promise<Snapshot>
  compareSnapshots(
    objectType: string,
    objectId: string,
    version1: number,
    version2: number
  ): Promise<DiffResult>

  // 版本操作
  incrementVersion(objectType: string, objectId: string): Promise<number>
  getVersion(objectType: string, objectId: string): Promise<number>
  listVersions(objectType: string, objectId: string): Promise<VersionInfo[]>
}
```

#### 快照存储策略

**JSON 快照格式**：
```json
{
  "objectType": "ENTITY",
  "objectId": "123",
  "version": 5,
  "operation": "UPDATE",
  "timestamp": "2024-03-15T10:30:00Z",
  "data": {
    "id": "123",
    "code": "Product",
    "name": "产品",
    "type": "Base",
    "fields": [...]
  },
  "changedFields": ["name", "description"],
  "comment": "更新产品实体名称"
}
```

### 5. CacheService - 缓存服务

提供元数据缓存管理。

#### 缓存策略

**多级缓存架构**：
```
┌─────────────────────────────────────────────┐
│              Application Cache              │
│  (Local Memory - L1)                        │
│  - Hot metadata (frequently accessed)       │
│  - TTL: 5 minutes                           │
└─────────────────────────────────────────────┘
                    │ Miss
                    ▼
┌─────────────────────────────────────────────┐
│              Distributed Cache              │
│  (Redis - L2)                               │
│  - All metadata                             │
│  - TTL: 1 hour                              │
└─────────────────────────────────────────────┘
                    │ Miss
                    ▼
┌─────────────────────────────────────────────┐
│              Database                       │
│  (MySQL)                                    │
│  - Persistent storage                       │
└─────────────────────────────────────────────┘
```

#### 接口定义

```typescript
interface CacheService {
  // 缓存操作
  get(key: string): Promise<any>
  set(key: string, value: any, ttl?: number): Promise<void>
  invalidate(pattern: string): Promise<void>
  warmup(): Promise<void>

  // 缓存统计
  getStats(): CacheStats
  clear(): Promise<void>
}
```

#### 缓存失效策略

1. **主动失效**：元数据变更时主动清理相关缓存
2. **定时失效**：使用 TTL 自动过期
3. **版本检查**：缓存中包含版本号，不匹配时重新加载

### 6. EventService - 事件服务

提供元数据变更事件的发布和订阅。

#### 事件类型

```typescript
enum MetadataEventType {
  ENTITY_CREATED = 'entity.created',
  ENTITY_UPDATED = 'entity.updated',
  ENTITY_DELETED = 'entity.deleted',
  FIELD_CREATED = 'field.created',
  FIELD_UPDATED = 'field.updated',
  FIELD_DELETED = 'field.deleted',
  RELEASE_PUBLISHED = 'release.published',
  RELEASE_ROLLED_BACK = 'release.rolled_back',
  PROMOTION_REQUESTED = 'promotion.requested'
}
```

#### 接口定义

```typescript
interface EventService {
  // 事件发布
  publish(event: MetadataEvent): Promise<void>

  // 事件订阅
  subscribe(eventType: MetadataEventType, handler: EventHandler): void
  unsubscribe(subscriptionId: string): void

  // 事件查询
  getEvents(filter: EventFilter): Promise<MetadataEvent[]>
}
```

## 服务间协作

### 创建实体流程

```
┌─────────────┐
│ API Gateway │
└──────┬──────┘
       │
       ▼
┌───────────────────────────────────────────┐
│         MetadataService                   │
│                                           │
│  1. 验证输入                              │
│  2. 调用 ValidationService 验证契约       │
│  3. 调用 VersionService 创建快照         │
│  4. 持久化到数据库                        │
│  5. 调用 CacheService 更新缓存           │
│  6. 调用 EventService 发布事件           │
└───────────────────────────────────────────┘
       │
       ▼
┌─────────────┐
│   Response  │
└─────────────┘
```

### 发布流程

```
┌─────────────┐
│ API Gateway │
└──────┬──────┘
       │
       ▼
┌───────────────────────────────────────────┐
│         GovernanceService                 │
│                                           │
│  1. 创建发布请求                          │
│  2. 调用 ValidationService 验证兼容性     │
│  3. 触发审批流程                          │
│  4. 审批通过后创建版本                    │
│  5. 灰度发布到测试租户                    │
│  6. 监控指标验证                          │
│  7. 全量发布                              │
│  8. 调用 EventService 发布事件           │
└───────────────────────────────────────────┘
       │
       ▼
┌─────────────┐
│   Response  │
└─────────────┘
```

## 错误处理

### 错误类型

```typescript
enum MetadataErrorType {
  VALIDATION_ERROR = 'VALIDATION_ERROR',
  COMPATIBILITY_ERROR = 'COMPATIBILITY_ERROR',
  CONFLICT_ERROR = 'CONFLICT_ERROR',
  VERSION_ERROR = 'VERSION_ERROR',
  PERMISSION_ERROR = 'PERMISSION_ERROR',
  NOT_FOUND_ERROR = 'NOT_FOUND_ERROR'
}

interface MetadataError {
  type: MetadataErrorType
  code: string
  message: string
  details: any
  timestamp: Date
}
```

### 错误处理策略

1. **验证错误**：返回详细错误信息，指导用户修正
2. **兼容性错误**：提供兼容性报告和解决方案
3. **冲突错误**：返回冲突详情和建议的解决策略
4. **版本错误**：提示版本冲突并提供回滚选项
5. **权限错误**：明确所需权限和操作限制

## 性能优化

### 批量操作

```typescript
interface MetadataService {
  // 批量创建
  batchCreateEntities(items: EntityCreateInput[]): Promise<Entity[]>
  batchCreateFields(entityId: string, items: FieldCreateInput[]): Promise<Field[]>

  // 批量更新
  batchUpdateEntities(updates: EntityUpdateInput[]): Promise<Entity[]>

  // 批量删除
  batchDeleteEntities(ids: string[]): Promise<void>
}
```

### 查询优化

1. **预加载**：使用 JOIN 减少查询次数
2. **分页**：大量数据使用游标分页
3. **索引提示**：优化器提示使用正确索引
4. **查询缓存**：复杂查询结果缓存

## 监控与日志

### 服务指标

```typescript
interface ServiceMetrics {
  // 性能指标
  requestCount: number
  averageResponseTime: number
  p95ResponseTime: number
  p99ResponseTime: number

  // 错误指标
  errorCount: number
  errorRate: number
  errorsByType: Record<string, number>

  // 业务指标
  entityCount: number
  fieldCount: number
  activeReleases: number
}
```

### 日志规范

**日志级别**：
- ERROR：错误导致操作失败
- WARN：警告但操作可继续
- INFO：关键操作信息
- DEBUG：详细调试信息

**日志格式**：
```json
{
  "timestamp": "2024-03-15T10:30:00Z",
  "level": "INFO",
  "service": "MetadataService",
  "operation": "createEntity",
  "userId": "user123",
  "tenantId": "tenant456",
  "entityId": "entity789",
  "duration": 125,
  "status": "success"
}
```

## 相关文档

- 存储层架构：[../01.storage/](../01.storage/)
- API 层架构：[../03.api/](../03.api/)
- 安全架构：[../04.security/](../04.security/)
- 运维架构：[../05.operations/](../05.operations/)
