# DAX measures

Measures in the semantic model. Percent/ratio measures use `DIVIDE`.

## FactAirQuality

| Measure | DAX | Format |
|---|---|---|
| Avg AQI | `AVERAGE(FactAirQuality[AQI])` | `0` |
| Max AQI | `MAX(FactAirQuality[AQI])` | `0` |
| Avg PM2.5 | `AVERAGE(FactAirQuality[PM25])` | `0.0` |
| Avg PM10 | `AVERAGE(FactAirQuality[PM10])` | `0.0` |
| Avg NO2 | `AVERAGE(FactAirQuality[NO2])` | `0.0` |
| Avg SO2 | `AVERAGE(FactAirQuality[SO2])` | `0.0` |
| Avg Temperature | `AVERAGE(FactAirQuality[Temperature])` | `0.0` |
| Avg Humidity | `AVERAGE(FactAirQuality[Humidity])` | `0.0` |
| Readings | `COUNTROWS(FactAirQuality)` | `#,0` |
| Stations Reporting | `DISTINCTCOUNT(FactAirQuality[StationName])` | `0` |
| Poor Air Readings % | `DIVIDE(CALCULATE(COUNTROWS(FactAirQuality), FactAirQuality[AQI] > 100), COUNTROWS(FactAirQuality))` | `0.0%` |

## FactSWM

| Measure | DAX | Format |
|---|---|---|
| Waste Collected (t) | `SUM(FactSWM[WasteTonnes])` | `#,0.0` |
| Waste Processed (t) | `SUM(FactSWM[ProcessedTonnes])` | `#,0.0` |
| Processing Rate % | `DIVIDE([Waste Processed (t)], [Waste Collected (t)])` | `0.0%` |
| Collection Efficiency % | `DIVIDE(SUM(FactSWM[CompletedPickups]), SUM(FactSWM[PlannedPickups]))` | `0.0%` |
| Pending Pickups | `SUM(FactSWM[PlannedPickups]) - SUM(FactSWM[CompletedPickups])` | `#,0` |
| Avg Bin Fill % | `DIVIDE(AVERAGE(FactSWM[AvgBinFillPct]), 100)` | `0.0%` |
| Segregation % | `DIVIDE(AVERAGE(FactSWM[SegregationPct]), 100)` | `0.0%` |
| Avg Vehicles Deployed | `AVERAGE(FactSWM[VehiclesDeployed])` | `0.0` |

## FactWater

| Measure | DAX | Format |
|---|---|---|
| Water Supplied (ML) | `DIVIDE(SUM(FactWater[SupplyKL]), 1000)` | `#,0.0` |
| Water Consumed (ML) | `DIVIDE(SUM(FactWater[ConsumptionKL]), 1000)` | `#,0.0` |
| Non-Revenue Water % | `DIVIDE(SUM(FactWater[SupplyKL]) - SUM(FactWater[ConsumptionKL]), SUM(FactWater[SupplyKL]))` | `0.0%` |
| Leakage (KL) | `SUM(FactWater[LeakageKL])` | `#,0` |
| Avg Pressure (bar) | `AVERAGE(FactWater[PressureBar])` | `0.00` |
| Avg Chlorine (mg/L) | `AVERAGE(FactWater[ChlorineMgL])` | `0.00` |
| Avg Turbidity (NTU) | `AVERAGE(FactWater[TurbidityNTU])` | `0.00` |
| Avg Reservoir Level % | `DIVIDE(AVERAGE(FactWater[ReservoirLevelPct]), 100)` | `0.0%` |
| Quality Compliance % | `DIVIDE(SUM(FactWater[QualityTestsPassed]), SUM(FactWater[QualityTestsDone]))` | `0.0%` |

## FactEnergy

| Measure | DAX | Format |
|---|---|---|
| Energy Consumed (MWh) | `DIVIDE(SUM(FactEnergy[ConsumptionKWh]), 1000)` | `#,0.0` |
| Solar Generated (MWh) | `DIVIDE(SUM(FactEnergy[SolarKWh]), 1000)` | `#,0.0` |
| Solar Share % | `DIVIDE(SUM(FactEnergy[SolarKWh]), SUM(FactEnergy[ConsumptionKWh]))` | `0.0%` |
| Peak Demand (MW) | `DIVIDE(MAX(FactEnergy[PeakDemandKW]), 1000)` | `0.00` |
| Avg Power Factor | `AVERAGE(FactEnergy[PowerFactor])` | `0.000` |
| Energy Cost (INR Lakh) | `DIVIDE(SUM(FactEnergy[EnergyCostINR]), 100000)` | `#,0.0` |
| Street Lights On % | `DIVIDE(SUM(FactEnergy[LightsOn]), SUM(FactEnergy[LightsTotal]))` | `0.0%` |

