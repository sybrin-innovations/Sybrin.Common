//
//  ValidateLicenseLegacyResponseModel.swift
//  Sybrin.iOS.Common
//
//  Created by Nico Celliers on 2020/08/14.
//  Copyright © 2020 Sybrin Systems. All rights reserved.
//
// update

struct ValidateLicenseLegacyResponseModel: Codable {
    
    // MARK: Private Properties
    private enum CodingKeys: String, CodingKey { case Message = "message", ExecutionState = "executionState", StatusCode = "statusCode" }
    
    // MARK: Internal Properties
    var Message: String
    var ExecutionState: Int
    var StatusCode: Bool
    
    // MARK: Initializers
    init(from decoder: Decoder) throws {
        
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        
        self.Message = (try? keyedContainer.decode(String.self, forKey: CodingKeys.Message)) ?? ""
        self.ExecutionState = (try? keyedContainer.decode(Int.self, forKey: CodingKeys.ExecutionState)) ?? 0
        self.StatusCode = (try? keyedContainer.decode(Bool.self, forKey: CodingKeys.StatusCode)) ?? false
        
    }
    
}
