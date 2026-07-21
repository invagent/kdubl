# KDUBL 扩展标签全局参考文档

本文档说明 KDUBL 测试文件中所有 `kdubl:` 扩展标签的含义、用途及与各国税务通道格式的对应关系。

> **范围**：
> - `kdubl:` 扩展标签：命名空间 `urn:piaozone:ExtensionComponent:1.0`，放在 `ext:UBLExtensions/kdubl:PiaozoneExtension` 内
> - 文档级 InvoiceTag 字段：使用标准 UBL `cac:AdditionalDocumentReference`，放在文档 body 中
>
> **当前覆盖国家**：Saudi Arabia (SA) · Hungary (HU) · Thailand (TH) · Spain (ES)

---

## 命名空间声明（所有文件通用）

所有使用扩展标签的 KDUBL 文件，均需在根元素声明以下两个命名空间：

```xml
xmlns:ext="urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2"
xmlns:kdubl="urn:piaozone:ExtensionComponent:1.0"
```

所有 `kdubl:` 扩展标签统一放在文档头部的 `ext:UBLExtensions` 块内：

```xml
<ext:UBLExtensions>
    <ext:UBLExtension>
        <ext:ExtensionAgencyName>Piaozone</ext:ExtensionAgencyName>
        <ext:ExtensionContent>
            <kdubl:PiaozoneExtension>
                <!-- 国家专用扩展字段放在此处 -->
            </kdubl:PiaozoneExtension>
        </ext:ExtensionContent>
    </ext:UBLExtension>
</ext:UBLExtensions>
```

---

## 一、文档级扩展机制 — `cac:AdditionalDocumentReference` InvoiceTag

**文档级扩展**使用标准 UBL `cac:AdditionalDocumentReference` 携带通道处理所需的控制字段，与放在 `kdubl:PiaozoneExtension` 内的 `kdubl:` 扩展标签互为补充：

| 维度 | 文档级 InvoiceTag ADR | `kdubl:PiaozoneExtension` 扩展 |
|------|-----------------------|-------------------------------|
| 放置位置 | 文档 body，与 `cac:Delivery` 等平级 | `ext:UBLExtensions/kdubl:PiaozoneExtension` |
| XML 元素 | 标准 UBL `cac:AdditionalDocumentReference` | 自定义 `kdubl:` 命名空间元素 |
| 作用粒度 | 文档级（整张发票） | 文档级或行级 |
| 典型用途 | 通道路由、业务分类、事务代码等控制字段 | 税务合规必填字段、金额换算、修改追踪 |

### 1.1 基本格式

```xml
<cac:AdditionalDocumentReference>
    <cbc:ID schemeName="InvoiceTag">{字段值}</cbc:ID>
    <cbc:DocumentType>{字段名}</cbc:DocumentType>
</cac:AdditionalDocumentReference>
```

- `cbc:ID @schemeName="InvoiceTag"`：固定标记，通道 XSLT 识别此标记后会**自动过滤，不输出到目标格式**
- `cbc:DocumentType`：字段名（Key）
- `cbc:ID` 的文本内容：字段值（Value）

### 1.2 已定义的 InvoiceTag 字段

#### SA / HU / TH — `SubInvoiceTypeCode` 发票类型代码

```xml
<cac:AdditionalDocumentReference>
    <cbc:ID schemeName="InvoiceTag">NORMAL</cbc:ID>
    <cbc:DocumentType>SubInvoiceTypeCode</cbc:DocumentType>
</cac:AdditionalDocumentReference>
```

| 属性 | 说明 |
|------|------|
| **含义** | **当前发票**的业务子类型码 |
| **适用国家** | SA（沙特）、HU（匈牙利）、TH（泰国）等 |
| **SA 常见值** | `0100000`=标准 B2B 发票、`0200000`=简化发票、`1100000`=预付款发票 |
| **HU 常见值** | `NORMAL`=普通发票、`SIMPLIFIED`=简化发票、`AGGREGATE`=汇总发票 |
| **TH 常见值** | `388`=增值税发票、`T02`=发票/税务发票、`T03`=收据/税务发票、`80`=借项、`81`=贷项 |

> **泰国特别说明**：泰国 80/81 调整发票在此处填写**当前调整发票**的类型（如 `80`）。
> 被引用原始发票的类型则单独存放在 `kdubl:PiaozoneExtension/kdubl:InvoiceDocumentReference/kdubl:SubInvoiceTypeCode`，
> 见 [TH_EXTENSIONS.md § 5.3](country/TH/TH_EXTENSIONS.md)。

#### 通用 — `InvoiceContext` 业务场景

```xml
<cac:AdditionalDocumentReference>
    <cbc:ID schemeName="InvoiceTag">B2B</cbc:ID>
    <cbc:DocumentType>InvoiceContext</cbc:DocumentType>
</cac:AdditionalDocumentReference>
```

| 属性 | 说明 |
|------|------|
| **含义** | 发票业务场景，供通道服务路由和规则匹配使用 |

**已知值说明：**

| 值 | 含义 | 适用场景 |
|----|------|----------|
| `B2B` | 企业对企业 | 标准商业发票 |
| `B2C` | 企业对消费者 | 零售/消费发票 |
| `B2G` | 企业对政府 | 政府采购发票，部分国家有额外验证规则 |
| `Standard` | 标准业务场景 | 无特殊场景要求时的默认值 |
| `NA` | 不适用（豁免） | 该发票无需经过正常通道校验流程，如平台内部单据 |
| `Adjustment` | 调整发票 | VN 等国家的调整类发票 |
| `Replacement` | 替换发票 | VN 等国家的替换类发票 |

