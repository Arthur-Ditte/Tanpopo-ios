import Foundation
import SafariServices

class AniListService: NSObject, SFSafariViewControllerDelegate {
    private let clientId = "21576"
    private let clientSecret = "n9SdIxNIIfmpGa9v22IjxLCV818xrajnLYYZNztx"
    private let redirectUri = "tanpopo://auth"
    private var safariVC: SFSafariViewController?
    
    override init() {
        super.init()
    }
    
    func getAuthorizationCode(from viewController: UIViewController) {
        let authURL = "https://anilist.co/api/v2/oauth/authorize?client_id=\(clientId)&redirect_uri=\(redirectUri)&response_type=code"
        if let url = URL(string: authURL) {
            safariVC = SFSafariViewController(url: url)
            safariVC?.delegate = self
            viewController.present(safariVC!, animated: true, completion: nil)
        }
    }
    
    func handleRedirect(url: URL) {
        if let code = extractAuthorizationCode(from: url) {
            exchangeCodeForToken(authorizationCode: code) { accessToken in
                if let token = accessToken {
                    self.getUserInfo(accessToken: token) { userInfo in
                        if let userInfo = userInfo {
                            self.saveUserInfo(userInfo: userInfo)
                        }
                    }
                }
            }
        }
    }

    private func extractAuthorizationCode(from url: URL) -> String? {
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems {
            for item in queryItems where item.name == "code" {
                return item.value
            }
        }
        return nil
    }

    func exchangeCodeForToken(authorizationCode: String, completion: @escaping (String?) -> Void) {
        guard let tokenURL = URL(string: "https://anilist.co/api/v2/oauth/token") else { return }
        
        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        let bodyData = [
            "client_id": clientId,
            "client_secret": clientSecret,
            "redirect_uri": redirectUri,
            "grant_type": "authorization_code",
            "code": authorizationCode
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: bodyData)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                completion(nil)
                return
            }
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let accessToken = json["access_token"] as? String {
                completion(accessToken)
            } else {
                completion(nil)
            }
        }.resume()
    }
    
    func getUserInfo(accessToken: String, completion: @escaping ([String: Any]?) -> Void) {
        let query = """
        query {
            Viewer {
                id
                name
                avatar {
                    large
                }
            }
        }
        """
        
        guard let url = URL(string: "https://graphql.anilist.co") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["query": query])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                completion(nil)
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String : Any],
               let viewerData = json["data"] as? [String : Any] {
                completion(viewerData["Viewer"] as? [String : Any])
            } else {
                completion(nil)
            }
        }.resume()
    }
    
    func saveUserInfo(userInfo: [String : Any]) {
        let defaults = UserDefaults.standard
        defaults.set(userInfo["id"], forKey: "user_id")
        defaults.set(userInfo["name"], forKey: "username")
        
        if let avatarDict = userInfo["avatar"] as? [String : Any],
           let avatarUrl = avatarDict["large"] as? String {
            defaults.set(avatarUrl, forKey: "avatar_url")
        }
        
        if let accessToken = userInfo["access_token"] as? String {
            defaults.set(accessToken, forKey: "access_token")
        }
    }

    func isLoggedIn() -> Bool {
        return UserDefaults.standard.string(forKey: "access_token") != nil
    }
}
