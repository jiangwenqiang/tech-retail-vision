---
title: 元数据存储层架构 - 数据库表结构
taxonomy:
    category: docs
---

# 元数据存储层架构 - 数据库表结构

## 概述

本页采用“最小列 + JSON 属性”模式：
- 列字段用于定位、约束、过滤
- 业务属性尽量收敛到 JSON
- DDL 使用 MySQL 8 语法（`CREATE TABLE IF NOT EXISTS`、`DATETIME(3)`、`utf8mb4_0900_ai_ci`）

## 表结构

### metadata_entity

- 列：`code, name, scope, status, customizable, props_json, version, yn`
- 索引：`(scope, status, yn)`

### metadata_field

- 列：`entity_code, code, name, scope, status, customizable, props_json, yn`
- 索引：`(entity_code, status, yn)`

### metadata_link

- 列：`entity_code, code, name, status, props_json, yn`
- 索引：`(entity_code, status, yn)`

### metadata_index

- 列：`entity_code, code, status, props_json, yn`
- 索引：`(entity_code, status, yn)`

### metadata_attribute

- 列：`entity_code, code, name, scope, status, customizable, props_json, yn`
- 索引：`(entity_code, status, yn)`

### metadata_client

- 列：`entity_code, scope(PLATFORM), customizable, props_json, yn`
- 索引：`(entity_code, scope, yn)`

### metadata_layout_profile

- 列：`code, name, scope, tenant_id, owner, status, customizable, props_json, yn`
- 索引：`(scope, owner, status, yn)`
- 约束：业务唯一（如 `(scope, owner, code)`）由服务层保证

### metadata_layout

- 列：`entity_code, profile_id, type, customizable, props_json, yn`
- 索引：`(entity_code, profile_id, type, yn)`

### metadata_customization

- 列：`tenant_id, entity_code, target_type, target_code, props_json, yn`（`props_json` 对应规格 `properties`）
- 索引：`(tenant_id, entity_code, target_type, target_code, yn)`

### metadata_client_customization

- 列：`tenant_id, entity_code, props_json, yn`（`props_json` 对应规格 `properties`）
- 索引：`(tenant_id, entity_code, yn)`

## 约束说明

1. 不使用数据库 `UNIQUE KEY` 约束。
2. 业务去重与冲突控制由服务层在事务内完成。

## 运行时规则（不变）

1. `status` 控制生效，`customizable` 控制是否允许覆盖/派生
2. Layout 按 `USER -> TENANT -> PLATFORM` 逐层：先 profile，再 layout
3. 三层均无可用 layout 返回空布局

## DDL

见 [ddl.sql](./ddl.sql)
