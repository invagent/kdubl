# KDUBL 扩展标签全局参考文档

本文档说明 KDUBL 测试文件中所有 `kdubl:` 扩展标签的含义、用途及与各国税务通道格式的对应关系。

> **范围**：
> - `kdubl:` 扩展标签：命名空间 `urn:piaozone:ExtensionComponent:1.0`，放在 `ext:UBLExtensions/kdubl:PiaozoneExtension` 内
> - 文档级 InvoiceTag 字段：使用标准 UBL `cac:AdditionalDocumentReference`，放在文档 body 中
>
> **当前覆盖国家**：Saudi Arabia (SA) · Hungary (HU) · Thailand (TH)

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

#### SA / HU — `SubInvoiceTypeCode` 发票类型代码

```xml
<cac:AdditionalDocumentReference>
    <cbc:ID schemeName="InvoiceTag">NORMAL</cbc:ID>
    <cbc:DocumentType>SubInvoiceTypeCode</cbc:DocumentType>
</cac:AdditionalDocumentReference>
```

| 属性 | 说明 |
|------|------|
| **含义** | 写入 PUF `InvoiceTypeCode/@name` 属性，标识发票的业务类型 |
| **适用国家** | SA（沙特）、HU（匈牙利） |
| **PUF 对应** | `cbc:InvoiceTypeCode @name="..."` |
| **SA 常见值** | `0100000`=标准 B2B 发票、`0200000`=简化发票、`1100000`=预付款发票 |
| **HU 常见值** | `NORMAL`=普通发票、`SIMPLIFIED`=简化发票、`AGGREGATE`=汇总发票 |

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
| **常见值** | `B2B`、`B2C`、`B2G` |

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

XSLT 通过以下模板自动过滤所有 `schemeName="InvoiceTag"` 的 ADR，不将其输出到目标格式（PUF 等）：

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

---

## 三、Saudi Arabia (SA) 专用扩展

对应 Pagero PUF KSA Phase2 格式，测试文件位于 `sa/`。

### 3.1 `kdubl:InvoiceDocumentReference` — 发票文档引用（调整/冲销原因）

用于红票（381）、借记票等需要关联原始发票的场景，放在 `kdubl:PiaozoneExtension` 下。适用国家：SA、TH 等。

```xml
<kdubl:InvoiceDocumentReference>
    <!-- 子发票类型码，细分发票类型（如借记票据、信用票据等） -->
    <kdubl:SubInvoiceTypeCode>T03</kdubl:SubInvoiceTypeCode>
    <!-- 开具原因代码，由各国税务规范定义 -->
    <kdubl:DocumentIssuanceReasonCode>DBNS01</kdubl:DocumentIssuanceReasonCode>
    <!-- 开具原因描述文本 -->
    <kdubl:DocumentIssuanceReason>Price calculation error - additional charge</kdubl:DocumentIssuanceReason>
    <!-- 原始发票金额（被冲销/调整的原始票据金额） -->
    <kdubl:OriginalAmount currencyID="THB">4357.04</kdubl:OriginalAmount>
    <!-- 差额金额（本次调整金额，正数为补收，负数为退款） -->
    <kdubl:DifferenceAmount currencyID="THB">100.00</kdubl:DifferenceAmount>
</kdubl:InvoiceDocumentReference>
```

| 子标签 | 必填 | 含义 | 备注 |
|--------|------|------|------|
| `SubInvoiceTypeCode` | 否 | 子发票类型码，细分发票业务类型 | 出现时不能为空（KDUBL-EXT-009）|
| `DocumentIssuanceReasonCode` | 条件 | 开具原因代码，由各国税务规范定义 | 存在 `OriginalAmount`/`DifferenceAmount` 时必填（KDUBL-EXT-007），不能为空字符串（KDUBL-EXT-008）|
| `DocumentIssuanceReason` | 否 | 原因描述文本 | SA KSA-10 对应 `BillingReferenceExtension/Note` |
| `OriginalAmount` | 否 | 原始发票金额（被冲销/调整的原始票据金额），需携带 `@currencyID` | 出现时必须同时有 `DocumentIssuanceReasonCode`（KDUBL-EXT-007）|
| `DifferenceAmount` | 否 | 差额金额（本次调整金额），需携带 `@currencyID` | 出现时必须同时有 `DocumentIssuanceReasonCode`（KDUBL-EXT-007）|

---

### 3.2 SA 行级扩展字段

