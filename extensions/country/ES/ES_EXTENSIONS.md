## 西班牙 (ES) 专用扩展

测试文件位于 `es/`。

---

### 0. 扩展字段总览

| # | 字段 | 位置 | 必填性 | 对应 SII 字段 |
|---|------|------|--------|--------------|
| 1 | `InvoiceCode` | `cac:AdditionalDocumentReference` | CM — 有系列号时必填 | `NumSerieFacturaEmisor`（拼接前缀） |
| 2 | `SubInvoiceTypeCode` | `cac:AdditionalDocumentReference` | CM — 非默认 F1 时必填 | `TipoFactura` |
| 3 | `TaxRegimeCode` | `kdubl:TaxSubtotalExtension` | **M** — 每个 TaxSubtotal 必填 | `ClaveRegimenEspecialOTrascendencia` |
| 4 | `TipoRecargoEquivalencia` | `kdubl:TaxSubtotalExtension` | O — 零售商等价附加税才填 | `DetalleIVA/TipoRecargoEquivalencia` |
| 5 | `CuotaRecargoEquivalencia` | `kdubl:TaxSubtotalExtension` | O — 与 4 配对使用 | `DetalleIVA/CuotaRecargoEquivalencia` |
| 6 | `OperationType` | `kdubl:PiaozoneExtension` | CM — 买方国家非 ES 时必填 | `TipoDesglose`（结构选择） |
| 7 | `EmitidaPorTercerosODestinatario` | `kdubl:PiaozoneExtension` | O — 第三方代开才填 | `EmitidaPorTercerosODestinatario` |
| 8 | `VariosDestinatarios` | `kdubl:PiaozoneExtension` | O — 多买方才填 | `VariosDestinatarios` |
| 9 | `CorrectionMethod` | `kdubl:InvoiceDocumentReference` | CM — 纠正票（R1~R5）必填 | `TipoRectificativa` |
| 10 | `OriginalInvoiceSeries` | `kdubl:InvoiceDocumentReference` | CM — 纠正票时填 | `NumSerieFacturaEmisor`（原始票） |
| 11 | `OriginalTaxableAmount` | `kdubl:InvoiceDocumentReference` | CM — 替代法（S）必填 | `ImporteRectificacion/BaseRectificada` |
| 12 | `OriginalTaxAmount` | `kdubl:InvoiceDocumentReference` | CM — 替代法（S）必填 | `ImporteRectificacion/CuotaRectificada` |
| 13 | `TaxReportIndicator` | `cac:AdditionalDocumentReference` | O — 需要向税局额外报送时填 | — |
| 14 | `CuotaDeducible` | `kdubl:PiaozoneExtension` | O — 进项发票部分抵扣才填 | `FacturaRecibida/CuotaDeducible` |

> **M** = 必填；**CM** = 条件必填；**O** = 可选

---

### 1. 发票系列号 — InvoiceCode

**什么时候传：** 西班牙 VeriFactu 强制要求，有发票系列号时必填。

**传什么：** 发票系列号字符串，不允许包含 `/`。

**位置：** 标准 UBL `cac:AdditionalDocumentReference`，非 PiaozoneExtension 扩展块。

```xml
<cac:AdditionalDocumentReference>
    <cbc:ID schemeName="InvoiceTag">INV</cbc:ID>
    <cbc:DocumentType>InvoiceCode</cbc:DocumentType>
</cac:AdditionalDocumentReference>
```

> 系统会将其与发票号（`cbc:ID`）拼接为 `INV/20260512001` 上报 SII（`NumSerieFacturaEmisor`）。发票号同样不允许包含 `/`。

---

### 2. 税务制度码 — TaxRegimeCode

**什么时候传：** 每个税率档（`cac:TaxSubtotal`）必填，西班牙发票上报 SII 必须提供。

**传什么：** 按顺序与 `cac:TaxTotal/cac:TaxSubtotal` 一一对应，XSLT 自动按位置匹配，不需要填写 `index` 属性。绝大多数场景填 `01`。

