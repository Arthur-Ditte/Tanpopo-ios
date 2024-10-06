import SwiftUI
import AuthenticationServices
import Foundation

// MARK: - SignInViewModel

@MainActor
class SignInViewModel: NSObject, ObservableObject {
    // Published properties to communicate with the SwiftUI view
    @Published var mediaCollections: [String: Set<Int>] = [:]
    @Published var isSignedIn: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var presentationContextProvider = PresentationContextProvider()
    private var token: String = ""
    private var userId: Int = 0
    
    // Path to save the JSON file
    private var localFileURL: URL {
        let fileManager = FileManager.default
        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documents.appendingPathComponent("userData.json")
    }
    
    func signIn() {
        let apiData = AnilistAPIConfigurations.load()
        let authUrl = AnilistAuthenticationURLBuilder(clientID: apiData.id)()
        
        let authSession = ASWebAuthenticationSession(
            url: authUrl,
            callbackURLScheme: apiData.redirectURL
        ) { [weak self] callbackURL, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Authentication error: \(error.localizedDescription)"
                }
                return
            }
            
            guard let callbackURL = callbackURL else {
                DispatchQueue.main.async {
                    self.errorMessage = "No callback URL received."
                }
                return
            }
            
            print("Callback URL: \(callbackURL)")
            if let token = self.getToken(from: callbackURL.absoluteString) {
                print("Access Token: \(token)")
                Task {
                    await self.handleSignIn(with: token)
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Access Token not found."
                }
            }
        }
        
        authSession.presentationContextProvider = presentationContextProvider
        authSession.prefersEphemeralWebBrowserSession = true
        authSession.start()
    }
    
    private func getToken(from urlString: String) -> String? {
        // Convert the string to a URL
        guard let url = URL(string: urlString),
              let fragment = url.fragment else {
            return nil
        }
        
        let URLString = "tanpopo://auth?\(fragment)"
        guard let URL = URL(string: URLString),
              let components = URLComponents(url: URL, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else {
            return nil
        }
        
        // Extract the access token
        return queryItems.first(where: { $0.name == "access_token" })?.value
    }
    
    private func handleSignIn(with token: String) async {
        self.token = token
        self.errorMessage = nil
        
        do {
            // Fetch user info
            let viewer = try await fetchUserInfo(accessToken: token)
            guard let viewer = viewer else {
                throw NSError(domain: "SignInViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve user information."])
            }
            self.userId = viewer.id
            print("User ID: \(self.userId)")
            
            // Fetch media lists
            let service = AniListService(token: self.token, userId: self.userId)
            let collections = try await service.getMediaLists()
            self.mediaCollections = collections
            print("Media Collections: \(mediaCollections)")
            
            // Save data locally
            try saveDataLocally()
        } catch {
            self.errorMessage = error.localizedDescription
            print("Error during sign-in process: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Fetch User Info
    
    func fetchUserInfo(accessToken: String) async throws -> Viewer? {
        let userInfoUrl = URL(string: "https://graphql.anilist.co")!
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
        
        print("request")
        var request = URLRequest(url: userInfoUrl)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("json")
        let json: [String: Any] = ["query": query]
        let jsonData = try JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            let message = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
            throw NSError(domain: "FetchUserInfo", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: message])
        }
        
        let decoder = JSONDecoder()
        let graphqlResponse = try decoder.decode(GraphQLUserResponse.self, from: data)
        print(graphqlResponse)
        
        if let errors = graphqlResponse.errors, !errors.isEmpty {
            let errorMessages = errors.map { $0.message }.joined(separator: ", ")
            throw NSError(domain: "FetchUserInfo", code: 1, userInfo: [NSLocalizedDescriptionKey: "GraphQL errors: \(errorMessages)"])
        }
        
        return graphqlResponse.data?.viewer
    }
    
    // MARK: - Save Data Locally
    
    private func saveDataLocally() throws {
        let userData = UserData(token: self.token, userId: self.userId, mediaCollections: self.mediaCollections)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(userData)
        try data.write(to: localFileURL)
        print("Data saved to \(localFileURL)")
    }
    
    // MARK: - Load Data (Optional)
    
    func loadData() throws {
        let data = try Data(contentsOf: localFileURL)
        let decoder = JSONDecoder()
        let userData = try decoder.decode(UserData.self, from: data)
        self.token = userData.token
        self.userId = userData.userId
        self.mediaCollections = userData.mediaCollections
        self.isSignedIn = true
    }
}


// MARK: - User Data Models

struct UserData: Codable {
    let token: String
    let userId: Int
    let mediaCollections: [String: Set<Int>]
}

struct GraphQLUserResponse: Codable {
    let data: GraphQLUserData?
    let errors: [GraphQLError]?
}