放在 `kdubl:LineExtension` 内：

#### 3.2.1 `kdubl:TaxInclusiveLineExtensionAmount` — 行含税金额（KSA-12）

```xml
<kdubl:TaxInclusiveLineExtensionAmount currencyID="SAR">115.00</kdubl:TaxInclusiveLineExtensionAmount>
```

| 属性 | 说明 |
|------|------|
| **含义** | 该行含税总金额 = `LineExtensionAmount` + `TaxTotal/TaxAmount`，KSA 要求在 PUF 中上报 |
| **计算公式** | `LineExtensionAmount + TaxTotal/TaxAmount` |
| **PUF 对应** | `puf:LineExtension/TaxInclusiveLineExtensionAmount`（KSA-12） |

#### 3.2.2 `kdubl:TaxExtensions` / `kdubl:TaxExtension` — 行税种扩展

```xml
<kdubl:TaxExtensions>
    <kdubl:TaxExtension>
        <kdubl:TaxIndex>1</kdubl:TaxIndex>
        <kdubl:InternalTaxCode>SA_VAT_S</kdubl:InternalTaxCode>
    </kdubl:TaxExtension>
</kdubl:TaxExtensions>
```

| 子标签 | 含义 |
|--------|------|
| `kdubl:TaxIndex` | 税种序号，与行内 `TaxTotal` 顺序对应 |
| `kdubl:InternalTaxCode` | 内部税种代码，用于通道转换时识别税率档。`SA_VAT_S`=标准税率、`SA_VAT_E`=免税 |

**完整 SA 行级扩展示例：**

```xml
<kdubl:LineExtensions>
    <kdubl:LineExtension>
        <kdubl:LineID>1</kdubl:LineID>
        <!-- KSA-12: LineExtensionAmount(100) + TaxAmount(15) = 115 -->
        <kdubl:TaxInclusiveLineExtensionAmount currencyID="SAR">115.00</kdubl:TaxInclusiveLineExtensionAmount>
        <kdubl:TaxExtensions>
            <kdubl:TaxExtension>
                <kdubl:TaxIndex>1</kdubl:TaxIndex>
                <kdubl:InternalTaxCode>SA_VAT_S</kdubl:InternalTaxCode>
            </kdubl:TaxExtension>
        </kdubl:TaxExtensions>
    </kdubl:LineExtension>
    <kdubl:LineExtension>
        <kdubl:LineID>2</kdubl:LineID>
        <kdubl:TaxInclusiveLineExtensionAmount currencyID="SAR">100.00</kdubl:TaxInclusiveLineExtensionAmount>
        <kdubl:TaxExtensions>
            <kdubl:TaxExtension>
                <kdubl:TaxIndex>1</kdubl:TaxIndex>
                <kdubl:InternalTaxCode>SA_VAT_E</kdubl:InternalTaxCode>
            </kdubl:TaxExtension>
        </kdubl:TaxExtensions>
    </kdubl:LineExtension>
</kdubl:LineExtensions>
```

---

### 3.3 `kdubl:PrepaidPaymentExtension` — 预付款发票 VAT 信息（KSA-26~34）

用于 **386 预付款发票**，放在 `kdubl:PiaozoneExtension` 下：

```xml
<kdubl:PrepaidPaymentExtension>
    <cac:TaxTotal>
        <cbc:TaxAmount currencyID="SAR">1.50</cbc:TaxAmount>
        <cac:TaxSubtotal>
            <cbc:TaxableAmount currencyID="SAR">10.00</cbc:TaxableAmount>
            <cbc:TaxAmount currencyID="SAR">1.50</cbc:TaxAmount>
            <cac:TaxCategory>
                <cbc:ID>S</cbc:ID>
                <cbc:Percent>15.00</cbc:Percent>
                <cac:TaxScheme>
                    <cbc:ID>VAT</cbc:ID>
                </cac:TaxScheme>
            </cac:TaxCategory>
        </cac:TaxSubtotal>
    </cac:TaxTotal>
</kdubl:PrepaidPaymentExtension>
```

| 属性 | 说明 | PUF 对应（KSA） |
|------|------|----------------|
| 整块 | 预付款发票关联的 VAT 明细，在 KDUBL 中以结构化 `cac:TaxTotal` 存储 | `puf:PrepaidPaymentExtension` |
| `TaxableAmount` | 预付款对应的不含税金额（KSA-31） | KSA-31 |
| `TaxAmount`（子计）| 预付款对应的 VAT 税额（KSA-32） | KSA-32 |
| `TaxCategory/ID` | VAT 税种代码（KSA-33） | KSA-33 |
| `TaxCategory/Percent` | VAT 税率（KSA-34） | KSA-34 |

