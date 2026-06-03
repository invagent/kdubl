# 清关通道类型枚举值（ClearanceChannelTypeEnum）

对应代码：`com.kingdee.enums.clearancechannel.ClearanceChannelTypeEnum`

发票上报时通过 `clearanceChannelType` 字段指定使用哪个清关通道，系统根据通道值路由到对应的税局对接实现。

---

## 枚举值列表

| 枚举名 | code | 适用国家 | 说明 |
|--------|------|---------|------|
| `SG_DP` | `SG_DP` | 新加坡 | DataPost（IRAS 官方通道） |
| `PAGERO` | `PAGERO` | 国际通用 | Pagero 聚合器（多国） |
| `PAGERO_HU` | `PAGERO_HU` | 匈牙利 | Pagero 匈牙利通道 |
| `PAGERO_SA` | `PAGERO_SA` | 沙特 | Pagero 沙特通道 |
| `DETAX_TH` | `DETAX_TH` | 泰国 | Detax Asia（泰国 RD 税局通道） |
| `FPT` | `FPT` | 越南 | FPT（越南税局授权服务商） |
| `MYINVOIS` | `MYINVOIS` | 马来西亚 | MyInvois（LHDN 官方通道） |
| `NL_CHANNEL` | `NL_CHANNEL` | 荷兰 | 荷兰 PEPPOL 通道 |
| `DE_CHANNEL` | `DE_CHANNEL` | 德国 | 德国 PEPPOL 通道 |
| `NAV_HU` | `NAV_HU` | 匈牙利 | NAV RTIR 直连（匈牙利税局） |
| `SFAP` | `SFAP` | 新加坡 | SFAP 通道 |
| `AEAT_ES` | `AEAT_ES` | 西班牙 | AEAT SII 直连（西班牙税局，SOAP） |
| `B2BROUTER_ES` | `B2BROUTER_ES` | 西班牙 | B2Brouter 通道（西班牙 SII CSV） |
| `NA` | `NA` | — | 不适用（内部占位，无实际通道） |

---

## 按国家/地区分组

| 国家/地区 | 可用通道 code |
|----------|-------------|
| 新加坡 | `SG_DP`、`SFAP` |
| 马来西亚 | `MYINVOIS` |
| 泰国 | `DETAX_TH` |
| 越南 | `FPT` |
| 西班牙 | `AEAT_ES`、`B2BROUTER_ES` |
| 匈牙利 | `NAV_HU`、`PAGERO_HU` |
| 沙特 | `PAGERO_SA` |
| 德国 | `DE_CHANNEL` |
| 荷兰 | `NL_CHANNEL` |
| 国际通用 | `PAGERO` |

---

## 协议与通道对应关系

| 协议 code | 通道 code | 国家 |
|----------|----------|------|
| `PINT_SG` | `SG_DP` | 新加坡 |
| `BIS_SG`、`BIS_SG_PEPPOL` | `SFAP` | 新加坡 |
| `PINT_MY` | `MYINVOIS` | 马来西亚 |
| `KDUBL_TH` | `DETAX_TH` | 泰国 |
| `KDUBL_VN`、`KDUBL_VN_REPORT` | `FPT` | 越南 |
| `SII_ES` | `AEAT_ES` | 西班牙 |
| `SII_ES_CSV` | `B2BROUTER_ES` | 西班牙 |
| `NAV_HU` | `NAV_HU` | 匈牙利 |
| `PUF_HU`、`BIS30_HU` | `PAGERO_HU` | 匈牙利 |
| `PUF_SA`、`BIS30_SA` | `PAGERO_SA` | 沙特 |
| `BIS30_DE` | `DE_CHANNEL` | 德国 |
| `BIS30_NL` | `NL_CHANNEL` | 荷兰 |
| `PUF`、`BIS30` | `PAGERO` | 国际通用 |

---

## 说明

- `AEAT_ES`：直连西班牙 AEAT SII SOAP 接口，需要企业数字证书（印章证书或个人证书）。
- `B2BROUTER_ES`：通过 B2Brouter 服务商以 CSV 格式上报 SII，适合不具备证书直连条件的场景。
- `NA`：占位通道，不触发任何实际清关逻辑，通常用于测试或内部单据。
- 已注释的通道（`CN_RPA`、`CN_LEQI`、`DATA_ONE_ASIA_TH`）暂未启用，不可使用。
