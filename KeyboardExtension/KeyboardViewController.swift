import UIKit
import CoreText

final class KeyboardViewController: UIInputViewController {
    private enum Layer {
        case letters
        case numbers
        case symbols
    }

    private var isRussian = true
    private var isUppercase = true
    private var layer: Layer = .letters

    private let russianRows = [
        ["Й","Ц","У","К","Е","Н","Г","Ш","Щ","З","Х"],
        ["Ф","Ы","В","А","П","Р","О","Л","Д","Ж","Э"],
        ["⇧","Я","Ч","С","М","И","Т","Ь","Б","Ю","⌫"]
    ]
    private let englishRows = [
        ["Q","W","E","R","T","Y","U","I","O","P"],
        ["A","S","D","F","G","H","J","K","L"],
        ["⇧","Z","X","C","V","B","N","M","⌫"]
    ]
    private let numberRows = [
        ["1","2","3","4","5","6","7","8","9","0"],
        ["-","/",":",";","(",")","₽","&","@","\""],
        ["#+=",".",",","?","!","'","⌫"]
    ]
    private let symbolRows = [
        ["[","]","{","}","#","%","^","*","+","="],
        ["_","\\","|","~","<",">","€","£","¥","•"],
        ["123",".",",","?","!","'","⌫"]
    ]

    private let specialKeys: Set<String> = ["⇧", "⌫", "🌐 EN", "🌐 RU", "123", "#+=", "ABC", "АБВ", "ввод"]

    override func viewDidLoad() {
        super.viewDidLoad()
        registerBundledFont()
        view.backgroundColor = UIColor(red: 0.82, green: 0.84, blue: 0.87, alpha: 1)
        buildKeyboard()
    }

    private func registerBundledFont() {
        guard let url = Bundle.main.url(forResource: "Ultimate_milki_nice", withExtension: "ttf") else { return }
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
    }

    private func buildKeyboard() {
        view.subviews.forEach { $0.removeFromSuperview() }
        let root = UIStackView()
        root.axis = .vertical
        root.spacing = 8
        root.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(root)
        NSLayoutConstraint.activate([
            root.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4),
            root.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4),
            root.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            root.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8)
        ])

        let rows: [[String]]
        switch layer {
        case .letters: rows = isRussian ? russianRows : englishRows
        case .numbers: rows = numberRows
        case .symbols: rows = symbolRows
        }

        for row in rows {
            let stack = UIStackView()
            stack.axis = .horizontal
            stack.spacing = 4
            stack.distribution = .fillEqually
            for title in row { stack.addArrangedSubview(makeKey(title)) }
            root.addArrangedSubview(stack)
            stack.heightAnchor.constraint(equalToConstant: 42).isActive = true
        }

        let bottom = UIStackView()
        bottom.axis = .horizontal
        bottom.spacing = 4
        bottom.distribution = .fill
        let language = makeKey(isRussian ? "🌐 EN" : "🌐 RU")
        language.widthAnchor.constraint(equalToConstant: 62).isActive = true
        bottom.addArrangedSubview(language)

        // Кнопка переключения слоя: в буквенном слое открывает цифры, в остальных возвращает буквы.
        let layerTitle: String
        switch layer {
        case .letters: layerTitle = "123"
        case .numbers, .symbols: layerTitle = isRussian ? "АБВ" : "ABC"
        }
        let layerKey = makeKey(layerTitle)
        layerKey.widthAnchor.constraint(equalToConstant: 48).isActive = true
        bottom.addArrangedSubview(layerKey)

        bottom.addArrangedSubview(makeKey("пробел"))
        let period = makeKey(".")
        period.widthAnchor.constraint(equalToConstant: 42).isActive = true
        bottom.addArrangedSubview(period)
        let enter = makeKey("ввод")
        enter.widthAnchor.constraint(equalToConstant: 62).isActive = true
        bottom.addArrangedSubview(enter)
        root.addArrangedSubview(bottom)
        bottom.heightAnchor.constraint(equalToConstant: 42).isActive = true
    }

    private func makeKey(_ title: String) -> UIButton {
        let fontSize: CGFloat = title.count > 2 ? 14 : 22
        let font = UIFont(name: "Milky Nice", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
        let isSpecial = specialKeys.contains(title)

        let button: UIButton
        if #available(iOS 26.0, *) {
            // Стеклянный стиль Liquid Glass (собирается только Xcode 26+).
            var config = UIButton.Configuration.glass()
            var attributed = AttributedString(title)
            attributed.uiKit.font = font
            attributed.uiKit.foregroundColor = .black
            config.attributedTitle = attributed
            if isSpecial {
                config.baseBackgroundColor = UIColor(red: 0.69, green: 0.72, blue: 0.77, alpha: 1)
            }
            config.cornerStyle = .medium
            button = UIButton(configuration: config)
        } else {
            button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.titleLabel?.font = font
            button.backgroundColor = isSpecial
                ? UIColor(red: 0.69, green: 0.72, blue: 0.77, alpha: 1) : .white
            button.layer.cornerRadius = 5
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOpacity = 0.12
            button.layer.shadowRadius = 0.5
            button.layer.shadowOffset = CGSize(width: 0, height: 1)
        }

        button.addAction(UIAction { [weak self] _ in self?.handleKey(title) }, for: .touchUpInside)
        return button
    }

    private func handleKey(_ key: String) {
        switch key {
        case "⇧":
            isUppercase.toggle()
            buildKeyboard()
        case "⌫":
            textDocumentProxy.deleteBackward()
        case "🌐 EN", "🌐 RU":
            isRussian.toggle()
            buildKeyboard()
        case "123":
            layer = .numbers
            buildKeyboard()
        case "#+=":
            layer = .symbols
            buildKeyboard()
        case "ABC", "АБВ":
            layer = .letters
            buildKeyboard()
        case "пробел":
            textDocumentProxy.insertText(" ")
        case "ввод":
            textDocumentProxy.insertText("\n")
        default:
            if layer != .letters {
                textDocumentProxy.insertText(key)
                return
            }
            textDocumentProxy.insertText(isUppercase ? key : key.lowercased())
            if isUppercase {
                isUppercase = false
                buildKeyboard()
            }
        }
    }
}