> **说明**：标准 KDUBL 中 `cac:PrepaidPayment` 存放预付款基本信息（金额、日期、ID），VAT 明细过于复杂无法直接放入，因此单独用 `kdubl:PrepaidPaymentExtension` 携带。

---

## 四、Hungary (HU) 专用扩展

对应 Pagero PUF RTIR 格式，测试文件位于 `hu/`。

### 4.1 公共扩展（所有 HU 文件必填）

#### 4.1.1 `kdubl:InvoiceAppearance` — 发票呈现方式

```xml
<kdubl:InvoiceAppearance>ELECTRONIC</kdubl:InvoiceAppearance>
```

| 属性 | 说明 |
|------|------|
| **含义** | 发票在开票方与受票方之间的分发方式，RTIR 强制要求 |
| **可选值** | `ELECTRONIC`（电子）、`PAPER`（纸质） |
| **PUF 对应** | `puf:RestrictedInformation[Key=invoiceAppearance]/Value` |

#### 4.1.2 `kdubl:CustomerVatStatus` — 买方增值税状态

```xml
<kdubl:CustomerVatStatus>DOMESTIC</kdubl:CustomerVatStatus>
```

| 属性 | 说明 |
|------|------|
| **含义** | 买方的增值税纳税人身份，决定买方信息允许内容与校验规则 |
| **可选值** | `DOMESTIC`（境内纳税人）、`OTHER`（境外买方等） |
| **PUF 对应** | `puf:RestrictedInformation[Key=customerVatStatus]/Value` |

#### 4.1.3 发票类型名称 — 使用文档级 `SubInvoiceTypeCode` ADR

HU 发票类型名称通过与 SA 相同的文档级 InvoiceTag ADR 机制携带，**不再使用** `kdubl:InvoiceTypeName` 扩展标签：

```xml
<cac:AdditionalDocumentReference>
    <cbc:ID schemeName="InvoiceTag">NORMAL</cbc:ID>
    <cbc:DocumentType>SubInvoiceTypeCode</cbc:DocumentType>
</cac:AdditionalDocumentReference>
```

| 可选值 | 含义 |
|--------|------|
| `NORMAL` | 普通发票 |
| `SIMPLIFIED` | 简化发票 |
| `AGGREGATE` | 汇总发票 |

**PUF 对应**：`cbc:InvoiceTypeCode @name="NORMAL"`（详见第一章 §1.2）

#### 4.1.4 `kdubl:LineExpressionIndicator` — 计量单位自然表达指示器

放在每行的 `kdubl:LineExtension` 内，**每行必填**：

```xml
<kdubl:LineExpressionIndicator>true</kdubl:LineExpressionIndicator>
```

| 值 | 适用行类型 |
|----|-----------|
| `true` | 普通商品行（可用整数自然单位，如 EA、PCS） |
| `false` | 预付款抵扣行（无计量单位概念） |

**PUF 对应**：`puf:RestrictedInformation[Key=lineExpressionIndicator]/Value`

---

### 4.2 红票（改票）专用扩展 — `HU_CREDITNOTE_381.xml`

#### 4.2.1 `kdubl:ModificationIndex` — 改票序号

```xml
<kdubl:ModificationIndex>1</kdubl:ModificationIndex>
```

| 属性 | 说明 |
|------|------|
| **含义** | 针对同一张原始发票的第几次修改，从 1 开始递增。匈牙利允许对同一原始发票多次出具改票 |
| **必填** | 是（所有改票/红票） |
| **PUF 对应** | `puf:RestrictedInformation[Key=modificationIndex]/Value` |

#### 4.2.2 `kdubl:ModifyWithoutMaster` — 原始发票是否已上报 RTIR

```xml
<kdubl:ModifyWithoutMaster>false</kdubl:ModifyWithoutMaster>
```

| 值 | 含义 |
|----|------|
| `false` | 原始发票已向 RTIR 上报，本改票基于已知记录修改 |
| `true` | 原始发票未上报（主记录缺失） |

**PUF 对应**：`puf:RestrictedInformation[Key=modifyWithoutMaster]/Value`