| 值 | 说明 |
|----|------|
| `01` | 普通税制（Régimen general，最常用） |
| `02` | 出口业务（Exportación） |
| `03` | 休达/梅利利亚特殊税（IPSI） |
| `04` | 加那利群岛特殊税（IGIC） |
| `05` | 旅行社特殊方案（Agencias de viajes） |
| `06` | 二手货物/艺术品/古董特殊方案（Bienes usados） |
| `07` | 现金收付制（Criterio de caja） |
| `08` | 与 IPSI/IGIC 相关的业务 |
| `09` | 发票替代简化发票（Facturación de los destinatarios） |
| `10` | 代收代缴（Cobros por cuenta de terceros） |
| `11` | 租赁业务（Arrendamiento de local de negocio） |
| `12` | 非营业性实体（Entidades acogidas a RECC） |
| `13` | 发票对应多个年度（Factura con varias fechas） |
| `14` | 首次交付新建房产（Primera entrega de inmuebles） |
| `15` | 财政代表（Representante fiscal） |
| `16` | 农业/林业/渔业特殊方案（Régimen especial agropecuario） |
| `17` | OSS/IOSS（跨境电商） |

**多税率档示例**（21% + 10% 两个税率档，均为普通税制）：

```xml
<kdubl:TaxSubtotalExtensions>
    <!-- 第1个 TaxSubtotalExtension 对应第1个 cac:TaxSubtotal -->
    <kdubl:TaxSubtotalExtension>
        <kdubl:TaxRegimeCode>01</kdubl:TaxRegimeCode>
    </kdubl:TaxSubtotalExtension>
    <!-- 第2个 TaxSubtotalExtension 对应第2个 cac:TaxSubtotal -->
    <kdubl:TaxSubtotalExtension>
        <kdubl:TaxRegimeCode>01</kdubl:TaxRegimeCode>
    </kdubl:TaxSubtotalExtension>
</kdubl:TaxSubtotalExtensions>
```

> 对应 SII `ClaveRegimenEspecialOTrascendencia`。同一张发票有多个不同制度码时，系统去重后依次填入 `ClaveRegimenEspecialOTrascendencia`、`ClaveRegimenEspecialOTrascendenciaAdicional1`、`ClaveRegimenEspecialOTrascendenciaAdicional2`（最多3个）。

---

### 3. 等价附加税 — RecargoEquivalencia

**什么时候传：** 适用等价附加税方案的零售商，在对应税率档填写。税率和税额必须同时填写。

**传什么：** 放在对应 `TaxSubtotalExtension` 内，与 `TaxRegimeCode` 同级。

| 字段 | 类型 | 说明 |
|------|------|------|
| `TipoRecargoEquivalencia` | Decimal | 等价附加税税率（%），如 `5.2` |
| `CuotaRecargoEquivalencia` | Decimal | 等价附加税税额，如 `52.00` |

常见税率对应关系：

| VAT 税率 | 等价附加税税率 |
|---------|-------------|
| 21% | 5.2% |
| 10% | 1.4% |
| 4% | 0.5% |

```xml
<kdubl:TaxSubtotalExtension>
    <kdubl:TaxRegimeCode>01</kdubl:TaxRegimeCode>
    <kdubl:TipoRecargoEquivalencia>5.2</kdubl:TipoRecargoEquivalencia>
    <kdubl:CuotaRecargoEquivalencia>52.00</kdubl:CuotaRecargoEquivalencia>
</kdubl:TaxSubtotalExtension>
```

> 对应 SII `DetalleIVA/TipoRecargoEquivalencia` / `CuotaRecargoEquivalencia`。

---

### 4. 业务类型 — OperationType

**什么时候传：** 买方国家非 ES 时必填。买方国家为 ES 时不需要传。

**传什么：**

| 值 | 说明 |
|----|------|
| `PRODUCT` | 纯货物交易 |
| `SERVICE` | 纯服务交易 |
| `PRODUCT_SERVICE` | 货物与服务混合 |

```xml
<kdubl:OperationType>SERVICE</kdubl:OperationType>
```

> 对应 SII `TipoDesglose` 下的业务分类节点：`PRODUCT` → `Entrega`；`SERVICE` → `PrestacionServicios`；`PRODUCT_SERVICE` → 两者都输出。

---

### 5. 第三方代开标志 — EmitidaPorTercerosODestinatario

**什么时候传：** 发票由第三方或受票方代开时填 `S`，普通场景不填（默认 `N`）。

**传什么：**

| 值 | 说明 |
|----|------|
| `S` | 是（第三方或受票方代开） |
| `N` | 否（默认，不填时系统不输出该字段） |

```xml
<kdubl:EmitidaPorTercerosODestinatario>S</kdubl:EmitidaPorTercerosODestinatario>
```

