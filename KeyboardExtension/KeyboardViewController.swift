import UIKit
import CoreText

final class KeyboardViewController: UIInputViewController {
    private var isRussian = true
    private var isUppercase = true

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

        let rows = isRussian ? russianRows : englishRows
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
        let numbers = makeKey("123")
        numbers.widthAnchor.constraint(equalToConstant: 48).isActive = true
        bottom.addArrangedSubview(numbers)
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
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont(name: "Milky Nice", size: title.count > 2 ? 14 : 22)
            ?? UIFont.systemFont(ofSize: title.count > 2 ? 14 : 22)
        let special = ["⇧", "⌫", "🌐 EN", "🌐 RU", "123", "ввод"]
        button.backgroundColor = special.contains(title)
            ? UIColor(red: 0.69, green: 0.72, blue: 0.77, alpha: 1) : .white
        button.layer.cornerRadius = 5
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.12
        button.layer.shadowRadius = 0.5
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
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
        case "пробел":
            textDocumentProxy.insertText(" ")
        case "ввод":
            textDocumentProxy.insertText("\n")
        case "123":
            // Цифровой и символьный слой пока не реализован.
            break
        case ".":
            textDocumentProxy.insertText(".")
        default:
            textDocumentProxy.insertText(isUppercase ? key : key.lowercased())
            if isUppercase {
                isUppercase = false
                buildKeyboard()
            }
        }
    }
}
