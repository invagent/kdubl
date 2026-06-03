## 西班牙 (ES) 专用扩展

测试文件位于 `es/`。

---

### 0. 扩展字段总览

| # | 字段 | 位置 | 必填性 | 对应 SII 字段 |
|---|------|------|--------|--------------|
| 1 | `InvoiceCode` | `cac:AdditionalDocumentReference` | CM — 有系列号时必填 | `NumSerieFacturaEmisor`（拼接前缀） |
| 2 | `TaxRegimeCode` | `kdubl:TaxSubtotalExtension` | **M** — 每个 TaxSubtotal 必填 | `ClaveRegimenEspecialOTrascendencia` |
| 3 | `TipoRecargoEquivalencia` | `kdubl:TaxSubtotalExtension` | O — 零售商等价附加税才填 | `DetalleIVA/TipoRecargoEquivalencia` |
| 4 | `CuotaRecargoEquivalencia` | `kdubl:TaxSubtotalExtension` | O — 与 3 配对使用 | `DetalleIVA/CuotaRecargoEquivalencia` |
| 5 | `OperationType` | `kdubl:PiaozoneExtension` | CM — 买方国家非 ES 时必填 | `TipoDesglose`（结构选择） |
| 6 | `EmitidaPorTercerosODestinatario` | `kdubl:PiaozoneExtension` | O — 第三方代开才填 | `EmitidaPorTercerosODestinatario` |
| 7 | `VariosDestinatarios` | `kdubl:PiaozoneExtension` | O — 多买方才填 | `VariosDestinatarios` |
| 8 | `CorrectionMethod` | `kdubl:InvoiceDocumentReference` | CM — 纠正票（R1~R5）必填 | `TipoRectificativa` |
| 9 | `OriginalInvoiceSeries` | `kdubl:InvoiceDocumentReference` | CM — 纠正票时填 | `NumSerieFacturaEmisor`（原始票） |
| 10 | `OriginalTaxableAmount` | `kdubl:InvoiceDocumentReference` | CM — 替代法（S）必填 | `ImporteRectificacion/BaseRectificada` |
| 11 | `OriginalTaxAmount` | `kdubl:InvoiceDocumentReference` | CM — 替代法（S）必填 | `ImporteRectificacion/CuotaRectificada` |

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

**什么时候传：** `cbc:InvoiceTypeCode` 的 `name` 属性为 R1~R5 时，以下字段必填。

#### 7.1 纠正票类型码

```xml
<cbc:InvoiceTypeCode name="R1">384</cbc:InvoiceTypeCode>
```

| name 值 | SII TipoFactura | 含义 |
|---------|----------------|------|
| `R1` | R1 | 普通纠正票（Art.80.1/80.2，法律错误） |
| `R2` | R2 | 纠正票（Art.80.3，破产） |
| `R3` | R3 | 纠正票（Art.80.4，坏账） |
| `R4` | R4 | 其他原因纠正票 |
| `R5` | R5 | 简化发票纠正票 |

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

### 8. PiaozoneExtension 元素顺序

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
└── kdubl:VariosDestinatarios              （可选）
```

---

### 9. 完整示例

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

```xml
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

#### 场景五：零售商等价附加税

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
