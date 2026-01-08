//
//  UIColor+Extensions.swift
//  Tracker
//
//  Created by Nikolay Zebolov on 03.01.2026.
//

import UIKit

extension UIColor {
    static var ypBlack: UIColor { UIColor(resource: .ypBlackIOS) }
    static var ypBackground: UIColor { UIColor(resource: .ypBackgroundIOS) }
    static var ypWhite: UIColor { UIColor(resource: .ypWhiteIOS) }
    static var ypBlue: UIColor { UIColor(resource: .ypBlueIOS) }
    static var ypRed: UIColor { UIColor(resource: .ypRedIOS) }
    static var ypGray: UIColor { UIColor(resource: .ypGrayIOS) }
    static var ypLightGray: UIColor { UIColor(resource: .ypLightGrayIOS) }
    static var colorSelected0: UIColor { UIColor(resource: .ypDateIOS) }
    static var colorSelected1: UIColor { UIColor(resource: .color1) }
    static var colorSelected2: UIColor { UIColor(resource: .color2) }
    static var colorSelected3: UIColor { UIColor(resource: .color3) }
    static var colorSelected4: UIColor { UIColor(resource: .color4) }
    static var colorSelected5: UIColor { UIColor(resource: .color5) }
    static var colorSelected6: UIColor { UIColor(resource: .color6) }
    static var colorSelected7: UIColor { UIColor(resource: .color7) }
    static var colorSelected8: UIColor { UIColor(resource: .color8) }
    static var colorSelected9: UIColor { UIColor(resource: .color9) }
    static var colorSelected10: UIColor { UIColor(resource: .color10) }
    static var colorSelected11: UIColor { UIColor(resource: .color11) }
    static var colorSelected12: UIColor { UIColor(resource: .color12) }
    static var colorSelected13: UIColor { UIColor(resource: .color13) }
    static var colorSelected14: UIColor { UIColor(resource: .color14) }
    static var colorSelected15: UIColor { UIColor(resource: .color15) }
    static var colorSelected16: UIColor { UIColor(resource: .color16) }
    static var colorSelected17: UIColor { UIColor(resource: .color17) }
    static var colorSelected18: UIColor { UIColor(resource: .color18) }
    static var colorSelected19: UIColor { UIColor(resource: .color) }
}

let colorDictionary: [String: UIColor] = [
    "ypBlackIOS": .ypBlack,
    "ypBackgroundIOS": .ypBackground,
    "ypWhiteIOS": .ypWhite,
    "ypBlueIOS": .ypBlue,
    "ypRedIOS": .ypRed,
    "ypGrayIOS": .ypGray,
    "ypLightGrayIOS": .ypLightGray,
    "ypDateIOS": .colorSelected0,
    "Color1": .colorSelected1,
    "Color2": .colorSelected2,
    "Color3": .colorSelected3,
    "Color4": .colorSelected4,
    "Color5": .colorSelected5,
    "Color6": .colorSelected6,
    "Color7": .colorSelected7,
    "Color8": .colorSelected8,
    "Color9": .colorSelected9,
    "Color10": .colorSelected10,
    "Color11": .colorSelected11,
    "Color12": .colorSelected12,
    "Color13": .colorSelected13,
    "Color14": .colorSelected14,
    "Color15": .colorSelected15,
    "Color16": .colorSelected16,
    "Color17": .colorSelected17,
    "Color18": .colorSelected18,
    "Color": .colorSelected19
]
