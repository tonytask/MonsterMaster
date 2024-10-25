//
//  GameLogic.swift
//  Monster Master
//
//  Created by Tony on 6/9/24.
//

import SwiftUI
import Foundation

struct Player: Codable{
    var name: String
    var level: Int
    var currentExp: Int
    var currentEnergy: Int = 100
    var maximumEnergy: Int = 100
    var cash: Int
    var gems: Int
    var partyList: [Monster]
    var ownedList: [Monster] = []
    var energyTime: Int = 180
    var mapsUnlocked: Int{
        var maps = 1
        if(missionsBeat.contains("Harbor Challenge")){
            maps += 4
        }
        return maps
    }
    var missionsUnlocked: [String:Int]
    var missionsBeat = Set([""])
    var monstersSeen = Set([""])
}

struct Monster: Codable, Identifiable, Hashable{
    var id = UUID()
    var idLabel: Int = 999
    var name: String
    var ascension: Int = 0
    var level: Int
    var statHP: Int
    var statATT: Int
    var statDEF: Int
    var statSPATT: Int
    var statSPDEF: Int
    var statSPD: Int
    var abilities: [Ability]
    var lockedAbility1: Ability
    var lockedAbility2: Ability
    var ability1Active: Bool = false
    var ability2Active: Bool = false
    var abilitiesActive: [Ability]{
        var abil = abilities
        if(ability1Active == true){
            abil.append(lockedAbility1)
        }
        if(ability2Active == true){
            abil.append(lockedAbility2)
        }
        return abil
    }
    var passive1: Passive
    var passive2: Passive
    
    /*var resistanceGround: Int
    var resistanceFire: Int
    var resistanceWater: Int
    var resistanceNeutral: Int
    var resistanceIce: Int
    var resistanceNature: Int
    var resistancePoison: Int
    var resistanceShadow: Int*/
    var resistances: [Attribute:Int]
    
    var currentHP: Int = 0
    var actualHP: Int{
        (level*statHP/4 + 5)*(100+2*ascension)/100
    }
    var actualATT: Int{
        level*statATT/10*(100+2*ascension)/100
    }
    var actualDEF: Int{
        level*statDEF/10*(100+2*ascension)/100
    }
    var actualSPATT: Int{
        level*statSPATT/10*(100+2*ascension)/100
    }
    var actualSPDEF: Int{
        level*statSPDEF/10*(100+2*ascension)/100
    }
    var actualSPD: Int{
        level*statSPD/10*(100+2*ascension)/100
    }
    var bst:Int{
        statHP + statATT + statDEF + statSPATT + statSPDEF + statSPD
    }
    
    var buffList: [Buff] = []
    var debuffList: [Debuff] = []
    
    var leaderBonus: [LeaderBonus] = []
    
}

struct LeaderBonus: Codable, Hashable{
    var stat: String
    var bonus: Int
}

struct Ability: Codable, Hashable{
    var name: String
    var power: Int
    var attribute: Attribute// = .Earth
    var type: String
    var buff: String = ""
    var debuff: String = ""
    var acc: Int = 100
    var description: String = ""
    
}

struct Passive: Codable, Hashable{
    var name: String
    var description: String = ""
    
}

enum Attribute: Codable, Hashable{
    case Neutral, Ground, Water, Fire, Ice, Nature, Poison, Shadow, Holy, Electric
}

struct Item: Codable, Hashable{
    var name: String
}

struct Buff: Codable, Hashable{
    var name: String
    var stat: [String]
    var bonus: [Int]
    var duration: Int
    var chance: Int = 100
    var image: String = "arrow.up.circle.fill"
}

struct Debuff: Codable, Hashable{
    var name: String
    var stat: [String]
    var bonus: [Int]
    var duration: Int
    var chance: Int
    var image: String = "arrow.down.circle"
}

struct Mission: Codable, Hashable{
    var map: String
    var name: String
    var energyCost: Int
    var captureRate: Int
    var description: String
    var expReward: Int
    var cashReward: Int
    var enemyTeam: [Monster]
    var recommendedLevel: String
}

@Observable
class GameWorld{
    
    private var timer: Timer?
    
    let defaultAbility = Ability(name: "Default", power: 50, attribute: .Neutral, type: "Physical")
    let defaultPassive = Passive(name: "Default")
    var energyRechargeCost = 50
    
    var attributes: [Attribute] = [.Neutral, .Ground, .Water, .Fire, .Ice, .Nature, .Poison, .Shadow, .Holy, .Electric]
    
    var enemyTeamSize = 1
    var playerTeamSize = 1
    var enemyTeamBeat = 0
    var playerTeamBeat = 0
    var enemyTeamMonsters: [Monster] = []
    var currentEnemy: Monster
    var playerWon = false
    var playerLost = false
    var captureSuccess = false
    var leveledUp = false
    
    var currentPlayerMonster: Monster
    var currentPlayerMonsterBuffs: [Buff] = []
    var currentPlayerMonsterDebuffs: [Debuff] = []
    var currentEnemyBuffs: [Buff] = []
    var currentEnemyDebuffs: [Debuff] = []
    var hasTimeElapsed = false
    
    var currentMap = ""
    var currentMission = ""
    
    var partyLeaderBonus: [LeaderBonus]{
        player.partyList[0].leaderBonus
    }
    
    var enemyLeaderBonus: [LeaderBonus]{
        enemyTeamMonsters[0].leaderBonus
    }
    
    var lastGameDate: Date{
        didSet{
            if let encoded = try? JSONEncoder().encode(lastGameDate){
                UserDefaults.standard.set(encoded, forKey: "lastGameDate")
            }
        }
    }
    
    var player: Player{
        didSet{
            if let encoded = try? JSONEncoder().encode(player){
                UserDefaults.standard.set(encoded, forKey: "Player")
            }
        }
    }
    
    var expToNextLevel = [0,15,32,54,88,130,247,376,585,848,1326,2000,2853,3792,5000,7164, 9708, 13062,99999999]//372,560,840,1242,1144,1573,2144,2800,3640,4700,5893,7360,9144,11120,13477,16268,19320,22880,27008,31477,36600,42444,48720,55813,63800,86784,98208,110932,124432,139372,155865,173280,192400,213345,235372,259392,285532,312928,342624,374760,408336,445544,483532,524160,567772,598886,631704,666321,702836,741351,781976,824828,870028,917625,967995,1021041,1076994,1136013,1198266,1263930,1333194,1406252,1483314,1564600,1650340,1740778,1836173,1936794,2042930,2154882,2272970,2397528,2528912,2667496,2813674,2967863,3130502,3302053,3483005,3673873,3875201,4087562,4311559,4547832,4797053,5059931,5337215,5629694,5938202,6263614,6606860,6968915,7350811,7753635,8178534,99999999]
    
    var mapList = ["Maple Island","Henesys", "Perion", "Kerning City", "Ellinia"]
    var mapRecommendedLevel = ["Maple Island": "Lv 1-8",
                               "Henesys": "Lv 8-20",
                               "Perion": "Lv 9-20",
                               "Kerning City": "Lv 10-20",
                               "Ellinia": "Lv 11-20",
                               
    
    ]
    var missionList = ["Maple Island": ["Small Forest", "Adventurer's Training 1", "Adventurer's Training 2", "Adventurer's Training 3", "Deep Forest 1", "Deep Forest 2", "Deep Forest 3", "Deep Forest 4", "Path to the Harbor 1", "Path to the Harbor 2", "Path to the Harbor 3", "Harbor Challenge"],
    
                       "Henesys": ["Hunting Grounds 1", "Hunting Grounds 2", "Hunting Grounds 3", "Tamer Challenge 1", "Tamer Challenge 2", "Tamer Challenge 3", "Pig Farm"],
                       
                       "Perion": ["Perion Entrance", "Perion Trial 1", "Perion Trial 2", "Rocky Mountain 1", "Rocky Mountain 2", "Rocky Mountain 3"],
                       
                       "Ellinia": ["Ellinia Forest 1", "Ellinia Forest 2", "Ellinia Forest 3"],
                       
                       "Kerning City": ["Construction Site 1", "Construction Site 2", "Construction Site 3", "Kerning Thugs 1", "Kerning Thugs 2"],
    
    ]
    
