//
//  NetworkManager.swift
//  FallingWords
//
//  Created by Ankur Arya on 17/07/20.
//  Copyright © 2020 Ankur Arya. All rights reserved.
//

import Foundation
import RxSwift

protocol NetworkManagerType {
    func getRequest<ResponseType: Decodable>(path: EndPoint, parameters: [String: String]) -> Single<ResponseType>
}

class NetworkManager: NetworkManagerType {

    var task: URLSessionTask?
    let baseUrl: EndPoint
    var headers: [String: String] = [:]

    init(baseUrl: EndPoint, headers: [String: String] = [:]) {
        self.baseUrl = baseUrl
        self.headers["Content-Type"] = "application/json"
        for (key, value) in headers {
            self.headers[key] = value
        }
    }

    func getRequest<ResponseType: Decodable>(path: EndPoint, parameters: [String: String]) -> Single<ResponseType> {
        sendRequest(request: buildRequest(path: path, urlParameters: parameters))
    }

    func sendRequest<ResponseType: Decodable>(request: URLRequest) -> Single<ResponseType> {

        return  Single<ResponseType>.create { observer in
            let session = URLSession.shared
            self.task = session.dataTask(with: request, completionHandler: { data, response, apiError in

                if let err = apiError {
                    observer(.error(err))
                } else if let response = response as? HTTPURLResponse {
                    switch response.statusCode {
                    case 200...300:
                        guard let responseData = data else {
                            observer(.error(DataError.dataNotFound))
                            return
                        }
                        do {
                            let apiResponse = try JSONDecoder().decode(ResponseType.self, from: responseData)
                            observer(.success(apiResponse))
                        } catch {
                            observer(.error(DataError.unableToDecode))
                        }
                    default:
                        observer(.error(DataError.timeout))
                    }
                }
                observer(.error(DataError.dataNotFound))
            })
            self.task?.resume()
            return Disposables.create {
                self.task?.cancel()
            }
        }
    }

    func buildRequest(
        path: EndPoint,
        httpMethod: HTTPMethod = .get,
        urlParameters: [String: String] = [:],
        body: Encodable? = nil
    ) -> URLRequest {

        let url = URL(string: self.baseUrl.rawValue)!.appendingPathComponent(path.rawValue)
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = urlParameters.map {key, value in
            URLQueryItem(name: key,
                         value: value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
        }
        var request = URLRequest(url: (urlComponents?.url!)!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 60.0)

        request.httpMethod = httpMethod.rawValue
        request.allHTTPHeaderFields = headers
        return request
    }

    func cancel() {
        self.task?.cancel()
    }
}
