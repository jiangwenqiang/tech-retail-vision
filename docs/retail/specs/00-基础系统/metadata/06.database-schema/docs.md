---
title: Database Schema and DDL
taxonomy:
    category: docs
---

# 数据库表结构与DDL

## 最终表清单（推荐）

1. `metadata_entity`
2. `metadata_field`
3. `metadata_attribute`
4. `metadata_client`
5. `metadata_version`

## 可选扩展表

1. `metadata_group`（仅当需要业务语义分组时启用）

## 统一规范

1. 主键：`id BIGINT AUTO_INCREMENT`
2. 软删除：`yn CHAR(1) DEFAULT 'N'`
3. 审计字段：`created_at/created_by_id/modified_at/modified_by_id`
4. 唯一索引需带 `yn`
5. JSON 字段承载可扩展参数

## 分组归属说明

显示分组能力归属 `metadata_client.client_json`。如果仅做页面分组，可不启用 `metadata_group`。

## 配置域说明

配置模型不在本目录定义，独立见：`docs/98.config`。

## DDL

> 为避免重复，DDL 以一份为准，见本目录维护文件：
> `docs/99.metadata/06.database-schema/ddl.sql`
