---
title: Composite Attribute
taxonomy:
    category: docs
---

# 复合属性（Composite）能力

## 定义

复合属性用于构建属性树：父属性为容器，子属性承载业务值。

## 建模规则

1. 子属性通过 `composite_attribute_id` 指向父属性
2. 父属性必须是 `composite` 类型
3. 父子必须属于同一实体
4. 禁止自引用与循环引用

## 页面渲染行为

1. 父复合属性作为容器渲染
2. 子属性由父容器自动渲染
3. 子属性在外层列表中不重复渲染

## 示例

“尺码规格”场景：

1. 父属性：`size_spec`（`type=composite`）
2. 子属性：`chest`、`waist`、`length`
3. 页面上显示为“尺码规格”容器下的子项输入区
