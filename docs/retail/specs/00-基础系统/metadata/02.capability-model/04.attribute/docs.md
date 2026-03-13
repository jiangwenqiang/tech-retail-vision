---
title: Capability Model - Attribute
taxonomy:
    category: docs
---

# Attribute

属性（Attribute）用于在不改变核心结构的前提下，为实体或字段附加扩展能力。

## 核心能力

1. 扩展键值：`key/value` 形式配置
2. 作用域控制：可挂在 `entity` 或 `field`
3. 生效条件：按环境、版本、租户差异化生效
4. 可追溯性：支持版本与审计记录

## 适用场景

1. UI 额外提示
2. 规则参数注入
3. 低频个性化扩展