#### 4.2.3 `kdubl:LineModification` — 行级修改信息

放在改票行对应的 `kdubl:LineExtension` 内：

```xml
<kdubl:LineModification>
    <kdubl:LineOperation>CREATE</kdubl:LineOperation>
    <kdubl:LineNumberReference>2</kdubl:LineNumberReference>
</kdubl:LineModification>
```

| 子标签 | 可选值 | 说明 |
|--------|--------|------|
| `kdubl:LineOperation` | `CREATE` / `MODIFY` / `DELETE` | 该行相对于原始发票的操作类型 |
| `kdubl:LineNumberReference` | 正整数 | 延续原始发票行号的连续编号。原始发票有行 1，则改票新增行的引用号为 2 |

**PUF 对应**：`lineModificationReferenceLineOperation` / `lineModificationReferenceLineNumberReference`

**完整红票行扩展示例：**

```xml
<kdubl:LineExtensions>
    <kdubl:LineExtension>
        <kdubl:LineID>1</kdubl:LineID>
        <kdubl:LineExpressionIndicator>true</kdubl:LineExpressionIndicator>
        <kdubl:LineModification>
            <kdubl:LineOperation>CREATE</kdubl:LineOperation>
            <kdubl:LineNumberReference>2</kdubl:LineNumberReference>
        </kdubl:LineModification>
    </kdubl:LineExtension>
</kdubl:LineExtensions>
```

---

### 4.3 预付款抵扣行专用扩展 — `HU_INVOICE_ADVANCE_380.xml`

#### 4.3.1 `kdubl:AdvancePayment` — 预付款信息块

放在预付款抵扣行（`LineExpressionIndicator=false`）的 `kdubl:LineExtension` 内：

```xml
<kdubl:AdvancePayment>
    <kdubl:AdvanceIndicator>true</kdubl:AdvanceIndicator>
    <kdubl:AdvanceOriginalInvoice>HU20260121001</kdubl:AdvanceOriginalInvoice>
    <kdubl:AdvancePaymentDate>2026-01-15</kdubl:AdvancePaymentDate>
    <kdubl:AdvanceExchangeRate>1.00</kdubl:AdvanceExchangeRate>
</kdubl:AdvancePayment>
```

| 子标签 | 含义 | PUF 对应 |
|--------|------|---------|
| `AdvanceIndicator` | 标识本行是预付款抵扣行，固定 `true` | `advanceIndicator` |
| `AdvanceOriginalInvoice` | 原始预付款发票的发票号 | `advanceOriginalInvoice` |
| `AdvancePaymentDate` | 买方实际支付预付款的日期（`YYYY-MM-DD`） | `advancePaymentDate` |
| `AdvanceExchangeRate` | 预付款支付时的汇率，同货币填 `1.00` | `advanceExchangeRate` |

**完整预付款抵扣行示例：**

```xml
<kdubl:LineExtensions>
    <kdubl:LineExtension>
        <kdubl:LineID>1</kdubl:LineID>
        <kdubl:LineExpressionIndicator>true</kdubl:LineExpressionIndicator>
    </kdubl:LineExtension>
    <kdubl:LineExtension>
        <kdubl:LineID>2</kdubl:LineID>
        <kdubl:LineExpressionIndicator>false</kdubl:LineExpressionIndicator>
        <kdubl:AdvancePayment>
            <kdubl:AdvanceIndicator>true</kdubl:AdvanceIndicator>
            <kdubl:AdvanceOriginalInvoice>HU20260121001</kdubl:AdvanceOriginalInvoice>
            <kdubl:AdvancePaymentDate>2026-01-15</kdubl:AdvancePaymentDate>
            <kdubl:AdvanceExchangeRate>1.00</kdubl:AdvanceExchangeRate>
        </kdubl:AdvancePayment>
    </kdubl:LineExtension>
</kdubl:LineExtensions>
```

---

### 4.4 外币发票专用扩展 — `HU_INVOICE_TAXCURRENCY_380.xml`

适用于开票货币（`DocumentCurrencyCode`）与计税货币（`TaxCurrencyCode`）不同的场景，如 EUR 开票 / HUF 计税。

#### 4.4.1 `kdubl:TaxCurrencyLegalMonetaryTotal` — 计税货币发票合计