## FactIrrigation

| Measure | DAX | Format |
|---|---|---|
| Avg Soil Moisture % | `DIVIDE(AVERAGE(FactIrrigation[SoilMoisturePct]), 100)` | `0.0%` |
| Water Used (KL) | `SUM(FactIrrigation[WaterUsedKL])` | `#,0` |
| Water Saved % | `DIVIDE(SUM(FactIrrigation[ScheduledKL]) - SUM(FactIrrigation[WaterUsedKL]), SUM(FactIrrigation[ScheduledKL]))` | `0.0%` |
| Avg Daily Rainfall (mm) | `AVERAGE(FactIrrigation[RainfallMM])` | `0.0` |
| Valve Runtime (hrs) | `DIVIDE(SUM(FactIrrigation[ValveRuntimeMin]), 60)` | `#,0` |
| Valves Active % | `DIVIDE(SUM(FactIrrigation[ValvesActive]), SUM(FactIrrigation[ValvesTotal]))` | `0.0%` |
| Stressed Zone-Days | `CALCULATE(COUNTROWS(FactIrrigation), FactIrrigation[SoilMoisturePct] < 30)` | `#,0` |

## FactSurveillance

| Measure | DAX | Format |
|---|---|---|
| Camera Uptime % | `DIVIDE(SUM(FactSurveillance[CamerasOnline]), SUM(FactSurveillance[CamerasTotal]))` | `0.0%` |
| Cameras Deployed | `DIVIDE(SUM(FactSurveillance[CamerasTotal]), DISTINCTCOUNT(FactSurveillance[Date]))` | `#,0` |
| Events Detected | `SUM(FactSurveillance[EventsDetected])` | `#,0` |
| Violations Detected | `SUM(FactSurveillance[Violations])` | `#,0` |
| Alerts Raised | `SUM(FactSurveillance[AlertsRaised])` | `#,0` |
| Avg Response (min) | `AVERAGE(FactSurveillance[AvgResponseMin])` | `0.0` |

## FactAlarm

| Measure | DAX | Format |
|---|---|---|
| Total Alarms | `COUNTROWS(FactAlarm)` | `#,0` |
| Open Alarms | `CALCULATE(COUNTROWS(FactAlarm), FactAlarm[AlarmStatusID] = 1)` | `#,0` |
| Abandoned Alarms | `CALCULATE(COUNTROWS(FactAlarm), FactAlarm[AlarmStatusID] = 2)` | `#,0` |
| Critical Open Alarms | `CALCULATE(COUNTROWS(FactAlarm), FactAlarm[AlarmStatusID] = 1, FactAlarm[Severity] = "Critical")` | `#,0` |
| Open Alarm % | `DIVIDE([Open Alarms], [Total Alarms])` | `0.0%` |

## FactIncident

| Measure | DAX | Format |
|---|---|---|
| Total Incidents | `COUNTROWS(FactIncident)` | `#,0` |
| Open Incidents | `CALCULATE(COUNTROWS(FactIncident), FactIncident[IncidentStatusID] = 5)` | `#,0` |
| In Progress Incidents | `CALCULATE(COUNTROWS(FactIncident), FactIncident[IncidentStatusID] = 7)` | `#,0` |
| Closed Incidents | `CALCULATE(COUNTROWS(FactIncident), FactIncident[IncidentStatusID] = 3)` | `#,0` |
| Closure Rate % | `DIVIDE([Closed Incidents], [Total Incidents])` | `0.0%` |
| Avg Resolution (hrs) | `AVERAGE(FactIncident[ResolutionHours])` | `0.0` |
| P1 Incidents | `CALCULATE(COUNTROWS(FactIncident), FactIncident[Priority] = "P1")` | `#,0` |

## _Measures (access + Overview)

| Measure | DAX |
|---|---|
| Visible Domains | `COUNTROWS(ALL(DimCategory))` |
| Is Manager View | `[Visible Domains] >= 6` |
| Access Message | `IF([Is Manager View], "Manager view ...", "Restricted ...")` |
| Total Open Alarms (City) | `IF([Is Manager View], [Open Alarms])` |
| Total Open Incidents (City) | `IF([Is Manager View], [Open Incidents] + [In Progress Incidents])` |
| OV <code> <KPI> (x24) | `IF([Is Manager View], CALCULATE([<KPI>], DimCategory[DomainCode] = "<code>"))` |

`ALL(DimCategory)` removes visual/slicer filters but **not** RLS filters, so it returns 6 rows for managers and 1 row for an operator.
