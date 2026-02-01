# Swift Charts Showcase

An overview of the chart visualizations demonstrated in this project.

## Overview

WeatherKitSamples includes multiple chart implementations that showcase
different Swift Charts techniques for weather data visualization, plus
3D charts built with RealityKit.

## 2D Charts (Swift Charts)

### Hourly Temperature — ``HourlyTemperatureChartView``

| Technique | Description |
|-----------|-------------|
| `LineMark` | Primary temperature line |
| `AreaMark` | Gradient fill beneath the line |
| `PointMark` | Individual data point markers |
| Gradient styling | `foregroundStyle` with linear gradient |
| Temporal X-axis | `AxisMarks` with hourly date values |

### Daily Temperature Range — ``DailyTemperatureRangeChartView``

| Technique | Description |
|-----------|-------------|
| `BarMark` with `yStart`/`yEnd` | Range bars for high/low temperatures |
| `RuleMark` | Reference lines for average values |
| Date aggregation | `unit: .day` for daily grouping |
| Color interpolation | Gradient based on temperature values |

### Precipitation — ``PrecipitationChartView``

| Technique | Description |
|-----------|-------------|
| `BarMark` | Precipitation probability bars |
| Dual-axis | Combined temperature line and precipitation bars |
| Conditional styling | Color changes based on precipitation threshold |

## 3D Charts (RealityKit)

### Temperature Bar Chart — ``Temperature3DBarChartView``

Renders temperature data as 3D bars in a RealityKit scene with
interactive rotation gestures.

### Daily Temperature Line — ``DailyTemperature3DLineChartView``

Displays daily temperature trends as a 3D line path with depth
perspective.

### Temperature Surface — ``Temperature3DSurfaceChartView``

Creates a 3D surface mesh from temperature data with color
interpolation based on values.

### Weather Point Cloud — ``Weather3DPointChartView``

Visualizes multi-dimensional weather data as positioned and colored
3D points.

## Chart Data Types

- ``HourlyChartData``: Wraps ``HourlyForecastEntity`` for chart consumption.
- ``DailyChartData``: Wraps ``DailyForecastEntity`` for chart consumption.

Both types conform to `Identifiable` for use with `ForEach` and `Chart`.

## Further Reading

- [Swift Charts Documentation](https://developer.apple.com/documentation/charts)
- [Creating a chart using Swift Charts](https://developer.apple.com/documentation/charts/creating-a-chart-using-swift-charts)
- [Hello Swift Charts (WWDC22)](https://developer.apple.com/videos/play/wwdc2022/10136/)
