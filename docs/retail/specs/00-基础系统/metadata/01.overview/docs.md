---
title: Overview and Scope
taxonomy:
    category: docs
---

# 总览与设计边界

## 目标

1. 元数据统一持久化到 MySQL
2. 表前缀统一为 `metadata_`
3. 主键统一 `BIGINT`
4. 软删除统一 `yn`（`N=有效`, `Y=删除`）
5. 支持版本审计、发布、回滚

## 边界

1. 本设计覆盖：`entity`、`field`、`attribute`、`client`、`version`
2. 分组按显示场景统一归属 `metadata_client`
3. 属性值维护在 `*_attribute_value` 体系
4. 本目录仅描述元数据域，不包含配置域

## 核心结论

1. `field` 与 `attribute` 都可扩展，但不等价
2. `composite` 是属性树结构，不是普通值字段
3. 页面渲染中，父复合属性会承载子属性显示容器
4. 配置能力单独拆分到 `docs/98.config`
