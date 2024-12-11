import XCTest
@testable import ATKit

final class ATKitTests: XCTestCase {
    let plainText = "f2618ae1-ef50-49d8-bbdc-650541dc68ab"
    
    let privateKey1024 = "-----BEGIN RSA PRIVATE KEY-----\nMIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBAL80/I4ko0X/anshK+ZVBOlVmKGZgIl5TdYN3zfWoS9wIklYzPfs9fPek+ldHpC0FUkXpfJmzFVDZnHPo243ggRDYO9jNx4KD3W4Jr2kBffh7O9eMctbVUBTHameIeJ+V0UG5upqoInjAdt2+XJnyZ3Op70wznqIuz6JWkhgb7TlAgMBAAECgYARFunJxJGJRJJeTfEwBYJKXpmlO+SGpP5ldtjwEzFV3ZZa6uJq+FVlRgv/TBDayxWp8kClQTXbGwqReob3Z2Op2SiyxAQmQVo49zBWih6VXcfSlVVMaIqOUN7vYiDNn/scNrHYxFMMcGtn48b0CHt93t9jH2hajmN4XlP5KzOqMQJBAMlsv5WeUXdbcAle8DU3YzEos2pM7iNKzFUhpcVwNxAxYG0nhiOg3tY2m+MQOW3Es4bmgW1ccmYglhLuggg0K60CQQDzA4ItUFMu7SyKQIE2un/IpJN8f4CjOmGpRhrrdP8cvOJQiik/KWqb3i5I2urmrcZGCgB8sEpnFpJE+eFvE1UZAkEAvvD2FLFF7O2jIV78OpZM05cPrV9MB+yqErGY4bdkm1cTX6YuBKxFUa/myrLgnevve5wbaT5Pu/x8B2pNndVG6QJBAKks8BsLqF0qz68PaOTowLy1ldc+DBeWNRbarzLrqA4hkIvxIvXNp2ILMr2VaaJdp4JqxBwJvkI1/G34Z3AkTUECQEPnBaAuaYtruck0VKLAXKkuMYoKWWzRsS0N/DAqeYPbjW+8zRmk+8gY81CcUy7DWdoow/4QVgp4iDUcRbK3SaU=\n-----END RSA PRIVATE KEY-----"
    let publicKey1024 = "-----BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC/NPyOJKNF/2p7ISvmVQTpVZihmYCJeU3WDd831qEvcCJJWMz37PXz3pPpXR6QtBVJF6XyZsxVQ2Zxz6NuN4IEQ2DvYzceCg91uCa9pAX34ezvXjHLW1VAUx2pniHifldFBubqaqCJ4wHbdvlyZ8mdzqe9MM56iLs+iVpIYG+05QIDAQAB\n-----END PUBLIC KEY-----"
    
