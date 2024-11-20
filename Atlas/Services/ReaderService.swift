import Foundation
import Get

protocol ReaderService {
    func content(of url: String) async throws -> ReaderResponse
}

struct JinaReaderService: ReaderService {
    let client = APIClient(baseURL: URL(string: "https://r.jina.ai/"))

    func content(of url: String) async throws -> ReaderResponse {
        var request = Request<ReaderResponse>(
            path: "",
            method: .post,
            headers: [
                "Authorization": "",
                "Accept": "application/json",
                "Content-Type": "application/json"
            ]
        )
        request.body = ReaderRequest(url: url)

        let response = try await client.send(request)
        return response.value
    }
}

struct JinaReaderWithCertificateService: ReaderService {
    let client = APIClient(baseURL: URL(string: "https://r.jina.ai/")) {
        $0.sessionDelegate = SessionDelegate()
    }

    func content(of url: String) async throws -> ReaderResponse {
        var request = Request<ReaderResponse>(
            path: "",
            method: .post,
            headers: [
                "Authorization": "",
                "Accept": "application/json",
                "Content-Type": "application/json"
            ]
        )
        request.body = ReaderRequest(url: url)

        let response = try await client.send(request)

        return response.value
    }

}

final class SessionDelegate: NSObject, URLSessionDataDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        print("URL:", task.originalRequest?.url?.absoluteString ?? "nil")

        return await checkPublicKey(challenge, pathToPublicKey: Bundle.main.path(forResource: "r-jina-ai-publickey", ofType: "der"))
//        return await checkCertificate(challenge, pathToCert: Bundle.main.path(forResource: "r-jina-ai", ofType: "cer"))
    }

    private func checkPublicKey(_ challenge: URLAuthenticationChallenge, pathToPublicKey: String?) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust,
              SecTrustGetCertificateCount(serverTrust) > 0 else {
            return (.cancelAuthenticationChallenge, nil)
        }

        // Hole das erste Zertifikat
        let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0)

        // Hole den öffentlichen Schlüssel aus dem Zertifikat
        guard let serverPublicKey = SecCertificateCopyKey(serverCertificate!),
              let serverPublicKeyData = SecKeyCopyExternalRepresentation(serverPublicKey, nil) as Data? else {
            return (.cancelAuthenticationChallenge, nil)
        }

        guard let pathToPublicKey,
              let expectedPublicKey = try? Data(contentsOf: URL(fileURLWithPath: pathToPublicKey)) else {
            return (.cancelAuthenticationChallenge, nil)
        }

        print("Expected Key Length: \(expectedPublicKey.count)")
        print("Server Key Length: \(serverPublicKeyData.count)")
        
        print("Expected Key: \(expectedPublicKey.base64EncodedString())")
        print("Server Key: \(serverPublicKeyData.base64EncodedString())")

        // Überprüfe, ob der empfangene Public Key mit dem gespeicherten übereinstimmt
        if serverPublicKeyData == expectedPublicKey {
            let credential = URLCredential(trust: serverTrust)
            return (.useCredential, credential)
        } else {
            return (.cancelAuthenticationChallenge, nil)
        }
    }

    private func checkCertificate(_ challenge: URLAuthenticationChallenge, pathToCert: String?) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust,
              let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
            return (.cancelAuthenticationChallenge, nil)
        }

        guard let pathToCert,
              let localCertificateData = try? Data(contentsOf: URL(fileURLWithPath: pathToCert)) else {
            return (.cancelAuthenticationChallenge, nil)
        }

        let serverCertificateData = SecCertificateCopyData(serverCertificate) as Data

        guard serverCertificateData == localCertificateData else {
            return (.cancelAuthenticationChallenge, nil)
        }

        // Zertifikate stimmen überein
        let credential = URLCredential(trust: serverTrust)
        return (.useCredential, credential)
    }
}

struct ReaderRequest: Encodable {
    let url: String
}

struct ReaderResponse: Decodable {
    struct Data: Decodable {
        let title: String
        let description: String
        let url: String
        let content: String
        let usage: Usage
    }

    struct Usage: Decodable {
        let tokens: Int
    }

    let code: Int
    let status: Int
    let data: Data
}