> 对应 SII `FacturaExpedida/EmitidaPorTercerosODestinatario`。

---

### 6. 多买方标志 — VariosDestinatarios

**什么时候传：** 发票有多个买方时填 `S`，普通场景不填（默认 `N`）。

**传什么：**

| 值 | 说明 |
|----|------|
| `S` | 是（多个买方） |
| `N` | 否（默认，不填时系统不输出该字段） |

```xml
<kdubl:VariosDestinatarios>S</kdubl:VariosDestinatarios>
```

> 对应 SII `FacturaExpedida/VariosDestinatarios`。

---

### 7. 纠正票专用扩展

**什么时候传：** SubInvoiceTypeCode 为 R1~R5 时，以下字段必填。

#### 7.1 纠正票类型码

西班牙 SII 的 TipoFactura（F1-F4 / R1-R5）通过 ADR `SubInvoiceTypeCode` 槽位承载（与 KSA Phase2 SubInvoiceTypeCode 一致），`cbc:InvoiceTypeCode` 仅承载 UBL 标准值（380/381/383）。未提供时默认为 `F1`。

```xml
<cbc:InvoiceTypeCode>381</cbc:InvoiceTypeCode>
<cac:AdditionalDocumentReference>
    <cbc:ID schemeName="InvoiceTag">R1</cbc:ID>
    <cbc:DocumentType>SubInvoiceTypeCode</cbc:DocumentType>
</cac:AdditionalDocumentReference>
```

| SubInvoiceTypeCode | UBL 码 | SII TipoFactura | 含义 |
|--------------------|--------|----------------|------|
| `F1` | 380 | F1 | 标准发票（默认） |
| `F2` | 380 | F2 | 简化发票（匿名/小票） |
| `F3` | 380 | F3 | 把 F2 升级成正式票 |
| `F4` | 380 | F4 | 多张 F2 汇总入册 |
| `R1` | 381/383 | R1 | 错了改（Art.80.1/80.2，最常用） |
| `R2` | 381/383 | R2 | 客户破产（Art.80.3） |
| `R3` | 381/383 | R3 | 收不回坏账（Art.80.4） |
| `R4` | 381/383 | R4 | 其他原因（退货/折扣） |
| `R5` | 381/383 | R5 | 改的是 F2 小票（简化纠正票） |

#### 7.2 原始发票号 — BillingReference（标准 UBL，非扩展）

原始发票号和日期通过标准 UBL `cac:BillingReference` 填写，不在 PiaozoneExtension 内：

```xml
<cac:BillingReference>
    <cac:InvoiceDocumentReference>
        <cbc:ID>20260512001</cbc:ID>
        <cbc:IssueDate>2026-05-12</cbc:IssueDate>
    </cac:InvoiceDocumentReference>
</cac:BillingReference>
```

#### 7.3 纠正方法 — CorrectionMethod

**位置：** `kdubl:PiaozoneExtension/kdubl:InvoiceDocumentReference/kdubl:CorrectionMethod`

| 值 | 说明 | OriginalTaxableAmount / OriginalTaxAmount |
|----|------|------------------------------------------|
| `S` | 替代法（Sustitutiva）：整单作废，全额重开 | **必填** |
| `I` | 差额法（Incremental）：只记录差异部分 | 不需要 |

**差额法（I）金额填写规则：**

| InvoiceTypeCode | 语义 | KDUBL 金额填法 | SII 输出 |
|----------------|------|---------------|---------|
| `381`（贷记单） | 红冲 | 正数（UBL 标准） | 自动取反为负数 |
| `383`（借记单） | 增额 | 正数 | 直接输出正数 |

- **381 + I**：KDUBL 按 UBL 标准填正数，XSLT 转换时自动对 `BaseImponible`、`CuotaRepercutida`、`ImporteTotal` 取反，SII 收到负数表示冲减。
- **383 + I**：KDUBL 填正数，XSLT 直接透传，SII 收到正数表示追加。
- 增额场景必须使用 `383`，不能用 `381` 传负数。

#### 7.4 原始发票系列号 — OriginalInvoiceSeries

**位置：** `kdubl:PiaozoneExtension/kdubl:InvoiceDocumentReference/kdubl:OriginalInvoiceSeries`

**传什么：** 被纠正原始发票的系列号（对应原始发票的 `InvoiceCode`），字符串，不含 `/`。

