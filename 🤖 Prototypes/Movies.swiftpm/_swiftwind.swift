//
//  _swiftwind.swift
//  Movies
//
//  Created by Cristian Felipe Patiño Rojas on 10/04/2024.
//

import SwiftUI

// Tailwind defaults for rapid prototyping
// Color
@available(iOS 13.0, *)
public struct WindColor {
    public let c50: Color
    public let c100: Color
    public let c200: Color
    public let c300: Color
    public let c400: Color
    public let c500: Color
    public let c600: Color
    public let c700: Color
    public let c800: Color
    public let c900: Color
}

@available(iOS 13.0, *)
public extension Color {
    
    static let slate50    = Color(red: 248/255, green: 250/255, blue: 252/255)
    static let slate100   = Color(red: 241/255, green: 245/255, blue: 249/255)
    static let slate200   = Color(red: 226/255, green: 232/255, blue: 240/255)
    static let slate300   = Color(red: 203/255, green: 213/255, blue: 225/255)
    static let slate400   = Color(red: 148/255, green: 163/255, blue: 184/255)
    static let slate500   = Color(red: 100/255, green: 116/255, blue: 139/255)
    static let slate600   = Color(red: 71/255 , green: 85/255 , blue: 105/255)
    static let slate700   = Color(red: 51/255 , green: 65/255 , blue:  85/255)
    static let slate800   = Color(red: 30/255 , green: 41/255 , blue:  59/255)
    static let slate900   = Color(red: 15/255 , green: 23/255 , blue:  42/255)
    static let gray50     = Color(red: 249/255, green: 250/255, blue: 251/255)
    static let gray100    = Color(red: 243/255, green: 244/255, blue: 246/255)
    static let gray200    = Color(red: 229/255, green: 231/255, blue: 235/255)
    static let gray300    = Color(red: 209/255, green: 213/255, blue: 219/255)
    static let gray400    = Color(red: 156/255, green: 163/255, blue: 175/255)
    static let gray500    = Color(red: 107/255, green: 114/255, blue: 128/255)
    static let gray600    = Color(red: 75/255 , green: 85/255 , blue:  99/255)
    static let gray700    = Color(red: 55/255 , green: 65/255 , blue:  81/255)
    static let gray800    = Color(red: 31/255 , green: 41/255 , blue:  55/255)
    static let gray900    = Color(red: 17/255 , green: 24/255 , blue:  39/255)
    static let zinc50     = Color(red: 250/255, green: 250/255, blue: 250/255)
    static let zinc100    = Color(red: 244/255, green: 244/255, blue: 245/255)
    static let zinc200    = Color(red: 228/255, green: 228/255, blue: 231/255)
    static let zinc300    = Color(red: 212/255, green: 212/255, blue: 216/255)
    static let zinc400    = Color(red: 161/255, green: 161/255, blue: 170/255)
    static let zinc500    = Color(red: 113/255, green: 113/255, blue: 122/255)
    static let zinc600    = Color(red: 82/255 , green: 82/255 , blue:  91/255)
    static let zinc700    = Color(red: 63/255 , green: 63/255 , blue:  70/255)
    static let zinc800    = Color(red: 39/255 , green: 39/255 , blue:  42/255)
    static let zinc900    = Color(red: 24/255 , green: 24/255 , blue:  27/255)
    static let neutral50  = Color(red: 250/255, green: 250/255, blue: 250/255)
    static let neutral100 = Color(red: 245/255, green: 245/255, blue: 245/255)
    static let neutral200 = Color(red: 229/255, green: 229/255, blue: 229/255)
    static let neutral300 = Color(red: 212/255, green: 212/255, blue: 212/255)
    static let neutral400 = Color(red: 163/255, green: 163/255, blue: 163/255)
    static let neutral500 = Color(red: 115/255, green: 115/255, blue: 115/255)
    static let neutral600 = Color(red: 82/255 , green: 82/255 , blue:  82/255)
    static let neutral700 = Color(red: 64/255 , green: 64/255 , blue:  64/255)
    static let neutral800 = Color(red: 38/255 , green: 38/255 , blue:  38/255)
    static let neutral900 = Color(red: 23/255 , green: 23/255 , blue:  23/255)
    static let stone50    = Color(red: 250/255, green: 250/255, blue: 249/255)
    static let stone100   = Color(red: 245/255, green: 245/255, blue: 244/255)
    static let stone200   = Color(red: 231/255, green: 229/255, blue: 228/255)
    static let stone300   = Color(red: 214/255, green: 211/255, blue: 209/255)
    static let stone400   = Color(red: 168/255, green: 162/255, blue: 158/255)
    static let stone500   = Color(red: 120/255, green: 113/255, blue: 108/255)
    static let stone600   = Color(red: 87/255 , green: 83/255 , blue:  78/255)
    static let stone700   = Color(red: 68/255 , green: 64/255 , blue:  60/255)
    static let stone800   = Color(red: 41/255 , green: 37/255 , blue:  36/255)
    static let stone900   = Color(red: 28/255 , green: 25/255 , blue:  23/255)
    static let red50      = Color(red: 254/255, green: 242/255, blue: 242/255)
    static let red100     = Color(red: 254/255, green: 226/255, blue: 226/255)
    static let red200     = Color(red: 254/255, green: 202/255, blue: 202/255)
    static let red300     = Color(red: 252/255, green: 165/255, blue: 165/255)
    static let red400     = Color(red: 248/255, green: 113/255, blue: 113/255)
    static let red500     = Color(red: 239/255, green: 68/255 , blue:  68/255)
    static let red600     = Color(red: 220/255, green: 38/255 , blue:  38/255)
    static let red700     = Color(red: 185/255, green: 28/255 , blue:  28/255)
    static let red800     = Color(red: 153/255, green: 27/255 , blue:  27/255)
    static let red900     = Color(red: 127/255, green: 29/255 , blue:  29/255)
    static let orange50   = Color(red: 255/255, green: 247/255, blue: 237/255)
    static let orange100  = Color(red: 255/255, green: 237/255, blue: 213/255)
    static let orange200  = Color(red: 254/255, green: 215/255, blue: 170/255)
    static let orange300  = Color(red: 253/255, green: 186/255, blue: 116/255)
    static let orange400  = Color(red: 251/255, green: 146/255, blue:  60/255)
    static let orange500  = Color(red: 249/255, green: 115/255, blue:  22/255)
    static let orange600  = Color(red: 234/255, green: 88/255 , blue:  12/255)
    static let orange700  = Color(red: 194/255, green: 65/255 , blue:  12/255)
    static let orange800  = Color(red: 154/255, green: 52/255 , blue:  18/255)
    static let orange900  = Color(red: 124/255, green: 45/255 , blue:  18/255)
    static let amber50    = Color(red: 255/255, green: 251/255, blue: 235/255)
    static let amber100   = Color(red: 254/255, green: 243/255, blue: 199/255)
    static let amber200   = Color(red: 253/255, green: 230/255, blue: 138/255)
    static let amber300   = Color(red: 252/255, green: 211/255, blue:  77/255)
    static let amber400   = Color(red: 251/255, green: 191/255, blue:  36/255)
    static let amber500   = Color(red: 245/255, green: 158/255, blue:  11/255)
    static let amber600   = Color(red: 217/255, green: 119/255, blue:   6/255)
    static let amber700   = Color(red: 180/255, green: 83/255 , blue:   9/255)
    static let amber800   = Color(red: 146/255, green: 64/255 , blue:  14/255)
    static let amber900   = Color(red: 120/255, green: 53/255 , blue:  15/255)
    static let yellow50   = Color(red: 254/255, green: 252/255, blue: 232/255)
    static let yellow100  = Color(red: 254/255, green: 249/255, blue: 195/255)
    static let yellow200  = Color(red: 254/255, green: 240/255, blue: 138/255)
    static let yellow300  = Color(red: 253/255, green: 224/255, blue:  71/255)
    static let yellow400  = Color(red: 250/255, green: 204/255, blue:  21/255)
    static let yellow500  = Color(red: 234/255, green: 179/255, blue:   8/255)
    static let yellow600  = Color(red: 202/255, green: 138/255, blue:   4/255)
    static let yellow700  = Color(red: 161/255, green: 98/255 , blue:   7/255)
    static let yellow800  = Color(red: 133/255, green: 77/255 , blue:  14/255)
    static let yellow900  = Color(red: 113/255, green: 63/255 , blue:  18/255)
    static let lime50     = Color(red: 247/255, green: 254/255, blue: 231/255)
    static let lime100    = Color(red: 236/255, green: 252/255, blue: 203/255)
    static let lime200    = Color(red: 217/255, green: 249/255, blue: 157/255)
    static let lime300    = Color(red: 190/255, green: 242/255, blue: 100/255)
    static let lime400    = Color(red: 163/255, green: 230/255, blue:  53/255)
    static let lime500    = Color(red: 132/255, green: 204/255, blue:  22/255)
    static let lime600    = Color(red: 101/255, green: 163/255, blue:  13/255)
    static let lime700    = Color(red: 77/255 , green: 124/255, blue:  15/255)
    static let lime800    = Color(red: 63/255 , green: 98/255 , blue:  18/255)
    static let lime900    = Color(red: 54/255 , green: 83/255 , blue:  20/255)
    static let green50    = Color(red: 240/255, green: 253/255, blue: 244/255)
    static let green100   = Color(red: 220/255, green: 252/255, blue: 231/255)
    static let green200   = Color(red: 187/255, green: 247/255, blue: 208/255)
    static let green300   = Color(red: 134/255, green: 239/255, blue: 172/255)
    static let green400   = Color(red: 74/255 , green: 222/255, blue: 128/255)
    static let green500   = Color(red: 34/255 , green: 197/255, blue:  94/255)
    static let green600   = Color(red: 22/255 , green: 163/255, blue:  74/255)
    static let green700   = Color(red: 21/255 , green: 128/255, blue:  61/255)
    static let green800   = Color(red: 22/255 , green: 101/255, blue:  52/255)
    static let green900   = Color(red: 20/255 , green: 83/255 , blue:  45/255)
    static let emerald50  = Color(red: 236/255, green: 253/255, blue: 245/255)
    static let emerald100 = Color(red: 209/255, green: 250/255, blue: 229/255)
    static let emerald200 = Color(red: 167/255, green: 243/255, blue: 208/255)
    static let emerald300 = Color(red: 110/255, green: 231/255, blue: 183/255)
    static let emerald400 = Color(red: 52/255 , green: 211/255, blue: 153/255)
    static let emerald500 = Color(red: 16/255 , green: 185/255, blue: 129/255)
    static let emerald600 = Color(red: 5/255  , green: 150/255, blue: 105/255)
    static let emerald700 = Color(red: 4/255  , green: 120/255, blue:  87/255)
    static let emerald800 = Color(red: 6/255  , green: 95/255 , blue:  70/255)
    static let emerald900 = Color(red: 6/255  , green: 78/255 , blue:  59/255)
    static let teal50     = Color(red: 240/255, green: 253/255, blue: 250/255)
    static let teal100    = Color(red: 204/255, green: 251/255, blue: 241/255)
    static let teal200    = Color(red: 153/255, green: 246/255, blue: 228/255)
    static let teal300    = Color(red: 94/255 , green: 234/255, blue: 212/255)
    static let teal400    = Color(red: 45/255 , green: 212/255, blue: 191/255)
    static let teal500    = Color(red: 20/255 , green: 184/255, blue: 166/255)
    static let teal600    = Color(red: 13/255 , green: 148/255, blue: 136/255)
    static let teal700    = Color(red: 15/255 , green: 118/255, blue: 110/255)
    static let teal800    = Color(red: 17/255 , green: 94/255 , blue:  89/255)
    static let teal900    = Color(red: 19/255 , green: 78/255 , blue:  74/255)
    static let cyan50     = Color(red: 236/255, green: 254/255, blue: 255/255)
    static let cyan100    = Color(red: 207/255, green: 250/255, blue: 254/255)
    static let cyan200    = Color(red: 165/255, green: 243/255, blue: 252/255)
    static let cyan300    = Color(red: 103/255, green: 232/255, blue: 249/255)
    static let cyan400    = Color(red: 34/255 , green: 211/255, blue: 238/255)
    static let cyan500    = Color(red: 6/255  , green: 182/255, blue: 212/255)
    static let cyan600    = Color(red: 8/255  , green: 145/255, blue: 178/255)
    static let cyan700    = Color(red: 14/255 , green: 116/255, blue: 144/255)
    static let cyan800    = Color(red: 21/255 , green: 94/255 , blue: 117/255)
    static let cyan900    = Color(red: 22/255 , green: 78/255 , blue:  99/255)
    static let sky50      = Color(red: 240/255, green: 249/255, blue: 255/255)
    static let sky100     = Color(red: 224/255, green: 242/255, blue: 254/255)
    static let sky200     = Color(red: 186/255, green: 230/255, blue: 253/255)
    static let sky300     = Color(red: 125/255, green: 211/255, blue: 252/255)
    static let sky400     = Color(red: 56/255 , green: 189/255, blue: 248/255)
    static let sky500     = Color(red: 14/255 , green: 165/255, blue: 233/255)
    static let sky600     = Color(red: 2/255  , green: 132/255, blue: 199/255)
    static let sky700     = Color(red: 3/255  , green: 105/255, blue: 161/255)
    static let sky800     = Color(red: 7/255  , green: 89/255 , blue: 133/255)
    static let sky900     = Color(red: 12/255 , green: 74/255 , blue: 110/255)
    static let blue50     = Color(red: 239/255, green: 246/255, blue: 255/255)
    static let blue100    = Color(red: 219/255, green: 234/255, blue: 254/255)
    static let blue200    = Color(red: 191/255, green: 219/255, blue: 254/255)
    static let blue300    = Color(red: 147/255, green: 197/255, blue: 253/255)
    static let blue400    = Color(red: 96/255 , green: 165/255, blue: 250/255)
    static let blue500    = Color(red: 59/255 , green: 130/255, blue: 246/255)
    static let blue600    = Color(red: 37/255 , green: 99/255 , blue: 235/255)
    static let blue700    = Color(red: 29/255 , green: 78/255 , blue: 216/255)
    static let blue800    = Color(red: 30/255 , green: 64/255 , blue: 175/255)
    static let blue900    = Color(red: 30/255 , green: 58/255 , blue: 138/255)
    static let indigo50   = Color(red: 238/255, green: 242/255, blue: 255/255)
    static let indigo100  = Color(red: 224/255, green: 231/255, blue: 255/255)
    static let indigo200  = Color(red: 199/255, green: 210/255, blue: 254/255)
    static let indigo300  = Color(red: 165/255, green: 180/255, blue: 252/255)
    static let indigo400  = Color(red: 129/255, green: 140/255, blue: 248/255)
    static let indigo500  = Color(red: 99/255 , green: 102/255, blue: 241/255)
    static let indigo600  = Color(red: 79/255 , green: 70/255 , blue: 229/255)
    static let indigo700  = Color(red: 67/255 , green: 56/255 , blue: 202/255)
    static let indigo800  = Color(red: 55/255 , green: 48/255 , blue: 163/255)
    static let indigo900  = Color(red: 49/255 , green: 46/255 , blue: 129/255)
    static let violet50   = Color(red: 245/255, green: 243/255, blue: 255/255)
    static let violet100  = Color(red: 237/255, green: 233/255, blue: 254/255)
    static let violet200  = Color(red: 221/255, green: 214/255, blue: 254/255)
    static let violet300  = Color(red: 196/255, green: 181/255, blue: 253/255)
    static let violet400  = Color(red: 167/255, green: 139/255, blue: 250/255)
    static let violet500  = Color(red: 139/255, green: 92/255 , blue: 246/255)
    static let violet600  = Color(red: 124/255, green: 58/255 , blue: 237/255)
    static let violet700  = Color(red: 109/255, green: 40/255 , blue: 217/255)
    static let violet800  = Color(red: 91/255 , green: 33/255 , blue: 182/255)
    static let violet900  = Color(red: 76/255 , green: 29/255 , blue: 149/255)
    static let purple50   = Color(red: 250/255, green: 245/255, blue: 255/255)
    static let purple100  = Color(red: 243/255, green: 232/255, blue: 255/255)
    static let purple200  = Color(red: 233/255, green: 213/255, blue: 255/255)
    static let purple300  = Color(red: 216/255, green: 180/255, blue: 254/255)
    static let purple400  = Color(red: 192/255, green: 132/255, blue: 252/255)
    static let purple500  = Color(red: 168/255, green: 85/255 , blue: 247/255)
    static let purple600  = Color(red: 147/255, green: 51/255 , blue: 234/255)
    static let purple700  = Color(red: 126/255, green: 34/255 , blue: 206/255)
    static let purple800  = Color(red: 107/255, green: 33/255 , blue: 168/255)
    static let purple900  = Color(red: 88/255 , green: 28/255 , blue: 135/255)
    static let fuchsia50  = Color(red: 253/255, green: 244/255, blue: 255/255)
    static let fuchsia100 = Color(red: 250/255, green: 232/255, blue: 255/255)
    static let fuchsia200 = Color(red: 245/255, green: 208/255, blue: 254/255)
    static let fuchsia300 = Color(red: 240/255, green: 171/255, blue: 252/255)
    static let fuchsia400 = Color(red: 232/255, green: 121/255, blue: 249/255)
    static let fuchsia500 = Color(red: 217/255, green: 70/255 , blue: 239/255)
    static let fuchsia600 = Color(red: 192/255, green: 38/255 , blue: 211/255)
    static let fuchsia700 = Color(red: 162/255, green: 28/255 , blue: 175/255)
    static let fuchsia800 = Color(red: 134/255, green: 25/255 , blue: 143/255)
    static let fuchsia900 = Color(red: 112/255, green: 26/255 , blue: 117/255)
    static let pink50     = Color(red: 253/255, green: 242/255, blue: 248/255)
    static let pink100    = Color(red: 252/255, green: 231/255, blue: 243/255)
    static let pink200    = Color(red: 251/255, green: 207/255, blue: 232/255)
    static let pink300    = Color(red: 249/255, green: 168/255, blue: 212/255)
    static let pink400    = Color(red: 244/255, green: 114/255, blue: 182/255)
    static let pink500    = Color(red: 236/255, green: 72/255 , blue: 153/255)
    static let pink600    = Color(red: 219/255, green: 39/255 , blue: 119/255)
    static let pink700    = Color(red: 190/255, green: 24/255 , blue:  93/255)
    static let pink800    = Color(red: 157/255, green: 23/255 , blue:  77/255)
    static let pink900    = Color(red: 131/255, green: 24/255 , blue:  67/255)
    static let rose50     = Color(red: 255/255, green: 241/255, blue: 242/255)
    static let rose100    = Color(red: 255/255, green: 228/255, blue: 230/255)
    static let rose200    = Color(red: 254/255, green: 205/255, blue: 211/255)
    static let rose300    = Color(red: 253/255, green: 164/255, blue: 175/255)
    static let rose400    = Color(red: 251/255, green: 113/255, blue: 133/255)
    static let rose500    = Color(red: 244/255, green: 63/255 , blue:  94/255)
    static let rose600    = Color(red: 225/255, green: 29/255 , blue:  72/255)
    static let rose700    = Color(red: 190/255, green: 18/255 , blue:  60/255)
    static let rose800    = Color(red: 159/255, green: 18/255 , blue:  57/255)
    static let rose900    = Color(red: 136/255, green: 19/255 , blue:  55/255)
    
}