    var missionBackground: [String:[Color]] = 
                            ["Small Forest": [.green,.brown],
                             "Adventurer's Training 1": [.gray,.white],
                             "Adventurer's Training 2": [.gray,.white],
                             "Adventurer's Training 3": [.orange,.red],
                             "Deep Forest 1": [.brown,.green],
                             "Deep Forest 2": [.brown,.green],
                             "Deep Forest 3": [.brown,.green],
                             "Deep Forest 4": [.purple,.black],
                             "Path to the Harbor 1": [.white,.blue],
                             "Path to the Harbor 2": [.white,.blue],
                             "Path to the Harbor 3": [.white,.blue],
                             "Harbor Challenge": [Color(red: 0/255, green: 100/255, blue: 0/255), .blue],
                             "Hunting Grounds 1": [.green, .yellow],
                             "Hunting Grounds 2": [.green,.yellow],
                             "Hunting Grounds 3": [.green,.yellow],
                             "Tamer Challenge 1": [.mint, .orange],
                             "Tamer Challenge 2": [.mint, .orange],
                             "Tamer Challenge 3": [.mint, .orange],
                             "Pig Farm": [Color(red: 173/255, green: 216/255, blue: 230/255), // Soft Green
                                          Color(red: 245/255, green: 222/255, blue: 179/255)],
                             
                             
                             "Perion Entrance": [Color(red: 139/255, green: 69/255, blue: 19/255), .gray],
                             "Perion Trial 1": [Color(red: 139/255, green: 69/255, blue: 19/255), .gray],
                             "Perion Trial 2": [Color(red: 139/255, green: 69/255, blue: 19/255), .gray],
                             "Rocky Mountain 1": [Color(red: 101/255, green: 67/255, blue: 33/255), Color(red: 245/255, green: 245/255, blue: 220/255)],
                             "Rocky Mountain 2": [Color(red: 101/255, green: 67/255, blue: 33/255), Color(red: 245/255, green: 245/255, blue: 220/255)],
                             "Rocky Mountain 3": [Color(red: 101/255, green: 67/255, blue: 33/255), Color(red: 245/255, green: 245/255, blue: 220/255)],
                             
                             "Construction Site 1": [Color(red: 169/255, green: 169/255, blue: 169/255),Color(red: 255/255, green: 103/255, blue: 1/255)],
                             "Construction Site 2": [Color(red: 169/255, green: 169/255, blue: 169/255),Color(red: 255/255, green: 103/255, blue: 1/255)],
                             "Construction Site 3": [Color(red: 169/255, green: 169/255, blue: 169/255),Color(red: 255/255, green: 103/255, blue: 1/255)],
                             "Kerning Thugs 1": [.purple,.black],
                             "Kerning Thugs 2": [.purple,.black],
                             
                             "Ellinia Forest 1": [Color(red: 34/255, green: 139/255, blue: 34/255),Color(red: 85/255, green: 107/255, blue: 47/255)],
                             "Ellinia Forest 2": [Color(red: 34/255, green: 139/255, blue: 34/255),Color(red: 85/255, green: 107/255, blue: 47/255)],
                             "Ellinia Forest 3": [Color(red: 34/255, green: 139/255, blue: 34/255),Color(red: 85/255, green: 107/255, blue: 47/255)],
                             
    
    ]
    var missions: [String:Mission]
                                   
    
    let abilityList: [String:Ability] = ["Harden Shell": Ability(name: "Harden Shell", power: 0, attribute: .Ground, type: "Physical",buff: "Harden Shell", description: "Increases DEF and SPDEF by 35% for 3 turns"),
                                        "Mud Spit": Ability(name:"Mud Spit", power: 30, attribute: .Ground, type: "Special", debuff: "Blind", description: "Spits mud at the enemy, potentially blinding them."),
                                         "Mano's Blessing": Ability(name: "Mano's Blessing", power: 0, attribute: .Ground, type: "Special",buff: "Mano's Blessing",description: "Increases SPATT and SPDEF by 40% for 3 turns"),
                                         "Sticky Slime": Ability(name: "Sticky Slime", power: 35, attribute: .Nature, type: "Special", debuff: "Slow",description: "Covers the enemy in sticky slime, with chance to slow"),
                                         "Aqua Slime": Ability(name: "Aqua Slime", power: 40, attribute: .Water, type: "Special",description: "Shoots a blob of water at the enemy."),
                                         "Searing Slime": Ability(name: "Searing Slime", power: 40, attribute: .Fire, type: "Special", debuff: "Burn",description:"Throws searing slime, with chance to burn"),
                                         "Tackle": Ability(name: "Tackle", power:40, attribute: .Neutral,type: "Physical", description: "Charges and tackles the enemy."),
                                         "Chilly Bite": Ability(name: "Chilly Bite", power:45, attribute: .Ice, type: "Physical",debuff: "Frostbite",description:"Bites the enemy with frosty jaws, with chance to frostbite"),
                                         "Nibble": Ability(name: "Nibble", power: 30, attribute: .Neutral, type: "Physical", description: "Nibbles at the enemy."),
                                         "Spore Shot": Ability(name: "Spore Shot", power: 35, attribute: .Nature, type: "Special",debuff: "Blind", description: "Shoots spores at the enemy, potentially blinding them."),
                                         "Poison Cloud": Ability(name: "Poison Cloud", power: 20, attribute: .Poison, type: "Special", debuff: "Poison",description: "Releases a cloud of poison, potentially poisoning the enemy."),
                                         "Nature Pulse": Ability(name: "Nature Pulse", power: 50, attribute: .Nature, type: "Special", description: "Unleashes a pulse of natural energy."),
                                         "Entangle": Ability(name: "Entangle", power: 40, attribute: .Nature, type: "Physical", debuff: "Slow", description: "Entangles the enemy with vines, potentially slowing them down."),
                                         "Photosynthesis": Ability(name: "Photosynthesis", power: 0, attribute: .Nature, type: "Special", description:"Heals 1/10 Max HP"),
                                         "Slam": Ability(name: "Slam", power: 55, attribute: .Neutral, type: "Physical", description: "Slams into the enemy with great force."),
                                         "Scratch": Ability(name: "Scratch", power: 35, attribute: .Neutral, type: "Physical", debuff: "Bleed", description: "Scratches the enemy, potentially bleeding them"),
                                         "Shadow Pounce": Ability(name: "Shadow Pounce", power: 50, attribute: .Shadow, type: "Physical", description: "Pounces on the enemy from the shadows."),
                                         "Poison Bite": Ability(name: "Poison Bite", power: 40, attribute: .Poison, type: "Physical", debuff: "Poison", description: "Bites the enemy, potentially poisoning them."),
                                         "Poison Slime": Ability(name: "Poison Slime", power: 40, attribute: .Poison, type: "Special", debuff: "Poison", description: "Covers the enemy in poisonous slime."),
                                         "Nature's Might": Ability(name: "Nature's Might", power: 0, attribute: .Nature, type: "Special", buff: "Nature's Might", description: "Increases ATT and DEF by 25% for 4 turns"),
                                         "Nature's Soul": Ability(name: "Nature's Soul", power: 0, attribute: .Nature, type: "Special", buff: "Nature's Soul",description: "Increases SPATT and DEF by 25% for 4 turns"),
                                         "Poison Dart": Ability(name: "Poison Dart", power: 50, attribute: .Poison, type: "Special", debuff: "Poison", description: "Shoots a dart that can poison the enemy."),
                                         "Mud Toss": Ability(name: "Mud Toss", power: 40, attribute: .Ground, type: "Special", debuff: "Blind", description: "Throws mud at the enemy, potentially blinding them."),
                                         "Mycelium Grip": Ability(name: "Mycelium Grip", power: 45, attribute: .Nature, type: "Physical", description: "Grips the enemy with strong mycelium."),
                                         "Shadow Bind": Ability(name: "Shadow Bind", power: 45, attribute: .Shadow, type: "Physical", debuff: "Slow", description: "Binds the enemy with shadows, potentially slowing them down."),
                                         "Axe Fury": Ability(name: "Axe Fury", power: 55, attribute: .Neutral, type: "Physical", debuff: "Bleed", description: "Furious axe attack that can bleed the enemy"),
                                         "Dark Slime": Ability(name: "Dark Slime", power: 40, attribute: .Shadow, type: "Special", debuff: "Blind", description: "Covers the enemy in dark slime, potentially blinding them."),
                                         "Icy Slime": Ability(name: "Icy Slime", power: 40, attribute: .Ice, type: "Special", debuff: "Frostbite", description: "Throws icy slime at the enemy, potentially causing frostbite."),
                                         "Ink Spray": Ability(name: "Ink Spray", power: 35, attribute: .Water, type: "Special", debuff: "Blind", description: "Sprays ink at the enemy, potentially blinding them."),
                                         "Tentacle Whip": Ability(name: "Tentacle Whip", power: 55, attribute: .Neutral, type: "Physical", description: "Whips the enemy with powerful tentacles."),
                                         "Regenerate": Ability(name: "Regenerate", power: 0, attribute: .Neutral, type: "Special", description: "Heals 1/8 Max HP"),
                                         "Pig Fury": Ability(name: "Pig Fury", power: 0, attribute: .Neutral, type: "Physical", buff: "Pig Fury", description: "Increases ATT by 50% and lowers DEF by 10% for 3 turns"),
                                         "Aqua Pulse": Ability(name: "Aqua Pulse", power: 60, attribute: .Water, type: "Special", description: "Fires a powerful pulse of water."),
                                         "Energy Bolt": Ability(name: "Energy Bolt", power: 50, attribute: .Electric, type: "Special", description:"Shoots a bolt of electric energy."),
                                         "Magic Bolt": Ability(name: "Magic Bolt", power: 50, attribute: .Holy, type: "Special", description: "Shoots a bolt of holy energy."),
                                         "Icy Bolt": Ability(name: "Icy Bolt", power: 50, attribute: .Ice, type: "Special", debuff: "Frostbite", description: "Shoots an icy bolt, potentially causing frostbite"),
                                         "Feline Agility": Ability(name: "Feline Agility", power: 0, attribute: .Neutral, type: "Physical", buff: "Feline Agility", description: "Increases ATT and SPD by 35% for 3 turns"),
                                         "Piercing Howl": Ability(name: "Piercing Howl", power: 0, attribute: .Neutral, type: "Physical", debuff: "Piercing Howl", description: "Lets out a terrifying howl that reduces the enemy's DEF"),
                                         "Slash": Ability(name: "Slash", power: 65, attribute: .Neutral, type: "Physical", debuff: "Bleed",description: "Slashes the enemy, potentially bleeding them"),
                                         "Shadow Swipe": Ability(name: "Shadow Swipe", power: 60, attribute: .Shadow, type: "Physical", debuff: "Armor Break",description: "Swipes at the target with shadow-infused claws, potentially reducing DEF"),
                                         "Horn Jab": Ability(name: "Horn Jab", power: 50, attribute: .Neutral, type: "Physical", debuff: "Bleed",description: "Jabs its sharp horns into the enemy, potentially bleeding them"),
                                         "Roar": Ability(name: "Roar", power: 0, attribute: .Neutral, type: "Special", debuff: "Frightened",description: "Roars at the enemy, lowering their ATT and SPATT"),
                                         "Tail Lash": Ability(name: "Tail Lash", power: 50, attribute: .Neutral, type: "Physical", debuff: "Armor Break",description: "Strikes the enemy with its tail, potentially reducing DEF"),
                                         "Toxic Fang": Ability(name: "Toxic Fang", power: 65, attribute: .Poison, type: "Physical", debuff: "Poison", description: "Bites the enemy, potentially poisoning them."),
    ]
    
    let buffList: [String:Buff] = ["Harden Shell": Buff(name: "Harden Shell", stat: ["DEF", "SPDEF"], bonus: [35,35], duration: 4, image: "shield.checkered"),
                                   "Mano's Blessing": Buff(name: "Mano's Blessing", stat: ["SPATT","SPDEF"], bonus: [40,40], duration: 4),
                                   "Nature's Might": Buff(name: "Nature's Might", stat: ["ATT","DEF"], bonus: [25,25], duration: 5, image: "leaf.fill"),
                                   "Nature's Soul": Buff(name: "Nature's Soul", stat: ["SPATT","DEF"], bonus: [25,25], duration: 5, image: "leaf.fill"),
                                   "Pig Fury": Buff(name: "Pig Fury", stat: ["ATT","DEF"], bonus: [50,-10], duration: 4),
                                   "Feline Agility": Buff(name: "Feline Agility", stat: ["ATT","SPD"], bonus: [35,35], duration: 4)
                                   
    
    ]
    
    let debuffList: [String:Debuff] = ["Blind": Debuff(name: "Blind", stat: ["ACC"], bonus: [-15], duration: 4, chance: 50, image: "eye.slash.fill"),
                                       "Slow": Debuff(name: "Slow", stat: ["SPD"], bonus: [-20], duration: 4, chance: 50, image:"tortoise.circle.fill"),
                                       "Frostbite": Debuff(name: "Frostbite", stat: ["SPATK","SPD"], bonus: [-10,-10], duration: 5, chance: 50, image: "snowflake.circle.fill"),
                                       "Bleed": Debuff(name: "Bleed", stat: ["HP"], bonus: [-5], duration: 4, chance: 25, image: "drop.fill"),
                                       "Piercing Howl": Debuff(name: "Piercing Howl", stat: ["DEF"], bonus: [-15], duration: 4, chance: 100, image: "shield.slash.fill"),
                                       "Armor Break": Debuff(name: "Armor Break", stat: ["DEF"], bonus: [-20], duration: 4, chance: 30, image: "shield.lefthalf.filled.slash"),
                                       "Frightened": Debuff(name: "Frightened", stat: ["ATT", "SPATT"], bonus: [-15, -15], duration: 4, chance: 100, image: "exclamationmark.triangle.fill")
    
    ]
    
    let passiveList: [String:Passive] = ["None": Passive(name: "None"),
                       "Desperation": Passive(name: "Desperation")]
    
    var monsterList: [String:Monster]
    
