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

| 属性 | 说明                                                      |
|------|---------------------------------------------------------|
| **含义** | 买方的增值税纳税人身份，决定买方信息允许内容与校验规则                             |
| **可选值** | `DOMESTIC`（境内纳税人）、`OTHER`（境外买方等）、 `PRIVATE_PERSON`（个人）  |
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

#### 4.1.5 `kdubl:PeriodicalSettlement` — 周期性结算标识

```xml
<kdubl:PeriodicalSettlement>true</kdubl:PeriodicalSettlement>
```

| 属性 | 说明 |
|------|------|
| **含义** | 标识发票属于周期性/汇总结算场景（买卖双方约定按时间段合并结算，如月结、季结） |
| **可选值** | `true` / `false` |
| **适用场景** | 汇总发票（AGGREGATE，gyűjtőszámla） |
| **NAV 对应** | `invoiceData/periodicalSettlement` |

#### 4.1.6 `kdubl:SmallBusinessIndicator` — 小微企业税制标识

```xml
<kdubl:SmallBusinessIndicator>true</kdubl:SmallBusinessIndicator>
```

| 属性 | 说明 |
|------|------|
| **含义** | 标识开票方是否属于小微企业税制（KATA，kisadózó）纳税人 |
| **可选值** | `true` / `false` |
| **NAV 对应** | `invoiceData/smallBusinessIndicator` |

#### 4.1.7 `kdubl:CashAccountingIndicator` — 现金收付制增值税标识

```xml
<kdubl:CashAccountingIndicator>true</kdubl:CashAccountingIndicator>
```

| 属性 | 说明 |
|------|------|
| **含义** | 标识发票适用现金收付制增值税（实际收款时才产生纳税义务，匈牙利增值税法第 169 条 h 款） |
| **可选值** | `true` / `false` |
| **NAV 对应** | `invoiceData/cashAccountingIndicator` |

---

### 4.2 红票（改票）专用扩展 — `HU_CREDITNOTE_381.xml`

#### 4.2.1 `kdubl:ModificationIndex` — 改票序号

```xml
<kdubl:ModificationIndex>1</kdubl:ModificationIndex>
```

| 属性 | 说明 |
|------|------|
| **含义** | 针对同一张原始发票的第几次修改，从 1 开始递增。匈牙利允许对同一原始发票多次出具改票 |
| **取值范围** | 正整数，**最小值 1，最大值 100**（NAV XSD `InvoiceIndexType`：`minInclusive=1, maxInclusive=100`） |
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
| `kdubl:LineOperation` | `CREATE` / `MODIFY` | 该行相对于原始发票的操作类型（NAV XSD `LineOperationType` 仅定义这两个值） |
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

#### 4.2.4 `kdubl:BatchIndex` — 批量提交位置序号

适用于 NAV `batchInvoice` 场景（一次请求提交多张发票），标识本张发票在该批次中的排列位置：

```xml
<kdubl:BatchIndex>1</kdubl:BatchIndex>
```

| 属性 | 说明 |
|------|------|
| **含义** | 本张发票在一次批量提交中的排列序号，从 1 开始递增 |
| **必填** | 仅批量提交场景（`batchInvoice`）时使用 |
| **NAV 对应** | `ManageInvoiceRequest/invoiceOperations/invoiceOperation/index` |

> **注意**：`BatchIndex` 与 `ModificationIndex` 独立。同一批次中改票的 `ModificationIndex` 描述对原始发票的第几次修改，`BatchIndex` 描述该发票在当前批次中的位置。

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

| 子标签 | 必填 | 含义 | PUF 对应 |
|--------|------|------|---------|
| `AdvanceIndicator` | 是 | 标识本行是预付款抵扣行，固定 `true` | `advanceIndicator` |
| `AdvanceOriginalInvoice` | 否* | 原始预付款发票的发票号 | `advanceOriginalInvoice` |
| `AdvancePaymentDate` | 否* | 买方实际支付预付款的日期（`YYYY-MM-DD`） | `advancePaymentDate` |
| `AdvanceExchangeRate` | 否* | 预付款支付时的汇率，同货币填 `1.00` | `advanceExchangeRate` |

