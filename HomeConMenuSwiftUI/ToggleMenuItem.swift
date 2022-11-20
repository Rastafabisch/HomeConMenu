//
//  PowerMenu.swift
//  macOSBridge
//
//  Created by Yuichi Yoshida on 2022/11/20.
//
//  MIT License
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Cocoa
import os

class ToggleMenuItem: NSMenuItem {//}, MenuItemFromUUID, ErrorMenuItem, MenuItemOrder {
    
    var orderPriority: Int {
        100
    }
    
    
    var reachable: Bool {
        didSet {
            if reachable {
                self.image = icon
            } else {
                self.image = NSImage(systemSymbolName: "exclamationmark.triangle", accessibilityDescription: nil)
            }
        }
    }
    
    func UUIDs() -> [UUID] {
        return characteristicIdentifiers
    }
    
    var icon: NSImage? {
        return NSImage(systemSymbolName: "powerplug", accessibilityDescription: nil)
    }
    
    func bind(with uniqueIdentifier: UUID) -> Bool {
        return characteristicIdentifiers.contains(where: { $0 == uniqueIdentifier })
    }
    
    let characteristicIdentifiers: [UUID]
//    var mac2ios: mac2iOS?
    
    @IBAction func toggle(sender: NSMenuItem) {
        guard let uuid = characteristicIdentifiers.first else { return }
        do {
//            let value = try self.mac2ios?.getCharacteristic(of: uuid)
//            if let boolValue = value as? Bool {
//                for uuid in characteristicIdentifiers {
//                    self.mac2ios?.setCharacteristic(of: uuid, object: !boolValue)
//                }
//            }
        } catch {
            Logger.app.error("\(error.localizedDescription)")
        }
    }
    
    func update(value: Bool) {
        reachable = true
        self.state = value ? .on : .off
    }
        
//    init?(serviceGroupInfo: ServiceGroupInfoProtocol, mac2ios: mac2iOS?) {
//
//        let characteristicInfos = serviceGroupInfo.services.map({ $0.characteristics }).flatMap({ $0 })
//
//        let infos = characteristicInfos.filter({ $0.type == .powerState })
//
//        guard infos.count > 0 else { return nil }
//
//        guard let sample = infos.first else { return nil}
//
//
//        let uuids = infos.map({$0.uniqueIdentifier})
//
//        self.reachable = true
//        self.mac2ios = mac2ios
//        self.characteristicIdentifiers = uuids
//        super.init(title: serviceGroupInfo.name, action: nil, keyEquivalent: "")
//
//        if let number = sample.value as? Int {
//            self.state = (number == 0) ? .off : .on
//        }
//        self.image = self.icon
//        self.action = #selector(self.toggle(sender:))
//        self.target = self
//    }
        
    init?(service: HCService) {
        guard let powerStateChara = service.characteristics.first(where: { obj in
            obj.type == .powerState
        }) else { return nil }
        self.reachable = true
        
        self.characteristicIdentifiers = [powerStateChara.uniqueIdentifier]
        super.init(title: service.serviceName, action: nil, keyEquivalent: "")
        
        if let number = powerStateChara.doubleValue {
            self.state = (number > 0) ? .on : .off
        }
        self.image = self.icon
        self.action = #selector(self.toggle(sender:))
        self.target = self
    }
    
    override init(title string: String, action selector: Selector?, keyEquivalent charCode: String) {
        self.characteristicIdentifiers = []
        self.reachable = true
        super.init(title: string, action: selector, keyEquivalent: charCode)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SwitchMenuItem: ToggleMenuItem {
    override var icon: NSImage? {
        return NSImage(systemSymbolName: "switch.2", accessibilityDescription: nil)
    }
}

class OutletMenuItem: ToggleMenuItem {
    override var icon: NSImage? {
        return NSImage(systemSymbolName: "powerplug", accessibilityDescription: nil)
    }
}
