import SwiftUI

@main
struct MilkyNiceKeyboardApp: App {
    var body: some Scene {
        WindowGroup {
            VStack(spacing: 14) {
                Text("Milky Nice Keyboard")
                    .font(.title2.bold())
                Text("Чтобы включить клавиатуру, откройте Настройки → Основные → Клавиатура → Клавиатуры → Новые клавиатуры и выберите Milky Nice.")
                    .multilineTextAlignment(.center)
                Text("Шрифт меняет только буквы на клавишах. Вводимый текст остаётся обычным.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
    }
}