> **\* 字段说明**：`AdvanceOriginalInvoice`、`AdvancePaymentDate`、`AdvanceExchangeRate` 在**最终结算发票（végszámla）的抵扣行**中必须填写；在**预付款发票（elolegszamla）自身**的行扩展中可省略，仅填 `AdvanceIndicator=true`。

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

### 4.6 汇总发票专用扩展 — `NAV_HU_AGGREGATE`

汇总发票（gyűjtőszámla）是买卖双方约定按周期合并结算的发票，每行对应某一天发生的实际交货。因为每行交货日期和外币汇率可能不同，需要行级扩展字段携带这些信息。

发票头需同时设置：
```xml
<kdubl:PeriodicalSettlement>true</kdubl:PeriodicalSettlement>
```

以及通过 `SubInvoiceTypeCode` ADR 标识：
```xml
<cac:AdditionalDocumentReference>
    <cbc:ID schemeName="InvoiceTag">AGGREGATE</cbc:ID>
    <cbc:DocumentType>SubInvoiceTypeCode</cbc:DocumentType>
</cac:AdditionalDocumentReference>
```

#### 4.6.1 `kdubl:AggregateLineData` — 汇总发票行交货数据

放在每行的 `kdubl:LineExtension` 内（`LineExpressionIndicator` 之后）：

```xml
<kdubl:AggregateLineData>
    <kdubl:LineDeliveryDate>2021-05-02</kdubl:LineDeliveryDate>
    <kdubl:LineExchangeRate>308.50</kdubl:LineExchangeRate>
</kdubl:AggregateLineData>
```

| 子标签 | 含义 | NAV 对应 |
|--------|------|---------|
| `LineDeliveryDate` | 该行货物/服务实际交货或完成日期（`YYYY-MM-DD`） | `lineData/lineDeliveryDate` |
| `LineExchangeRate` | 该行交货日期对应的汇率（外币发票使用，同货币可省略） | `lineData/lineExchangeRate` |

**完整汇总发票行扩展示例：**

```xml
<kdubl:LineExtensions>
    <kdubl:LineExtension>
        <kdubl:LineID>1</kdubl:LineID>
        <kdubl:LineExpressionIndicator>true</kdubl:LineExpressionIndicator>
        <kdubl:AggregateLineData>
            <kdubl:LineDeliveryDate>2021-05-02</kdubl:LineDeliveryDate>
            <kdubl:LineExchangeRate>308.50</kdubl:LineExchangeRate>
        </kdubl:AggregateLineData>
    </kdubl:LineExtension>
    <kdubl:LineExtension>
        <kdubl:LineID>2</kdubl:LineID>
        <kdubl:LineExpressionIndicator>true</kdubl:LineExpressionIndicator>
        <kdubl:AggregateLineData>
            <kdubl:LineDeliveryDate>2021-05-06</kdubl:LineDeliveryDate>
            <kdubl:LineExchangeRate>309.00</kdubl:LineExchangeRate>
        </kdubl:AggregateLineData>
    </kdubl:LineExtension>
</kdubl:LineExtensions>
```

---

### 4.7 产品环境税（termékdíj）专用扩展 — `NAV_HU_PRODUCT_FEE`

匈牙利《产品环境税法》要求对特定商品（电子产品、涂料、纸品等）在进入流通时缴纳环境税（termékdíj）。发票需同时携带发票级汇总和行级明细。

#### 4.7.1 `kdubl:ProductFeeSummary` — 发票级产品环境税汇总

放在 `kdubl:PiaozoneExtension` 内（`CashAccountingIndicator` 之后、`ModificationIndex` 之前）：

```xml
<kdubl:ProductFeeSummary>
    <kdubl:ProductFeeOperation>DEPOSIT</kdubl:ProductFeeOperation>
    <kdubl:ProductFeeData>
        <kdubl:ProductFeeCode schemeID="KT">702</kdubl:ProductFeeCode>
        <kdubl:ProductFeeQuantity unitCode="KG">50.000</kdubl:ProductFeeQuantity>
        <kdubl:ProductFeeRate>57.00</kdubl:ProductFeeRate>
        <kdubl:ProductFeeAmount currencyID="HUF">2850.00</kdubl:ProductFeeAmount>
    </kdubl:ProductFeeData>
    <kdubl:ProductFeeData>
        <kdubl:ProductFeeCode schemeID="KT">801</kdubl:ProductFeeCode>
        <kdubl:ProductFeeQuantity unitCode="KG">1200.000</kdubl:ProductFeeQuantity>
        <kdubl:ProductFeeRate>19.00</kdubl:ProductFeeRate>
        <kdubl:ProductFeeAmount currencyID="HUF">22800.00</kdubl:ProductFeeAmount>
    </kdubl:ProductFeeData>
    <kdubl:ProductChargeSum currencyID="HUF">25935.00</kdubl:ProductChargeSum>
</kdubl:ProductFeeSummary>
```