```xml
<kdubl:OriginalInvoiceSeries>INV</kdubl:OriginalInvoiceSeries>
```

#### 7.5 原始发票税基 — OriginalTaxableAmount

**位置：** `kdubl:PiaozoneExtension/kdubl:InvoiceDocumentReference/kdubl:OriginalTaxableAmount`

**传什么：** 被纠正原始发票的税基金额，替代法（S）必填，必须带 `currencyID` 属性。格式：`(\+|-)?\d{1,12}(\.\d{0,2})?`

```xml
<kdubl:OriginalTaxableAmount currencyID="EUR">1000.00</kdubl:OriginalTaxableAmount>
```

> 对应 SII `ImporteRectificacion/BaseRectificada`。

#### 7.6 原始发票税额 — OriginalTaxAmount

**位置：** `kdubl:PiaozoneExtension/kdubl:InvoiceDocumentReference/kdubl:OriginalTaxAmount`

**传什么：** 被纠正原始发票的税额，替代法（S）必填，必须带 `currencyID` 属性。格式：`(\+|-)?\d{1,12}(\.\d{0,2})?`

```xml
<kdubl:OriginalTaxAmount currencyID="EUR">210.00</kdubl:OriginalTaxAmount>
```

> 对应 SII `ImporteRectificacion/CuotaRectificada`。

---

### 8. 进项发票可抵扣税额 — CuotaDeducible

**什么时候传：** 仅进项发票（Recibida，即 `ProfileID=payable` / `book_type=Recibida`）有意义，且**只在部分抵扣场景**需要填写。销项发票忽略此字段。

- **全额抵扣**：可不填。B2BRouter 服务端会从税明细（`tax_breakdowns`）按已承担进项税（`CuotaSoportada`）全额推算，行为与不带此字段一致（向后兼容）。
- **部分抵扣**（兼营免税业务、自用车辆、按比例抵扣等，实际可抵扣额 < 已承担进项税）：**必须显式填写**，否则会按全额抵扣错误上报。

**传什么：** 发票级的可抵扣税额（整票一个值，非按税率档拆分），必须带 `currencyID` 属性。格式：`(\+|-)?\d{1,12}(\.\d{0,2})?`

**位置：** `kdubl:PiaozoneExtension` 直接子元素（发票级），排在 `TaxSubtotalExtensions` 之后。

```xml
<kdubl:CuotaDeducible currencyID="EUR">78.75</kdubl:CuotaDeducible>
```

> 对应 SII `FacturaRecibida/CuotaDeducible`（AEAT XSD 中该元素必填）。
>
> **与 `CuotaSoportada` 的区别**：`CuotaSoportada`（已承担进项税）来自税率行 `TaxSubtotal/TaxAmount`，是供应商向你收取的 VAT；`CuotaDeducible`（可抵扣税额）是其中你实际能抵扣的部分，是购买方的税务判定。UBL/KDUBL 无原生"可抵扣税额"语义，故通过本扩展承载。
>
> **符号规则**：与发票 `tax_amount` 一致。差额法（`CorrectionMethod=I`）贷项票（`381`）整单取反时，本字段同样由转换器（`KdublToSiiCtcConverter`）取反后填入 B2BRouter 的 `cuota_deducible_in_cents`（分单位，元值 ×100）。
>
> **暂未承载**：SII 的跨期抵扣字段（`ADeducirEnPeriodoPosterior` / `EjercicioDeduccion` / `PeriodoDeduccion`）当前未支持，如后续需要按同一扩展模式补充。

**部分抵扣示例**（进项发票，承担进项税 105.00，仅 75% 可抵扣）：

```xml
<cbc:ProfileID>urn:piaozone.com:profile:payable:v1.0</cbc:ProfileID>
<cac:AdditionalDocumentReference>
    <cbc:ID schemeName="InvoiceTag">Recibida</cbc:ID>
    <cbc:DocumentType>TaxReportEntryType</cbc:DocumentType>
</cac:AdditionalDocumentReference>

<cac:TaxTotal>
    <cbc:TaxAmount currencyID="EUR">105.00</cbc:TaxAmount>  <!-- CuotaSoportada 来源 -->
    ...
</cac:TaxTotal>

<ext:UBLExtensions>
    <ext:UBLExtension>
        <ext:ExtensionContent>
            <kdubl:PiaozoneExtension>
                <kdubl:TaxSubtotalExtensions>
                    <kdubl:TaxSubtotalExtension>
                        <kdubl:TaxRegimeCode>01</kdubl:TaxRegimeCode>
                    </kdubl:TaxSubtotalExtension>
                </kdubl:TaxSubtotalExtensions>
                <!-- 只有 78.75 可抵扣，必须显式给出 -->
                <kdubl:CuotaDeducible currencyID="EUR">78.75</kdubl:CuotaDeducible>
            </kdubl:PiaozoneExtension>
        </ext:ExtensionContent>
    </ext:UBLExtension>
</ext:UBLExtensions>
```

