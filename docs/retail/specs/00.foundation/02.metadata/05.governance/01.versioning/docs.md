---
title: 生命周期与治理 - 版本审计与发布回滚
taxonomy:
    category: docs
---

# 版本审计与发布回滚

## 版本对象范围

1. 实体（ENTITY）
2. 分组（GROUP）
3. 字段（FIELD）
4. 属性（ATTRIBUTE）
5. 客户端配置（CLIENT）

## 版本记录结构

- 表：`metadata_version`
- 主键：`id`
- 唯一性：`object_type + object_id + version`
- 快照：`snapshot_json`

## 建议流程

1. 变更前读取当前对象，生成 `version + 1`
2. 落快照到 `metadata_version`
3. 更新主表对象
4. 发布时记录 `operation=PUBLISH`
5. 回滚时按历史快照回放并记录 `operation=ROLLBACK`

## 最小审计要求

1. 记录操作者 `created_by_id`
2. 记录变更说明 `comment`
3. 记录变更时间 `created_at`