```xml
<kdubl:TaxCurrencyLegalMonetaryTotal>
    <cbc:LineExtensionAmount currencyID="HUF">90417.50</cbc:LineExtensionAmount>
    <cbc:TaxExclusiveAmount currencyID="HUF">90417.50</cbc:TaxExclusiveAmount>
    <cbc:TaxInclusiveAmount currencyID="HUF">114830.23</cbc:TaxInclusiveAmount>
    <cbc:AllowanceTotalAmount currencyID="HUF">0.00</cbc:AllowanceTotalAmount>
    <cbc:ChargeTotalAmount currencyID="HUF">0.00</cbc:ChargeTotalAmount>
    <cbc:PayableRoundingAmount currencyID="HUF">0.00</cbc:PayableRoundingAmount>
    <cbc:PayableAmount currencyID="HUF">114830.23</cbc:PayableAmount>
</kdubl:TaxCurrencyLegalMonetaryTotal>
```

| 子标签（cbc:） | 含义 | PUF 对应 |
|--------------|------|---------|
| `LineExtensionAmount` | 所有行不含税金额之和（计税货币） | `puf:TaxCurrencyLineExtensionAmount` |
| `TaxExclusiveAmount` | 不含税总金额（计税货币） | `puf:TaxCurrencyTaxExclusiveAmount` |
| `TaxInclusiveAmount` | 含税总金额（计税货币） | `puf:TaxCurrencyTaxInclusiveAmount` |
| `AllowanceTotalAmount` | 表头折扣合计（计税货币） | — |
| `ChargeTotalAmount` | 表头收费合计（计税货币） | — |
| `PayableRoundingAmount` | 舍入金额（计税货币） | — |
| `PayableAmount` | 应付总金额（计税货币） | `puf:TaxCurrencyPayableAmount` |

> **说明**：子元素使用标准 UBL `cbc:` 命名空间，与 `cac:LegalMonetaryTotal` 的子元素结构相同，以计税货币（如 HUF）表示对应金额。

#### 4.4.2 `kdubl:TaxTotalExtensions` — 各 TaxTotal 的税率档含税总额

与 UBL body 中的双 `TaxTotal` 一一对应，每个 `kdubl:TaxTotalExtension` 对应一个 `cac:TaxTotal`，在其中为每个税率档补充含税总额。

```xml
<kdubl:TaxTotalExtensions>
    <!-- 第一个 TaxTotal 的扩展（开票货币 EUR） -->
    <kdubl:TaxTotalExtension>
        <kdubl:TaxSubtotalExtensions>
            <kdubl:TaxSubtotalExtension>
                <!-- 该税率档含税总额（开票货币 EUR） -->
                <kdubl:TaxInclusiveAmount currencyID="EUR">317.50</kdubl:TaxInclusiveAmount>
            </kdubl:TaxSubtotalExtension>
        </kdubl:TaxSubtotalExtensions>
    </kdubl:TaxTotalExtension>
    <!-- 第二个 TaxTotal 的扩展（计税货币 HUF） -->
    <kdubl:TaxTotalExtension>
        <kdubl:TaxSubtotalExtensions>
            <kdubl:TaxSubtotalExtension>
                <!-- 该税率档含税总额（计税货币 HUF） -->
                <kdubl:TaxInclusiveAmount currencyID="HUF">114830.23</kdubl:TaxInclusiveAmount>
            </kdubl:TaxSubtotalExtension>
        </kdubl:TaxSubtotalExtensions>
    </kdubl:TaxTotalExtension>
</kdubl:TaxTotalExtensions>
```

| 标签 | 含义 |
|------|------|
| `kdubl:TaxTotalExtensions` | 所有 TaxTotal 扩展的容器 |
| `kdubl:TaxTotalExtension` | 单个 TaxTotal 的扩展，与 UBL body 中的 `cac:TaxTotal` 顺序对应 |
| `kdubl:TaxSubtotalExtensions` | 该 TaxTotal 内各税率档扩展的容器 |
| `kdubl:TaxSubtotalExtension` | 单税率档扩展，与 `cac:TaxSubtotal` 顺序对应 |
| `kdubl:TaxInclusiveAmount` | 该税率档含税总额，`currencyID` 随所属 TaxTotal 货币变化（EUR/HUF） |

> **说明**：外币发票 UBL body 中包含两个 `TaxTotal`（第一个用开票货币含完整 `TaxSubtotal`，第二个用计税货币仅含总税额）。`TaxTotalExtensions` 为每个 TaxTotal 下的每个税率档补充含税总额，供 PUF 格式输出使用。

