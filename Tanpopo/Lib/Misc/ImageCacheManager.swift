class ImageCacheManager {
    static let shared = URLCache(memoryCapacity: 100 * 1024 * 1024, diskCapacity: 500 * 1024 * 1024)
    
    static func loadImage(from url: URL, completion: @escaping (Image?) -> Void) {
        let request = URLRequest(url: url)
        
        // Check if image is in cache
        if let cachedResponse = shared.cachedResponse(for: request),
           let image = cachedResponse.data.toImage() {
            completion(image)
            return
        }
        
        // If not cached, download the image
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, let response = response, let image = data.toImage(), error == nil else {
                completion(nil)
                return
            }
            
            // Cache the response
            let cachedData = CachedURLResponse(response: response, data: data)
            shared.storeCachedResponse(cachedData, for: request)
            
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
}