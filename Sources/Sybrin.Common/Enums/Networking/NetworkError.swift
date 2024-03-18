//
//  NetworkError.swift
//  Sybrin.iOS.Common
//
//  Created by Nico Celliers on 2020/08/14.
//  Copyright © 2020 Sybrin Systems. All rights reserved.
//

public enum NetworkError: String, Error {
    case BadRequest = "Bad Request"
    case Error = "Error Received"
    case NilResponse = "Response was nil"
    case IncorrectResponseCode = "Incorrect Response Code"
    case NilData = "Data was nil"
    case Parsing = "Could not parse the response"
    case Undetermined = "Undetermined Error"
}
