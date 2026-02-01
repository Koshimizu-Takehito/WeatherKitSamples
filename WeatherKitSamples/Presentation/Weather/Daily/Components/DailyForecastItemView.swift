import SwiftUI

// MARK: - DailyForecastItemView

/// 日別予報の1行分を表示するコンポーネント
struct DailyForecastItemView {
    let forecast: DailyForecastEntity
    let temperatureRange: ClosedRange<Double>

    private static let dayOfWeekFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "E"
        return formatter
    }()
}

// MARK: View

extension DailyForecastItemView: View {
    var body: some View {
        HStack(spacing: 12) {
            Text(dayOfWeekString)
                .font(.callout)
                .frame(width: 40, alignment: .leading)

            Image(systemName: forecast.symbolName)
                .symbolRenderingMode(.multicolor)
                .font(.title3)
                .frame(width: 30)

            if forecast.precipitationChance > 0 {
                Text(precipitationChanceString)
                    .font(.caption)
                    .foregroundStyle(.cyan)
                    .frame(width: 35)
            } else {
                Spacer()
                    .frame(width: 35)
            }

            Text(lowTemperatureString)
                .font(.callout)
                .foregroundStyle(.secondary)
                .frame(width: 45, alignment: .trailing)

            temperatureBar
                .frame(height: 6)

            Text(highTemperatureString)
                .font(.callout)
                .fontWeight(.medium)
                .frame(width: 45, alignment: .leading)
        }
        .padding(.vertical, 10)
    }

    // MARK: - Private Views

    private var temperatureBar: some View {
        GeometryReader { geometry in
            let range = temperatureRange.upperBound - temperatureRange.lowerBound
            let lowPercent = (forecast.lowTemperature - temperatureRange.lowerBound) / range
            let highPercent = (forecast.highTemperature - temperatureRange.lowerBound) / range

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(.gray.opacity(0.3))

                RoundedRectangle(cornerRadius: 3)
                    .fill(
                        LinearGradient(
                            colors: [.cyan, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * (highPercent - lowPercent))
                    .offset(x: geometry.size.width * lowPercent)
            }
        }
    }

    // MARK: - Private Computed Properties

    private var dayOfWeekString: String {
        if Calendar.current.isDateInToday(forecast.date) {
            "今日"
        } else if Calendar.current.isDateInTomorrow(forecast.date) {
            "明日"
        } else {
            Self.dayOfWeekFormatter.string(from: forecast.date)
        }
    }

    private var lowTemperatureString: String {
        String(format: "%.0f°", forecast.lowTemperature)
    }

    private var highTemperatureString: String {
        String(format: "%.0f°", forecast.highTemperature)
    }

    private var precipitationChanceString: String {
        String(format: "%.0f%%", forecast.precipitationChance * 100)
    }
}
