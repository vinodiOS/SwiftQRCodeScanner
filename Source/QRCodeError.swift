//
//  QRCodeError.swift
//  SwiftQRScanner
//
//  Created by Vinod Jagtap on 14/05/22.
//

import Foundation

public enum QRCodeError: Error {
    case inputFailed
    case outoutFailed
    case emptyResult
}

extension QRCodeError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .inputFailed:
            return "Failed to add input."
        case .outoutFailed:
            return "Failed to add output."
        case .emptyResult:
            return "Empty string found."
        }
    }
}

extension QRCodeError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .inputFailed:
            return NSLocalizedString(
                "Failed to add input.",
                comment: "Failed to add input."
            )
        case .outoutFailed:
            return NSLocalizedString(
                "Failed to add output.",
                comment: "Failed to add output."
            )
        case .emptyResult:
            return NSLocalizedString(
                "Empty string found.",
                comment: "Empty string found."
            )
        }
    }
}
