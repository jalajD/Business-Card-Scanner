import Foundation

struct BusinessCardData {
    var name: String?
    var company: String?
    var jobTitle: String?
    var email: String?
    var phone: String?
    var address: String?
    var website: String?
}

class BusinessCardParser {
    static let shared = BusinessCardParser()

    private init() {}

    func parse(text: String) -> BusinessCardData {
        var cardData = BusinessCardData()

        let lines = text.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }

        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)

            if cardData.email == nil, let email = extractEmail(from: trimmedLine) {
                cardData.email = email
            }

            if cardData.phone == nil, let phone = extractPhone(from: trimmedLine) {
                cardData.phone = phone
            }

            if cardData.website == nil, let website = extractWebsite(from: trimmedLine) {
                cardData.website = website
            }
        }

        let nonContactLines = lines.filter { line in
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            return extractEmail(from: trimmedLine) == nil &&
                   extractPhone(from: trimmedLine) == nil &&
                   extractWebsite(from: trimmedLine) == nil
        }

        if !nonContactLines.isEmpty {
            cardData.name = nonContactLines[0].trimmingCharacters(in: .whitespaces)
        }

        if nonContactLines.count > 1 {
            let secondLine = nonContactLines[1].trimmingCharacters(in: .whitespaces)
            if isLikelyJobTitle(secondLine) {
                cardData.jobTitle = secondLine
                if nonContactLines.count > 2 {
                    cardData.company = nonContactLines[2].trimmingCharacters(in: .whitespaces)
                }
            } else {
                cardData.company = secondLine
                if nonContactLines.count > 2 {
                    cardData.jobTitle = nonContactLines[2].trimmingCharacters(in: .whitespaces)
                }
            }
        }

        let addressLines = nonContactLines.dropFirst(min(3, nonContactLines.count))
        if !addressLines.isEmpty {
            cardData.address = addressLines.joined(separator: ", ")
        }

        return cardData
    }

    private func extractEmail(from text: String) -> String? {
        let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        guard let regex = try? NSRegularExpression(pattern: emailPattern, options: []) else { return nil }
        let range = NSRange(text.startIndex..., in: text)
        guard let match = regex.firstMatch(in: text, options: [], range: range) else { return nil }
        guard let matchRange = Range(match.range, in: text) else { return nil }
        return String(text[matchRange])
    }

    private func extractPhone(from text: String) -> String? {
        let phonePatterns = [
            "\\+?[0-9]{1,3}[\\s.-]?\\(?[0-9]{3}\\)?[\\s.-]?[0-9]{3}[\\s.-]?[0-9]{4}",
            "\\(?[0-9]{3}\\)?[\\s.-]?[0-9]{3}[\\s.-]?[0-9]{4}",
            "[0-9]{3}[\\s.-]?[0-9]{3}[\\s.-]?[0-9]{4}"
        ]

        for pattern in phonePatterns {
            guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { continue }
            let range = NSRange(text.startIndex..., in: text)
            if let match = regex.firstMatch(in: text, options: [], range: range),
               let matchRange = Range(match.range, in: text) {
                return String(text[matchRange])
            }
        }
        return nil
    }

    private func extractWebsite(from text: String) -> String? {
        let websitePattern = "(https?://)?(www\\.)?[-a-zA-Z0-9@:%._\\+~#=]{1,256}\\.[a-zA-Z0-9()]{1,6}\\b([-a-zA-Z0-9()@:%_\\+.~#?&//=]*)"
        guard let regex = try? NSRegularExpression(pattern: websitePattern, options: []) else { return nil }
        let range = NSRange(text.startIndex..., in: text)

        let lowercaseText = text.lowercased()
        if lowercaseText.contains("www.") || lowercaseText.contains("http") || lowercaseText.hasSuffix(".com") || lowercaseText.hasSuffix(".net") || lowercaseText.hasSuffix(".org") {
            if let match = regex.firstMatch(in: text, options: [], range: range),
               let matchRange = Range(match.range, in: text) {
                return String(text[matchRange])
            }
        }
        return nil
    }

    private func isLikelyJobTitle(_ text: String) -> Bool {
        let jobTitleKeywords = ["manager", "director", "engineer", "developer", "designer", "ceo", "cto", "cfo", "president", "vice president", "vp", "head", "lead", "senior", "junior", "assistant", "coordinator", "specialist", "consultant", "analyst", "architect"]
        let lowercaseText = text.lowercased()
        return jobTitleKeywords.contains { lowercaseText.contains($0) }
    }
}