---

### 9. PiaozoneExtension 元素顺序

XSD 定义的元素顺序如下，填写时必须按此顺序：

```
kdubl:PiaozoneExtension
├── kdubl:InvoiceDocumentReference   （纠正票时填，在最前）
│   ├── kdubl:CorrectionMethod
│   ├── kdubl:OriginalInvoiceSeries
│   ├── kdubl:OriginalTaxableAmount
│   └── kdubl:OriginalTaxAmount
├── kdubl:OperationType              （跨境发票时填，在 TaxSubtotalExtensions 之前）
├── kdubl:TaxSubtotalExtensions      （每张西班牙发票必填）
│   └── kdubl:TaxSubtotalExtension   （每个 TaxSubtotal 对应一个）
│       ├── kdubl:TaxRegimeCode      （必填）
│       ├── kdubl:TipoRecargoEquivalencia  （可选）
│       └── kdubl:CuotaRecargoEquivalencia （可选）
├── kdubl:EmitidaPorTercerosODestinatario  （可选）
├── kdubl:VariosDestinatarios              （可选）
└── kdubl:CuotaDeducible                   （可选，仅进项发票部分抵扣时填）
```

---

### 10. 税局报送类型 — TaxReportIndicator

**什么时候传：** 使用 NA 通道开票（不经过税局清关）后，需要额外向税局报备时填写。缺省或填 `NA` 表示不需要报送。

**传什么：**

| 值 | 说明 |
|----|------|
| `NA` | 不报送（缺省值，可省略此节点） |
| `SII` | 向西班牙 AEAT 进行 SII 报备（通过 B2Brouter SFTP 提交） |

**位置：** 标准 UBL `cac:AdditionalDocumentReference`，非 PiaozoneExtension 扩展块。

```xml
<cac:AdditionalDocumentReference>
    <cbc:ID schemeName="InvoiceTag">SII</cbc:ID>
    <cbc:DocumentType>TaxReportIndicator</cbc:DocumentType>
</cac:AdditionalDocumentReference>
```

**处理流程：**
- 开票成功后，系统自动在 `output_tax_report_record` 表创建报送记录（状态 `PENDING`）
- 由 MQ + 定时任务驱动实际报送
- 报送结果可通过 `GET /gjfp/v1/tax-report/result/{requestId}` 查询
- 报送文件可通过 `GET /gjfp/v1/documents/{documentId}/file?filetype=TaxReport` 下载

> 填 `NA` 与不填该节点效果相同，系统不触发任何报送流程。

---

### 11. 完整示例

#### 场景一：普通境内发票（最简）

```xml
<cac:AdditionalDocumentReference>
    <cbc:ID schemeName="InvoiceTag">INV</cbc:ID>
    <cbc:DocumentType>InvoiceCode</cbc:DocumentType>
</cac:AdditionalDocumentReference>

<ext:UBLExtensions>
    <ext:UBLExtension>
        <ext:ExtensionContent>
            <kdubl:PiaozoneExtension>
                <kdubl:TaxSubtotalExtensions>
                    <kdubl:TaxSubtotalExtension>
                        <kdubl:TaxRegimeCode>01</kdubl:TaxRegimeCode>
                    </kdubl:TaxSubtotalExtension>
                </kdubl:TaxSubtotalExtensions>
            </kdubl:PiaozoneExtension>
        </ext:ExtensionContent>
    </ext:UBLExtension>
</ext:UBLExtensions>
```

#### 场景二：境外买方 + 纯服务