#### 4.4.3 外币发票行级扩展字段

放在对应行的 `kdubl:LineExtension` 内：

```xml
<kdubl:TaxCurrencyTaxInclusiveLineExtensionAmount currencyID="HUF">114830.23</kdubl:TaxCurrencyTaxInclusiveLineExtensionAmount>
<kdubl:TaxCurrencyLineExtensionAmount currencyID="HUF">90417.50</kdubl:TaxCurrencyLineExtensionAmount>
<kdubl:TaxInclusiveLineExtensionAmount currencyID="EUR">317.50</kdubl:TaxInclusiveLineExtensionAmount>
```

| 标签 | 含义 | PUF 对应 |
|------|------|---------|
| `TaxCurrencyTaxInclusiveLineExtensionAmount` | 行含税金额（计税货币） | `puf:TaxCurrencyTaxInclusiveLineExtensionAmount` |
| `TaxCurrencyLineExtensionAmount` | 行不含税净额（计税货币） | `puf:TaxCurrencyLineExtensionAmount` |
| `TaxInclusiveLineExtensionAmount` | 行含税金额（开票货币） | `puf:TaxInclusiveLineExtensionAmount` |

#### 4.4.4 外币发票配套的 UBL 标准字段（非扩展）

外币发票除扩展标签外，还需在 UBL body 中添加：

```xml
<!-- ① 计税货币代码 -->
<cbc:TaxCurrencyCode>HUF</cbc:TaxCurrencyCode>

<!-- ② 汇率 -->
<cac:TaxExchangeRate>
    <cbc:SourceCurrencyCode>EUR</cbc:SourceCurrencyCode>
    <cbc:TargetCurrencyCode>HUF</cbc:TargetCurrencyCode>
    <cbc:CalculationRate>361.67</cbc:CalculationRate>
    <cbc:MathematicOperatorCode>Multiply</cbc:MathematicOperatorCode>
    <cbc:Date>2026-01-21</cbc:Date>
</cac:TaxExchangeRate>

<!-- ③ 双 TaxTotal：第一个用开票货币（含 TaxSubtotal），第二个用计税货币（仅总额） -->
<cac:TaxTotal>
    <cbc:TaxAmount currencyID="EUR">67.50</cbc:TaxAmount>
    <cac:TaxSubtotal>...</cac:TaxSubtotal>
</cac:TaxTotal>
<cac:TaxTotal>
    <cbc:TaxAmount currencyID="HUF">24412.73</cbc:TaxAmount>
</cac:TaxTotal>
```

---

### 4.5 HU 买方 Party 字段规范（所有 HU 文件）

匈牙利买方使用两个特殊 `schemeID`，与其他国家不同：

```xml
<cac:AccountingCustomerParty>
    <cac:Party>
        <cac:PartyIdentification>
            <!-- 集团成员税号 -->
            <cbc:ID schemeID="HU:GroupMemberTaxpayerId">23545565414</cbc:ID>
        </cac:PartyIdentification>
        <cac:PartyLegalEntity>
            <cbc:RegistrationName>Buyer name</cbc:RegistrationName>
            <!-- 主纳税人号 -->
            <cbc:CompanyID schemeID="HU:TaxpayerId">23544565214</cbc:CompanyID>
        </cac:PartyLegalEntity>
    </cac:Party>
</cac:AccountingCustomerParty>
```

| 字段路径 | schemeID | 含义 |
|---------|----------|------|
| `PartyIdentification/ID` | `HU:GroupMemberTaxpayerId` | 集团成员税号，识别买方所属集团中的具体成员 |
| `PartyLegalEntity/CompanyID` | `HU:TaxpayerId` | 主纳税人号，买方在匈牙利税务局的主税号 |

---

## 五、Thailand (TH) 专用扩展

对应泰国电子发票格式，测试文件位于 `th/`（或 Max 示例）。

### 5.1 `kdubl:SupplierAddressInfo` — 卖方地址扩展

补充泰国行政区划中 UBL 标准字段无法覆盖的次级行政单位，放在 `kdubl:PiaozoneExtension` 下：

```xml
<kdubl:SupplierAddressInfo>
    <!-- 次区划代码（Subdistrict / Tambon 级别） -->
    <kdubl:SubdistrictCode>10360400</kdubl:SubdistrictCode>
    <!-- 次区划名称 -->
    <kdubl:SubdistrictName>Donmeung</kdubl:SubdistrictName>
    <!-- 区划代码（District / Amphoe 级别，补充 UBL CitySubdivisionName） -->
    <kdubl:CitySubdivisionCode>1033</kdubl:CitySubdivisionCode>
</kdubl:SupplierAddressInfo>
```

