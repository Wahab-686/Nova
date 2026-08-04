//
//  CloudinaryManager.swift
//  Nova
//
//  Created by Wahab on 03/08/2026.
//

import Foundation
import UIKit

final class CloudinaryManager {
    static let shared = CloudinaryManager()
    private init() {}
    
    func uploadImage(_ image: UIImage) async throws -> String {
        
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            throw NSError(domain: "Cloudinary", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not process image"])
        }
        
        let uploadURL = "https://api.cloudinary.com/v1_1/\(Secrets.cloudinaryCloudName)/image/upload"
        guard let url = URL(string: uploadURL) else {
            throw NSError(domain: "Cloudinary", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid Cloudinary URL"])
        }
        
        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"upload_preset\"\r\n\r\n".data(using: .utf8)!)
        body.append("nova_unsigned\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"upload.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    throw NSError(domain: "Cloudinary", code: -1, userInfo: [NSLocalizedDescriptionKey: "Upload failed"])
                }

                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                guard let secureURL = json?["secure_url"] as? String else {
                    throw NSError(domain: "Cloudinary", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not get image URL from response"])
                }

                return secureURL
    }
}
