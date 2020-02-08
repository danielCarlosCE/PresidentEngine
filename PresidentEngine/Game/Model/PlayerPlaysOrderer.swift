//
//  PlayerPlaysOrderer.swift
//  PresidentEngine
//
//  Created by Daniel Carlos Souza Carvalho on 2/7/20.
//  Copyright © 2020 danielcarlosce. All rights reserved.
//

protocol PlayerPlaysOrderer {
    func nextPlay(forHand: [Card]) -> PlayerPlaysOrdererPlay
}

enum PlayerPlaysOrdererPlay {
    case go(Range<Int>)
    case skip
}
