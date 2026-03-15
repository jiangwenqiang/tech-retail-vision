---
title: 元数据存储层架构
taxonomy:
    category: docs
---

# 元数据存储层架构

## 概述

存储层架构定义元数据管理系统的数据存储结构和访问方式，包括数据库表设计、索引策略和数据流转。

## 子域目录

1. [数据库表结构与 DDL](./database-schema.md)
   - 完整的 DDL 定义
   - 表结构说明
   - 索引设计
   - 字段类型与 JSON 字段结构
   - 数据完整性约束
   - 性能优化建议
   - 迁移策略

## 核心表

- `metadata_entity` - 实体元数据表
- `metadata_field` - 字段元数据表
- `metadata_attribute` - 属性元数据表
- `metadata_client` - 客户端配置元数据表
- `metadata_version` - 版本审计表

## 设计原则

1. **统一前缀**：所有表名以 `metadata_` 开头
2. **主键规范**：统一使用 `id BIGINT AUTO_INCREMENT`
3. **软删除**：使用 `yn CHAR(1)` 字段（N=有效，Y=删除）
4. **审计字段**：`created_at/created_by_id/modified_at/modified_by_id`
5. **版本控制**：`version INT` 字段记录当前版本
6. **扩展性**：使用 JSON 字段承载可扩展参数

## 相关文档

- 业务规格：[../../../00.specs/00.foundation/02.metadata/04.runtime-storage/](../../../00.specs/00.foundation/02.metadata/04.runtime-storage/)
- 服务层架构：[../02.services/](../02.services/)
- 安全架构：[../04.security/](../04.security/)
