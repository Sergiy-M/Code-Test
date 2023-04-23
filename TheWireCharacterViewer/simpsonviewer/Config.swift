import Foundation

public class Config {
    static let simpsonsApiUrl = "https://api.duckduckgo.com/?q=simpsons+characters&format=json"
    static let wireApiUrl = "https://api.duckduckgo.com/?q=the+wire+characters&format=json"
    
    static let simpsonsTitle = "Simpsons Characters"
    static let wireTitle = "Wire Characters"
    
    let title: String
    let apiUrl: String
    var isSimpsonCharacters: Bool
    
    init(isSimpsonCharacters: Bool) {
        self.isSimpsonCharacters = isSimpsonCharacters
        self.title = isSimpsonCharacters ? Self.simpsonsTitle : Self.wireTitle
        self.apiUrl = isSimpsonCharacters ? Self.simpsonsApiUrl : Self.wireApiUrl
    }
    
    
    public static var sharedConfig: Config = {
        // Set the config based on the dedicated Info.plist parameter
        let isSimpsons = Bundle.main.object(forInfoDictionaryKey: "SimpsonsCharacters") as? Bool
        let config = Config(isSimpsonCharacters: isSimpsons ?? true)
        return config
     }()
    
}
