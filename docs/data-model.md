# Data model

Star schema: shared dimensions (Date, Tenant, Category, Alarm status, Incident status) around eight fact tables.

```text
DimDate ----+
DimTenant --+--> FactAirQuality / FactSWM / FactWater / FactEnergy / FactIrrigation / FactSurveillance / FactAlarm / FactIncident
DimCategory-+     (every fact carries Date, TenantID, CategoryKey)
DimAlarm ------> FactAlarm.AlarmStatusID
DimIncident ---> FactIncident.IncidentStatusID
```

All relationships are many-to-one, single direction (dimension filters fact). `DimCategory` is what the RLS roles filter.

## Dimension values

- `DimAlarm`: **1 = Open**, **2 = Abandoned**
- `DimIncident`: **5 = Open**, **3 = Closed**, **7 = In Progress**
- `DimCategory`: AQ, SWM, WTR, ENG, IRR, SUR (Air Quality, Solid Waste, Water, Energy, Irrigation, Surveillance)
- `DimTenant`: the four Salem Corporation zones (Suramangalam, Hasthampatti, Ammapet, Kondalampatti)

## Tables

### DimTenant

| Column | Type | Notes |
|---|---|---|
| TenantID | int64 |  |
| TenantName | string |  |
| ZoneNumber | int64 |  |
| City | string |  |
| District | string |  |
| State | string |  |
| Wards | int64 |  |
| Population | int64 |  |
| AreaSqKm | double |  |

### DimCategory

| Column | Type | Notes |
|---|---|---|
| CategoryKey | int64 |  |
| DomainCode | string |  |
| DomainName | string |  |
| SortOrder | int64 | hidden key |
| Department | string |  |
| Description | string |  |
| ThemeColor | string |  |

### DimAlarm

| Column | Type | Notes |
|---|---|---|
| AlarmStatusID | int64 |  |
| AlarmStatus | string |  |
| Meaning | string |  |

### DimIncident

| Column | Type | Notes |
|---|---|---|
| IncidentStatusID | int64 |  |
| IncidentStatus | string |  |
| Meaning | string |  |

### FactAirQuality

| Column | Type | Notes |
|---|---|---|
| Date | dateTime | hidden key |
| TenantID | int64 | hidden key |
| CategoryKey | int64 | hidden key |
| StationName | string |  |
| PM25 | double |  |
| PM10 | double |  |
| NO2 | double |  |
| SO2 | double |  |
| CO | double |  |
| AQI | int64 |  |
| AQIBand | string |  |
| Temperature | double |  |
| Humidity | double |  |

### FactSWM

| Column | Type | Notes |
|---|---|---|
| Date | dateTime | hidden key |
| TenantID | int64 | hidden key |
| CategoryKey | int64 | hidden key |
| WasteType | string |  |
| VehiclesDeployed | int64 |  |
| PlannedPickups | int64 |  |
| CompletedPickups | int64 |  |
| WasteTonnes | double |  |
| ProcessedTonnes | double |  |
| AvgBinFillPct | double |  |
| SegregationPct | double |  |

### FactWater

| Column | Type | Notes |
|---|---|---|
| Date | dateTime | hidden key |
| TenantID | int64 | hidden key |
| CategoryKey | int64 | hidden key |
| SupplySource | string |  |
| SupplyKL | double |  |
| ConsumptionKL | double |  |
| LeakageKL | double |  |
| PressureBar | double |  |
| ChlorineMgL | double |  |
| TurbidityNTU | double |  |
| ReservoirLevelPct | double |  |
| QualityTestsDone | int64 |  |
| QualityTestsPassed | int64 |  |

### FactEnergy

| Column | Type | Notes |
|---|---|---|
| Date | dateTime | hidden key |
| TenantID | int64 | hidden key |
| CategoryKey | int64 | hidden key |
| ConsumerClass | string |  |
| ConsumptionKWh | double |  |
| SolarKWh | double |  |
| PeakDemandKW | double |  |
| PowerFactor | double |  |
| EnergyCostINR | double |  |
| LightsOn | int64 |  |
| LightsTotal | int64 |  |

### FactIrrigation

| Column | Type | Notes |
|---|---|---|
| Date | dateTime | hidden key |
| TenantID | int64 | hidden key |
| CategoryKey | int64 | hidden key |
| ZoneType | string |  |
| SoilMoisturePct | double |  |
| WaterUsedKL | double |  |
| ScheduledKL | double |  |
| RainfallMM | double |  |
| ValveRuntimeMin | int64 |  |
| ValvesActive | int64 |  |
| ValvesTotal | int64 |  |

### FactSurveillance

| Column | Type | Notes |
|---|---|---|
| Date | dateTime | hidden key |
| TenantID | int64 | hidden key |
| CategoryKey | int64 | hidden key |
| CameraType | string |  |
| CamerasTotal | int64 |  |
| CamerasOnline | int64 |  |
| EventsDetected | int64 |  |
| Violations | int64 |  |
| AlertsRaised | int64 |  |
| AvgResponseMin | double |  |

### FactAlarm

| Column | Type | Notes |
|---|---|---|
| Date | dateTime | hidden key |
| TenantID | int64 | hidden key |
| CategoryKey | int64 | hidden key |
| AlarmID | string |  |
| AlarmStatusID | int64 | hidden key |
| Severity | string |  |
| AlarmType | string |  |
| DeviceID | string |  |
| RaisedAt | dateTime |  |

### FactIncident

| Column | Type | Notes |
|---|---|---|
| Date | dateTime | hidden key |
| TenantID | int64 | hidden key |
| CategoryKey | int64 | hidden key |
| IncidentID | string |  |
| IncidentStatusID | int64 | hidden key |
| Priority | string |  |
| IncidentType | string |  |
| ResolutionHours | double |  |

### DimDate

Calculated in Power Query for 2026-01-01..2026-12-31: Date, Year, MonthNum, MonthName, YearMonth, MonthYear, DayName, WeekdayNum.

### _Measures

Hidden placeholder column; holds the access measures and the Overview card measures.
