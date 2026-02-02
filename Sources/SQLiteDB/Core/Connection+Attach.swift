import Foundation
import SQLCipher

extension Connection {
    /// See https://www.zetetic.net/sqlcipher/sqlcipher-api/#attach
    public func attach(_ location: Location, as schemaName: String, key: String? = nil) throws {
        if let key {
            try run("ATTACH DATABASE ? AS ? KEY ?", location.description, schemaName, key)
        } else {
            try run("ATTACH DATABASE ? AS ?", location.description, schemaName)
        }
    }

    /// See https://www3.sqlite.org/lang_detach.html
    public func detach(_ schemaName: String) throws {
        try run("DETACH DATABASE ?", schemaName)
    }
}