#### 通用 — `SelfBilled` 反向开票标识

```xml
<cac:AdditionalDocumentReference>
    <cbc:ID schemeName="InvoiceTag">false</cbc:ID>
    <cbc:DocumentType>SelfBilled</cbc:DocumentType>
</cac:AdditionalDocumentReference>
```

| 属性 | 说明 |
|------|------|
| **含义** | 标识本发票是否为买方代开（Self-Billing） |
| **值** | `true` / `false` |

#### 通用 — `BillId` 业务开票申请单ID（幂等去重）

```xml
<cac:AdditionalDocumentReference>
    <cbc:ID schemeName="InvoiceTag">BILL-20260616-001</cbc:ID>
    <cbc:DocumentType>BillId</cbc:DocumentType>
</cac:AdditionalDocumentReference>
```

| 属性 | 说明 |
|------|------|
| **含义** | 业务系统的开票申请单唯一标识（单据ID），用于保证同一业务单据**只开出一张成功的票**（幂等去重） |
| **适用国家** | 通用（所有国家/通道） |
| **值** | 业务系统的单据ID（字符串），由业务端生成并保证唯一 |
| **是否必填** | 可选；缺省（不带该 ADR）时不触发去重约束，行为与现状一致（向后兼容） |

**幂等不变式**：同一 `BillId`（按企业隔离）下，至多存在一个「非失败」文档（开票状态 ∈ 进行中 / 已成功）；失败文档可共存、可被重试覆盖。

**工作机制**：
- 平台解析该字段写入文档记录 `document_info.bill_id`；
- 数据库通过生成列 + 唯一索引在并发下强制约束；
- 命中已存在「非失败」文档时，该文档返回错误码 `BILL_ALREADY_PROCESSED`（逐文档校验错误，不影响同批次其它文档）；
- 文档变为失败后自动释放占用，允许同一 `BillId` 重新开票；已成功则永久占用（成功即锁死）。

> 多文档批量提交时，每个文档可携带各自独立的 `BillId`，互不影响。

#### SA — `SenderEmail` 发送方邮箱

```xml
<cac:AdditionalDocumentReference>
    <cbc:ID schemeName="InvoiceTag">user@example.com</cbc:ID>
    <cbc:DocumentType>SenderEmail</cbc:DocumentType>
</cac:AdditionalDocumentReference>
```

| 属性 | 说明 |
|------|------|
| **含义** | 发票发送方的邮箱地址，供通道投递使用 |
| **适用国家** | SA |

### 1.3 InvoiceTag ADR 的自动过滤规则

XSLT 通过以下模板自动过滤所有 `schemeName="InvoiceTag"` 的 ADR，不将其输出到目标格式：

```xslt
<!-- 过滤所有 InvoiceTag ADR，不输出到目标文件 -->
<xsl:template match="cac:AdditionalDocumentReference[cbc:ID/@schemeName='InvoiceTag']"
              mode="invoice creditnote"/>
```

---

## 二、通用行级扩展结构（跨国家共用）

`kdubl:LineExtensions` 是行级扩展的公共容器，所有使用行级扩展的国家均遵循此结构：

```xml
<kdubl:LineExtensions>
    <kdubl:LineExtension>
        <kdubl:LineID>1</kdubl:LineID>
        <!-- 各国行级扩展字段放在此处 -->
    </kdubl:LineExtension>
</kdubl:LineExtensions>
```

| 标签 | 说明 |
|------|------|
| `kdubl:LineExtensions` | 行级扩展容器，`PiaozoneExtension` 的直接子元素 |
| `kdubl:LineExtension` | 单行扩展，每条 `InvoiceLine` 对应一个 |
| `kdubl:LineID` | 必填，值与对应 `InvoiceLine/cbc:ID` 一致，用于关联 |


## 三、国家扩展

各国特有扩展字段见 `country/` 目录下对应文档：

| 国家 | 文档 | 覆盖要点 |
|------|------|---------|
| 沙特 (SA) | [country/SA/SA_EXTENSIONS.md](country/SA/SA_EXTENSIONS.md) | ZATCA Phase2 字段 |
| 匈牙利 (HU) | [country/HU/HU_EXTENSIONS.md](country/HU/HU_EXTENSIONS.md) | NAV 上报字段 |
| 泰国 (TH) | [country/TH/TH_EXTENSIONS.md](country/TH/TH_EXTENSIONS.md) | 80/81 调整发票、原始发票引用 |
| 西班牙 (ES) | [country/ES/ES_EXTENSIONS.md](country/ES/ES_EXTENSIONS.md) | SII 上报字段（销项 `TaxRegimeCode`/纠正票扩展，进项 `CuotaDeducible` 可抵扣税额） |

> **西班牙进项可抵扣税额 `CuotaDeducible`**：进项发票（`book_type=Recibida`）部分抵扣场景下，
> 在 `kdubl:PiaozoneExtension` 内以发票级字段承载实际可抵扣税额；全额抵扣可省略。
> 详见 [ES_EXTENSIONS.md § 8](country/ES/ES_EXTENSIONS.md)。