    init(){
        
        if let savedDateData = UserDefaults.standard.data(forKey: "lastGameDate"),
           let decodedDate = try? JSONDecoder().decode(Date.self, from:savedDateData) {
            lastGameDate = decodedDate
        } else {
            lastGameDate = Date.now
        }
        
        
        
        self.monsterList = ["Snail": Monster(idLabel: 1,name: "Snail", level: 1, statHP: 32, statATT: 30, statDEF: 38, statSPATT: 32, statSPDEF: 36, statSPD: 20, abilities: [ abilityList["Mud Spit"] ?? defaultAbility], lockedAbility1: abilityList["Harden Shell"] ?? defaultAbility,lockedAbility2: abilityList["Sticky Slime"] ?? defaultAbility, passive1: passiveList["Desperation"] ?? defaultPassive, passive2: passiveList["None"] ?? defaultPassive, resistances: [.Ground: 80, .Fire: 200, .Water: 80, .Neutral: 100, .Ice: 125, .Nature: 80, .Poison: 100, .Shadow: 100, .Holy: 100, .Electric: 75], leaderBonus: [LeaderBonus(stat: "DEF", bonus: 4)]),
                            "Blue Snail": Monster(idLabel: 2,name: "Blue Snail", level: 2, statHP: 34, statATT: 32, statDEF: 40, statSPATT: 35, statSPDEF: 38, statSPD: 21, abilities: [abilityList["Mud Spit"] ?? defaultAbility],lockedAbility1: abilityList["Harden Shell"] ?? defaultAbility, lockedAbility2: abilityList["Aqua Slime"] ?? defaultAbility, passive1: passiveList["Desperation"] ?? defaultPassive, passive2: passiveList["None"] ?? defaultPassive,resistances: [.Ground: 80, .Fire: 150, .Water: 60, .Neutral: 100, .Ice: 125, .Nature: 80, .Poison: 100, .Shadow: 100, .Holy: 100,.Electric: 100], leaderBonus:  [LeaderBonus(stat: "SPDEF", bonus: 4)]),
                            "Red Snail": Monster(idLabel: 3,name: "Red Snail", level: 4, statHP: 37, statATT: 35, statDEF: 41, statSPATT: 37, statSPDEF: 40, statSPD: 22, abilities: [abilityList["Mud Spit"] ?? defaultAbility], lockedAbility1: abilityList["Mano's Blessing"] ?? defaultAbility,lockedAbility2: abilityList["Searing Slime"] ?? defaultAbility, passive1: passiveList["Desperation"] ?? defaultPassive, passive2: defaultPassive, resistances: [.Ground: 100, .Fire: 100, .Water: 125, .Neutral: 100, .Ice: 80, .Nature: 60, .Poison: 100, .Shadow: 100, .Holy: 100,.Electric: 75], leaderBonus:  [LeaderBonus(stat: "DEF", bonus: 3),LeaderBonus(stat: "SPDEF", bonus: 2)]),
                            "Shroom": Monster(idLabel: 4,name: "Shroom", level: 3, statHP: 30, statATT: 35, statDEF: 28, statSPATT: 50, statSPDEF: 30, statSPD: 42, abilities: [abilityList["Nibble"] ?? defaultAbility, abilityList["Spore Shot"] ?? defaultAbility], lockedAbility1: abilityList["Poison Cloud"] ?? defaultAbility,lockedAbility2: abilityList["Nature Pulse"] ?? defaultAbility,passive1: defaultPassive, passive2: passiveList["None"] ?? defaultPassive,resistances: [.Ground: 80, .Fire: 200, .Water: 80, .Neutral: 125, .Ice: 150, .Nature: 50, .Poison: 80, .Shadow: 100, .Holy: 125,.Electric: 75], leaderBonus:  [LeaderBonus(stat: "SPATT", bonus: 4)]),
                            
                            
                            
                            "Orange Mushroom": Monster(idLabel: 5,name: "Orange Mushroom", level: 7, statHP: 48, statATT: 48, statDEF: 45, statSPATT: 30, statSPDEF: 35, statSPD: 40, abilities: [abilityList["Mycelium Grip"] ?? defaultAbility, abilityList["Poison Bite"] ?? defaultAbility], lockedAbility1: abilityList["Nature's Might"] ?? defaultAbility, lockedAbility2: defaultAbility, passive1: defaultPassive, passive2: defaultPassive,resistances: [.Ground: 80, .Fire: 200, .Water: 80, .Neutral: 100, .Ice: 150, .Nature: 60, .Poison: 80, .Shadow: 100, .Holy: 100,.Electric: 75], leaderBonus:  [LeaderBonus(stat: "HP", bonus: 3),LeaderBonus(stat: "ATT", bonus: 3)]),
                            "Green Mushroom": Monster(idLabel: 6,name: "Green Mushroom", level: 10, statHP: 49, statATT: 35, statDEF: 41, statSPATT: 59, statSPDEF: 46, statSPD: 42, abilities: [abilityList["Nature Pulse"] ?? defaultAbility, abilityList["Mud Toss"] ?? defaultAbility,], lockedAbility1: abilityList["Nature's Soul"] ?? defaultAbility, lockedAbility2: abilityList["Nature Pulse"] ?? defaultAbility, passive1: defaultPassive, passive2: defaultPassive, resistances: [.Ground: 80, .Fire: 250, .Water: 75, .Neutral: 100, .Ice: 150, .Nature: 50, .Poison: 175, .Shadow: 100, .Holy: 100,.Electric: 75], leaderBonus:  [LeaderBonus(stat: "HP", bonus: 3),LeaderBonus(stat: "SPATT", bonus: 4)]),
                            "Horny Mushroom": Monster(idLabel: 7,name: "Horny Mushroom", level: 10, statHP: 51, statATT: 56, statDEF: 46, statSPATT: 34, statSPDEF: 44, statSPD: 43, abilities: [abilityList["Horn Jab"] ?? defaultAbility, abilityList["Mycelium Grip"] ?? defaultAbility,], lockedAbility1: abilityList["Nature's Might"] ?? defaultAbility, lockedAbility2: abilityList["Horn Jab"] ?? defaultAbility, passive1: defaultPassive, passive2: defaultPassive, resistances: [.Ground: 80, .Fire: 200, .Water: 80, .Neutral: 100, .Ice: 150, .Nature: 50, .Poison: 100, .Shadow: 100, .Holy: 175,.Electric: 75], leaderBonus:  [LeaderBonus(stat: "ATT", bonus: 5), LeaderBonus(stat: "DEF", bonus: 2)]),
                            "Blue Mushroom": Monster(idLabel: 8,name: "Blue Mushroom", level: 10, statHP: 52, statATT: 41, statDEF: 48, statSPATT: 50, statSPDEF: 49, statSPD: 39, abilities: [abilityList["Aqua Pulse"] ?? defaultAbility, abilityList["Mud Toss"] ?? defaultAbility,], lockedAbility1: abilityList["Nature's Soul"] ?? defaultAbility, lockedAbility2: abilityList["Regenerate"] ?? defaultAbility, passive1: defaultPassive, passive2: defaultPassive, resistances: [.Ground: 80, .Fire: 150, .Water: 60, .Neutral: 100, .Ice: 175, .Nature: 75, .Poison: 150, .Shadow: 100, .Holy: 100,.Electric: 175], leaderBonus:  [LeaderBonus(stat: "HP", bonus: 4), LeaderBonus(stat: "SPATT", bonus: 3)]),
                            
                            "Pig": Monster(idLabel: 12,name: "Pig", level: 8, statHP: 54, statATT: 55, statDEF: 44, statSPATT: 25, statSPDEF: 42, statSPD: 25, abilities: [abilityList["Tackle"] ?? defaultAbility, abilityList["Mud Toss"] ?? defaultAbility], lockedAbility1: abilityList["Slam"] ?? defaultAbility, lockedAbility2: abilityList["Pig Fury"] ?? defaultAbility, passive1: defaultPassive, passive2: defaultPassive, resistances: [.Ground: 100, .Fire: 200, .Water: 75, .Neutral: 100, .Ice: 150, .Nature: 100, .Poison: 150, .Shadow: 125, .Holy: 75,.Electric: 175], leaderBonus:  [LeaderBonus(stat: "HP", bonus: 6)]),
                            "Ribbon Pig": Monster(idLabel: 13,name: "Ribbon Pig", level: 8, statHP: 56, statATT: 55, statDEF: 46, statSPATT: 25, statSPDEF: 45, statSPD: 28, abilities: [abilityList["Slam"] ?? defaultAbility, abilityList["Slam"] ?? defaultAbility], lockedAbility1: abilityList["Roar"] ?? defaultAbility, lockedAbility2: abilityList["Pig Fury"] ?? defaultAbility, passive1: defaultPassive, passive2: defaultPassive, resistances: [.Ground: 100, .Fire: 200, .Water: 75, .Neutral: 100, .Ice: 150, .Nature: 100, .Poison: 150, .Shadow: 125, .Holy: 75,.Electric: 175], leaderBonus:  [LeaderBonus(stat: "HP", bonus: 4), LeaderBonus(stat: "ATT", bonus: 4)]),
                            
                            "Slime": Monster(idLabel: 25,name: "Slime", level: 6, statHP: 45, statATT: 35, statDEF: 30, statSPATT: 52, statSPDEF: 50, statSPD: 42, abilities: [abilityList["Sticky Slime"] ?? defaultAbility, abilityList["Aqua Slime"] ?? defaultAbility], lockedAbility1: abilityList["Searing Slime"] ?? defaultAbility, lockedAbility2: abilityList["Poison Slime"] ?? defaultAbility, passive1: defaultPassive, passive2: defaultPassive, resistances: [.Ground: 100, .Fire: 200, .Water: 50, .Neutral: 100, .Ice: 150, .Nature: 75, .Poison: 50, .Shadow: 100, .Holy: 200,.Electric: 175], leaderBonus:  [LeaderBonus(stat: "SPATT", bonus: 3), LeaderBonus(stat: "SPDEF", bonus: 2)]),
                            "Bubbling": Monster(idLabel: 26,name: "Bubbling", level: 9, statHP: 47, statATT: 35, statDEF: 30, statSPATT: 57, statSPDEF: 50, statSPD: 43, abilities: [abilityList["Aqua Slime"] ?? defaultAbility, abilityList["Poison Slime"] ?? defaultAbility], lockedAbility1: abilityList["Icy Slime"] ?? defaultAbility, lockedAbility2: abilityList["Dark Slime"] ?? defaultAbility, passive1: defaultPassive, passive2: defaultPassive, resistances: [.Ground: 100, .Fire: 150, .Water: 50, .Neutral: 100, .Ice: 200, .Nature: 125, .Poison: 50, .Shadow: 100, .Holy: 200,.Electric: 250], leaderBonus:  [LeaderBonus(stat: "SPATT", bonus: 3), LeaderBonus(stat: "SPDEF", bonus: 3)]),
                            "Octopus": Monster(idLabel: 27,name: "Octopus", level: 9, statHP: 68, statATT: 42, statDEF: 30, statSPATT: 44, statSPDEF: 32, statSPD: 24, abilities: [abilityList["Ink Spray"] ?? defaultAbility, abilityList["Tentacle Whip"] ?? defaultAbility], lockedAbility1: abilityList["Regenerate"] ?? defaultAbility, lockedAbility2: abilityList["Regenerate"] ?? defaultAbility, passive1: defaultPassive, passive2: defaultPassive, resistances: [.Ground: 100, .Fire: 150, .Water: 50, .Neutral: 100, .Ice: 150, .Nature: 125, .Poison: 50, .Shadow: 100, .Holy: 125,.Electric: 250], leaderBonus:  [LeaderBonus(stat: "HP", bonus: 6)]),
                            "Jr Necki": Monster(idLabel: 28,name: "Jr Necki", level: 9, statHP: 42, statATT: 62, statDEF: 41, statSPATT: 40, statSPDEF: 41, statSPD: 64, abilities: [abilityList["Poison Bite"] ?? defaultAbility], lockedAbility1: abilityList["Tail Lash"] ?? defaultAbility, lockedAbility2: abilityList["Toxic Fang"] ?? defaultAbility, passive1: defaultPassive, passive2: defaultPassive, resistances: [.Ground: 100, .Fire: 175, .Water: 50, .Neutral: 100, .Ice: 150, .Nature: 75, .Poison: 50, .Shadow: 100, .Holy: 175,.Electric: 200], leaderBonus:  [LeaderBonus(stat: "SPD", bonus: 7)]),
                            //Ligator
                            //Wraith
                            
                            
                            
                            
                            
                            "Muru": Monster(idLabel: 0,name: "Muru", level: 1, statHP: 40, statATT: 41, statDEF: 35, statSPATT: 32, statSPDEF: 40, statSPD: 30, abilities: [abilityList["Tackle"] ?? defaultAbility],lockedAbility1: abilityList["Chilly Bite"] ?? defaultAbility, lockedAbility2: abilityList["Slam"] ?? defaultAbility,passive1: defaultPassive, passive2: defaultPassive,  resistances: [.Ground: 100, .Fire: 200, .Water: 80, .Neutral: 100, .Ice: 50, .Nature: 100, .Poison: 125, .Shadow: 125, .Holy: 75,.Electric: 175], leaderBonus:  [LeaderBonus(stat: "ATT", bonus: 5)]),
                            
                            
                            "Stump": Monster(idLabel: 49,name: "Stump", level: 5, statHP: 45, statATT: 40, statDEF: 44, statSPATT: 20, statSPDEF: 38, statSPD: 18, abilities: [abilityList["Entangle"] ?? defaultAbility], lockedAbility1: abilityList["Photosynthesis"] ?? defaultAbility, lockedAbility2: abilityList["Slam"] ?? defaultAbility,passive1: defaultPassive, passive2: defaultPassive,resistances: [.Ground: 80, .Fire: 250, .Water: 75, .Neutral: 85, .Ice: 150, .Nature: 75, .Poison: 150, .Shadow: 100, .Holy: 100,.Electric: 75], leaderBonus:  [LeaderBonus(stat: "DEF", bonus: 5)]),
                            "Dark Stump": Monster(idLabel: 50,name: "Dark Stump", level: 9, statHP: 51, statATT: 48, statDEF: 49, statSPATT: 22, statSPDEF: 43, statSPD: 18, abilities: [abilityList["Shadow Bind"] ?? defaultAbility, abilityList["Entangle"] ?? defaultAbility], lockedAbility1: defaultAbility, lockedAbility2: defaultAbility, passive1: defaultPassive, passive2: defaultPassive, resistances: [.Ground: 80, .Fire: 250, .Water: 75, .Neutral: 85, .Ice: 150, .Nature: 75, .Poison: 150, .Shadow: 75, .Holy: 200,.Electric: 75], leaderBonus:  [LeaderBonus(stat: "ATT", bonus: 3), LeaderBonus(stat: "DEF", bonus: 3)]),
                            "Axe Stump": Monster(idLabel: 51,name: "Axe Stump", level: 10, statHP: 43, statATT: 65, statDEF: 40, statSPATT: 20, statSPDEF: 36, statSPD: 18, abilities: [abilityList["Axe Fury"] ?? defaultAbility, abilityList["Entangle"] ?? defaultAbility], lockedAbility1: abilityList["Photosynthesis"] ?? defaultAbility, lockedAbility2: defaultAbility, passive1: defaultPassive, passive2: defaultPassive, resistances: [.Ground: 80, .Fire: 250, .Water: 75, .Neutral: 85, .Ice: 150, .Nature: 75, .Poison: 150, .Shadow: 100, .Holy: 100,.Electric: 75], leaderBonus:  [LeaderBonus(stat: "ATT", bonus: 6)]),
                            "Dark Axe Stump": Monster(idLabel: 52,name: "Dark Axe Stump", level: 11, statHP: 46, statATT: 72, statDEF: 44, statSPATT: 20, statSPDEF: 39, statSPD: 18, abilities: [abilityList["Shadow Bind"] ?? defaultAbility, abilityList["Axe Fury"] ?? defaultAbility], lockedAbility1: defaultAbility, lockedAbility2: defaultAbility, passive1: defaultPassive, passive2: defaultPassive, resistances: [.Ground: 80, .Fire: 250, .Water: 75, .Neutral: 85, .Ice: 150, .Nature: 75, .Poison: 150, .Shadow: 75, .Holy: 200,.Electric: 75], leaderBonus:  [LeaderBonus(stat: "ATT", bonus: 7)]),
                            //Wooden Mask
                            //Rocky Mask
                            
                            "Fierry": Monster(idLabel: 75,name: "Fierry", level: 11, statHP: 45, statATT: 30, statDEF: 35, statSPATT: 65, statSPDEF: 54, statSPD: 48, abilities: [abilityList["Nature Pulse"] ?? defaultAbility, abilityList["Magic Bolt"] ?? defaultAbility], lockedAbility1: abilityList["Energy Bolt"] ?? defaultAbility, lockedAbility2: abilityList["Icy Bolt"] ?? defaultAbility, passive1: defaultPassive, passive2: defaultPassive, resistances: [.Ground: 75, .Fire: 175, .Water: 100, .Neutral: 100, .Ice: 125, .Nature: 75, .Poison: 150, .Shadow: 200, .Holy: 50,.Electric: 150], leaderBonus:  [LeaderBonus(stat: "SPATT", bonus: 8)]),
                            //Evil Eye
                            //Curse Eye
                            //Lupin
                            //Zombie Lupin
                            //Malady
                            
                            "Black Cat": Monster(idLabel: 102,name: "Black Cat", level: 4, statHP: 45, statATT: 50, statDEF: 40, statSPATT: 35, statSPDEF: 38, statSPD: 55, abilities: [abilityList["Scratch"] ?? defaultAbility, abilityList["Shadow Pounce"] ?? defaultAbility], lockedAbility1: abilityList["Feline Agility"] ?? defaultAbility, lockedAbility2: abilityList["Shadow Swipe"] ?? defaultAbility, passive1: defaultPassive, passive2: defaultPassive, resistances: [.Ground: 100, .Fire: 200, .Water: 125, .Neutral: 100, .Ice: 125, .Nature: 100, .Poison: 125, .Shadow: 50, .Holy: 200,.Electric: 175], leaderBonus:  [LeaderBonus(stat: "SPD", bonus: 6)]),
                            "Fox": Monster(idLabel: 103,name: "Fox", level: 4, statHP: 47, statATT: 54, statDEF: 41, statSPATT: 25, statSPDEF: 38, statSPD: 48, abilities: [abilityList["Poison Bite"] ?? defaultAbility, abilityList["Shadow Pounce"] ?? defaultAbility], lockedAbility1: abilityList["Piercing Howl"] ?? defaultAbility, lockedAbility2: abilityList["Slash"] ?? defaultAbility, passive1: defaultPassive, passive2: defaultPassive, resistances: [.Ground: 100, .Fire: 200, .Water: 100, .Neutral: 100, .Ice: 125, .Nature: 100, .Poison: 150, .Shadow: 50, .Holy: 200,.Electric: 175], leaderBonus:  [LeaderBonus(stat: "ATT", bonus: 3), LeaderBonus(stat: "SPD", bonus: 3)]),
                            "Frog": Monster(idLabel: 104,name: "Frog", level: 7, statHP: 40, statATT: 35, statDEF: 38, statSPATT: 55, statSPDEF: 40, statSPD: 45, abilities: [abilityList["Aqua Slime"] ?? defaultAbility, abilityList["Poison Dart"] ?? defaultAbility], lockedAbility1: abilityList["Aqua Pulse"] ?? defaultAbility, lockedAbility2: abilityList["Aqua Pulse"] ?? defaultAbility, passive1: defaultPassive, passive2: defaultPassive, resistances: [.Ground: 100, .Fire: 125, .Water: 50, .Neutral: 100, .Ice: 125, .Nature: 125, .Poison: 75, .Shadow: 125, .Holy: 75,.Electric: 250], leaderBonus:  [LeaderBonus(stat: "SPATT", bonus: 3), LeaderBonus(stat: "SPD", bonus: 3)]),
        ]
        
        self.missions = [:]
        
        if let savedPlayerData = UserDefaults.standard.data(forKey: "Player"),
           let decodedPlayer = try? JSONDecoder().decode(Player.self, from: savedPlayerData) {
            player = decodedPlayer
        } else {
            let defaultPartyList = [Monster(idLabel: 0,name: "Muru", level: 1, statHP: 40, statATT: 41, statDEF: 35, statSPATT: 32, statSPDEF: 40, statSPD: 30, abilities: [abilityList["Tackle"] ?? defaultAbility],lockedAbility1: abilityList["Chilly Bite"] ?? defaultAbility, lockedAbility2: abilityList["Slam"] ?? defaultAbility,passive1: defaultPassive, passive2: defaultPassive,  resistances: [.Ground: 100, .Fire: 200, .Water: 80, .Neutral: 100, .Ice: 50, .Nature: 100, .Poison: 125, .Shadow: 125, .Holy: 75,.Electric: 175], leaderBonus:  [LeaderBonus(stat: "ATT", bonus: 3)]),
                                    Monster(idLabel: 0,name: "Empty", level: 1, statHP: 40, statATT: 41, statDEF: 35, statSPATT: 32, statSPDEF: 40, statSPD: 30, abilities: [abilityList["Tackle"] ?? defaultAbility],lockedAbility1: abilityList["Chilly Bite"] ?? defaultAbility, lockedAbility2: abilityList["Slam"] ?? defaultAbility,passive1: defaultPassive, passive2: defaultPassive,  resistances: [.Ground: 100, .Fire: 200, .Water: 85, .Neutral: 100, .Ice: 50, .Nature: 100, .Poison: 125, .Shadow: 125, .Holy: 75,.Electric: 175], leaderBonus:  [LeaderBonus(stat: "ATT", bonus: 3)]),
                                    Monster(idLabel: 0,name: "Empty", level: 1, statHP: 40, statATT: 41, statDEF: 35, statSPATT: 32, statSPDEF: 40, statSPD: 30, abilities: [abilityList["Tackle"] ?? defaultAbility],lockedAbility1: abilityList["Chilly Bite"] ?? defaultAbility, lockedAbility2: abilityList["Slam"] ?? defaultAbility,passive1: defaultPassive, passive2: defaultPassive,  resistances: [.Ground: 100, .Fire: 200, .Water: 85, .Neutral: 100, .Ice: 50, .Nature: 100, .Poison: 125, .Shadow: 125, .Holy: 75,.Electric: 175], leaderBonus:  [LeaderBonus(stat: "ATT", bonus: 3)]),
            
            ]
            player = Player(name: "", level: 1, currentExp: 0, cash: 0, gems: 0,partyList: defaultPartyList, ownedList: defaultPartyList, missionsUnlocked: ["Maple Island":1, "Henesys":1, "Perion": 1, "Ellinia": 1, "Kerning City": 1, "Sleepywood": 1, "Florina Beach": 1])
        }
        currentEnemy = Monster(name: "Snail", level: 1, statHP: 32, statATT: 30, statDEF: 38, statSPATT: 32, statSPDEF: 36, statSPD: 20, abilities: [ abilityList["Mud Spit"] ?? defaultAbility], lockedAbility1: abilityList["Harden Shell"] ?? defaultAbility,lockedAbility2: abilityList["Sticky Slime"] ?? defaultAbility, passive1: passiveList["Desperation"] ?? defaultPassive, passive2: passiveList["None"] ?? defaultPassive, resistances: [.Ground: 80, .Fire: 200, .Water: 90, .Neutral: 100, .Ice: 100, .Nature: 80, .Poison: 100, .Shadow: 100, .Holy: 100,.Electric: 75])
        currentPlayerMonster = Monster(name: "Snail", level: 1, statHP: 32, statATT: 30, statDEF: 38, statSPATT: 32, statSPDEF: 36, statSPD: 20, abilities: [ abilityList["Mud Spit"] ?? defaultAbility], lockedAbility1: abilityList["Harden Shell"] ?? defaultAbility,lockedAbility2: abilityList["Sticky Slime"] ?? defaultAbility, passive1: passiveList["Desperation"] ?? defaultPassive, passive2: passiveList["None"] ?? defaultPassive, resistances: [.Ground: 80, .Fire: 200, .Water: 90, .Neutral: 100, .Ice: 100, .Nature: 80, .Poison: 100, .Shadow: 100, .Holy: 100,.Electric: 75])
    }
    
    
    
