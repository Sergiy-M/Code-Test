import Foundation

struct Record {
    let firstUrl: String?
    let iconUrl: String?
    let result: String?
    let text: String?
    
    func getFirstName() -> String {
        let firstName = text?.split(separator: " - ").first
        return String(firstName ?? "")
    }
}

struct Model {
    var records: [Record] = []
    
    static func extractViewModel(_ json: Any) -> Model{
        guard let topics = (json as? Dictionary<String, Any>)?["RelatedTopics"] as? [Any] else {
            return Model()
        }
        var records: [Record] = []
        
        for item in topics {
            guard let tempRecord = item as? Dictionary<String, Any> else { continue }
            let firstUrl = tempRecord["FirstURL"] as? String
            let result = tempRecord["Result"] as? String
            let text = tempRecord["Text"] as? String
            
            var iconUrl: String?
            if let iconData = tempRecord["Icon"] as? [String: String] {
                iconUrl = iconData["URL"]
            }
            
            let record = Record(firstUrl: firstUrl, iconUrl: iconUrl, result: result, text: text)
            records.append(record)
        }
        return Model(records: records)
    }
}
