    import XCTest
    @testable import ATKit

    final class ATKitTests: XCTestCase {
        
        func testAes() {
            do {
                let aPlainText = "abcd@1234"
                let aPasskey = "M4cRCrpu6LzXZWT0SS0mQUnZ4WIh2s99"
                
                let aCipher = try ATEncryptionManager.shared.encryptAes(string: aPlainText, passKey: aPasskey, encoding: .hex)
                Swift.print("aCipher:", aCipher)
                
                let aDecipher = try ATEncryptionManager.shared.decryptAes(string: aCipher, passKey: aPasskey, encoding: .hex)
                Swift.print("aDecipher:", aDecipher)
                
                XCTAssertEqual(aPlainText, aDecipher)
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
        
    }