| 子标签 | 含义 | 对应泰国行政级别 |
|--------|------|----------------|
| `SubdistrictCode` | 次区划（街道/村落级）代码 | Subdistrict（Tambon），UBL 无对应字段 |
| `SubdistrictName` | 次区划名称 | Subdistrict（Tambon） |
| `CitySubdivisionCode` | 区划（区/县级）代码 | District（Amphoe），补充 `cbc:CitySubdivisionName` |

> **对应 UBL 路径**：`AccountingSupplierParty/Party/PostalAddress`

---

### 5.2 `kdubl:CustomerAddressInfo` — 买方地址扩展

与 `kdubl:SupplierAddressInfo` 结构完全相同，用于补充买方泰国行政区划信息：

```xml
<kdubl:CustomerAddressInfo>
    <kdubl:SubdistrictCode>10360400</kdubl:SubdistrictCode>
    <kdubl:SubdistrictName>Donmeung</kdubl:SubdistrictName>
    <kdubl:CitySubdivisionCode>1033</kdubl:CitySubdivisionCode>
</kdubl:CustomerAddressInfo>
```

| 子标签 | 含义 |
|--------|------|
| `SubdistrictCode` | 次区划代码（同 SupplierAddressInfo） |
| `SubdistrictName` | 次区划名称（同 SupplierAddressInfo） |
| `CitySubdivisionCode` | 区划代码（同 SupplierAddressInfo） |

> **对应 UBL 路径**：`AccountingCustomerParty/Party/PostalAddress`

---

## 六、全局扩展标签汇总表

### 文档级扩展（`cac:AdditionalDocumentReference` InvoiceTag，放在文档 body）

| 字段名（DocumentType） | 国家 | 适用场景 | 说明 |
|----------------------|------|---------|------|
| `SubInvoiceTypeCode` | SA、HU、TH | 所有文件 | 发票类型代码，写入 PUF `InvoiceTypeCode/@name`。SA 用 7 位事务代码，HU 用 `NORMAL`/`SIMPLIFIED`/`AGGREGATE`，TH 用国家自定义码 |
| `InvoiceContext` | 通用 | 业务场景标识 | `B2B` / `B2C` / `B2G`，供通道路由使用 |
| `SelfBilled` | 通用 | 反向开票标识 | `true` / `false` |
| `SenderEmail` | SA | 发票投递 | 发送方邮箱地址 |

### `kdubl:PiaozoneExtension` 内扩展标签（放在 `ext:UBLExtensions` 块）

