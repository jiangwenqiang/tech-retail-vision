---
title: 元数据核心服务（DDD）
taxonomy:
    category: docs
---

# 元数据核心服务（DDD）

## 一、应用服务接口（Java）

```java
public interface MetadataDefinitionAppService {
    CreateEntityResult createEntity(CreateEntityCommand cmd);
    UpdateEntityResult updateEntity(UpdateEntityCommand cmd);

    CreateFieldResult createField(CreateFieldCommand cmd);
    UpdateFieldResult updateField(UpdateFieldCommand cmd);

    CreateAttributeResult createAttribute(CreateAttributeCommand cmd);
    UpdateAttributeResult updateAttribute(UpdateAttributeCommand cmd);

    UpsertClientResult upsertClient(UpsertClientCommand cmd);

    CreateLayoutProfileResult createLayoutProfile(CreateLayoutProfileCommand cmd);
    UpdateLayoutProfileResult updateLayoutProfile(UpdateLayoutProfileCommand cmd);
    UpsertLayoutResult upsertLayout(UpsertLayoutCommand cmd);
}

public interface MetadataCustomizationAppService {
    void upsertMetadataCustomization(UpsertMetadataCustomizationCommand cmd);
    void upsertClientCustomization(UpsertClientCustomizationCommand cmd);
}

public interface MetadataRuntimeQueryService {
    RuntimeMetadataView resolve(RuntimeMetadataQuery query);
}
```

## 二、领域模型职责

1. `MetadataEntityDefinition` 聚合
- 校验 `entityCode` 归属一致
- 维护 Field/Link/Index/Attribute 约束

2. `MetadataLayoutProfile` 聚合
- 校验 `scope/owner/tenantId` 关系
- 维护 `customizable` 派生闸门

3. `MetadataLayoutResolutionPolicy`（领域服务）
- 规则：`USER -> TENANT -> PLATFORM`
- 每层先 profile（显式 `profile.code` 优先，否则 ACTIVE）
- 再 layout（`entityCode + profileId + type`）

4. `MetadataUniquenessPolicy`（领域服务）
- 在事务内基于业务键执行冲突判断
- 存储层无 UNIQUE KEY，冲突由领域抛出

5. `MetadataFieldTypeContractPolicy`（领域服务）
- 校验 `Field.type` 必须命中字段类型白名单
- 校验 `Field.params` 必须符合对应类型参数白名单与参数类型/范围

6. `MetadataAttributeStructurePolicy`（领域服务）
- 校验 `Attribute.type=composite` 仅用于父属性占位
- 校验 `composite` 必须至少存在一个子属性
- 校验子属性类型必须满足字段类型契约，且父子必须同 `entityCode`

## 三、仓储接口（示意）

```java
public interface MetadataEntityRepository {
    Optional<EntityPo> findActiveByCode(String code);
    void save(EntityPo po);
}

public interface MetadataLayoutProfileRepository {
    Optional<LayoutProfilePo> findProfile(String scope, String owner, String code);
    Optional<LayoutProfilePo> findActiveProfile(String scope, String owner);
}

public interface MetadataCustomizationRepository {
    void lockByBusinessKey(String tenantId, String entityCode, String targetType, String targetCode);
    void save(CustomizationPo po);
}
```

## 四、端到端调用链（示意）

```text
REST Controller
  -> Assembler(Request -> Command)
  -> Application Service
  -> Domain Aggregate / Domain Service
  -> Repository(interface)
  -> RepositoryImpl(MySQL)
  -> Assembler(Result -> Response)
```

## 五、持久化映射

1. 基础字段落独立列（如 `name/status/scope/customizable`）
2. 扩展属性落 `props_json`
3. API `properties` -> 领域对象 -> 持久化 `props_json`

## 六、异常与错误语义

- `MetadataEntityNotActiveException`
- `MetadataBusinessConflictException`
- `MetadataCustomizationNotAllowedException`
- `MetadataCrossEntityReferenceException`
- `MetadataProfileNotFoundException`
