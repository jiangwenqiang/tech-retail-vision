---
title: 元数据 REST API（DDD）
taxonomy:
    category: docs
---

# 元数据 REST API（DDD）

## 一、分层映射

1. `Controller`：接收 HTTP、参数校验
2. `Application Service`：执行 Command/Query
3. `Assembler`：DTO <-> Command/Query
4. `Repository`：持久化（`props_json`）

## 一点五、目录建议（接口层）

```text
interfaces/rest
├─ command
│  ├─ MetadataCommandController
│  └─ request/*
├─ query
│  ├─ MetadataQueryController
│  └─ response/*
└─ assembler/*
```

## 二、Java 风格示例

```java
@RestController
@RequestMapping("/metadata/v1")
@RequiredArgsConstructor
public class MetadataCommandController {

    private final MetadataDefinitionAppService metadataDefinitionAppService;

    @PostMapping("/entities")
    public EntityResponse createEntity(@Valid @RequestBody CreateEntityRequest req) {
        CreateEntityCommand cmd = MetadataEntityAssembler.toCommand(req);
        CreateEntityResult result = metadataDefinitionAppService.createEntity(cmd);
        return MetadataEntityAssembler.toResponse(result);
    }

    @PutMapping("/customizations/metadata/{tenantId}/{entityCode}/{targetType}/{targetCode}")
    public void upsertCustomization(
            @PathVariable Long tenantId,
            @PathVariable String entityCode,
            @PathVariable String targetType,
            @PathVariable String targetCode,
            @Valid @RequestBody UpsertCustomizationRequest req) {
        // req.properties -> command -> props_json
    }
}
```

## 三、资源与语义

说明：`LayoutProfile.code` 仅在 `scope+owner` 内唯一，不是全局唯一。任何 `Layout` 读写接口都必须携带 `scope+owner+profileCode` 组合键。

### Command API（写）

- `POST /entities`
- `PUT /entities/{entityCode}`
- `POST /entities/{entityCode}/fields`
- `PUT /entities/{entityCode}/fields/{code}`
- `POST /entities/{entityCode}/attributes`
- `PUT /entities/{entityCode}/attributes/{code}`
- `PUT /entities/{entityCode}/client`
- `POST /layout-profiles`
- `PUT /layout-profiles/{scope}/{owner}/{code}`
- `PUT /layouts/{entityCode}/{scope}/{owner}/{profileCode}/{type}`
- `PUT /customizations/metadata/{tenantId}/{entityCode}/{targetType}/{targetCode}`
- `PUT /customizations/client/{tenantId}/{entityCode}`

### Query API（读）

- `GET /entities/{entityCode}`
- `GET /entities/{entityCode}/fields`
- `GET /entities/{entityCode}/attributes`
- `GET /entities/{entityCode}/client`
- `GET /layout-profiles/{scope}/{owner}/{code}`
- `GET /layouts/{entityCode}/{scope}/{owner}/{profileCode}/{type}`
- `GET /runtime/metadata/{entityCode}?tenantId=...&userId=...&userProfileCode=...&tenantProfileCode=...&platformProfileCode=...`

## 三点五、对象命名约定

1. Controller 层：`*Request` / `*Response`
2. Application 层：`*Command` / `*Query` / `*Result`
3. Domain 层：聚合/值对象（不出现 DTO 命名）

## 四、运行时查询规则

`/runtime/metadata` 对每个 layout type：
1. `USER -> TENANT -> PLATFORM`
2. 每层先解析 profile（该层显式 `profile.code` 优先，否则 ACTIVE）
3. 再查 `layout(entityCode + profileId + type)`
4. 三层无命中返回空布局

## 五、错误映射

```java
@RestControllerAdvice
public class ApiExceptionHandler {

    @ExceptionHandler(MetadataBusinessConflictException.class)
    @ResponseStatus(HttpStatus.CONFLICT)
    public ErrorResponse handleConflict(MetadataBusinessConflictException ex) {
        return ErrorResponse.of("CONFLICT", ex.getMessage());
    }

    @ExceptionHandler(IllegalArgumentException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ErrorResponse handleBadRequest(IllegalArgumentException ex) {
        return ErrorResponse.of("VALIDATION_ERROR", ex.getMessage());
    }
}
```

错误码：
- `400 VALIDATION_ERROR`
- `403 FORBIDDEN`
- `404 RESOURCE_NOT_FOUND`
- `409 CONFLICT`
- `422 BUSINESS_RULE_VIOLATION`