    public func useMonster(name: String, level: Int, ability1Active: Bool, ability2Active: Bool, ascension: Int = 0) -> Monster{
        var mon = monsterList[name]
        mon?.level = level
        mon?.ability1Active = ability1Active
        mon?.ability2Active = ability2Active
        mon?.ascension = ascension
        return mon ?? Monster(name: "Empty", level: 1, statHP: 40, statATT: 41, statDEF: 35, statSPATT: 32, statSPDEF: 40, statSPD: 30, abilities: [abilityList["Tackle"] ?? defaultAbility],lockedAbility1: abilityList["Chilly Bite"] ?? defaultAbility, lockedAbility2: abilityList["Slam"] ?? defaultAbility,passive1: defaultPassive, passive2: defaultPassive,  resistances: [.Ground: 100, .Fire: 200, .Water: 85, .Neutral: 100, .Ice: 50, .Nature: 100, .Poison: 125, .Shadow: 125, .Holy: 75,.Electric: 75])
    }
    
    
    
    
    
    private func delay() async{
        try? await Task.sleep(nanoseconds:300_000_000)
        hasTimeElapsed = true
    }
    
    public func refillEnergy(){
        if(self.player.gems >= self.energyRechargeCost){
            self.player.gems -= self.energyRechargeCost
            self.player.currentEnergy += self.player.maximumEnergy/2
        }
    }
    