struct GraphQLUserData: Codable {
    let viewer: Viewer?
}

struct Viewer: Codable {
    let id: Int
    let name: String
    let avatar: Avatar
    
    enum CodingKeys: String, CodingKey {
        case id, name, avatar
    }
}

struct Avatar: Codable {
    let large: String
}

// MARK: - GraphQL Response Models

struct GraphQLResponse: Codable {
    let data: MediaListCollectionData?
    let errors: [GraphQLError]?
}

struct MediaListCollectionData: Codable {
    let MediaListCollection: MediaListCollection?
}

struct MediaListCollection: Codable {
    let lists: [MediaListList]
}

struct MediaListList: Codable {
    let entries: [MediaListEntry]
}

struct MediaListEntry: Codable {
    let media: Media
}

struct Media: Codable {
    let id: Int
}

struct GraphQLError: Codable {
    let message: String
}

// MARK: - Media Status Enum

enum MediaStatus: String, CaseIterable, Codable {
    case current = "CURRENT"
    case repeating = "REPEATING"
    case completed = "COMPLETED"
    case planning = "PLANNING"
}

// MARK: - AniList Service

struct AniListService {
    private let graphqlURL = URL(string: "https://graphql.anilist.co")!
    private let token: String
    private let userId: Int
    
    init(token: String, userId: Int) {
        self.token = token
        self.userId = userId
    }
    
    func getMediaLists() async throws -> [String: Set<Int>] {
        var collections: [String: Set<Int>] = [:]
        
        for status in MediaStatus.allCases {
            let mediaIDs = try await fetchMediaIDs(for: status)
            collections[status.rawValue] = mediaIDs
            // Delay of 1 second between requests to respect rate limits
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        }
        
        return collections
    }
    
    private func fetchMediaIDs(for status: MediaStatus) async throws -> Set<Int> {
        // Define the GraphQL query
        let query = """
        query ($userId: Int, $type: MediaType, $status: MediaListStatus) {
          MediaListCollection(userId: $userId, type: $type, status: $status) {
            lists {
              entries {
                media {
                  id
                }
              }
            }
          }
        }
        """
        
        // Define the variables for the query
        let variables: [String: Any] = [
            "userId": userId,
            "type": "ANIME",
            "status": status.rawValue
        ]
        
        // Construct the request payload
        let payload: [String: Any] = [
            "query": query,
            "variables": variables
        ]
        
        // Serialize the payload to JSON
        let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
        
        // Create the URLRequest
        var request = URLRequest(url: graphqlURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        // Perform the network request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Check for HTTP errors
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            throw NSError(domain: "AniListService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Request failed with status code \(httpResponse.statusCode)"])
        }
        
        // Decode the JSON response
        let decoder = JSONDecoder()
        let graphqlResponse = try decoder.decode(GraphQLResponse.self, from: data)
        
        // Handle GraphQL errors
        if let errors = graphqlResponse.errors, !errors.isEmpty {
            let errorMessages = errors.map { $0.message }.joined(separator: ", ")
            throw NSError(domain: "AniListService", code: 1, userInfo: [NSLocalizedDescriptionKey: "GraphQL errors: \(errorMessages)"])
        }
        
        // Extract media IDs
        guard let mediaLists = graphqlResponse.data?.MediaListCollection?.lists else {
            return []
        }
        
        let mediaIDs = mediaLists.flatMap { $0.entries.map { $0.media.id } }
        return Set(mediaIDs)
    }
}

// MARK: - SwiftUI View

struct MediaView: View {
    @StateObject private var signInViewModel = SignInViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if !signInViewModel.isSignedIn {
                    Button(action: {
                        signInViewModel.signIn()
                    }) {
                        Text("Sign In with AniList")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                } else {
                    if signInViewModel.isLoading {
                        ProgressView("Fetching Media Lists...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
                    } else if let error = signInViewModel.errorMessage {
                        Text("Error: \(error)")
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        List {
                            ForEach(signInViewModel.mediaCollections.keys.sorted(), id: \.self) { status in
                                Section(header: Text(status.capitalized)) {
                                    if let mediaIDs = signInViewModel.mediaCollections[status] {
                                        ForEach(Array(mediaIDs).sorted(), id: \.self) { mediaID in
                                            Text("Media ID: \(mediaID)")
                                        }
                                    } else {
                                        Text("No media found.")
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("AniList Media Lists")
            .onAppear {
                // Optionally, load data if already saved
                do {
                    try signInViewModel.loadData()
                } catch {
                    print("No saved data found or failed to load: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - Preview

struct MediaView_Previews: PreviewProvider {
    static var previews: some View {
        MediaView()
    }
}