| 子标签 | 必填 | 含义 | NAV 对应 |
|--------|------|------|---------|
| `ProductFeeOperation` | 是 | 操作类型：`DEPOSIT`（纳入）或 `RECLAIM`（退还） | `productFeeSummary/productFeeOperation` |
| `ProductFeeData` | 否 | 单个税种明细，可重复（每个 KT 分类一条） | `productFeeSummary/productFeeData` |
| `ProductFeeData/ProductFeeCode` | 是 | 税种代码，携带 `schemeID="KT"` 属性 | `productFeeCode` |
| `ProductFeeData/ProductFeeQuantity` | 否 | 应税数量，携带 `unitCode` 属性（如 `KG`） | `productFeeQuantity` |
| `ProductFeeData/ProductFeeRate` | 否 | 每单位税率（HUF/单位） | `productFeeRate` |
| `ProductFeeData/ProductFeeAmount` | 否 | 该税种应缴金额，携带 `currencyID` | `productFeeAmount` |
| `ProductChargeSum` | 否 | 发票级产品环境税合计，携带 `currencyID` | `productChargeSum` |

#### 4.7.2 行级产品环境税字段

放在对应行的 `kdubl:LineExtension` 内（`LineExpressionIndicator` 之后）：

```xml
<kdubl:LineExtension>
    <kdubl:LineID>1</kdubl:LineID>
    <kdubl:LineExpressionIndicator>true</kdubl:LineExpressionIndicator>
    <!-- 标识该行有产品环境税义务 -->
    <kdubl:ObligatedForProductFee>true</kdubl:ObligatedForProductFee>
    <!-- 当税务义务转让给买方时使用（takeoverReason != 01） -->
    <kdubl:ProductFeeClause>
        <kdubl:TakeoverReason>02_b</kdubl:TakeoverReason>
        <kdubl:TakeoverAmount currencyID="HUF">0</kdubl:TakeoverAmount>
    </kdubl:ProductFeeClause>
    <!-- 该行的税种明细，同一行可有多个（不同 KT 税种） -->
    <kdubl:ProductFeeContent>
        <kdubl:ProductFeeCode schemeID="KT">801</kdubl:ProductFeeCode>
        <kdubl:ProductFeeQuantity unitCode="KG">1200.00</kdubl:ProductFeeQuantity>
        <kdubl:ProductFeeRate>19.00</kdubl:ProductFeeRate>
        <kdubl:ProductFeeAmount currencyID="HUF">22800.00</kdubl:ProductFeeAmount>
    </kdubl:ProductFeeContent>
</kdubl:LineExtension>
```

| 字段 | 含义 | NAV 对应 |
|------|------|---------|
| `ObligatedForProductFee` | 该行商品是否有产品环境税缴纳义务（`true`/`false`） | `lineData/obligatedForProductFee` |
| `ProductFeeClause/TakeoverReason` | 税务义务转让原因代码（如 `02_a`、`02_b`），义务由开票方承担时可省略 | `takeoverData/takeoverReason` |
| `ProductFeeClause/TakeoverAmount` | 转让金额，`0` 表示全额转让给买方 | `takeoverData/takeoverAmount` |
| `ProductFeeContent` | 行级税种明细，结构与 `ProductFeeData` 相同，**同一行可重复**（多个 KT 税种） | `lineData/productFeeData` |

> **`ProductFeeClause` vs `ProductFeeContent` 区别**：`ProductFeeClause` 描述税务义务的**转让关系**（谁来缴税）；`ProductFeeContent` 描述**实际税种和金额**（缴多少）。两者可同时存在。