```xml
<ext:UBLExtensions>
    <ext:UBLExtension>
        <ext:ExtensionContent>
            <kdubl:PiaozoneExtension>
                <kdubl:OperationType>SERVICE</kdubl:OperationType>
                <kdubl:TaxSubtotalExtensions>
                    <kdubl:TaxSubtotalExtension>
                        <kdubl:TaxRegimeCode>01</kdubl:TaxRegimeCode>
                    </kdubl:TaxSubtotalExtension>
                </kdubl:TaxSubtotalExtensions>
            </kdubl:PiaozoneExtension>
        </ext:ExtensionContent>
    </ext:UBLExtension>
</ext:UBLExtensions>
```

#### 场景三：纠正票（替代法）

```xml
<cac:BillingReference>
    <cac:InvoiceDocumentReference>
        <cbc:ID>20260512001</cbc:ID>
        <cbc:IssueDate>2026-05-12</cbc:IssueDate>
    </cac:InvoiceDocumentReference>
</cac:BillingReference>

<ext:UBLExtensions>
    <ext:UBLExtension>
        <ext:ExtensionContent>
            <kdubl:PiaozoneExtension>
                <kdubl:InvoiceDocumentReference>
                    <kdubl:CorrectionMethod>S</kdubl:CorrectionMethod>
                    <kdubl:OriginalInvoiceSeries>INV</kdubl:OriginalInvoiceSeries>
                    <kdubl:OriginalTaxableAmount currencyID="EUR">1000.00</kdubl:OriginalTaxableAmount>
                    <kdubl:OriginalTaxAmount currencyID="EUR">210.00</kdubl:OriginalTaxAmount>
                </kdubl:InvoiceDocumentReference>
                <kdubl:TaxSubtotalExtensions>
                    <kdubl:TaxSubtotalExtension>
                        <kdubl:TaxRegimeCode>01</kdubl:TaxRegimeCode>
                    </kdubl:TaxSubtotalExtension>
                </kdubl:TaxSubtotalExtensions>
            </kdubl:PiaozoneExtension>
        </ext:ExtensionContent>
    </ext:UBLExtension>
</ext:UBLExtensions>
```

#### 场景四：纠正票（差额法）

差额法分两种子场景，由 `InvoiceTypeCode` 决定：

**4a. 红冲（381 + I）**：冲减原发票金额，KDUBL 按 UBL 标准填正数，系统自动取反后上报 SII。

```xml
<cbc:InvoiceTypeCode>381</cbc:InvoiceTypeCode>
<cac:AdditionalDocumentReference>
    <cbc:ID schemeName="InvoiceTag">R4</cbc:ID>
    <cbc:DocumentType>SubInvoiceTypeCode</cbc:DocumentType>
</cac:AdditionalDocumentReference>

<cac:BillingReference>
    <cac:InvoiceDocumentReference>
        <cbc:ID>20260512001</cbc:ID>
        <cbc:IssueDate>2026-05-12</cbc:IssueDate>
    </cac:InvoiceDocumentReference>
</cac:BillingReference>

<!-- TaxSubtotal 金额填正数，如原发票税基 1000、税额 210 -->
<cac:TaxTotal>
    <cbc:TaxAmount currencyID="EUR">210.00</cbc:TaxAmount>
    <cac:TaxSubtotal>
        <cbc:TaxableAmount currencyID="EUR">1000.00</cbc:TaxableAmount>
        <cbc:TaxAmount currencyID="EUR">210.00</cbc:TaxAmount>
        ...
    </cac:TaxSubtotal>
</cac:TaxTotal>

<ext:UBLExtensions>
    <ext:UBLExtension>
        <ext:ExtensionContent>
            <kdubl:PiaozoneExtension>
                <kdubl:InvoiceDocumentReference>
                    <kdubl:CorrectionMethod>I</kdubl:CorrectionMethod>
                    <kdubl:OriginalInvoiceSeries>INV</kdubl:OriginalInvoiceSeries>
                    <!-- 差额法不需要 OriginalTaxableAmount / OriginalTaxAmount -->
                </kdubl:InvoiceDocumentReference>
                <kdubl:TaxSubtotalExtensions>
                    <kdubl:TaxSubtotalExtension>
                        <kdubl:TaxRegimeCode>01</kdubl:TaxRegimeCode>
                    </kdubl:TaxSubtotalExtension>
                </kdubl:TaxSubtotalExtensions>
            </kdubl:PiaozoneExtension>
        </ext:ExtensionContent>
    </ext:UBLExtension>
</ext:UBLExtensions>
```

> XSLT 自动将 `BaseImponible`、`CuotaRepercutida`、`ImporteTotal` 取反，SII 收到 `-1000`、`-210`、`-1210`。

