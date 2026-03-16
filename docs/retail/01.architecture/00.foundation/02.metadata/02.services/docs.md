---
title: 元数据服务层架构（DDD）
taxonomy:
    category: docs
---

# 元数据服务层架构（DDD）

## 设计目标

服务层采用 DDD，将“模型规则”与“技术实现”解耦，确保：
1. 领域规则集中在聚合与领域服务
2. 应用服务负责用例编排，不承载领域判断
3. 仓储只负责持久化（当前映射到 MySQL 8 + `props_json`）

## 限界上下文（Bounded Context）

1. `MetadataDefinitionContext`
- 管理 Entity/Field/Link/Index/Attribute/Client/LayoutProfile/Layout 基线定义

2. `MetadataCustomizationContext`
- 管理 Metadata Customization / Client Customization

3. `MetadataRuntimeContext`
- 生成运行时元数据视图（`USER -> TENANT -> PLATFORM`）

## 聚合与聚合根

1. `MetadataEntityDefinition`（聚合根）
- 内含：Field、Link、Index、Attribute
- 不变量：`entityCode` 强归属、跨实体引用禁止

2. `MetadataLayoutProfile`（聚合根）
- 内含：Layout 条目集合（按 `entityCode + type`）
- 不变量：scope/owner 归属合法、双闸门规则

3. `MetadataClientDefinition`（聚合根）
- 内含：client 配置与租户覆盖映射

## 服务分层

1. 应用服务（Application Service）
- `MetadataDefinitionAppService`
- `MetadataCustomizationAppService`
- `MetadataRuntimeQueryService`

2. 领域服务（Domain Service）
- `MetadataUniquenessPolicy`（服务层去重，不依赖 DB UNIQUE）
- `MetadataLayoutResolutionPolicy`（逐层 profile/layout 命中）
- `MetadataCustomizationPolicy`（`status/customizable` 规则）
- `MetadataFieldTypeContractPolicy`（`Field.type` 白名单与 `params` 参数契约）
- `MetadataAttributeStructurePolicy`（`Attribute.type=composite` 结构约束与父子归属校验）

3. 仓储（Repository）
- `MetadataEntityRepository` / `MetadataFieldRepository` / `MetadataLayoutProfileRepository` / ...

## 事务边界

1. 单聚合修改：一个事务
2. 跨聚合用例：应用服务事务编排
3. 去重冲突：在事务内锁定业务键并校验

## 代码分层落地（Java package）

```text
com.retail.metadata
├─ interfaces
│  └─ rest
├─ application
│  ├─ command
│  ├─ query
│  ├─ result
│  ├─ service
│  └─ handler
├─ domain
│  ├─ model
│  ├─ service
│  ├─ repository
│  └─ event
└─ infrastructure
   ├─ persistence
   │  ├─ po
   │  ├─ mapper
   │  └─ repository
   └─ cache
```

## 命名约定（避免 DTO 污染应用层）

1. `interfaces.rest`：`*Request` / `*Response`
2. `application`：`*Command` / `*Query` / `*Result`
3. `domain`：聚合和值对象（不带 DTO 后缀）
4. `infrastructure.persistence`：`*Po`（持久化对象）

## 相关文档

- [元数据核心服务（DDD）](./metadata-service.md)
- [存储层架构](../01.storage/)
- [API 层架构（DDD）](../03.api/)
