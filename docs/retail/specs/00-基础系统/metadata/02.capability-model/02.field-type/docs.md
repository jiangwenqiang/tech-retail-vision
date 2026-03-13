---
title: Capability Model - Field Type
taxonomy:
    category: docs
---

# Field Type

字段类型（Field Type）定义字段的基础数据语义与校验规则模板。

## 核心能力

1. 基础类型：`string`、`number`、`boolean`、`date`、`json`
2. 约束模板：长度、范围、正则、枚举
3. 渲染提示：默认控件类型、格式化规则
4. 扩展机制：允许项目注册自定义类型

## 建议实践

1. 类型定义与业务字段解耦
2. 类型升级通过版本化发布
3. 新增类型需配套迁移与回滚策略