**4b. 增额（383 + I）**：追加原发票未开足的金额，KDUBL 填正数，直接上报 SII。

```xml
<cbc:InvoiceTypeCode>383</cbc:InvoiceTypeCode>
<cac:AdditionalDocumentReference>
    <cbc:ID schemeName="InvoiceTag">R4</cbc:ID>
    <cbc:DocumentType>SubInvoiceTypeCode</cbc:DocumentType>
</cac:AdditionalDocumentReference>

<cac:BillingReference>
    <cac:InvoiceDocumentReference>
        <cbc:ID>20260512001</cbc:ID>
        <cbc:IssueDate>2026-05-12</cbc:IssueDate>
    </cac:InvoiceDocumentReference>
</cac:BillingReference>

<!-- TaxSubtotal 金额填追加的差额，如追加税基 200、税额 42 -->
<cac:TaxTotal>
    <cbc:TaxAmount currencyID="EUR">42.00</cbc:TaxAmount>
    <cac:TaxSubtotal>
        <cbc:TaxableAmount currencyID="EUR">200.00</cbc:TaxableAmount>
        <cbc:TaxAmount currencyID="EUR">42.00</cbc:TaxAmount>
        ...
    </cac:TaxSubtotal>
</cac:TaxTotal>

<ext:UBLExtensions>
    <ext:UBLExtension>
        <ext:ExtensionContent>
            <kdubl:PiaozoneExtension>
                <kdubl:InvoiceDocumentReference>
                    <kdubl:CorrectionMethod>I</kdubl:CorrectionMethod>
                    <kdubl:OriginalInvoiceSeries>INV</kdubl:OriginalInvoiceSeries>
                </kdubl:InvoiceDocumentReference>
                <kdubl:TaxSubtotalExtensions>
                    <kdubl:TaxSubtotalExtension>
                        <kdubl:TaxRegimeCode>01</kdubl:TaxRegimeCode>
                    </kdubl:TaxSubtotalExtension>
                </kdubl:TaxSubtotalExtensions>
            </kdubl:PiaozoneExtension>
        </ext:ExtensionContent>
    </ext:UBLExtension>
</ext:UBLExtensions>
```

> 383 不触发取反，SII 收到 `200`、`42`、`242`，表示追加。

#### 场景五：需要 SII 报送的普通境内发票

```xml
<cac:AdditionalDocumentReference>
    <cbc:ID schemeName="InvoiceTag">INV</cbc:ID>
    <cbc:DocumentType>InvoiceCode</cbc:DocumentType>
</cac:AdditionalDocumentReference>

<cac:AdditionalDocumentReference>
    <cbc:ID schemeName="InvoiceTag">SII</cbc:ID>
    <cbc:DocumentType>TaxReportIndicator</cbc:DocumentType>
</cac:AdditionalDocumentReference>

<ext:UBLExtensions>
    <ext:UBLExtension>
        <ext:ExtensionContent>
            <kdubl:PiaozoneExtension>
                <kdubl:TaxSubtotalExtensions>
                    <kdubl:TaxSubtotalExtension>
                        <kdubl:TaxRegimeCode>01</kdubl:TaxRegimeCode>
                    </kdubl:TaxSubtotalExtension>
                </kdubl:TaxSubtotalExtensions>
            </kdubl:PiaozoneExtension>
        </ext:ExtensionContent>
    </ext:UBLExtension>
</ext:UBLExtensions>
```

#### 场景六：零售商等价附加税

```xml
<ext:UBLExtensions>
    <ext:UBLExtension>
        <ext:ExtensionContent>
            <kdubl:PiaozoneExtension>
                <kdubl:TaxSubtotalExtensions>
                    <kdubl:TaxSubtotalExtension>
                        <kdubl:TaxRegimeCode>01</kdubl:TaxRegimeCode>
                        <kdubl:TipoRecargoEquivalencia>5.2</kdubl:TipoRecargoEquivalencia>
                        <kdubl:CuotaRecargoEquivalencia>52.00</kdubl:CuotaRecargoEquivalencia>
                    </kdubl:TaxSubtotalExtension>
                </kdubl:TaxSubtotalExtensions>
            </kdubl:PiaozoneExtension>
        </ext:ExtensionContent>
    </ext:UBLExtension>
</ext:UBLExtensions>
```
