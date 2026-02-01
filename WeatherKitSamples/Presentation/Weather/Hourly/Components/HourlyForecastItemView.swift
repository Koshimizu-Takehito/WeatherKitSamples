import SwiftUI

// MARK: - HourlyForecastItemView

/// 時間別予報の1時間分を表示するコンポーネント
struct HourlyForecastItemView {
    let forecast: HourlyForecastEntity

    private static let hourFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "H時"
        return formatter
    }()
}

// MARK: View

extension HourlyForecastItemView: View {
    var body: some View {
        VStack(spacing: 8) {
            Text(hourString)
                .font(.caption)
                .foregroundStyle(.secondary)

            Image(systemName: forecast.symbolName)
                .symbolRenderingMode(.multicolor)
                .font(.title2)

            Text(temperatureString)
                .font(.callout)
                .fontWeight(.medium)

            if forecast.precipitationChance > 0 {
                Text(precipitationChanceString)
                    .font(.caption2)
                    .foregroundStyle(.cyan)
            }
        }
        .frame(width: 60)
    }

    // MARK: - Private Computed Properties

    private var hourString: String {
        Self.hourFormatter.string(from: forecast.date)
    }

    private var temperatureString: String {
        String(format: "%.0f°C", forecast.temperature)
    }

    private var precipitationChanceString: String {
        String(format: "%.0f%%", forecast.precipitationChance * 100)
    }
}
