//
//  Created by Mehmet Özdede on 10/05/2025.
//  Copyright © 2025 Mehmet Özdede. All rights reserved.
//

import Foundation

enum SWError: Int, Error {
    case urlError                = -6000
    case networkRequestFailed    = -6001
    case jsonSerializationFailed = -6002
    case jsonParsingFailed       = -6003
    case unableToFindLocation    = -6004
}

extension SWError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .urlError:
            return "The weather service URL is invalid."
        case .networkRequestFailed:
            return "The network appears to be down."
        case .jsonSerializationFailed:
            return "Unable to serialize weather data."
        case .jsonParsingFailed:
            return "Unable to parse weather data."
        case .unableToFindLocation:
            return "Unable to find your location."
        }
    }
}
