---
title: 元数据存储层架构
taxonomy:
    category: docs
---

# 元数据存储层架构

## 设计策略（简化版）

1. 每张表仅显式列化少量基础字段（优先 `name`、`status`）与定位约束字段；其余放入 `props_json`
2. 业务可扩展属性统一放入 JSON 列（统一命名为 `props_json`）
3. 保留 `yn` 与审计列，便于软删除与追踪

## 表清单

1. `metadata_entity`
2. `metadata_field`
3. `metadata_link`
4. `metadata_index`
5. `metadata_attribute`
6. `metadata_client`
7. `metadata_layout_profile`
8. `metadata_layout`
9. `metadata_customization`
10. `metadata_client_customization`

## 去重策略

1. 不在数据库层声明 `UNIQUE KEY`（支持多次作废/历史残留）
2. 业务唯一由服务层校验与事务控制保证
3. 数据库仅保留普通索引用于查询性能

## JSON 承载建议

- `metadata_entity.props_json`: 非 `name/status` 的业务属性（如 `namePlural,type,iconClass,color,...`）
- `metadata_field.props_json`: 非 `name/status` 的字段属性（如 `type,required,readOnly,defaultValue,params,sortOrder,...`）
- `metadata_link.props_json`: 非 `name/status` 的关系属性（如 `type,foreignEntity,foreign,required,...`）
- `metadata_index.props_json`: 非 `status` 的索引属性（如 `fields,unique,...`）
- `metadata_attribute.props_json`: 非 `name/status` 的属性字段（如 `type,required,isMultilang,parentId,sortOrder,...`）
- `metadata_client.props_json`: 客户端配置（`controller,views,recordViews,relationshipPanels,...`）
- `metadata_layout_profile.props_json`: 非 `name/status` 的 profile 属性
- `metadata_layout.props_json`: 布局定义完整配置

## 相关文档

- [数据库表结构与 DDL](./database-schema.md)
