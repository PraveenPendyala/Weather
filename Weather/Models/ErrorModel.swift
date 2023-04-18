//
//  ErrorModel.swift
//  Weather
//
//  Created by Praveen on 4/17/23.
//

import Foundation

struct ErrorModel: Decodable {
    var cod     : String
    var message : String
}