    public func loadGame(){
        self.missions = ["Small Forest": Mission(map: "Maple Island", name: "Small Forest", energyCost: 3, captureRate: 40, description: "You venture into the Small Forest, where the sunlight filters through the leaves above, casting dappled shadows on the forest floor. What awaits inside this peaceful yet mysterious woodland?", expReward: 15, cashReward: 125, enemyTeam: [useMonster(name: "Snail", level: 1, ability1Active: false, ability2Active: false)], recommendedLevel: "1"),
                         "Adventurer's Training 1": Mission(map: "Maple Island", name: "Adventurer's Training 1", energyCost: 3, captureRate: 39, description: "You discover a training center nestled in the woods, designed for new adventurers. Here, experienced tamers offer guidance and basic training. This seems like a good place to hone your skills and prepare for the challenges ahead.", expReward: 16, cashReward: 150, enemyTeam: [useMonster(name: "Blue Snail", level: 2, ability1Active: false, ability2Active: false),useMonster(name: "Snail", level: 1, ability1Active: false, ability2Active: false)], recommendedLevel: "2"),
                         "Adventurer's Training 2": Mission(map: "Maple Island", name: "Adventurer's Training 2", energyCost: 3, captureRate: 38, description: "The training regimen intensifies, pushing your abilities to the limit. You find yourself battling stronger monsters and learning advanced tactics. Each session makes you a little more prepared for the real world.", expReward: 17, cashReward: 175, enemyTeam: [useMonster(name: "Shroom", level: 3, ability1Active: false, ability2Active: false),useMonster(name: "Blue Snail", level: 2, ability1Active: false, ability2Active: false)], recommendedLevel: "3"),
                         "Adventurer's Training 3": Mission(map: "Maple Island", name: "Adventurer's Training 3", energyCost: 3, captureRate: 0, description: "Tamer Mai, a seasoned expert, has been observing your progress. You learn that monsters can ascend and learn new abilities. Now, she wants to test your skills in a real battle. This is the final lesson, where you must prove your readiness to move beyond basic training.", expReward: 20, cashReward: 225, enemyTeam: [useMonster(name: "Shroom", level: 3, ability1Active: true, ability2Active: false, ascension: 3),useMonster(name: "Green Mushroom", level: 2, ability1Active: false, ability2Active: false, ascension: 5), useMonster(name: "Blue Snail", level: 3, ability1Active: true, ability2Active: true, ascension: 3)], recommendedLevel: "3"),
                         "Deep Forest 1": Mission(map: "Maple Island", name: "Deep Forest 1", energyCost: 4, captureRate: 37, description: "Feeling adventurous, you decide to delve deeper into the forest. The air grows cooler, and the sounds of wildlife surround you. With each step, the path becomes less clear, and the forest more enigmatic.", expReward: 27, cashReward: 225, enemyTeam: [useMonster(name: "Red Snail", level: 4, ability1Active: false, ability2Active: false),useMonster(name: "Shroom", level: 4, ability1Active: false, ability2Active: false)], recommendedLevel: "4"),
                         "Deep Forest 2": Mission(map: "Maple Island", name: "Deep Forest 2", energyCost: 4, captureRate: 36, description: "As you venture further, the monsters become noticeably tougher. You must stay on high alert, ready to face any challenge that emerges from the dense foliage.", expReward: 29, cashReward: 275, enemyTeam: [useMonster(name: "Stump", level: 5, ability1Active: false, ability2Active: false)], recommendedLevel: "5"),
                         "Deep Forest 3": Mission(map: "Maple Island", name: "Deep Forest 3", energyCost: 4, captureRate: 35, description: "The trees grow denser, their thick canopies almost blocking out the light. The path is barely visible through the thick underbrush, and navigating this area requires careful attention and skill.", expReward: 31, cashReward: 325, enemyTeam: [useMonster(name: "Stump", level: 5, ability1Active: false, ability2Active: false),useMonster(name: "Red Snail", level: 4, ability1Active: false, ability2Active: true)], recommendedLevel: "5"),
                         "Deep Forest 4": Mission(map: "Maple Island", name: "Deep Forest 4", energyCost: 4, captureRate: 0, description: "In the heart of the forest, a mysterious tamer appears and challenges you to a battle. Their monster is formidable, and defeating them will test the limits of your training and strategy.", expReward: 35, cashReward: 400, enemyTeam: [useMonster(name: "Black Cat", level: 6, ability1Active: false, ability2Active: false),useMonster(name: "Fox", level: 4, ability1Active: true, ability2Active: false, ascension: 1),useMonster(name: "Octopus", level: 4, ability1Active: false, ability2Active: false, ascension: 1)], recommendedLevel: "6"),
                         "Path to the Harbor 1": Mission(map: "Maple Island", name: "Path to the Harbor 1", energyCost: 4, captureRate: 34, description: "You emerge from the forest to see the harbor far off in the distance. The journey to reach it is fraught with dangers, but the promise of new adventures spurs you on.", expReward: 33, cashReward: 400, enemyTeam: [useMonster(name: "Slime", level: 6, ability1Active: false, ability2Active: false),useMonster(name: "Stump", level: 5, ability1Active: false, ability2Active: false)], recommendedLevel: "6"),
                         "Path to the Harbor 2": Mission(map: "Maple Island", name: "Path to the Harbor 2", energyCost: 4, captureRate: 33, description: "Weary from your journey, you take a rest by the side of the road. However, the local monsters won't give you peace, forcing you to defend yourself even as you try to recover your strength.", expReward: 36, cashReward: 450, enemyTeam: [useMonster(name: "Slime", level: 6, ability1Active: false, ability2Active: false),useMonster(name: "Slime", level: 6, ability1Active: true, ability2Active: false)], recommendedLevel: "6"),
                         "Path to the Harbor 3": Mission(map: "Maple Island", name: "Path to the Harbor 3", energyCost: 4, captureRate: 32, description: "As you press on towards the harbor, another group of aggressive monsters blocks your path. Defeating them is the only way to continue your journey.", expReward: 39, cashReward: 500, enemyTeam: [useMonster(name: "Orange Mushroom", level: 7, ability1Active: false, ability2Active: false),useMonster(name: "Slime", level: 6, ability1Active: false, ability2Active: false)], recommendedLevel: "7"),
                         "Harbor Challenge": Mission(map: "Maple Island", name: "Harbor Challenge", energyCost: 5, captureRate: 0, description: "You’ve reached the final challenge on Maple Island. To leave this island and venture into the vast world beyond, you must prove your skills as a monster tamer. The Guardian of the Island awaits, ready to test your mettle in a decisive battle.", expReward: 60, cashReward: 700, enemyTeam: [useMonster(name: "Shroom", level: 8, ability1Active: true, ability2Active: true, ascension: 6),useMonster(name: "Orange Mushroom", level: 7, ability1Active: false, ability2Active: false),useMonster(name: "Frog", level: 8, ability1Active: false, ability2Active: false)], recommendedLevel: "8"),
                         
                         
                         "Hunting Grounds 1": Mission(map: "Henesys", name: "Hunting Grounds 1", energyCost: 5, captureRate: 30, description: "You take the taxi to Henesys. You see many tamers enter the Hunting Grounds. You join them to see what is there.", expReward: 59, cashReward: 700, enemyTeam: [useMonster(name: "Pig", level: 8, ability1Active: false, ability2Active: false),useMonster(name: "Orange Mushroom", level: 7, ability1Active: true, ability2Active: false), useMonster(name: "Red Snail", level: 7, ability1Active: false, ability2Active: true)], recommendedLevel: "8"),
                         "Hunting Grounds 2": Mission(map: "Henesys", name: "Hunting Grounds 2", energyCost: 5, captureRate: 30, description: "As you venture deeper into the Hunting Grounds, the scenery becomes more rugged and the monsters more challenging. You can hear the sounds of other tamers battling in the distance. The thrill of the hunt is palpable.", expReward: 64, cashReward: 750, enemyTeam: [useMonster(name: "Pig", level: 8, ability1Active: true, ability2Active: false),useMonster(name: "Pig", level: 8, ability1Active: false, ability2Active: false),useMonster(name: "Orange Mushroom", level: 8, ability1Active: true, ability2Active: false)], recommendedLevel: "8"),
                         "Hunting Grounds 3": Mission(map: "Henesys", name: "Hunting Grounds 3", energyCost: 5, captureRate: 30, description: "You discover a secluded part of the Hunting Grounds, teeming with more aggressive and powerful monsters. The area is lush with greenery, and you can sense the presence of formidable foes hiding in the shadows. This is a perfect place to test your skills and grow stronger.", expReward: 75, cashReward: 800, enemyTeam:[useMonster(name: "Green Mushroom", level: 9, ability1Active: false, ability2Active: false),useMonster(name: "Slime", level: 8, ability1Active: true, ability2Active: true, ascension: 6),useMonster(name: "Pig", level: 9, ability1Active: true, ability2Active: false)], recommendedLevel: "9"),
                         "Tamer Challenge 1": Mission(map: "Henesys", name: "Tamer Challenge 1", energyCost: 5, captureRate: 0, description: "Some tamers want to battle to test their skills.", expReward: 85, cashReward: 900, enemyTeam:[useMonster(name: "Fierry", level: 10, ability1Active: true, ability2Active: false),useMonster(name: "Muru", level: 10, ability1Active: true, ability2Active: true, ascension: 6),useMonster(name: "Pig", level: 10, ability1Active: true, ability2Active: false)], recommendedLevel: "10"),
                         "Tamer Challenge 2": Mission(map: "Henesys", name: "Tamer Challenge 2", energyCost: 5, captureRate: 0, description: "Another tamer wants to battle.", expReward: 95, cashReward: 1000, enemyTeam:[useMonster(name: "Green Mushroom", level: 11, ability1Active: true, ability2Active: true, ascension: 3),useMonster(name: "Dark Axe Stump", level: 11, ability1Active: true, ability2Active: false, ascension: 3),useMonster(name: "Octopus", level: 11, ability1Active: true, ability2Active: false)], recommendedLevel: "11"),
                         "Tamer Challenge 3": Mission(map: "Henesys", name: "Tamer Challenge 3", energyCost: 5, captureRate: 0, description: "One final tamer wants to battle.", expReward: 105, cashReward: 1100, enemyTeam:[useMonster(name: "Horny Mushroom", level: 12, ability1Active: true, ability2Active: true, ascension: 3),useMonster(name: "Blue Mushroom", level: 12, ability1Active: true, ability2Active: false, ascension: 3),useMonster(name: "Bubbling", level: 12, ability1Active: true, ability2Active: false, ascension: 3)], recommendedLevel: "12"),
                         "Pig Farm": Mission(map: "Henesys", name: "Pig Farm", energyCost: 5, captureRate: 27, description: "You visit the Pig Farm.", expReward: 140, cashReward: 1400, enemyTeam:[useMonster(name: "Pig", level: 14, ability1Active: true, ability2Active: true, ascension: 5),useMonster(name: "Ribbon Pig", level: 14, ability1Active: true, ability2Active: true, ascension: 3),useMonster(name: "Ribbon Pig", level: 14, ability1Active: true, ability2Active: false, ascension: 3)], recommendedLevel: "14"),
                         
                         
                         "Perion Entrance": Mission(map: "Perion", name: "Perion Entrance", energyCost: 5, captureRate: 0, description: "As you approach the entrance to Perion, a village renowned for its warrior training, a seasoned tamer steps forward to block your path. His steely gaze and imposing presence make it clear that only the strong are allowed to enter. 'If you wish to pass, you'll need to prove your strength in battle,' he declares. Prepare yourself for a challenging fight to earn your right to enter Perion.", expReward: 75, cashReward: 800, enemyTeam: [useMonster(name: "Dark Stump", level: 9, ability1Active: false, ability2Active: false),useMonster(name: "Stump", level: 9, ability1Active: false, ability2Active: true, ascension: 3),useMonster(name: "Red Snail", level: 9, ability1Active: true, ability2Active: true, ascension: 5)], recommendedLevel: "9"),
                         "Perion Trial 1": Mission(map: "Perion", name: "Perion Trial 1", energyCost: 5, captureRate: 0, description: "Having proven your worth at the entrance, you venture deeper into Perion. As you navigate through the rugged terrain, another tamer, adorned in warrior gear, emerges to challenge you. 'Only those who can withstand the harsh trials of this land deserve to proceed,' he asserts. This trial will test your strength and resilience as you face off against formidable opponents.", expReward: 85, cashReward: 900, enemyTeam: [useMonster(name: "Dark Stump", level: 10, ability1Active: false, ability2Active: false, ascension: 0),useMonster(name: "Axe Stump", level: 10, ability1Active: false, ability2Active: false, ascension: 2),useMonster(name: "Frog", level: 9, ability1Active: true, ability2Active: true, ascension: 6)], recommendedLevel: "10"),
                         "Perion Trial 2": Mission(map: "Perion", name: "Perion Trial 2", energyCost: 5, captureRate: 0, description: "Deeper into Perion, the trials grow even more demanding. As you approach a steep incline, a veteran tamer with an air of experience and confidence steps forward. 'You've come far, but this is where many falter,' he warns. 'Show me the strength that brought you this far.' The battles ahead are tougher than ever, pushing your skills and strategies to the limit.", expReward: 95, cashReward: 1000, enemyTeam: [useMonster(name: "Fierry", level: 11, ability1Active: false, ability2Active: false, ascension: 0), useMonster(name: "Axe Stump", level: 11, ability1Active: false, ability2Active: false, ascension: 2), useMonster(name: "Dark Axe Stump", level: 11, ability1Active: false, ability2Active: false)], recommendedLevel: "11"),
                         "Rocky Mountain 1": Mission(map: "Perion", name: "Rocky Mountain 1", energyCost: 5, captureRate: 29, description: "You meet the leader of Perion, Dances with Balrog. He tells you of a hidden threat deep within Perion. If you clear the threat, you will be greatly rewarded. You decide to enter the Rocky Mountains.", expReward: 95, cashReward: 1000, enemyTeam: [useMonster(name: "Stump", level: 11, ability1Active: true, ability2Active: true, ascension: 6), useMonster(name: "Dark Stump", level: 11, ability1Active: false, ability2Active: false, ascension: 1), useMonster(name: "Axe Stump", level: 11, ability1Active: false, ability2Active: false)], recommendedLevel: "11"),
                         "Rocky Mountain 2": Mission(map: "Perion", name: "Rocky Mountain 2", energyCost: 5, captureRate: 29, description: "You don't notice any imminent dangers in the Rocky Mountains. Only stumps inhabit it.", expReward: 105, cashReward: 1100, enemyTeam: [useMonster(name: "Dark Stump", level: 12, ability1Active: false, ability2Active: false, ascension: 2), useMonster(name: "Axe Stump", level: 12, ability1Active: false, ability2Active: false, ascension: 1), useMonster(name: "Axe Stump", level: 12, ability1Active: false, ability2Active: false)], recommendedLevel: "12"),
                         "Rocky Mountain 3": Mission(map: "Perion", name: "Rocky Mountain 3", energyCost: 5, captureRate: 29, description: "You don't notice any imminent dangers in the Rocky Mountains. Only stumps inhabit it.", expReward: 120, cashReward: 1250, enemyTeam: [useMonster(name: "Dark Stump", level: 13, ability1Active: false, ability2Active: false, ascension: 2), useMonster(name: "Axe Stump", level: 13, ability1Active: false, ability2Active: false, ascension: 2), useMonster(name: "Dark Axe Stump", level: 13, ability1Active: false, ability2Active: false)], recommendedLevel: "13"),
                         
                         
                         "Construction Site 1": Mission(map: "Kerning City", name: "Construction Site 1", energyCost: 5, captureRate: 29, description: "On your way to Kerning, you see a construction site. There are some strange monsters here.", expReward: 85, cashReward: 900, enemyTeam: [useMonster(name: "Octopus", level: 10, ability1Active: false, ability2Active: false, ascension: 1), useMonster(name: "Slime", level: 10, ability1Active: true, ability2Active: false, ascension: 4), useMonster(name: "Red Snail", level: 10, ability1Active: true, ability2Active: true, ascension: 5)], recommendedLevel: "10"),
                         "Construction Site 2": Mission(map: "Kerning City", name: "Construction Site 2", energyCost: 5, captureRate: 29, description: "You decide to explore the construction site more. You see some new monsters here.", expReward: 95, cashReward: 1000, enemyTeam: [useMonster(name: "Octopus", level: 11, ability1Active: false, ability2Active: false, ascension: 1), useMonster(name: "Orange Mushroom", level: 11, ability1Active: true, ability2Active: true, ascension: 4), useMonster(name: "Bubbling", level: 11, ability1Active: false, ability2Active: false, ascension: 0)], recommendedLevel: "11"),
                         "Construction Site 3": Mission(map: "Kerning City", name: "Construction Site 2", energyCost: 5, captureRate: 29, description: "You decide to explore the construction site more. You see some new monsters here.", expReward: 105, cashReward: 1100, enemyTeam: [useMonster(name: "Octopus", level: 12, ability1Active: false, ability2Active: false, ascension: 2), useMonster(name: "Bubbling", level: 12, ability1Active: true, ability2Active: false, ascension: 2), useMonster(name: "Bubbling", level: 12, ability1Active: false, ability2Active: true, ascension: 1)], recommendedLevel: "12"),
                         "Kerning Thugs 1": Mission(map: "Kerning City", name: "Kerning Thugs 1", energyCost: 5, captureRate: 0, description: "You enter Kerning City. Some thugs block your path.", expReward: 125, cashReward: 1400, enemyTeam: [useMonster(name: "Black Cat", level: 13, ability1Active: false, ability2Active: true, ascension: 3), useMonster(name: "Fox", level: 13, ability1Active: true, ability2Active: true, ascension: 0), useMonster(name: "Bubbling", level: 13, ability1Active: true, ability2Active: true, ascension: 1)], recommendedLevel: "13"),
                         "Kerning Thugs 2": Mission(map: "Kerning City", name: "Kerning Thugs 2", energyCost: 5, captureRate: 0, description: "You enter Kerning City. Some thugs block your path.", expReward: 140, cashReward: 1400, enemyTeam: [useMonster(name: "Horny Mushroom", level: 14, ability1Active: false, ability2Active: true, ascension: 5), useMonster(name: "Fox", level: 14, ability1Active: true, ability2Active: true, ascension: 3), useMonster(name: "Jr Necki", level: 14, ability1Active: true, ability2Active: true, ascension: 1)], recommendedLevel: "14"),
                         
                         "Ellinia Forest 1": Mission(map: "Ellinia", name: "Ellinia Forest 1", energyCost: 5, captureRate: 28, description: "The forests of Ellinia are vast. There is much to explore.", expReward: 95, cashReward: 1000, enemyTeam: [useMonster(name: "Slime", level: 11, ability1Active: true, ability2Active: true, ascension: 6), useMonster(name: "Green Mushroom", level: 11, ability1Active: true, ability2Active: true, ascension: 0), useMonster(name: "Axe Stump", level: 11, ability1Active: true, ability2Active: true, ascension: 1)], recommendedLevel: "11"),
                         "Ellinia Forest 2": Mission(map: "Ellinia", name: "Ellinia Forest 2", energyCost: 5, captureRate: 28, description: "The forests of Ellinia are vast. There is much to explore.", expReward: 105, cashReward: 1100, enemyTeam: [useMonster(name: "Bubbling", level: 12, ability1Active: true, ability2Active: false, ascension: 1), useMonster(name: "Fierry", level: 12, ability1Active: true, ability2Active: true, ascension: 0), useMonster(name: "Horny Mushroom", level: 12, ability1Active: true, ability2Active: false, ascension: 1)], recommendedLevel: "12"),
                         "Ellinia Forest 3": Mission(map: "Ellinia", name: "Ellinia Forest 3", energyCost: 5, captureRate: 28, description: "The forests of Ellinia are vast. There is much to explore.", expReward: 115, cashReward: 1200, enemyTeam: [useMonster(name: "Blue Mushroom", level: 13, ability1Active: true, ability2Active: false, ascension: 1), useMonster(name: "Fierry", level: 13, ability1Active: true, ability2Active: false, ascension: 4), useMonster(name: "Horny Mushroom", level: 13, ability1Active: false, ability2Active: true, ascension: 2)], recommendedLevel: "13"),
                         
                         
                         ]
        let diffTime = lastGameDate.timeIntervalSinceNow
        self.player.monstersSeen.insert("Muru")
        print(self.player.monstersSeen)
        let awayFor = Int(-diffTime)
        let addEnergyAmount = awayFor/300
        let origEnergy = self.player.currentEnergy
        self.player.currentEnergy += addEnergyAmount
        if(self.player.currentEnergy > self.player.maximumEnergy){
            if(origEnergy < self.player.maximumEnergy){
                self.player.currentEnergy = self.player.maximumEnergy
            }
            else{
                self.player.currentEnergy = origEnergy
            }
            
        }
    }
    