| 标签 | 国家 | 适用场景 | 来源格式字段 |
|------|------|---------|-------------|
| `kdubl:LineExtensions` | 通用 | 所有含行扩展的文件 | 行级扩展容器 |
| `kdubl:LineExtension` | 通用 | 单行扩展 | — |
| `kdubl:LineID` | 通用 | 每个 LineExtension | 关联 `InvoiceLine/ID` |
| `kdubl:InvoiceDocumentReference` | SA、TH | 红票 381、借记票等调整票 | 关联原始发票的原因与金额差异块 |
| `kdubl:SubInvoiceTypeCode`（InvoiceDocumentReference 内） | SA、TH | 调整票 | 子发票类型码（注意与 InvoiceTag ADR 的 SubInvoiceTypeCode 不同，此处放在扩展块内） |
| `kdubl:DocumentIssuanceReasonCode` | SA、TH | 调整票 | 开具原因代码，存在 OriginalAmount/DifferenceAmount 时必填 |
| `kdubl:DocumentIssuanceReason` | SA、TH | 调整票 | 原因描述文本，KSA-10 对应 `BillingReferenceExtension/Note` |
| `kdubl:OriginalAmount` | TH | 调整票 | 原始发票金额，必须携带 `@currencyID`（KDUBL-EXT-005） |
| `kdubl:DifferenceAmount` | TH | 调整票 | 差额金额，必须携带 `@currencyID`（KDUBL-EXT-005） |
| `kdubl:TaxInclusiveLineExtensionAmount` | SA | 每行 | KSA-12 行含税金额 |
| `kdubl:TaxExtensions` | SA | 每行 | 行税种扩展容器 |
| `kdubl:TaxExtension` | SA | 每行 | 单税种扩展 |
| `kdubl:TaxIndex` | SA | 每行 | 税种序号 |
| `kdubl:InternalTaxCode` | SA | 每行 | 内部税种代码（SA_VAT_S / SA_VAT_E） |
| `kdubl:PrepaidPaymentExtension` | SA | 386 预付款发票 | KSA-26~34 预付款 VAT 块 |
| `kdubl:InvoiceAppearance` | HU | 所有 HU 文件 | `invoiceAppearance` |
| `kdubl:CustomerVatStatus` | HU | 所有 HU 文件 | `customerVatStatus` |
| `kdubl:LineExpressionIndicator` | HU | 每行 | `lineExpressionIndicator` |
| `kdubl:ModificationIndex` | HU | 红票 381 | `modificationIndex` |
| `kdubl:ModifyWithoutMaster` | HU | 红票 381 | `modifyWithoutMaster` |
| `kdubl:LineModification` | HU | 红票行 | 行修改信息容器 |
| `kdubl:LineOperation` | HU | 红票行 | `lineModificationReferenceLineOperation` |
| `kdubl:LineNumberReference` | HU | 红票行 | `lineModificationReferenceLineNumberReference` |
| `kdubl:AdvancePayment` | HU | 预付款抵扣行 | 预付款信息容器 |
| `kdubl:AdvanceIndicator` | HU | 预付款抵扣行 | `advanceIndicator` |
| `kdubl:AdvanceOriginalInvoice` | HU | 预付款抵扣行 | `advanceOriginalInvoice` |
| `kdubl:AdvancePaymentDate` | HU | 预付款抵扣行 | `advancePaymentDate` |
| `kdubl:AdvanceExchangeRate` | HU | 预付款抵扣行 | `advanceExchangeRate` |
| `kdubl:TaxTotalExtensions` | HU | 外币发票 | 所有 TaxTotal 扩展的容器，与 UBL body 双 TaxTotal 对应 |
| `kdubl:TaxTotalExtension` | HU | 外币发票 | 单个 TaxTotal 的扩展，顺序与 `cac:TaxTotal` 一致 |
| `kdubl:TaxSubtotalExtensions` | HU | 外币发票 | TaxTotal 内各税率档扩展的容器 |
| `kdubl:TaxSubtotalExtension` | HU | 外币发票 | 单税率档扩展，顺序与 `cac:TaxSubtotal` 一致 |
| `kdubl:TaxInclusiveAmount` | HU | 外币发票（税率档） | 该税率档含税总额，货币随所属 TaxTotal 变化（EUR/HUF） |
| `kdubl:TaxCurrencyLegalMonetaryTotal` | HU | 外币发票 | 计税货币发票合计，使用标准 `cbc:` 子元素（结构同 `LegalMonetaryTotal`） |
| `kdubl:TaxCurrencyTaxInclusiveLineExtensionAmount` | HU | 外币发票行 | `puf:TaxCurrencyTaxInclusiveLineExtensionAmount` |
| `kdubl:TaxCurrencyLineExtensionAmount` | HU | 外币发票行 | `puf:TaxCurrencyLineExtensionAmount` |
| `kdubl:TaxInclusiveLineExtensionAmount` | HU | 外币发票行 | `puf:TaxInclusiveLineExtensionAmount` |
| `kdubl:SupplierAddressInfo` | TH | 所有 TH 文件 | 卖方泰国行政区划扩展容器 |
| `kdubl:CustomerAddressInfo` | TH | 所有 TH 文件 | 买方泰国行政区划扩展容器 |
| `kdubl:SubdistrictCode` | TH | SupplierAddressInfo / CustomerAddressInfo | 次区划代码（Tambon 级） |
| `kdubl:SubdistrictName` | TH | SupplierAddressInfo / CustomerAddressInfo | 次区划名称（Tambon 级） |
| `kdubl:CitySubdivisionCode` | TH | SupplierAddressInfo / CustomerAddressInfo | 区划代码（Amphoe/District 级），补充 `cbc:CitySubdivisionName` |

---

*最后更新：2026-03-03*
*覆盖测试文件：`sa/SA_*.xml`（SA Phase2）· `hu/HU_*.xml`（HU RTIR）· `th/TH_*.xml`（TH）· `examples/KDUBL_Invoice_Max.xml`（最大集示例）*
