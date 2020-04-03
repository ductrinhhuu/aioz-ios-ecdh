//
//  ViewController.swift
//  test-aioz
//
//  Created by Trieu Nguyen on 2/4/20.
//  Copyright © 2020 Trieu Nguyen. All rights reserved.
//

import UIKit
import Secp256k1Kit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBOutlet weak var textvk1: UITextField!
    @IBOutlet weak var textvk2: UITextField!
    @IBOutlet weak var textshared: UITextField!
    
    @IBAction func onTapGenerate(_ sender: Any) {
        
        let ctx = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN))
        
        let tfPrivkey1 = textvk1.text!
        let tfPrivkey2 = textvk2.text!

        let privkeyBuffer1 = Data(base64Encoded: tfPrivkey1)!
        let privkeyBuffer2 = Data(base64Encoded: tfPrivkey2)!
        
        let prKey1 = [UInt8](privkeyBuffer1)
        let prKey2 = [UInt8](privkeyBuffer2)
        
        var pbKey1 = secp256k1_pubkey()
        let _ = secp256k1_ec_pubkey_create(ctx!, &pbKey1, prKey1)
        
        var pbKey2 = secp256k1_pubkey()
        let _ = secp256k1_ec_pubkey_create(ctx!, &pbKey2, prKey2)

        let sharedSecretLength = 32
        let sharedSecret1 = UnsafeMutablePointer<UInt8>
            .allocate(capacity: sharedSecretLength)
        let sharedSecret2 = UnsafeMutablePointer<UInt8>
        .allocate(capacity: sharedSecretLength)

        let status1 = secp256k1_ecdh(ctx!, sharedSecret1, &pbKey2, prKey1, customSecp256k1Func, nil)
        assert(status1 == 1)
        
        let status2 = secp256k1_ecdh(ctx!, sharedSecret2, &pbKey1, prKey2, customSecp256k1Func, nil)
        assert(status2 == 1)
        
        var sharedSecretBytes1: [UInt8] = []
        for i in 0..<sharedSecretLength {
            sharedSecretBytes1.append(sharedSecret1[i])
        }
        var sharedSecretBytes2: [UInt8] = []
        for i in 0..<sharedSecretLength {
            sharedSecretBytes2.append(sharedSecret2[i])
        }

        let sharedSecretStr1 = sharedSecretBytes1
            .map { String(format: "%02hhx", $0) }
            .joined()
//        print("Shared secret 1: \(sharedSecretStr1)")
        
        let sharedSecretStr2 = sharedSecretBytes2
            .map { String(format: "%02hhx", $0) }
            .joined()
//        print("Shared secret 2: \(sharedSecretStr2)")
        
        assert(sharedSecretStr1 == sharedSecretStr2)
        textshared.text = sharedSecretStr1
    }
    
}

func customSecp256k1Func(out: Optional<UnsafeMutablePointer<UInt8>>,
x: Optional<UnsafePointer<UInt8>>,
y: Optional<UnsafePointer<UInt8>>,
data: Optional<UnsafeMutableRawPointer>) -> Int32 {
    var xx = [UInt8]()
    var yy = [UInt8]()
    for i in 0..<32 {
        xx.append(x.unsafelyUnwrapped[i])
        yy.append(y.unsafelyUnwrapped[i])
    }
    out?.assign(from: xx, count: xx.count)
    return 1
}
