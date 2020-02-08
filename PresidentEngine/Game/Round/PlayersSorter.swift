//
//  PlayersSorter.swift
//  PresidentEngine
//
//  Created by Daniel Carlos Souza Carvalho on 2/7/20.
//  Copyright © 2020 danielcarlosce. All rights reserved.
//

/**
 Sorts considering the rank of roles
 */
class PlayersSorter {
    
    /**
     Sorts descending by roles. Thus, President being the highest rank, it will be placed first.
     */
    func sortByRoles(players: [Player]) throws -> [Player] {
        try validate(players: players)
        
        return players.sorted { $0.role.rawValue > $1.role.rawValue }
    }
    
    /**
     Sorts descending by roles, but always places winner as first.
     */
    func sortByRoles(players: [Player], consideringWinner winner: Player) throws -> [Player] {
        var players = try sortByRoles(players: players)
        
        guard let index = players.firstIndex(of: winner) else {
            return players
        }
        
        let winner = players.remove(at: index)
        players.insert(winner, at: 0)
        
        return players
    }
    
    private func validate(players: [Player]) throws {
        let roles = players.map { $0.role }
        
        let rulesValidator = RulesValidator()
        try rulesValidator.validateRolesAreUnique(roles: roles)
    }
    
}

extension PlayersSorter {
    private class RulesValidator {
        func validateRolesAreUnique(roles: [Role]) throws {
            for role in roles {
                guard (roles.filter { $0 == role }).count == 1 else {
                    throw Error.repeatedRoles
                }
            }
        }
    }
    
    enum Error: Swift.Error {
        case repeatedRoles
    }
}
