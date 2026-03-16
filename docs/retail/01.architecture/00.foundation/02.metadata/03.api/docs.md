---
title: 元数据 API 层架构（DDD）
taxonomy:
    category: docs
---

# 元数据 API 层架构（DDD）

## 设计原则

1. API 是应用层端口（Application Layer Port）
2. 写操作使用 Command Model，读操作使用 Query Model
3. API DTO 与领域对象解耦（Assembler/Mapper 转换）

## 接口分组

1. Definition Commands
- 创建/修改 Entity、Field、Attribute、Client、LayoutProfile、Layout

2. Customization Commands
- Metadata/Client 覆盖命令

3. Runtime Queries
- 运行时元数据读取（不产生副作用）

## 约束

1. 外部定位统一使用 code（如 `entityCode`, `profile.code`）
2. `Layout` 资源定位必须使用 `entityCode + scope + owner + profile.code + type` 组合键（避免跨层同名 profile 冲突）
3. 冲突返回 `409`（源于领域 `MetadataBusinessConflictException`）
4. 扩展属性经应用层映射到存储 `props_json`

## Adapter 落地

1. Controller 只处理协议细节（HTTP、Header、参数校验）
2. Assembler 负责：
- `Request -> Command/Query`
- `Result/View -> Response`
3. 不在 Controller 写领域规则，不直接操作 Repository

## 相关文档

- [REST API（DDD）](./rest-api.md)
- [服务层架构（DDD）](../02.services/)