    public func startEnergyTimer(){
        self.timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){_ in
            self.lastGameDate = Date.now
            self.player.energyTime -= 1
            if(self.player.currentEnergy >= self.player.maximumEnergy){
                self.player.energyTime = 1
            }
            if(self.player.energyTime <= 0){
                self.player.energyTime = 240
                if(self.player.currentEnergy < self.player.maximumEnergy){
                    self.player.currentEnergy += 1
                }
                
            }
            
        }
    }
    
    
    public func damageDealt(attacker: Monster, defender: Monster, ability: Ability, attackerBuffs: [Buff], defenderBuffs: [Buff], attackerDebuffs: [Debuff], defenderDebuffs: [Debuff], attackerLeaderBonus: [LeaderBonus], defenderLeaderBonus: [LeaderBonus]) -> Int{
        if(ability.power == 0){
            return 0
        }
        var crit = Int.random(in: 1...16)
        if(crit == 16){
            crit = 2
        }
        else{
            crit = 1
        }
        var attackerAtt = 0
        var attackerBoost = 0
        var defenderDef = 0
        var defenderBoost = 0
        var acc = ability.acc
        if(ability.type == "Physical"){
            attackerAtt = attacker.actualATT
            defenderDef = defender.actualDEF
            for leaderBonus in attackerLeaderBonus{
                if(leaderBonus.stat == "ATT"){
                    attackerAtt = attackerAtt * (100+leaderBonus.bonus) / 100
                }
            }
            for leaderBonus in defenderLeaderBonus{
                if(leaderBonus.stat == "DEF"){
                    defenderDef = defenderDef * (100+leaderBonus.bonus) / 100
                }
            }
            for buff in attackerBuffs{
                for num in 0..<buff.stat.count{
                    if(buff.stat[num] == "ATT"){
                        attackerBoost += buff.bonus[num]
                    }
                }
            }
            for debuff in attackerDebuffs{
                for num in 0..<debuff.stat.count{
                    if(debuff.stat[num] == "ATT"){
                        attackerBoost += debuff.bonus[num]
                    }
                    else if(debuff.stat[num] == "ACC"){
                        acc += debuff.bonus[num]
                    }
                }
            }
            for buff in defenderBuffs{
                for num in 0..<buff.stat.count{
                    if(buff.stat[num] == "DEF"){
                        defenderBoost += buff.bonus[num]
                    }
                }
            }
            for debuff in defenderDebuffs{
                for num in 0..<debuff.stat.count{
                    if(debuff.stat[num] == "DEF"){
                        defenderBoost += debuff.bonus[num]
                    }
                }
            }
        }
        else
        {
            attackerAtt = attacker.actualSPATT
            defenderDef = defender.actualSPDEF
            for leaderBonus in attackerLeaderBonus{
                if(leaderBonus.stat == "SPATT"){
                    attackerAtt = attackerAtt * (100+leaderBonus.bonus) / 100
                }
            }
            for leaderBonus in defenderLeaderBonus{
                if(leaderBonus.stat == "SPDEF"){
                    defenderDef = defenderDef * (100+leaderBonus.bonus) / 100
                }
            }
            for buff in attackerBuffs{
                for num in 0..<buff.stat.count{
                    if(buff.stat[num] == "SPATT"){
                        attackerBoost += buff.bonus[num]
                    }
                }
            }
            for debuff in attackerDebuffs{
                for num in 0..<debuff.stat.count{
                    if(debuff.stat[num] == "SPATT"){
                        attackerBoost += debuff.bonus[num]
                    }
                    else if(debuff.stat[num] == "ACC"){
                        acc += debuff.bonus[num]
                    }
                }
            }
            for buff in defenderBuffs{
                for num in 0..<buff.stat.count{
                    if(buff.stat[num] == "SPDEF"){
                        defenderBoost += buff.bonus[num]
                    }
                }
            }
            for debuff in defenderDebuffs{
                for num in 0..<debuff.stat.count{
                    if(debuff.stat[num] == "SPDEF"){
                        defenderBoost += debuff.bonus[num]
                    }
                }
            }
            
        }
        attackerAtt = attackerAtt * (100+attackerBoost) / 100
        defenderDef = defenderDef * (100+defenderBoost) / 100
        var damage = ((2*attacker.level/5) + 2) * ability.power * attackerAtt / defenderDef / 25
        damage = damage + 2
        switch(ability.attribute){
        case .Ground:
            damage = damage * (defender.resistances[.Ground] ?? 100) / 100
        case .Fire:
            damage = damage * (defender.resistances[.Fire] ?? 100) / 100
        case .Ice:
            damage = damage * (defender.resistances[.Ice] ?? 100) / 100
        case .Neutral:
            damage = damage * (defender.resistances[.Neutral] ?? 100) / 100
        case .Water:
            damage = damage * (defender.resistances[.Water] ?? 100) / 100
        case .Nature:
            damage = damage * (defender.resistances[.Nature] ?? 100) / 100
        case .Poison:
            damage = damage * (defender.resistances[.Poison] ?? 100) / 100
            
            
            
        case .Shadow:
            damage = damage * (defender.resistances[.Shadow] ?? 100) / 100
        case .Holy:
            damage = damage * (defender.resistances[.Holy] ?? 100) / 100
        case .Electric:
            damage = damage * (defender.resistances[.Electric] ?? 100) / 100
        }
        damage = damage * crit
        
        let randomMultiplier = Int.random(in: 180...255)
        damage = damage*randomMultiplier/255
        
        if(damage<1){
            damage = 1
        }
        if(acc != 100){
            let randomNum = Int.random(in:1...100)
                if(randomNum > acc){
                    damage = 0
                }
            
        }
        print("ACC: \(acc) \(attacker.name): \(damage)")
        return damage
    }
    
    public func setTeams(missionName: String, mapName: String){
        self.currentMission = missionName
        self.currentMap = mapName
        self.captureSuccess = false
        enemyTeamMonsters.removeAll()
        if let monsters = self.missions[missionName]?.enemyTeam{
            for monster in  monsters{
                    enemyTeamMonsters.insert(monster, at: 0)
                
            }
        }
        enemyTeamBeat = 0
        playerTeamBeat = 0
        playerTeamSize = player.partyList.count
        for monster in player.partyList{
            if monster.name == "Empty"{
                playerTeamSize -= 1
            }
        }
        self.player.partyList[0] = self.useMonster(name: self.player.ownedList[0].name, level: self.player.ownedList[0].level, ability1Active: self.player.ownedList[0].ability1Active, ability2Active: self.player.ownedList[0].ability2Active, ascension: self.player.ownedList[0].ascension)
        self.player.partyList[1] = self.useMonster(name: self.player.ownedList[1].name, level: self.player.ownedList[1].level, ability1Active: self.player.ownedList[1].ability1Active, ability2Active: self.player.ownedList[1].ability2Active, ascension: self.player.ownedList[1].ascension)
        self.player.partyList[2] = self.useMonster(name: self.player.ownedList[2].name, level: self.player.ownedList[2].level, ability1Active: self.player.ownedList[2].ability1Active, ability2Active: self.player.ownedList[2].ability2Active, ascension: self.player.ownedList[2].ascension)//self.player.ownedList[2]
        enemyTeamSize = enemyTeamMonsters.count
        enemyTeamMonsters.shuffle()
        self.currentEnemy = enemyTeamMonsters[0]
        self.currentEnemy.currentHP = enemyTeamMonsters[0].actualHP
        self.currentPlayerMonster = player.partyList[0]
        self.currentPlayerMonster.currentHP = player.partyList[0].actualHP
        
        if self.player.monstersSeen.contains(currentEnemy.name) == false{
            self.player.monstersSeen.insert(currentEnemy.name)
        }
        
        currentPlayerMonsterBuffs = []
        currentPlayerMonsterDebuffs = []
        currentEnemyBuffs = []
        currentEnemyDebuffs = []
        //self.partyLeaderBonus = self.player.partyList[0].leaderBonus
        //self.enemyLeaderBonus = self.enemyTeamMonsters[0].leaderBonus
    }
    
    public func levelUp(){
        self.player.currentExp -= self.expToNextLevel[self.player.level]
        self.player.level += 1
        self.player.maximumEnergy += 1
        self.player.currentEnergy += (self.player.maximumEnergy/4)
        self.player.gems += 100
        self.leveledUp = true
    }
    
    public func monsterLevelUp(monster: Monster) -> Monster{
        //let cost = monster.bst*monster.level*monster.level/3
        let cost2 = monster.bst*monster.level*Int(log2(Float(monster.level)))/4+100
        if(self.player.cash<cost2){
            return monster
        }
        player.cash -= cost2
        if let index = player.ownedList.firstIndex(of: monster)
        {
            player.ownedList[index].level += 1
            player.partyList[0] = player.ownedList[0]
            player.partyList[1] = player.ownedList[1]
            player.partyList[2] = player.ownedList[2]
            return player.ownedList[index]
        }
        return Monster(name: "Snail", level: 1, statHP: 32, statATT: 30, statDEF: 38, statSPATT: 32, statSPDEF: 36, statSPD: 20, abilities: [ abilityList["Mud Spit"] ?? defaultAbility], lockedAbility1: abilityList["Harden Shell"] ?? defaultAbility,lockedAbility2: abilityList["Sticky Slime"] ?? defaultAbility, passive1: passiveList["Desperation"] ?? defaultPassive, passive2: passiveList["None"] ?? defaultPassive, resistances: [.Ground: 80, .Fire: 200, .Water: 90, .Neutral: 100, .Ice: 100, .Nature: 80, .Poison: 100, .Shadow: 100])
        
    }
    
    public func win(){
        self.player.currentExp += self.missions[currentMission]?.expReward ?? 0
        self.player.cash += self.missions[currentMission]?.cashReward ?? 0
        self.playerWon = true
        if(self.player.currentExp>=self.expToNextLevel[self.player.level]){
            self.levelUp()
        }
        self.player.currentEnergy -= self.missions[currentMission]?.energyCost ?? 0
        
        let rand = Int.random(in: 1...100)
            if(rand <= self.missions[currentMission]?.captureRate  ?? 0){
                self.tameMonster()
                captureSuccess = true
                
        }
        
        if self.player.missionsBeat.contains(currentMission) == false{
            self.player.missionsBeat.insert(currentMission)
            if let num = self.player.missionsUnlocked[currentMap]{
                self.player.missionsUnlocked[currentMap] = num + 1
            }
            
        }
    }
    
    public func buyMonster(monster:String){
        let capturedMonster = self.monsterList[monster] ?? Monster(name: "Snail", level: 1, statHP: 32, statATT: 30, statDEF: 38, statSPATT: 32, statSPDEF: 36, statSPD: 20, abilities: [ abilityList["Mud Spit"] ?? defaultAbility], lockedAbility1: abilityList["Harden Shell"] ?? defaultAbility,lockedAbility2: abilityList["Sticky Slime"] ?? defaultAbility, passive1: passiveList["Desperation"] ?? defaultPassive, passive2: passiveList["None"] ?? defaultPassive, resistances: [.Ground: 80, .Fire: 200, .Water: 90, .Neutral: 100, .Ice: 100, .Nature: 80, .Poison: 100, .Shadow: 100, .Holy: 100])
        var isMonsterFound = false
        for (index,monster) in self.player.ownedList.enumerated() {
            if monster.name == capturedMonster.name{
                if(monster.ascension < 6){
                    self.player.ownedList[index].ascension += 1
                    if(self.player.ownedList[index].ascension == 3){
                        self.player.ownedList[index].ability1Active = true
                    }
                    if(self.player.ownedList[index].ascension == 6){
                        self.player.ownedList[index].ability2Active = true
                    }
                }
                isMonsterFound = true
                break
                
            }
        }
        if(isMonsterFound == false){
            var isThereEmpty = false
            for (index,monster) in self.player.ownedList.enumerated(){
                if monster.name == "Empty"{
                    self.player.ownedList[index] = capturedMonster
                    isThereEmpty = true
                    break
                }
            }
            if(isThereEmpty == false){
                self.player.ownedList.append(capturedMonster)
            }
            
        }
        player.partyList[0] = player.ownedList[0]
        player.partyList[1] = player.ownedList[1]
        player.partyList[2] = player.ownedList[2]
    }
    
    public func tameMonster(){
        self.enemyTeamMonsters.shuffle()
        var capturedMonster = self.enemyTeamMonsters[0]
        var isMonsterFound = false
        for (index,monster) in self.player.ownedList.enumerated() {
            if monster.name == capturedMonster.name{
                if(monster.ascension < 6){
                    self.player.ownedList[index].ascension += 1
                    if(self.player.ownedList[index].ascension == 3){
                        self.player.ownedList[index].ability1Active = true
                    }
                    if(self.player.ownedList[index].ascension == 6){
                        self.player.ownedList[index].ability2Active = true
                    }
                }
                isMonsterFound = true
                break
                
            }
        }
        if(isMonsterFound == false){
            var isThereEmpty = false
            capturedMonster.level = 1
            capturedMonster.ability1Active = false
            capturedMonster.ability2Active = false
            capturedMonster.ascension = 0
            for (index,monster) in self.player.ownedList.enumerated(){
                if monster.name == "Empty"{
                    self.player.ownedList[index] = capturedMonster
                    isThereEmpty = true
                    break
                }
            }
            if(isThereEmpty == false){
                self.player.ownedList.append(capturedMonster)
            }
            
        }
        player.partyList[0] = player.ownedList[0]
        player.partyList[1] = player.ownedList[1]
        player.partyList[2] = player.ownedList[2]
    }
    
    public func lose(){
        self.playerLost = true
    }
    
    
    
    public func startBattle(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.performBattleIteration()
                }
    }
    
    public func playerMonsterTurn(){
        
        //Select Ability
        let abilitySelected = self.currentPlayerMonster.abilitiesActive.shuffled()[0]
        if(abilitySelected.name == "Photosynthesis"){
            self.currentPlayerMonster.currentHP += (self.currentPlayerMonster.actualHP / 10)
            if(self.currentPlayerMonster.currentHP > self.currentPlayerMonster.actualHP){
                self.currentPlayerMonster.currentHP = self.currentPlayerMonster.actualHP
            }
        }
        else if(abilitySelected.name == "Regenerate"){
            self.currentPlayerMonster.currentHP += (self.currentPlayerMonster.actualHP / 8)
            if(self.currentPlayerMonster.currentHP > self.currentPlayerMonster.actualHP){
                self.currentPlayerMonster.currentHP = self.currentPlayerMonster.actualHP
            }
        }
        
        //Enemy Takes Damage
        self.currentEnemy.currentHP -= self.damageDealt(attacker: self.currentPlayerMonster, defender: self.currentEnemy, ability: abilitySelected, attackerBuffs: self.currentPlayerMonsterBuffs,defenderBuffs:self.currentEnemyBuffs, attackerDebuffs: self.currentPlayerMonsterDebuffs, defenderDebuffs: self.currentEnemyDebuffs, attackerLeaderBonus: self.partyLeaderBonus, defenderLeaderBonus: enemyLeaderBonus)
        
        //Add Buff if There's a Buff
        if(abilitySelected.buff != ""){
            if let buff = buffList[abilitySelected.buff]{
                let randNum = Int.random(in: 1...100)
                if(randNum<buff.chance){
                    currentPlayerMonsterBuffs.append(buff)
                }
            }
        }
        
        //Add Debuff if There's a Debuff
        if(abilitySelected.debuff != ""){
            if let debuff = debuffList[abilitySelected.debuff]{
                let randNum = Int.random(in: 1...100)
                if(randNum <= debuff.chance){
                    currentEnemyDebuffs.append(debuff)
                }
            }
        }
        
    }
    
    public func enemyMonsterTurn(){
        
        //Select Ability
        let abilitySelected = self.currentEnemy.abilitiesActive.shuffled()[0]
        if(abilitySelected.name == "Photosynthesis"){
            self.currentEnemy.currentHP += (self.currentEnemy.actualHP / 10)
            if(self.currentEnemy.currentHP > self.currentEnemy.actualHP){
                self.currentEnemy.currentHP = self.currentEnemy.actualHP
            }
        }
        else if(abilitySelected.name == "Regenerate"){
            self.currentEnemy.currentHP += (self.currentEnemy.actualHP / 8)
            if(self.currentEnemy.currentHP > self.currentEnemy.actualHP){
                self.currentEnemy.currentHP = self.currentEnemy.actualHP
            }
        }
        
        
        //Player Monster Takes Damage
        self.currentPlayerMonster.currentHP -= self.damageDealt(attacker: self.currentEnemy, defender: self.currentPlayerMonster, ability: abilitySelected, attackerBuffs: self.currentEnemyBuffs, defenderBuffs: self.currentPlayerMonsterBuffs, attackerDebuffs: self.currentPlayerMonsterDebuffs, defenderDebuffs: self.currentEnemyDebuffs, attackerLeaderBonus: enemyLeaderBonus, defenderLeaderBonus: partyLeaderBonus)
        
        //Add Buff if There's a Buff
        if(abilitySelected.buff != ""){
            if let buff = buffList[abilitySelected.buff]{
                let randNum = Int.random(in: 1...100)
                if(randNum<buff.chance){
                    currentEnemyBuffs.append(buff)
                }
            }
        }
        
        //Add Debuff if There's a Debuff
        if(abilitySelected.debuff != ""){
            if let debuff = debuffList[abilitySelected.debuff]{
                let randNum = Int.random(in: 1...100)
                if(randNum <= debuff.chance){
                    currentPlayerMonsterDebuffs.append(debuff)
                }
            }
        }
        
    }
    
    public func clearPlayerStats(){
        currentPlayerMonsterBuffs.removeAll()
        currentPlayerMonsterDebuffs.removeAll()
    }
    
    public func clearEnemyStats(){
        currentEnemyBuffs.removeAll()
        currentEnemyDebuffs.removeAll()
    }
    
    public func performBattleIteration(){
       
        if(enemyTeamBeat == enemyTeamSize || playerTeamBeat == playerTeamSize){
            return
        }
        //calculate speed
        var playerMonsterSpeed = currentPlayerMonster.actualSPD
        var playerMonsterSpeedIncrease = 0
        var enemyMonsterSpeed = currentEnemy.actualSPD
        var enemyMonsterSpeedIncrease = 0
        for leaderBonus in self.partyLeaderBonus{
            if(leaderBonus.stat == "SPD"){
                playerMonsterSpeed = playerMonsterSpeed * (100+leaderBonus.bonus) / 100
            }
        }
        for leaderBonus in self.enemyLeaderBonus{
            if(leaderBonus.stat == "SPD"){
                enemyMonsterSpeed = enemyMonsterSpeed * (100+leaderBonus.bonus) / 100
            }
        }
        for buff in currentPlayerMonsterBuffs{
            for num in 0..<buff.stat.count{
                if(buff.stat[num] == "SPD"){
                    playerMonsterSpeedIncrease += buff.bonus[num]
                }
            }
        }
        for debuff in currentPlayerMonsterDebuffs{
            for num in 0..<debuff.stat.count{
                if(debuff.stat[num] == "SPD"){
                    playerMonsterSpeedIncrease += debuff.bonus[num]
                }
            }
        }
        for buff in currentEnemyBuffs{
            for num in 0..<buff.stat.count{
                if(buff.stat[num] == "SPD"){
                    enemyMonsterSpeedIncrease += buff.bonus[num]
                }
            }
        }
        for debuff in currentEnemyDebuffs{
            for num in 0..<debuff.stat.count{
                if(debuff.stat[num] == "SPD"){
                    enemyMonsterSpeedIncrease += debuff.bonus[num]
                }
            }
        }
        playerMonsterSpeed = playerMonsterSpeed * (100+playerMonsterSpeedIncrease) / 100
        enemyMonsterSpeed = enemyMonsterSpeed * (100+enemyMonsterSpeedIncrease) / 100
        
        //If player monster faster, he goes first
        if(playerMonsterSpeed > enemyMonsterSpeed){
            
            playerMonsterTurn()

            //Check if Enemy is Defeated
            if(self.currentEnemy.currentHP<=0){
                self.currentEnemyBuffs.removeAll()
                self.currentEnemy.currentHP = 0
                self.enemyTeamBeat += 1
                if(self.enemyTeamBeat != self.enemyTeamSize){
                    self.currentEnemy = self.enemyTeamMonsters[enemyTeamBeat]
                    self.currentEnemy.currentHP = self.currentEnemy.actualHP
                    clearEnemyStats()
                    if self.player.monstersSeen.contains(currentEnemy.name) == false{
                        self.player.monstersSeen.insert(currentEnemy.name)
                    }
                }
                else{
                    self.win()
                }
            }
            
            //If Enemy not Defeated
            else{
                enemyMonsterTurn()
                if(self.currentPlayerMonster.currentHP <= 0){
                    self.currentPlayerMonsterBuffs.removeAll()
                    self.currentPlayerMonster.currentHP = 0
                    self.playerTeamBeat += 1
                    if(self.playerTeamBeat != self.playerTeamSize){
                        self.currentPlayerMonster = self.player.partyList[playerTeamBeat]
                        self.currentPlayerMonster.currentHP = self.currentPlayerMonster.actualHP
                        clearPlayerStats()
                    }
                    else{
                        self.lose()
                    }
                }
            }
            
        }
        
        //If enemy faster, he goes first
        else if(playerMonsterSpeed < enemyMonsterSpeed){
            
            enemyMonsterTurn()
            
            //If Player Monster Defeated
            if(self.currentPlayerMonster.currentHP <= 0){
                self.currentPlayerMonsterBuffs.removeAll()
                self.currentPlayerMonster.currentHP = 0
                self.playerTeamBeat += 1
                if(self.playerTeamBeat != self.playerTeamSize){
                    self.currentPlayerMonster = self.player.partyList[playerTeamBeat]
                    self.currentPlayerMonster.currentHP = self.currentPlayerMonster.actualHP
                    clearPlayerStats()
                }
                else{
                    self.lose()
                }
            }
            
            
            //If player monster not defeated
            else{
                playerMonsterTurn()
                
                if(self.currentEnemy.currentHP<=0){
                    self.currentEnemyBuffs.removeAll()
                    self.currentEnemy.currentHP = 0
                    self.enemyTeamBeat += 1
                    if(self.enemyTeamBeat != self.enemyTeamSize){
                        self.currentEnemy = self.enemyTeamMonsters[enemyTeamBeat]
                        self.currentEnemy.currentHP = self.currentEnemy.actualHP
                        clearEnemyStats()
                        if self.player.monstersSeen.contains(currentEnemy.name) == false{
                            self.player.monstersSeen.insert(currentEnemy.name)
                        }
                    }
                    else{
                        self.win()
                    }
                }
            }
            
            
            
        }
        
        //else select a random monster to go first
        else{
            let random = Int.random(in: 1...2)
            if(random == 1){
                playerMonsterTurn()

                //Check if Enemy is Defeated
                if(self.currentEnemy.currentHP<=0){
                    self.currentEnemyBuffs.removeAll()
                    self.currentEnemy.currentHP = 0
                    self.enemyTeamBeat += 1
                    if(self.enemyTeamBeat != self.enemyTeamSize){
                        self.currentEnemy = self.enemyTeamMonsters[enemyTeamBeat]
                        self.currentEnemy.currentHP = self.currentEnemy.actualHP
                        clearEnemyStats()
                        if self.player.monstersSeen.contains(currentEnemy.name) == false{
                            self.player.monstersSeen.insert(currentEnemy.name)
                        }
                    }
                    else{
                        self.win()
                    }
                }
                
                //If Enemy not Defeated
                else{
                    enemyMonsterTurn()
                    if(self.currentPlayerMonster.currentHP <= 0){
                        self.currentPlayerMonsterBuffs.removeAll()
                        self.currentPlayerMonster.currentHP = 0
                        self.playerTeamBeat += 1
                        if(self.playerTeamBeat != self.playerTeamSize){
                            self.currentPlayerMonster = self.player.partyList[playerTeamBeat]
                            self.currentPlayerMonster.currentHP = self.currentPlayerMonster.actualHP
                            clearPlayerStats()
                        }
                        else{
                            self.lose()
                        }
                    }
                }
            }
            else{
                enemyMonsterTurn()
                
                if(self.currentPlayerMonster.currentHP <= 0){
                    self.currentPlayerMonsterBuffs.removeAll()
                    self.currentPlayerMonster.currentHP = 0
                    self.playerTeamBeat += 1
                    if(self.playerTeamBeat != self.playerTeamSize){
                        self.currentPlayerMonster = self.player.partyList[playerTeamBeat]
                        self.currentPlayerMonster.currentHP = self.currentPlayerMonster.actualHP
                        clearPlayerStats()
                    }
                    else{
                        self.lose()
                    }
                }
                
                else{
                    playerMonsterTurn()
                    
                    if(self.currentEnemy.currentHP<=0){
                        self.currentEnemyBuffs.removeAll()
                        self.currentEnemy.currentHP = 0
                        self.enemyTeamBeat += 1
                        if(self.enemyTeamBeat != self.enemyTeamSize){
                            self.currentEnemy = self.enemyTeamMonsters[enemyTeamBeat]
                            self.currentEnemy.currentHP = self.currentEnemy.actualHP
                            clearEnemyStats()
                            if self.player.monstersSeen.contains(currentEnemy.name) == false{
                                self.player.monstersSeen.insert(currentEnemy.name)
                            }
                        }
                        else{
                            self.win()
                        }
                    }
                }
                
            }
            
        }
        
        
        //End of Turn Things
        
        for (index,buff) in currentPlayerMonsterBuffs.enumerated() {
            if(buff.duration > 0){
                currentPlayerMonsterBuffs[index].duration -= 1
            }
        }
        currentPlayerMonsterBuffs.removeAll{ $0.duration <= 0}
        
        for (index,buff) in currentEnemyBuffs.enumerated() {
            if(buff.duration > 0){
                currentEnemyBuffs[index].duration -= 1
            }
        }
        currentEnemyBuffs.removeAll{ $0.duration <= 0}
        
        for (index,debuff) in currentPlayerMonsterDebuffs.enumerated(){
            if(debuff.duration > 0){
                currentPlayerMonsterDebuffs[index].duration -= 1
            }
        }
        currentPlayerMonsterDebuffs.removeAll{ $0.duration <= 0}
        
        for (index,debuff) in currentEnemyDebuffs.enumerated(){
            if(debuff.duration > 0){
                currentEnemyDebuffs[index].duration -= 1
            }
        }
        currentEnemyDebuffs.removeAll{ $0.duration <= 0}
        
        self.startBattle()
    }
    
    
    
    
    
}