// MARK: - Sizing
public extension CGFloat {
    
    static let base: Self = 4
    
    static let s1h: Self = base * 1.5
    static let s2h: Self = base * 2.5
    static let s3h: Self = base * 3.5
    
    static let px: Self = 1
    static let s05: Self = base / 2
    static let s1: Self = base * 1
    static let s2: Self = base * 2
    static let s3: Self = base * 3
    static let s4: Self = base * 4
    static let s5: Self = base * 5
    static let s6: Self = base * 6
    static let s7: Self = base * 7
    static let s8: Self = base * 8
    static let s9: Self = base * 9
    static let s10: Self = base * 10
    static let s11: Self = base * 11
    static let s12: Self = base * 12
    static let s14: Self = base * 14
    static let s16: Self = base * 16
    static let s18: Self = base * 18
    static let s20: Self = base * 20
    static let s22: Self = base * 22
    static let s24: Self = base * 24
    static let s28: Self = base * 28
    static let s32: Self = base * 32
    static let s36: Self = base * 36
    static let s40: Self = base * 40
    static let s44: Self = base * 44
    static let s48: Self = base * 48
    static let s52: Self = base * 52
    static let s56: Self = base * 56
    static let s60: Self = base * 60
    static let s64: Self = base * 64
    static let s72: Self = base * 72
    static let s80: Self = base * 80
    static let s96: Self = base * 96
}