    let privateKey2048 = "-----BEGIN RSA PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDzpAqej2uxbvHRAMliBMYNahZWfsctNcec3Ji9bxV3qt2AzcijQVh/F+fDo8JiqThvG0OO+/XhwmdEqPXbufVMB7TnwUQtuKnD8v/cNEd5NS1kCNjK8OOPBeALpLOSLxIvT5eYGhXkVNf05o0anzxguiDCkD1fpKow/mEvvoFLRzm68R2A9hKPmIpwU+u+jhOC2hXnzhIxIv3iUKoWAZhVuUV8tuHcfvr6r+Bh8flbFRUl10UngHihtKoBF39W8dMVcpt7KglRB9o3P8UIGjl00EHE4ADXdhzmS33UKntaWF9D6jY6bMJUbvFKWjNWy5B3yBv+K3IYiJuEsKgurRHRAgMBAAECggEAFxzDqSD/3Vgh9mq1r+e2BgW/Urs6F87XPckrcCT+i1iZJKPg2aPUSlIxOTzqrsNQyDF06jZ6r8zqUPgaQprUaz776VRLLG8tI5qErRYEhboGsUupjS7m12V+SHx6UG7IsdZCEjq/QubNibzpO9JJPv/JJcvbFpyfTICFJatTxpkuvUS1OE4uJcMe8WcBzoU+huNC1lciKHmvsZgGG0Vuk9qq7vdB1r5Bsk5++G/DfizT2FcfMAdcqpka/N6tB0F9FHaAyP7ASi/U/YXEezCLD1QIBXiNPkIdHG9hDQWyktvXnBl4tehjlToB4ZUt4b3xZXLlJ0W2tAP/aU/hQgqPxQKBgQD7xJ678O3P4dYuV0SysG04SDvwsuVTwMTlGWtILTy+XC6U0zhTB4u+3Et9IfaHyRB/mBOuN1HpyP4+m57qFqMcvcYzOWg5SmOd2yCKrxjfchWtDXBpuI69dfjk87mUKHcMP9fvVcgMBgk7s5wgb3Wqqs9fB0twAxMFdQwA5m7JnwKBgQD3vHL5N+/yd66l3cQbTam6Z7c71FltDBth54CiN1q+VTvYFX6wg9OiNyxK6rb371APwuzo9Rm8GicjoAoGnY2TjK+b33HLC8ihGzyBQce775PcGPYrfaNqNGOqcWVZUNQWSBfX/JrEptz+8VSO5GDDRyIOM1Q2Ob+6p7MKxSROjwKBgAVjyS4m00B/CjHFxn+4zS3GRho6CjTHzK9G4wgRh9pfaNPgzbThVXmJh8gvAPMZN9QzckBpiMRjfCXk+Prz7xv/aA3SrcuELyvC9Chj5TlrXNFulzh8LfoaW3CzUwa78wh9GWdTQ8wWGP6BMtdy62by7yuOoWvNdQvJ3K7sP/TrAoGAWdxFaBjeNHktJIUYiT7WfgL49/7CoUdu90hd5HlntPp9xpelaKmoroKM0m/pBm4MAGuYO7gMKari341Blby4ifjSChw2zovrrmSOweP2azkvzPpQ8N2V1QRD0qNnO8qR47Mq0vGRwhs0tlUbculsH+lBdR0xQqoX3cDOtO1ligkCgYEA0kGlITgx8o777fswxaBsCSiaHSWzqRGTQDCYQQPNVeeo/F5Ts43AGpRiAOtAm8TvowjnCmaePbgmxu2wSmG3XG8rP+QCr5ZWoIVsEoPNvD4OSv2scfdmv9mrzeK/ByUqACu7PP+3HJ95yWyEdEG/D1+yjkKWpQzzKYJZr/1dJFw=\n-----END RSA PRIVATE KEY-----"
    let publicKey2048 = "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA86QKno9rsW7x0QDJYgTGDWoWVn7HLTXHnNyYvW8Vd6rdgM3Io0FYfxfnw6PCYqk4bxtDjvv14cJnRKj127n1TAe058FELbipw/L/3DRHeTUtZAjYyvDjjwXgC6Szki8SL0+XmBoV5FTX9OaNGp88YLogwpA9X6SqMP5hL76BS0c5uvEdgPYSj5iKcFPrvo4TgtoV584SMSL94lCqFgGYVblFfLbh3H76+q/gYfH5WxUVJddFJ4B4obSqARd/VvHTFXKbeyoJUQfaNz/FCBo5dNBBxOAA13Yc5kt91Cp7WlhfQ+o2OmzCVG7xSlozVsuQd8gb/ityGIibhLCoLq0R0QIDAQAB\n-----END PUBLIC KEY-----"
    
    
    func testAes() {
        do {
            let aPlainText = "abcd@1234"
            let aPasskey = "M4cRCrpu6LzXZWT0SS0mQUnZ4WIh2s99"
            let anInitializationVector: String? = "ABCDEFGHIJKLMNOP"
            
            let aCipher = try ATEncryptionManager.encryptAes(string: aPlainText, passKey: aPasskey, initializationVector: anInitializationVector, encoding: .base64)
            Swift.print("aCipher:", aCipher)
            
            let aDecipher = try ATEncryptionManager.decryptAes(string: aCipher, passKey: aPasskey, initializationVector: anInitializationVector, encoding: .base64)
            Swift.print("aDecipher:", aDecipher)
            
            XCTAssertEqual(aPlainText, aDecipher)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testRsaSignature() {
        do {
            var aSignature = try ATEncryptionManager.generateRsaSignature(string: self.plainText, privateKey: self.privateKey1024, encoding: .base64)
            XCTAssertEqual(aSignature, "t/5tEUOwA/2fW03TQ2jpjgaKBHprGM26gAW7QCD+w7sfaqbVoO5Gx0rEwBh1rPPxlIGJLhAZD7ISIFZ4Ych576gPMFANsg3lqdaxWJiUEb3IDCInTSdp0NSmXiAkH2Ds9BsU336L2Noajn7C4d+dntgZQhGPST8Z4yJ8iIF+1rA=")
            
            aSignature = try ATEncryptionManager.generateRsaSignature(string: self.plainText, privateKey: self.privateKey1024, encoding: .hex)
            XCTAssertEqual(aSignature, "b7fe6d1143b003fd9f5b4dd34368e98e068a047a6b18cdba8005bb4020fec3bb1f6aa6d5a0ee46c74ac4c01875acf3f19481892e10190fb21220567861c879efa80f30500db20de5a9d6b158989411bdc80c22274d2769d0d4a65e20241f60ecf41b14df7e8bd8da1a8e7ec2e1df9d9ed81942118f493f19e3227c88817ed6b0")
            
            aSignature = try ATEncryptionManager.generateRsaSignature(string: self.plainText, privateKey: self.privateKey2048, encoding: .base64)
            XCTAssertEqual(aSignature, "H3RCHr4rHpsN9nSFHfzubxp/Lm6kDv2JXdWFXL5ZXcknLl9M60rLbR/vjIn4iCUoaKrBCxic4wp1UWCRakIDHDoumiY8cSdD53gMg3bdg6Ggg9RfacdrQA0mawQI/HIvL+BKtT/2/1foGO7Lwq6Z7k4MSKNL6z0V+Y/m2X5W3HR07SYqYU47ZseeXzQf3kiQ8JnG14v5cwFPVCDifUuvdwKcJDaJTxBhGeDOQeTOwa6zew18fv8bata/FgPMOQQnaNtBbzL6oPqns8zsAuALkugQKeEAS+o3dC6gzc+j5PBaJWdf3Tww2K+VDxooxFJeM8jwMblF9UqTaE51YVbnzQ==")
            
            aSignature = try ATEncryptionManager.generateRsaSignature(string: self.plainText, privateKey: self.privateKey2048, encoding: .hex)
            XCTAssertEqual(aSignature, "1f74421ebe2b1e9b0df674851dfcee6f1a7f2e6ea40efd895dd5855cbe595dc9272e5f4ceb4acb6d1fef8c89f888252868aac10b189ce30a755160916a42031c3a2e9a263c712743e7780c8376dd83a1a083d45f69c76b400d266b0408fc722f2fe04ab53ff6ff57e818eecbc2ae99ee4e0c48a34beb3d15f98fe6d97e56dc7474ed262a614e3b66c79e5f341fde4890f099c6d78bf973014f5420e27d4baf77029c2436894f106119e0ce41e4cec1aeb37b0d7c7eff1b6ad6bf1603cc39042768db416f32faa0faa7b3ccec02e00b92e81029e1004bea37742ea0cdcfa3e4f05a25675fdd3c30d8af950f1a28c4525e33c8f031b945f54a93684e756156e7cd")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testRsaEncryption() {
        do {
            var anEncryptedString = try ATEncryptionManager.encryptRsa(string: self.plainText, publicKey: self.publicKey1024)
            var aDecryptedString = try ATEncryptionManager.decryptRsa(base64EncodedString: anEncryptedString, privateKey: self.privateKey1024)
            XCTAssertEqual(aDecryptedString, self.plainText)
            
            anEncryptedString = try ATEncryptionManager.encryptRsa(data: self.plainText.data(using: .utf8)!, publicKey: self.publicKey2048)
            aDecryptedString = try ATEncryptionManager.decryptRsa(base64EncodedString: anEncryptedString, privateKey: self.privateKey2048)
            XCTAssertEqual(aDecryptedString, self.plainText)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
}
