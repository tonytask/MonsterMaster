//
//  MainView.swift
//  Monster Master
//
//  Created by Tony on 6/9/24.
//

import SwiftUI

struct MainView: View {
    
    
    
    var gameWorld: GameWorld
    var body: some View {
        TabView{
            HomeView(gameWorld:gameWorld)
                .tabItem{
                    Label("Home", image: "house")
                }
        }
    }
}

struct HomeView: View{
    
    @AppStorage("FirstTime") var firstVisit: Bool = true
    @AppStorage("FirstShopVisit") var firstShopVisit: Bool = true
    //@State private var firstVisit: Bool = true
    @State private var message = 1
    @State private var showMaps = false
    @State private var showMissions = false
    @State private var selectedMap = ""
    @State private var selectedMission = ""
    @State private var showMissionDesc = false
    @State private var showBattle = false
    @State private var showParty = false
    @State private var showSwapList = false
    @State private var showMonsterDescription = false
    @State private var currentMon: Monster = Monster(idLabel: 0,name: "", level: 0, statHP: 0, statATT: 0, statDEF: 0, statSPATT: 0, statSPDEF: 0, statSPD: 0, abilities: [Ability(name: "", power: 0, attribute: .Neutral, type: "Physical")], lockedAbility1: Ability(name: "", power: 0, attribute: .Neutral, type: "Physical"), lockedAbility2: Ability(name: "", power: 0, attribute: .Neutral, type: "Physical"), passive1: Passive(name: ""), passive2: Passive(name: ""), resistances:[:], currentHP: 0)
    
    @State private var levelUpAlert = false
    @State private var notEnoughCash = false
    @State private var levelLimitAlert = false
    @State private var showSwitchScreen = false
    @State private var onStatScreen = true
    @State private var onMovesScreen = false
    
    @State private var showShop = false
    @AppStorage("MuruCost") var muruCost = 100
    @State private var showShopPurchase = false
    @State private var shopPurchaseTitle = "Awesome"
    @State private var shopPurchaseMessage = ""
    @State private var shopPurchaseImage = ""
    @State private var showEnergyPurchase = false
    @State private var showBestiary = false
    @State private var showBestiaryDetails = false
    @State private var showGuide = false
    @State private var showAttribute = false
    
    @State private var showAbilities = false
    @State private var showStatuses = false
    @State private var statusSelection = 0
    
    var gameWorld: GameWorld
    var body: some View{
        ZStack{
            
            //Background Color
            LinearGradient(colors: [.gray,.mint], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea(.container, edges: .top)
            
            VStack{
                
                //Top of the screen: Lvl, EN, Cash, and EXP Bar
                VStack(spacing:0){
                        
                    
                    //Top of the Screen: Level, Energy, Cash
                    HStack(spacing:5){
                        VStack(spacing:1){
                            Text("Player")
                            Text("Lv \(gameWorld.player.level)")
                                .font(.caption)
                        }
                        
                        Spacer()
                        VStack(alignment:.leading, spacing:1){
                            HStack(spacing:5){
                                Text("\(gameWorld.player.currentEnergy)/\(gameWorld.player.maximumEnergy)")
                                Image("bolt.fill")
                            }
                            Text(String(format: "  %02d:%02d", gameWorld.player.energyTime/60, gameWorld.player.energyTime % 60))
                                .font(.caption)
                        }
                        .onTapGesture{
                            withAnimation{
                                showEnergyPurchase = true
                            }
                            
                        }
                        
                        Spacer()
                        
                        Text("\(gameWorld.player.gems)")
                        Image("smallcircle.filled.circle.fill")
                        Spacer()
                        
                        Text("\(gameWorld.player.cash)")
                        Image("dollarsign.square.fill")
                    }
                        .padding(10)
                        .background(.thinMaterial)
                        .padding(.top)
                    
                    //Right below: EXP Bar
                    ZStack{
                        
                        Text("Exp:\(gameWorld.player.currentExp)/\(gameWorld.expToNextLevel[gameWorld.player.level])")
                            .font(.subheadline)
                            .frame(maxWidth:.infinity)
                            
                            .background(.white)
                            .cornerRadius(5)
                        
                        GeometryReader { geometry in
                            Rectangle()
                                .fill(Color.green)
                                .frame(width: geometry.size.width * CGFloat(gameWorld.player.currentExp) / CGFloat(gameWorld.expToNextLevel[gameWorld.player.level]), height: 18)
                                .cornerRadius(5)
                                //.animation(.linear, value: gameWorld.enemy.currentHP)
                        }
                        Text("Exp:\(gameWorld.player.currentExp)/\(gameWorld.expToNextLevel[gameWorld.player.level])")
                            .font(.subheadline)
                            .foregroundStyle(.black)
                    }
                    
                    .frame(height: 10)
                    }
                    
                
                Spacer()
                
                //Placeholder
                HStack{
                    ForEach(gameWorld.player.partyList){ monster in
                        if(monster.name != "Empty"){
                            Image(monster.name.lowercased())
                        }
                        
                    }
                }
                .padding(.bottom)
                
                //Placeholder Buttons
                HStack{
                    Button {
                        withAnimation{
                            showParty = true
                        }
                        
                    } label: {
                        Text("Party")
                            .font(.title2)
                        .frame(width: 150, height: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    Button {
                        withAnimation{
                            showGuide = true
                        }
                        
                    } label: {
                        Text("Guide")
                            .font(.title2)
                        .frame(width: 150, height: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                
                
                //Placeholder Buttons
                HStack{
                    Button {
                        withAnimation{
                            showMaps = true
                        }
                        
                    } label: {
                        Text("Explore")
                            .font(.title2)
                        .frame(width: 150, height: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    Button {
                        withAnimation{
                            showShop = true
                        }
                    } label: {
                        Text("Shop")
                            .font(.title2)
                        .frame(width: 150, height: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                
               
                
                Spacer()
            }
            
            //New Player Message
            if(firstVisit == true){
                if(message == 1){
                    CustomAlert(title: "Welcome", message: "Hello, my name is Grendel. Welcome to the vibrant world of Monster Masters, where adventurers tame monsters to help them seek glory and treasure amidst whimsical landscapes and treacherous dungeons. These loyal companions will stand by your side, ready to lend their strength and abilities in the face of daunting challenges.", picture: "grendel"){
                        withAnimation{
                            message = 2
                        }
                        
                    }
                }
                else if(message == 2){
                    CustomAlert(title: "Welcome", message: "Here is your first monster to help you battle. Try exploring the world.", picture: "muru"){
                        withAnimation{
                            firstVisit = false
                        }
                    }
                }
                
                
            }
            
            if(showEnergyPurchase == true){
                VStack{
                    HStack{
                        Button {
                            withAnimation{
                                showEnergyPurchase = false
                            }
                            
                        } label: {
                            Image("x.square.fill")
                        }
                        Spacer()
                        Text("Recharge")
                            .font(.title)
                            .foregroundStyle(.black)
                            .fontWeight(.bold)
                        Spacer()
                        Button {
                            withAnimation{
                                showEnergyPurchase = false
                            }
                            
                        } label: {
                            Image("x.square.fill")
                        }
                    }
                    //.padding()
                    
                    Divider()
                    
                    VStack{
                        
                        Text("50% Max Energy")
                            .font(.title2)
                            .foregroundStyle(.black)
                        
                        Text("(\(gameWorld.player.maximumEnergy/2) Energy)")
                            .foregroundStyle(.black)
                            
                            Button {
                                withAnimation{
                                    gameWorld.refillEnergy()
                                }
                                
                            } label: {
                                HStack{
                                    Text("\(gameWorld.energyRechargeCost)")
                                    Image("smallcircle.filled.circle.fill")
                                }
                                .frame(width: 100, height: 50)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            
                        
                    }
                    .padding(5)
                    //.background(.thinMaterial)
                    
                    
                }
                .padding()
                .background(.white)
                .cornerRadius(10)
                .padding(.trailing,5)
                .padding(.leading,5)
            }
            
            else if(showMonsterDescription == true){
            ZStack{
                VStack {
                    HStack{
                        Button {
                            withAnimation{
                                showMonsterDescription = false
                                showSwitchScreen = false
                                levelUpAlert = false
                            }
                            
                        } label: {
                            Image("arrow.left.square.fill")
                            
                        }
                        Spacer()
                        Spacer()
                        Spacer()
                        Text(currentMon.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.black)
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                    }
                    
                    Divider()
            
                    VStack{
                        
                        Image(currentMon.name.lowercased())
                        Text("Level: \(currentMon.level)")
                        HStack{
                            ForEach((0...currentMon.ascension), id:\.self){num in
                                Image("star.circle.fill 1")
                            }
                            if(currentMon.ascension != 6){
                                ForEach(((currentMon.ascension+1)...6), id:\.self){num in
                                    Image("star.circle.fill")
                                }
                            }
                            
                        }
                        
                    }
                    .padding()
                    .frame(minWidth:150,minHeight:100)
                    .background(.mint)
                    .cornerRadius(10)
                    
                    VStack{
                        HStack{
                            Text("Leader Bonus")
                                
                            VStack{
                                ForEach(currentMon.leaderBonus, id:\.self){ leaderBonus in
                                    HStack{
                                        Text(leaderBonus.stat)
                                            .font(.caption)
                                        
                                        Text("+\(leaderBonus.bonus)%")
                                            .font(.caption)
                                    }
                                    
                                    
                                }
                            }
                        }
                    }
                    .padding()
                    .background(.orange)
                    .cornerRadius(10)
                    
                    
                    VStack{
                        HStack{
                            Spacer()
                            Text("Stats")
                                .padding()
                                .background(onStatScreen ? .gray : .blue)
                                .foregroundStyle(.white)
                                .cornerRadius(10)
                                .onTapGesture(){
                                    withAnimation{
                                        onStatScreen = true
                                        onMovesScreen = false
                                    }
                                    
                                }
                            Spacer()
                            Text("Abilities")
                                .padding()
                                .background(onMovesScreen ? .gray : .blue)
                                .foregroundStyle(.white)
                                .cornerRadius(10)
                                .onTapGesture(){
                                    withAnimation{
                                        onStatScreen = false
                                        onMovesScreen = true
                                    }
                                    
                                }
                            Spacer()
                        }
                        Divider()
                        Spacer()
                        HStack{
                            
                            if(onStatScreen == true){
                                HStack{
                                    Spacer()
                                    VStack{
                                        HStack{
                                            Text("HP: ")
                                                .font(.body)
                                            Spacer()
                                            Text("\(currentMon.actualHP)")
                                                .font(.body)
                                        }
                                        HStack{
                                            Text("ATT: ")
                                                //.font(.body)
                                            Spacer()
                                            Text("\(currentMon.actualATT)")
                                                //.font(.body)
                                        }
                                        HStack{
                                            Text("DEF: ")
                                                .font(.body)
                                            Spacer()
                                            Text("\(currentMon.actualDEF)")
                                                .font(.body)
                                        }
                                        HStack{
                                            Text("SPATT: ")
                                                .font(.body)
                                            Spacer()
                                            Text("\(currentMon.actualSPATT)")
                                                .font(.body)
                                        }
                                        HStack{
                                            Text("SPDEF: ")
                                                .font(.body)
                                            Spacer()
                                            Text("\(currentMon.actualSPDEF)")
                                                .font(.body)
                                        }
                                        HStack{
                                            Text("SPD: ")
                                                .font(.body)
                                            Spacer()
                                            Text("\(currentMon.actualSPD)")
                                                .font(.body)
                                        }
                                        //Spacer()
                                    }
                                    .frame(maxWidth:100)
                                    Spacer()
                                    VStack{
                                        Text("Weakness")
                                            .font(.headline)
                                        ScrollView{
                                            VStack{
                                                ForEach(gameWorld.attributes, id:\.self){ key in
                                                    HStack{
                                                        switch (key){
                                                        case .Fire:
                                                            Image("diamond.fill")
                                                        case .Ground:
                                                            Image("diamond.fill 4")
                                                        case.Ice:
                                                            Image("diamond.fill 2")
                                                        case.Nature:
                                                            Image("diamond.fill 1")
                                                        case.Neutral:
                                                            Image("diamond.fill 3")
                                                        case.Water:
                                                            Image("diamond.fill 5")
                                                        case.Poison:
                                                            Image("diamond.fill 6")
                                                        case.Shadow:
                                                            Image("diamond.fill 7")
                                                        case.Holy:
                                                            Image("diamond.fill 8")
                                                        case.Electric:
                                                            Image("diamond.fill 9")
                                                            
                                                        }
                                                        Spacer()
                                                        
                                                        Text("\(currentMon.resistances[key] ?? 100)%")
                                                    
                                            /*LazyVGrid(columns: [GridItem(.flexible(), spacing: 0), GridItem(.flexible(), spacing: 0)], spacing: 5) {
                                                ForEach(Array(currentMon.resistances.keys), id:\.self){ key in
                                                    HStack{
                                                            switch (key){
                                                            case .Fire:
                                                                Image("diamond.fill")
                                                            case .Ground:
                                                                Image("diamond.fill 4")
                                                            case.Ice:
                                                                Image("diamond.fill 2")
                                                            case.Nature:
                                                                Image("diamond.fill 1")
                                                            case.Neutral:
                                                                Image("diamond.fill 3")
                                                            case.Water:
                                                                Image("diamond.fill 5")
                                                            case.Poison:
                                                                Image("diamond.fill 6")
                                                            case.Shadow:
                                                                Image("diamond.fill 7")
                                                            }
                                                        
                                                        Text(String(format: "%03d%%",currentMon.resistances[key] ?? 100))
                                                        //Text("\(currentMon.resistances[key] ?? 100)%")*/
                                                    }
                                                    .frame(maxWidth:85)
                                                    
                                                }
                                            }
                                        }
                                        
                                        
                                    }
                                    .padding(1)
                                    Spacer()
                                    
                                }
                                
                            }
                            
                            else if(onMovesScreen == true){
                                HStack{
                                        VStack{
                                            Text("Ascension 4")
                                                .foregroundStyle(currentMon.ascension >= 3 ? .green : .red)
                                            Button{
                                                if(currentMon.ascension >= 3){
                                                    if let index = gameWorld.player.ownedList.firstIndex(of: currentMon){
                                                        gameWorld.player.ownedList[index].ability1Active.toggle()
                                                        currentMon = gameWorld.player.ownedList[index]
                                                    }
                                                }
                                                
                                                
                                            } label: {
                                                Text(currentMon.ability1Active ? "Skill On" : "Skill Off")
                                                    .padding(5)
                                                    .foregroundStyle(.white)
                                                    .background(currentMon.ability1Active ? .green : .red)
                                                    .cornerRadius(5)
                                            }
                                            
                                            Text("Ascension 7")
                                                .foregroundStyle(currentMon.ascension >= 6 ? .green : .red)
                                            Button{
                                                if(currentMon.ascension >= 6){
                                                    if let index = gameWorld.player.ownedList.firstIndex(of: currentMon){
                                                        gameWorld.player.ownedList[index].ability2Active.toggle()
                                                        currentMon = gameWorld.player.ownedList[index]
                                                    }
                                                }
                                                
                                                
                                            } label: {
                                                Text(currentMon.ability2Active ? "Skill On" : "Skill Off")
                                                    .padding(5)
                                                    .foregroundStyle(.white)
                                                    .background(currentMon.ability2Active ? .green : .red)
                                                    .cornerRadius(5)
                                            }
                                            
                                            Spacer()
                                        }
                                        .padding(5)
                                        
                                    
                                    VStack{
                                        ForEach(currentMon.abilitiesActive,id:\.self){ ability in
                                            HStack{
                                                Spacer()
                                                Text("\(ability.name) \(ability.power)")
                                                    .font(.caption)
                                                switch (ability.attribute){
                                                case .Fire:
                                                    Image("diamond.fill")
                                                case .Ground:
                                                    Image("diamond.fill 4")
                                                case.Ice:
                                                    Image("diamond.fill 2")
                                                case.Nature:
                                                    Image("diamond.fill 1")
                                                case.Neutral:
                                                    Image("diamond.fill 3")
                                                case.Water:
                                                    Image("diamond.fill 5")
                                                case.Poison:
                                                    Image("diamond.fill 6")
                                                case.Shadow:
                                                    Image("diamond.fill 7")
                                                case.Holy:
                                                    Image("diamond.fill 8")
                                                case.Electric:
                                                    Image("diamond.fill 9")
                                                }
                                                if(ability.type == "Physical"){
                                                    Image("hand.raised.fingers.spread.fill")
                                                }
                                                else{
                                                    Image("swirl.circle.righthalf.filled")
                                                }
                                            }
                                            
                                        }
                                        
                                        if(currentMon.ability1Active == false){
                                            HStack{
                                                Spacer()
                                                Text("\(currentMon.lockedAbility1.name) \(currentMon.lockedAbility1.power)")
                                                    .font(.caption)
                                                    .opacity(0.20)
                                                switch (currentMon.lockedAbility1.attribute){
                                                case .Fire:
                                                    Image("diamond.fill")
                                                case .Ground:
                                                    Image("diamond.fill 4")
                                                case.Ice:
                                                    Image("diamond.fill 2")
                                                case.Nature:
                                                    Image("diamond.fill 1")
                                                case.Neutral:
                                                    Image("diamond.fill 3")
                                                case.Water:
                                                    Image("diamond.fill 5")
                                                case.Poison:
                                                    Image("diamond.fill 6")
                                                case.Shadow:
                                                    Image("diamond.fill 7")
                                                case.Holy:
                                                    Image("diamond.fill 8")
                                                case.Electric:
                                                    Image("diamond.fill 9")
                                                }
                                                if(currentMon.lockedAbility1.type == "Physical"){
                                                    Image("hand.raised.fingers.spread.fill")
                                                }
                                                else{
                                                    Image("swirl.circle.righthalf.filled")
                                                }
                                            }
                                        }
                                        if(currentMon.ability2Active == false){
                                            HStack{
                                                Spacer()
                                                Text("\(currentMon.lockedAbility2.name) \(currentMon.lockedAbility2.power)")
                                                    .font(.caption)
                                                    .opacity(0.20)
                                                switch (currentMon.lockedAbility2.attribute){
                                                case .Fire:
                                                    Image("diamond.fill")
                                                case .Ground:
                                                    Image("diamond.fill 4")
                                                case.Ice:
                                                    Image("diamond.fill 2")
                                                case.Nature:
                                                    Image("diamond.fill 1")
                                                case.Neutral:
                                                    Image("diamond.fill 3")
                                                case.Water:
                                                    Image("diamond.fill 5")
                                                case.Poison:
                                                    Image("diamond.fill 6")
                                                case.Shadow:
                                                    Image("diamond.fill 7")
                                                case.Holy:
                                                    Image("diamond.fill 8")
                                                case.Electric:
                                                    Image("diamond.fill 9")
                                                }
                                                if(currentMon.lockedAbility2.type == "Physical"){
                                                    Image("hand.raised.fingers.spread.fill")
                                                }
                                                else{
                                                    Image("swirl.circle.righthalf.filled")
                                                }
                                            }
                                        }
                                        Spacer()
                                    }
                                    .padding(5)
                                }
                                
                            }
                            
                            
                            
                            
                        }
                        Spacer()
                    }
                    .frame(minHeight:160,maxHeight:240)
                    .padding(10)
                    .background(.regularMaterial)
                    
                    Divider()
                    
                    HStack{
                        
                        Button {
                            
                            withAnimation{
                                showSwitchScreen = true
                                showMonsterDescription = false
                            }
                            
                        } label: {
                            Text("Switch")
                                .font(.title2)
                            .frame(width: 125, height: 50)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        
                        Button {
                            withAnimation{
                                levelUpAlert = true
                                //gameWorld.monsterLevelUp(monster: currentMon)
                                
                            }
                            
                        } label: {
                            Text("Level Up")
                                .font(.title2)
                            .frame(width: 125, height: 50)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    
                }
                .padding()
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 10)
                
                
                
                if(levelUpAlert == true){
                    
                    VStack{
                        //Text("\(currentMon.name)")
                        HStack{
                            Text("Lv ")
                            Spacer()
                            Text("\(currentMon.level)  ->  \(currentMon.level+1)")
                        }
                        HStack{
                            Text("HP ")
                            Spacer()
                            let upper = (currentMon.level+1)*currentMon.statHP/4+5
                            let lower = currentMon.level*currentMon.statHP/4+5
                            Text("\(currentMon.actualHP) -> \(currentMon.actualHP*upper/lower)")
                        }
                        HStack{
                            Text("ATT ")
                            Spacer()
                            Text("\(currentMon.actualATT) -> \(currentMon.actualATT * (currentMon.level + 1) / currentMon.level)")
                        }
                        HStack{
                            Text("DEF ")
                            Spacer()
                            Text("\(currentMon.actualDEF) -> \(currentMon.actualDEF * (currentMon.level + 1) / currentMon.level)")
                        }
                        HStack{
                            Text("SPATT ")
                            Spacer()
                            Text("\(currentMon.actualSPATT) -> \(currentMon.actualSPATT * (currentMon.level + 1) / currentMon.level)")
                        }
                        HStack{
                            Text("SPDEF ")
                            Spacer()
                            Text("\(currentMon.actualSPDEF) -> \(currentMon.actualSPDEF * (currentMon.level + 1) / currentMon.level)")
                        }
                        HStack{
                            Text("SPD ")
                            Spacer()
                            Text("\(currentMon.actualSPD) -> \(currentMon.actualSPD * (currentMon.level + 1) / currentMon.level)")
                        }
                    
                        Button {
                            
                            if(currentMon.level >= gameWorld.player.level){
                                withAnimation{
                                    levelLimitAlert = true
                                    levelUpAlert = false
                                }
                                
                            } else if(gameWorld.player.cash < currentMon.bst*currentMon.level*Int(log2(Float(currentMon.level)))/4+100)
                            {
                                withAnimation{
                                    notEnoughCash = true
                                    levelUpAlert = false
                                }
                                
                            } else{
                                    withAnimation{
                                        levelUpAlert = true
                                        currentMon = gameWorld.monsterLevelUp(monster: currentMon)
                                        
                                        
                                    }
                                }
                            
                            
                        } label: {
                            Text("Cost: \(currentMon.bst*currentMon.level*Int(log2(Float(currentMon.level)))/4+100)")
                                .font(.title2)
                            .frame(width: 125, height: 50)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        Button {
                            withAnimation{
                                levelUpAlert = false
                            }
                            
                        } label: {
                            Text("Cancel")
                                .font(.title2)
                            .frame(width: 125, height: 50)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                    .frame(minWidth: 125, maxWidth:175)
                    .background(.thinMaterial)
                    .cornerRadius(10)
                    
                }
                if(levelLimitAlert == true){
                    VStack{
                        Text("Tamed Monsters Cannot Exceed Your Level")
                            .font(.title2)
                        Button {
                            withAnimation{
                                levelLimitAlert = false
                            }
                            
                        } label: {
                            Text("OK")
                                .font(.title2)
                            .frame(width: 125, height: 50)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(.thinMaterial)
                    .cornerRadius(10)
                }
                else if(notEnoughCash == true){
                    VStack{
                        Text("Not Enough Cash")
                            .font(.title2)
                        Button {
                            withAnimation{
                                notEnoughCash = false
                            }
                            
                        } label: {
                            Text("OK")
                                .font(.title2)
                            .frame(width: 125, height: 50)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(.thinMaterial)
                    .cornerRadius(10)
                    
                }
                
            }
            .padding()
            
        }
            
            else if(showSwitchScreen == true){
                VStack{
                    Text("Switch")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.black)
                    Divider()
                    VStack{
                        
                        Image(currentMon.name.lowercased())
                        Text("Lv\(currentMon.level)")
                    }
                    .padding(5)
                    .frame(minWidth:110, minHeight:120)
                    .background(.mint)
                    .cornerRadius(10)

                    
                    Divider()
                    
                    HStack{
                        ForEach(gameWorld.player.partyList,id:\.self){ selMonster in
                            VStack{
                                if(selMonster.name == "Empty"){
                                    Text("Empty")
                                }
                                
                                else{
                                    
                                    Image(selMonster.name.lowercased())
                                    Text("Lv\(selMonster.level)")
                                }
                                
                            }
                            .padding(5)
                            .frame(minWidth:110, minHeight:120)
                            .background(.yellow)
                            .cornerRadius(10)
                            .onTapGesture{
                                withAnimation{
                                    if let index = gameWorld.player.ownedList.firstIndex(of: currentMon){
                                        
                                        if let index2 = gameWorld.player.ownedList.firstIndex(of: selMonster){
                                            gameWorld.player.ownedList[index] = selMonster
                                            gameWorld.player.ownedList[index2] = currentMon
                                        }
                                        gameWorld.player.partyList[0] = gameWorld.player.ownedList[0]
                                        gameWorld.player.partyList[1] = gameWorld.player.ownedList[1]
                                        gameWorld.player.partyList[2] = gameWorld.player.ownedList[2]
                                    }
                                    showSwitchScreen = false
                                    showMonsterDescription = false
                                }
                            }
                        }
                    }
                    
                    Divider()
                    
                    Button {
                        
                        withAnimation{
                            showSwitchScreen = false
                            showMonsterDescription = true
                        }
                        
                    } label: {
                        Text("Cancel")
                            .font(.title2)
                        .frame(width: 125, height: 50)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                }
                .padding()
                .background(.white)
                .cornerRadius(10)
                .shadow(radius: 10)
                .padding(.trailing)
                .padding(.leading)
                
                
            }
            
            //Party Screen
            else if(showParty == true){
                VStack {
                    HStack{
                        Button {
                            withAnimation{
                                showParty = false
                            }
                            
                        } label: {
                            Image("arrow.left.square.fill")
                                
                        }
                        Spacer()
                        Spacer()
                        Spacer()
                        Text("Party")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.black)
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                    }
                    
                    Divider()
                    
                    HStack{
                        ForEach(gameWorld.player.partyList,id:\.self){ monster in
                            
                            VStack{
                                if(monster.name == "Empty"){
                                    Text("Empty")
                                }
                                
                                else{
                                    VStack{
                                        
                                        Image(monster.name.lowercased())
                                            .frame(minHeight:90)
                                        Spacer()
                                        Text("Lv\(monster.level)")
                                        Spacer()
                                    }
                                    .onTapGesture{
                                        if let monn = gameWorld.player.ownedList.first(where: {$0.name == monster.name}){
                                            currentMon = monn
                                            withAnimation{
                                                showMonsterDescription = true
                                            }
                                        }
                                        
                                        
                                    }
                                    
                                }
                                
                            }
                            .padding(5)
                            .frame(minWidth:110, maxHeight:130)
                            .background(.mint)
                            .cornerRadius(10)
                            
                        }
                    }
                    
                    VStack{
                        HStack{
                            Text("Leader Bonus")
                                
                            VStack{
                                ForEach(gameWorld.partyLeaderBonus, id:\.self){ leaderBonus in
                                    HStack{
                                        Text(leaderBonus.stat)
                                            .font(.caption)
                                        
                                        Text("+\(leaderBonus.bonus)%")
                                            .font(.caption)
                                    }
                                    
                                    
                                }
                            }
                        }
                    }
                    .padding()
                    .background(.orange)
                    .cornerRadius(10)
                    
                    Divider()
                    
                    VStack{
                        ScrollView{
                            ForEach(0..<min(3, gameWorld.player.ownedList.count), id: \.self) { index in
                                let monster = gameWorld.player.ownedList[index]
                                if(monster.name != "Empty"){
                                    HStack{
                                        Image(monster.name.lowercased())
                                        Spacer()
                                        
                                        Text("Lv")
                                        Text("\(monster.level)")
                                        
                                    }
                                    .padding()
                                    .frame(maxWidth:250,minHeight:75)
                                    .background(.thinMaterial)
                                    .onTapGesture{
                                        withAnimation{
                                            currentMon = monster
                                            showMonsterDescription = true
                                        }
                                    }
                                }
                                
                            }
                            
                            ForEach(gameWorld.player.ownedList.dropFirst(3).sorted(by: { $0.level > $1.level }), id: \.self) { monster in
                                if(monster.name != "Empty"){
                                    HStack{
                                        Image(monster.name.lowercased())
                                        Spacer()
                                        
                                        Text("Lv")
                                        Text("\(monster.level)")
                                        
                                    }
                                    .padding()
                                    .frame(maxWidth:250,minHeight:75)
                                    .background(.thinMaterial)
                                    .onTapGesture{
                                        withAnimation{
                                            currentMon = monster
                                            showMonsterDescription = true
                                        }
                                    }
                                }
                                }
                        }
                        
                    }
                    
                }
                .padding()
                .background(.white)
                .cornerRadius(10)
                .padding(.trailing,5)
                .padding(.leading,5)
            }
            
            //Battle Screen
            else if(showBattle == true){
                ZStack{
                    if let colors = gameWorld.missionBackground[selectedMission]{
                        LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                            .ignoresSafeArea(.container, edges: .top)
                    }
                    
                    
                    VStack{
                        Spacer()
                            VStack{
                                HStack{
                                    VStack{
                                        Text(gameWorld.currentEnemy.name)
                                        Image(gameWorld.currentEnemy.name.lowercased())
                                            .scaleEffect(x:-1)
                                        Text("Lv \(gameWorld.currentEnemy.level)")
                                        Text("HP: \(gameWorld.currentEnemy.currentHP)/\(gameWorld.currentEnemy.actualHP)")
                                        GeometryReader { geometry in
                                                    let totalWidth = geometry.size.width
                                                    let hpBarWidth = 100 * CGFloat(gameWorld.currentEnemy.currentHP) / CGFloat(gameWorld.currentEnemy.actualHP)
                                                    let xOffset = (totalWidth - hpBarWidth) / 2

                                                    Rectangle()
                                                        .fill(Color.red)
                                                        .frame(width: hpBarWidth, height: 15)
                                                        .cornerRadius(5)
                                                        .animation(.linear, value: gameWorld.currentEnemy.currentHP)
                                                        .position(x: xOffset + hpBarWidth / 2, y: 15 / 2)
                                                }
                                                .frame(height: 20)
                                    }
                                    .opacity(0)
                                    Spacer()
                                    VStack{
                                        Text("\(gameWorld.currentEnemy.name) Lv \(gameWorld.currentEnemy.level)")
                                        Image(gameWorld.currentEnemy.name.lowercased())
                                        Text("HP: \(gameWorld.currentEnemy.currentHP)/\(gameWorld.currentEnemy.actualHP)")
                                        GeometryReader { geometry in
                                                    let totalWidth = geometry.size.width
                                            let hpBarWidth = 125 * CGFloat(gameWorld.currentEnemy.currentHP) / CGFloat(gameWorld.currentEnemy.actualHP)
                                                    let xOffset = (totalWidth - hpBarWidth) / 2

                                                    Rectangle()
                                                        .fill(Color.red)
                                                        .frame(width: hpBarWidth, height: 15)
                                                        .cornerRadius(5)
                                                        .animation(.linear, value: gameWorld.currentEnemy.currentHP)
                                                        .position(x: xOffset + hpBarWidth / 2, y: 15 / 2)
                                                }
                                                .frame(height: 20)
                                        ForEach(gameWorld.currentEnemy.abilitiesActive, id:\.self){ ability in
                                            HStack{
                                                Text(ability.name)
                                                switch (ability.attribute){
                                                case .Fire:
                                                    Image("diamond.fill")
                                                case .Ground:
                                                    Image("diamond.fill 4")
                                                case.Ice:
                                                    Image("diamond.fill 2")
                                                case.Nature:
                                                    Image("diamond.fill 1")
                                                case.Neutral:
                                                    Image("diamond.fill 3")
                                                case.Water:
                                                    Image("diamond.fill 5")
                                                case.Poison:
                                                    Image("diamond.fill 6")
                                                case.Shadow:
                                                    Image("diamond.fill 7")
                                                case.Holy:
                                                    Image("diamond.fill 8")
                                                case.Electric:
                                                    Image("diamond.fill 9")

                                                }
                                            }

                                        }
                                        HStack{
                                            ForEach(gameWorld.currentEnemyBuffs, id:\.self){ buff in
                                                Image(buff.image)
                                            }
                                            ForEach(gameWorld.currentEnemyDebuffs, id:\.self){ debuff in
                                                Image(debuff.image)
                                            }
                                        }
                                    }
                                }
                                
                            }
                            .padding()
                            .frame(maxWidth:.infinity,minHeight:300)
                            .background(.thinMaterial)
                            Spacer()
                            VStack{
                                HStack{
                                    VStack{
                                        Text("\(gameWorld.currentPlayerMonster.name) Lv \(gameWorld.currentPlayerMonster.level)")
                                        Image(gameWorld.currentPlayerMonster.name.lowercased())
                                            .scaleEffect(x:-1)
                                        Text("HP: \(gameWorld.currentPlayerMonster.currentHP)/\(gameWorld.currentPlayerMonster.actualHP)")
                                        GeometryReader { geometry in
                                                    let totalWidth = geometry.size.width
                                            let hpBarWidth = 125 * CGFloat(gameWorld.currentPlayerMonster.currentHP) / CGFloat(gameWorld.currentPlayerMonster.actualHP)
                                                    let xOffset = (totalWidth - hpBarWidth) / 2

                                                    Rectangle()
                                                        .fill(Color.red)
                                                        .frame(width: hpBarWidth, height: 15)
                                                        .cornerRadius(5)
                                                        .animation(.linear, value: gameWorld.currentPlayerMonster.currentHP)
                                                        .position(x: xOffset + hpBarWidth / 2, y: 15 / 2)
                                                }
                                                .frame(height: 20)
                                        ForEach(gameWorld.currentPlayerMonster.abilitiesActive, id:\.self){ ability in
                                            HStack{
                                                Text(ability.name)
                                                switch (ability.attribute){
                                                case .Fire:
                                                    Image("diamond.fill")
                                                case .Ground:
                                                    Image("diamond.fill 4")
                                                case.Ice:
                                                    Image("diamond.fill 2")
                                                case.Neutral:
                                                    Image("diamond.fill 3")
                                                case.Nature:
                                                    Image("diamond.fill 1")
                                                
                                                case.Water:
                                                    Image("diamond.fill 5")
                                                case.Poison:
                                                    Image("diamond.fill 6")
                                                case.Shadow:
                                                    Image("diamond.fill 7")
                                                case.Holy:
                                                    Image("diamond.fill 8")
                                                case.Electric:
                                                    Image("diamond.fill 9")
                                                    
                                                }
                                            }
                                            
                                        }
                                        HStack{
                                            ForEach(gameWorld.currentPlayerMonsterBuffs, id:\.self){ buff in
                                                Image(buff.image)
                                            }
                                            ForEach(gameWorld.currentPlayerMonsterDebuffs, id:\.self){ debuff in
                                                Image(debuff.image)
                                            }
                                        }
                                    }
                                    Spacer()
                                    VStack{
                                        Text("\(gameWorld.currentEnemy.name) Lv \(gameWorld.currentEnemy.level)")
                                        Image(gameWorld.currentEnemy.name.lowercased())
                                            .scaleEffect(x:-1)
                                        Text("HP: \(gameWorld.currentEnemy.actualHP)/\(gameWorld.currentEnemy.actualHP)")
                                        GeometryReader { geometry in
                                                    let totalWidth = geometry.size.width
                                                    let hpBarWidth = 100 * CGFloat(gameWorld.currentEnemy.actualHP) / CGFloat(gameWorld.currentEnemy.actualHP)
                                                    let xOffset = (totalWidth - hpBarWidth) / 2

                                                    Rectangle()
                                                        .fill(Color.red)
                                                        .frame(width: hpBarWidth, height: 15)
                                                        .cornerRadius(5)
                                                        .animation(.linear, value: gameWorld.currentEnemy.actualHP)
                                                        .position(x: xOffset + hpBarWidth / 2, y: 15 / 2)
                                                }
                                                .frame(height: 20)
                                    }
                                    .opacity(0)
                                }
                                
                            }
                            .padding()
                            .frame(maxWidth:.infinity,minHeight:300)
                            .background(.thinMaterial)
                        Spacer()
                    }
                }
                
                if(gameWorld.playerWon == true){
                    ZStack{
                        VStack {
                            Text("You Won")
                                .font(.title2).bold()
                                .foregroundStyle(.black)
                                .padding(.top)
                            Text("Rewards:")
                                .font(.body)
                                .foregroundStyle(.black)
                                .padding([.top, .horizontal])
                            Text("\(gameWorld.missions[selectedMission]?.expReward  ?? 0) EXP")
                                .foregroundStyle(.black)
                            HStack{
                                Text("\(gameWorld.missions[selectedMission]?.cashReward ?? 0)")
                                    .foregroundStyle(.black)
                                Image("dollarsign.square.fill") 
                            }
                            
                            Button {
                                gameWorld.playerWon = false
                                withAnimation{
                                    showBattle = false
                                }
                                
                                
                            } label: {
                                Text("Collect")
                                    .fontWeight(.bold)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .padding()
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(radius: 10)
                        .padding()
                    
                        if(gameWorld.captureSuccess == true){
                            VStack{
                                Text("\(gameWorld.enemyTeamMonsters[0].name)")
                                    .font(.title2).bold()
                                    .foregroundStyle(.black)
                                    .padding(.top)
                                
                                Image(gameWorld.enemyTeamMonsters[0].name.lowercased())
                                
                                Text("would like to join your team!")
                                    .font(.body)
                                    .foregroundStyle(.black)
                                    .padding([.top, .horizontal])
                                
                                Text("(If you already have this monster, they will ascend.)")
                                    .font(.caption)
                                    .foregroundStyle(.black)
                                    .padding([.top, .horizontal])
                                
                                Button {
                                    withAnimation{ 
                                        gameWorld.captureSuccess = false
                                    }
                                    
                                    
                                } label: {
                                    Text("Tame")
                                        .fontWeight(.bold)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                        .padding()
                                }
                            }
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(radius:10)
                            .padding()
                        }
                        
                        
                    }
                }
                else if(gameWorld.playerLost){
                    ZStack{
                        VStack {
                            Text("You Lost")
                                .font(.title2).bold()
                                .foregroundStyle(.black)
                                .padding(.top)
                            
                            Button {
                                gameWorld.playerLost = false
                                withAnimation{
                                    showBattle = false
                                }
                                
                                
                            } label: {
                                Text("Back")
                                    .fontWeight(.bold)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .padding()
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(radius: 10)
                        .padding()
                    
                        
                    }
                }
                
            }
            
            
            //Level Up Alert
            else if(gameWorld.leveledUp == true){
                CustomAlert(title: "Level Up", message: "You leveled up. You received 100 gems.\nSome energy has been recovered.", picture: "smallcircle.filled.circle.fill"){
                    gameWorld.leveledUp = false
                }
            }
            //Mission Description
            else if(showMissionDesc == true){
                VStack{
                    HStack{
                        Button {
                            withAnimation{
                                showMissionDesc = false
                            }
                            
                        } label: {
                            Image("arrow.left.square.fill")
                        }
                        Spacer()
                        Text(selectedMission)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.black)
                        Spacer()
                        Button {
                            withAnimation{
                                showMaps = false
                                showMissions = false
                                showMissionDesc = false
                            }
                            
                        } label: {
                            Image("x.square.fill")
                        }
                    }
                    //.padding()
                    
                    Divider()
                        .background(.gray)

                    Text("Recommended Lv: \(gameWorld.missions[selectedMission]?.recommendedLevel ?? "99")")
                        .font(.title3)
                        .foregroundStyle(.black)
                        .padding(5)
                    
                    Text(gameWorld.missions[selectedMission]?.description ?? "")
                        .foregroundStyle(.black)
                    
                    if((gameWorld.missions[selectedMission]?.captureRate  ?? 0) > 0 ){
                        VStack{
                            Text("Chance to Capture:")
                            HStack{
                                ForEach(gameWorld.missions[selectedMission]?.enemyTeam ?? [],id:\.self){ monster in
                                    Image(monster.name.lowercased())
                                }
                            }
                        }
                        .padding()
                        .background(.regularMaterial)
                    }
                    
                    Button {
                        if(gameWorld.player.currentEnergy >= gameWorld.missions[selectedMission]?.energyCost ?? 99){
                            withAnimation{
                                showBattle = true
                            }
                            
                            gameWorld.setTeams(missionName: selectedMission, mapName: selectedMap)
                            gameWorld.startBattle()
                        }
                        
                    } label: {
                        HStack{
                            Text("\(gameWorld.missions[selectedMission]?.energyCost ?? 99)")
                            Image("bolt.fill")
                        }
                            .font(.title2)
                        .frame(width: 100, height: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                }
                .padding()
                //.frame(minHeight:325)
                .background(.white)
                .cornerRadius(10)
                .padding(.trailing)
                .padding(.leading)
            }
            
            //Mission List
            else if(showMissions == true){
                VStack{
                    HStack{
                        Button {
                            withAnimation{
                                showMissions = false
                                
                            }
                            
                            
                        } label: {
                            Image("arrow.left.square.fill")
                        }
                        Spacer()
                        Text("Select Battle")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.black)
                        Spacer()
                        Button {
                            withAnimation{
                                showMaps = false
                                showMissions = false
                            }
                            
                        } label: {
                            Image("x.square.fill")
                        }
                    }
                    //.padding()
                    
                    Divider()
                        .background(.gray)
                    //let __ = print("Missions Unlocked: \(gameWorld.player.missionsUnlocked[selectedMap] ?? -1)")
                    ScrollView{
                        if let missions = gameWorld.player.missionsUnlocked[selectedMap]{
                            
                            ForEach(0...missions, id: \.self){ num in
                                HStack{
                                    if let missionsList = gameWorld.missionList[selectedMap]{
                                        if num < missionsList.count{
                                            Text(missionsList[num])
                                                .font(.title2)
                                            .foregroundStyle(.black)
                                            
                                            Spacer()

                                            Spacer()
                                            Button {
                                                
                                                if(num != missions){
                                                    selectedMission = missionsList[num]
                                                    withAnimation{
                                                        showMissionDesc = true
                                                    }
                                                }
                                                
                                                
                                            } label: {
                                                Text(num != missions ? "Select" : "Locked")
                                                    .font(.title2)
                                                .frame(width: 100, height: 50)
                                                .background(num != missions ? Color.blue : .red)
                                                .foregroundColor(.white)
                                                .cornerRadius(10)
                                            }
                                        }
                                        
                                    }
                                    
                                    
                                }
                                .padding(5)
                            }
                        }
                    }
                    .padding(8)
                    //.background(.thinMaterial)
                    
                    
                    
                }
                .padding()
                //.frame(minHeight:325)
                .background(.white)
                .cornerRadius(10)
                .padding(.trailing)
                .padding(.leading)
            }
            
            //Map List
            else if(showMaps == true){
                    
                    VStack{
                        HStack{
                            Button {
                                withAnimation{
                                    showMaps = false
                                }
                                
                            } label: {
                                Image("arrow.left.square.fill")
                            }
                            Spacer()
                            Text("Select Map")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(.black)
                            Spacer()
                            Button {
                                withAnimation{
                                    showMaps = false
                                }
                                
                            } label: {
                                Image("x.square.fill")
                            }
                        }
                        
                        Divider()
                        
                        VStack{
                            ForEach(0...gameWorld.player.mapsUnlocked, id: \.self){ num in
                                HStack{
                                    if(num<gameWorld.mapList.count){
                                        VStack{
                                            Text(num != gameWorld.player.mapsUnlocked ? gameWorld.mapList[num] : "???")
                                                .font(.title2)
                                                .foregroundStyle(.black)
                                            
                                            
                                        }
                                        Spacer()
                                        
                                        Text(num != gameWorld.player.mapsUnlocked ? gameWorld.mapRecommendedLevel[gameWorld.mapList[num]] ?? "" : "???")
                                            .font(.caption)
                                            .foregroundStyle(.black)
                                        
                                        Button {
                                            selectedMap = gameWorld.mapList[num]
                                            withAnimation{
                                                if(num != gameWorld.player.mapsUnlocked){
                                                    showMissions = true
                                                }
                                                
                                            }
                                            
                                            
                                        } label: {
                                            Text(num != gameWorld.player.mapsUnlocked ? "Select" : "Locked")
                                                .font(.title2)
                                            .frame(width: 90, height: 50)
                                            .background(num != gameWorld.player.mapsUnlocked ? Color.blue : .red)
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                        }
                                    }
                                    
                                }
                                .padding(5)
                            }
                        }
                        .padding(5)
                        //.background(.thinMaterial)
                        
                        
                    }
                    .padding()
                    //.frame(minHeight:325)
                    .background(.white)
                    .cornerRadius(10)
                    .padding(.trailing)
                    .padding(.leading)
                    
                
            }
            
            else if(showShop == true){
                VStack{
                    HStack{
                        Button {
                            withAnimation{
                                showShop = false
                            }
                            
                        } label: {
                            Image("arrow.left.square.fill")
                        }
                        Spacer()
                        Text("Shop")
                            .font(.title)
                            .foregroundStyle(.black)
                            .fontWeight(.bold)
                        Spacer()
                        Button {
                            withAnimation{
                                showShop = false
                            }
                            
                        } label: {
                            Image("x.square.fill")
                        }
                    }
                    //.padding()
                    
                    Divider()
                    
                    VStack{
                        Text("Maple Island")
                            .font(.title2)
                            .foregroundStyle(.black)
                        HStack{
                            
                            Image("muru")
                            Spacer()
                                
                            Text("Muru")
                            Spacer()
                            
                            Button {
                                withAnimation{
                                    if(gameWorld.player.cash >= muruCost && muruCost < 700){
                                        gameWorld.player.cash -= muruCost
                                        muruCost += 100
                                        gameWorld.buyMonster(monster: "Muru")
                                        shopPurchaseTitle = "Awesome"
                                        shopPurchaseMessage = "Your Muru has ascended!"
                                        shopPurchaseImage = "muru"
                                        showShopPurchase = true
                                    }
                                }
                                
                            } label: {
                                HStack{
                                    Text("\(muruCost)")
                                    Image("dollarsign.square.fill")
                                }
                                
                                .frame(width: 100, height: 50)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            
                        }
                        .padding()
                        .background(.thinMaterial)
                        .cornerRadius(10)
                        .opacity(muruCost < 700 ? 1.0 : 0.2)
                        
                    }
                    .padding(5)
                    //.background(.thinMaterial)
                    
                    
                }
                .padding()
                .background(.white)
                .cornerRadius(10)
                .padding(.trailing,5)
                .padding(.leading,5)
                
                if(firstShopVisit == true){
                    CustomAlert(title: "Welcome", message: "This is the shop. Tame more monsters of the same kind to increase their ascension level! Each ascension boosts all stats by 2%. Monsters can also learn new abilities.", picture: ""){
                        firstShopVisit = false
                    }
                }
                else if(showShopPurchase == true){
                    CustomAlert(title: shopPurchaseTitle, message: shopPurchaseMessage, picture: shopPurchaseImage){
                        showShopPurchase = false
                    }
                }
            }
            
            else if(showBestiary == true){
                VStack{
                    HStack{
                        Button {
                            withAnimation{
                                showBestiary = false
                                showGuide = true
                            }
                            
                        } label: {
                            Image("arrow.left.square.fill")
                        }
                        Spacer()
                        Text("Bestiary")
                            .font(.title)
                            .foregroundStyle(.black)
                            .fontWeight(.bold)
                        Spacer()
                        Button {
                            withAnimation{
                                showBestiary = false
                                showGuide = false
                            }
                            
                        } label: {
                            Image("x.square.fill")
                        }
                    }
                    //.padding()
                    
                    Divider()
                    
                    VStack{
                        
                        ScrollView{
                            ForEach(Array(gameWorld.monsterList.values).sorted(by: { $0.idLabel < $1.idLabel }), id: \.self) { monster in
                                if(gameWorld.player.monstersSeen.contains(monster.name)){
                                    VStack{
                                        Text(monster.name)
                                            .foregroundColor(.black)
                                        Image(monster.name.lowercased())
                                    }
                                    .frame(width:200, height:100)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                                    .onTapGesture{
                                        withAnimation{
                                            showBestiary = false
                                            showBestiaryDetails = true
                                        }
                                        
                                        currentMon = monster
                                    }
                                }
                                else{
                                    VStack{
                                        Text("???")
                                    }
                                    .frame(width:200, height:100)
                                    .background(Color.gray)
                                    .cornerRadius(10)
                                    
                                }
                                
                                
                            }
                        }
                        
                        
                    }
                    .padding(5)
                    //.background(.thinMaterial)
                    
                    
                }
                .padding()
                .background(.white)
                .cornerRadius(10)
                .padding(.trailing,5)
                .padding(.leading,5)
                
                
            }
            
            else if(showBestiaryDetails == true){
                VStack {
                    HStack{
                        Button {
                            withAnimation{
                                showBestiaryDetails = false
                                showBestiary = true
                            }
                            
                        } label: {
                            Image("x.square.fill")
                            
                        }
                        Spacer()
                        Spacer()
                        Spacer()
                        Text(currentMon.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.black)
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                    }
                    
                    Divider()
                    
                    VStack{
                        
                        Image(currentMon.name.lowercased())
                        
                        
                    }
                    .padding()
                    .frame(minWidth:150,minHeight:100)
                    .background(.mint)
                    .cornerRadius(10)
                    
                    VStack{
                        HStack{
                            Text("Leader Bonus")
                                
                            VStack{
                                ForEach(currentMon.leaderBonus, id:\.self){ leaderBonus in
                                    HStack{
                                        Text(leaderBonus.stat)
                                            .font(.caption)
                                        
                                        Text("+\(leaderBonus.bonus)%")
                                            .font(.caption)
                                    }
                                    
                                    
                                }
                            }
                        }
                    }
                    .padding()
                    .background(.orange)
                    .cornerRadius(10)
                    
                    
                    VStack{
                        HStack{
                            Spacer()
                            Text("Stats")
                                .padding()
                                .background(onStatScreen ? .gray : .blue)
                                .foregroundStyle(.white)
                                .cornerRadius(10)
                                .onTapGesture(){
                                    withAnimation{
                                        onStatScreen = true
                                        onMovesScreen = false
                                    }
                                    
                                }
                            Spacer()
                            Text("Abilities")
                                .padding()
                                .background(onMovesScreen ? .gray : .blue)
                                .foregroundStyle(.white)
                                .cornerRadius(10)
                                .onTapGesture(){
                                    withAnimation{
                                        onStatScreen = false
                                        onMovesScreen = true
                                    }
                                    
                                }
                            Spacer()
                        }
                        Divider()
                        Spacer()
                        HStack{
                            
                            if(onStatScreen == true){
                                HStack{
                                    Spacer()
                                    VStack{
                                        HStack{
                                            Text("HP: ")
                                                .font(.body)
                                            Spacer()
                                            Text("\(currentMon.statHP)")
                                                .font(.body)
                                        }
                                        HStack{
                                            Text("ATT: ")
                                            //.font(.body)
                                            Spacer()
                                            Text("\(currentMon.statATT)")
                                            //.font(.body)
                                        }
                                        HStack{
                                            Text("DEF: ")
                                                .font(.body)
                                            Spacer()
                                            Text("\(currentMon.statDEF)")
                                                .font(.body)
                                        }
                                        HStack{
                                            Text("SPATT: ")
                                                .font(.body)
                                            Spacer()
                                            Text("\(currentMon.statSPATT)")
                                                .font(.body)
                                        }
                                        HStack{
                                            Text("SPDEF: ")
                                                .font(.body)
                                            Spacer()
                                            Text("\(currentMon.statSPDEF)")
                                                .font(.body)
                                        }
                                        HStack{
                                            Text("SPD: ")
                                                .font(.body)
                                            Spacer()
                                            Text("\(currentMon.statSPD)")
                                                .font(.body)
                                        }
                                        //Spacer()
                                    }
                                    .frame(maxWidth:100)
                                    Spacer()
                                    VStack{
                                        Text("Weakness")
                                            .font(.headline)
                                        ScrollView{
                                            VStack{
                                                ForEach(gameWorld.attributes, id:\.self){ key in
                                                    HStack{
                                                        switch (key){
                                                        case .Fire:
                                                            Image("diamond.fill")
                                                        case .Ground:
                                                            Image("diamond.fill 4")
                                                        case.Ice:
                                                            Image("diamond.fill 2")
                                                        case.Nature:
                                                            Image("diamond.fill 1")
                                                        case.Neutral:
                                                            Image("diamond.fill 3")
                                                        case.Water:
                                                            Image("diamond.fill 5")
                                                        case.Poison:
                                                            Image("diamond.fill 6")
                                                        case.Shadow:
                                                            Image("diamond.fill 7")
                                                        case.Holy:
                                                            Image("diamond.fill 8")
                                                        case.Electric:
                                                            Image("diamond.fill 9")
                                                        }
                                                        Spacer()
                                                        
                                                        Text("\(currentMon.resistances[key] ?? 100)%")
                                                    }
                                                    .frame(maxWidth:85)
                                                    
                                                }
                                            }
                                        }
                                        
                                        
                                    }
                                    .padding(1)
                                    Spacer()
                                    
                                }
                                
                            }
                            
                            else if(onMovesScreen == true){
                                HStack{
                                    
                                    
                                    VStack{
                                        ForEach(currentMon.abilitiesActive,id:\.self){ ability in
                                            HStack{
                                                Text("\(ability.name)")
                                                    .font(.title3)
                                                    .frame(minWidth:150)
                                                Text("\(ability.power)")
                                                    .font(.title3)
                                                    .frame(minWidth:30)
                                                switch (ability.attribute){
                                                case .Fire:
                                                    Image("diamond.fill")
                                                        .frame(minWidth:30)
                                                case .Ground:
                                                    Image("diamond.fill 4")
                                                        .frame(minWidth:30)
                                                case.Ice:
                                                    Image("diamond.fill 2")
                                                        .frame(minWidth:30)
                                                case.Nature:
                                                    Image("diamond.fill 1")
                                                        .frame(minWidth:30)
                                                case.Neutral:
                                                    Image("diamond.fill 3")
                                                        .frame(minWidth:30)
                                                case.Water:
                                                    Image("diamond.fill 5")
                                                        .frame(minWidth:30)
                                                case.Poison:
                                                    Image("diamond.fill 6")
                                                        .frame(minWidth:30)
                                                case.Shadow:
                                                    Image("diamond.fill 7")
                                                        .frame(minWidth:30)
                                                case.Holy:
                                                    Image("diamond.fill 8")
                                                        .frame(minWidth:30)
                                                case.Electric:
                                                    Image("diamond.fill 9")
                                                        .frame(minWidth:30)
                                                }
                                                if(ability.type == "Physical"){
                                                    Image("hand.raised.fingers.spread.fill")
                                                        .frame(minWidth:30)
                                                }
                                                else{
                                                    Image("swirl.circle.righthalf.filled")
                                                        .frame(minWidth:30)
                                                }
                                            }
                                            
                                        }
                                        
                                        if(currentMon.ability1Active == false){
                                            HStack{
                                                Text("\(currentMon.lockedAbility1.name)")
                                                    .font(.title3)
                                                    .frame(minWidth:150)
                                                    .opacity(0.20)
                                                Text("\(currentMon.lockedAbility1.power)")
                                                    .font(.title3)
                                                    .frame(minWidth:30)
                                                    .opacity(0.20)
                                                switch (currentMon.lockedAbility1.attribute){
                                                case .Fire:
                                                    Image("diamond.fill")
                                                        .frame(minWidth:30)
                                                case .Ground:
                                                    Image("diamond.fill 4")
                                                        .frame(minWidth:30)
                                                case.Ice:
                                                    Image("diamond.fill 2")
                                                        .frame(minWidth:30)
                                                case.Nature:
                                                    Image("diamond.fill 1")
                                                        .frame(minWidth:30)
                                                case.Neutral:
                                                    Image("diamond.fill 3")
                                                        .frame(minWidth:30)
                                                case.Water:
                                                    Image("diamond.fill 5")
                                                        .frame(minWidth:30)
                                                case.Poison:
                                                    Image("diamond.fill 6")
                                                        .frame(minWidth:30)
                                                case.Shadow:
                                                    Image("diamond.fill 7")
                                                        .frame(minWidth:30)
                                                case.Holy:
                                                    Image("diamond.fill 8")
                                                        .frame(minWidth:30)
                                                case.Electric:
                                                    Image("diamond.fill 9")
                                                        .frame(minWidth:30)
                                                }
                                                if(currentMon.lockedAbility1.type == "Physical"){
                                                    Image("hand.raised.fingers.spread.fill")
                                                        .frame(minWidth:30)
                                                }
                                                else{
                                                    Image("swirl.circle.righthalf.filled")
                                                        .frame(minWidth:30)
                                                }
                                            }
                                        }
                                        if(currentMon.ability2Active == false){
                                            HStack{
                                                Text("\(currentMon.lockedAbility2.name)")
                                                    .font(.title3)
                                                    .frame(minWidth:150)
                                                    .opacity(0.20)
                                                Text("\(currentMon.lockedAbility2.power)")
                                                    .font(.title3)
                                                    .frame(minWidth:30)
                                                    .opacity(0.20)
                                                switch (currentMon.lockedAbility2.attribute){
                                                case .Fire:
                                                    Image("diamond.fill")
                                                        .frame(minWidth:30)
                                                case .Ground:
                                                    Image("diamond.fill 4")
                                                        .frame(minWidth:30)
                                                case.Ice:
                                                    Image("diamond.fill 2")
                                                        .frame(minWidth:30)
                                                case.Nature:
                                                    Image("diamond.fill 1")
                                                        .frame(minWidth:30)
                                                case.Neutral:
                                                    Image("diamond.fill 3")
                                                        .frame(minWidth:30)
                                                case.Water:
                                                    Image("diamond.fill 5")
                                                        .frame(minWidth:30)
                                                case.Poison:
                                                    Image("diamond.fill 6")
                                                        .frame(minWidth:30)
                                                case.Shadow:
                                                    Image("diamond.fill 7")
                                                        .frame(minWidth:30)
                                                case.Holy:
                                                    Image("diamond.fill 8")
                                                        .frame(minWidth:30)
                                                case.Electric:
                                                    Image("diamond.fill 9")
                                                        .frame(minWidth:30)
                                                }
                                                if(currentMon.lockedAbility2.type == "Physical"){
                                                    Image("hand.raised.fingers.spread.fill")
                                                        .frame(minWidth:30)
                                                }
                                                else{
                                                    Image("swirl.circle.righthalf.filled")
                                                        .frame(minWidth:30)
                                                }
                                            }
                                        }
                                        Spacer()
                                    }
                                    .padding(5)
                                }
                                
                            }
                            
                            
                            
                            
                        }
                        Spacer()
                    }
                    .frame(minHeight:160,maxHeight:240)
                    .padding(10)
                    .background(.regularMaterial)
                    
                    
                    
                    
                }
                .padding()
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 10)
            }
            
            else if(showAttribute == true){
                VStack{
                    HStack{
                        Button {
                            withAnimation{
                                showAttribute = false
                                showGuide = true
                            }
                            
                        } label: {
                            Image("arrow.left.square.fill")
                        }
                        Spacer()
                        Text("Attributes")
                            .font(.title)
                            .foregroundStyle(.black)
                            .fontWeight(.bold)
                        Spacer()
                        Button {
                            withAnimation{
                                showAttribute = false
                                showGuide = false
                            }
                            
                        } label: {
                            Image("x.square.fill")
                        }
                    }
                    //.padding()
                    
                    Divider()
                    
                    VStack{
                        
                        ScrollView{
                            ForEach(gameWorld.attributes, id: \.self){ attr in
                                HStack{
                                    switch(attr){
                                    case .Fire:
                                        Image("diamond.fill")
                                            .frame(minWidth:30)
                                        Text("Fire")
                                            .frame(minWidth:100)
                                    case .Ground:
                                        Image("diamond.fill 4")
                                            .frame(minWidth:30)
                                        Text("Ground")
                                            .frame(minWidth:100)
                                    case.Ice:
                                        Image("diamond.fill 2")
                                            .frame(minWidth:30)
                                        Text("Ice")
                                            .frame(minWidth:100)
                                    case.Nature:
                                        Image("diamond.fill 1")
                                            .frame(minWidth:30)
                                        Text("Nature")
                                            .frame(minWidth:100)
                                    case.Neutral:
                                        Image("diamond.fill 3")
                                            .frame(minWidth:30)
                                        Text("Neutral")
                                            .frame(minWidth:100)
                                    case.Water:
                                        Image("diamond.fill 5")
                                            .frame(minWidth:30)
                                        Text("Water")
                                            .frame(minWidth:100)
                                    case.Poison:
                                        Image("diamond.fill 6")
                                            .frame(minWidth:30)
                                        Text("Poison")
                                            .frame(minWidth:100)
                                    case.Shadow:
                                        Image("diamond.fill 7")
                                            .frame(minWidth:30)
                                        Text("Shadow")
                                            .frame(minWidth:100)
                                    case.Holy:
                                        Image("diamond.fill 8")
                                            .frame(minWidth:30)
                                        Text("Holy")
                                            .frame(minWidth:100)
                                    case.Electric:
                                        Image("diamond.fill 9")
                                            .frame(minWidth:30)
                                        Text("Electric")
                                            .frame(minWidth:100)
                                    }
                                    
                                }
                                .padding(5)
                                .frame(minWidth:150,minHeight:40)
                                .background(.thinMaterial)
                                .cornerRadius(10)
                            }
                        }
                        
                        
                    }
                    .padding(5)
                    
                    
                }
                .padding()
                .background(.white)
                .cornerRadius(10)
                .padding(.trailing,5)
                .padding(.leading,5)
            }
            
            else if(showAbilities == true){
                VStack{
                    HStack{
                        Button {
                            withAnimation{
                                showAbilities = false
                                showGuide = true
                            }
                            
                        } label: {
                            Image("arrow.left.square.fill")
                        }
                        Spacer()
                        Text("Abilities")
                            .font(.title)
                            .foregroundStyle(.black)
                            .fontWeight(.bold)
                        Spacer()
                        Button {
                            withAnimation{
                                showAbilities = false
                                showGuide = false
                            }
                            
                        } label: {
                            Image("x.square.fill")
                        }
                    }
                    //.padding()
                    
                    Divider()
                    
                    VStack{
                        
                        ScrollView{
                            ForEach(Array(gameWorld.abilityList.keys).sorted(by: {$0 < $1}), id: \.self){ moveName in
                                HStack{
                                    Text(moveName)
                                        .font(.caption)
                                        .frame(minWidth:100)
                                    //Spacer()
                                    if let ability = gameWorld.abilityList[moveName]{
                                        
                                        switch(ability.attribute){
                                        case .Fire:
                                            Image("diamond.fill")
                                                .frame(minWidth:30)
                                        case .Ground:
                                            Image("diamond.fill 4")
                                                .frame(minWidth:30)
                                        case.Ice:
                                            Image("diamond.fill 2")
                                                .frame(minWidth:30)
                                        case.Nature:
                                            Image("diamond.fill 1")
                                                .frame(minWidth:30)
                                        case.Neutral:
                                            Image("diamond.fill 3")
                                                .frame(minWidth:30)
                                        case.Water:
                                            Image("diamond.fill 5")
                                                .frame(minWidth:30)
                                        case.Poison:
                                            Image("diamond.fill 6")
                                                .frame(minWidth:30)
                                        case.Shadow:
                                            Image("diamond.fill 7")
                                                .frame(minWidth:30)
                                        case.Holy:
                                            Image("diamond.fill 8")
                                                .frame(minWidth:30)
                                        case.Electric:
                                            Image("diamond.fill 9")
                                                .frame(minWidth:30)
                                        }
                                        //Spacer()
                                        VStack{
                                            Text("Power")
                                                .font(.caption)
                                            Text("\(ability.power)")
                                        }
                                        .frame(minWidth:50)
                                        //Spacer()
                                        Text(ability.description)
                                            .font(.caption2)
                                            .frame(minWidth:100)
                                    }
                                    
                                    
                                }
                                .padding(5)
                                .frame(minWidth:350,minHeight:90)
                                .background(.thinMaterial)
                                .cornerRadius(10)
                            }
                        }
                        
                        
                    }
                    .padding(5)
                    
                    
                }
                .padding()
                .background(.white)
                .cornerRadius(10)
                .padding(.trailing,5)
                .padding(.leading,5)
            }
            
            else if(showStatuses == true){
                VStack{
                    HStack{
                        Button {
                            withAnimation{
                                showStatuses = false
                                showGuide = true
                            }
                            
                        } label: {
                            Image("arrow.left.square.fill")
                        }
                        Spacer()
                        Text("Statuses")
                            .font(.title)
                            .foregroundStyle(.black)
                            .fontWeight(.bold)
                        Spacer()
                        Button {
                            withAnimation{
                                showStatuses = false
                                showGuide = false
                            }
                            
                        } label: {
                            Image("x.square.fill")
                        }
                    }
                    //.padding()
                    
                    Divider()
                    
                    VStack{
                        VStack{
                            Picker("", selection: $statusSelection){
                                Text("Buffs").tag(0)
                                Text("Debuffs").tag(1)
                            }
                            .background(.blue)
                            .cornerRadius(10)
                            .pickerStyle(.segmented)
                            
                            
                        }
                        if(statusSelection == 0){
                            ScrollView{
                                ForEach(Array(gameWorld.buffList.keys).sorted(by: {$0 < $1}), id: \.self){ buffName in
                                    if let buff = gameWorld.buffList[buffName]{
                                        HStack{
                                            Text(buff.name)
                                                .frame(maxWidth:100)
                                            Spacer()
                                            Image(buff.image)
                                                .frame(maxWidth:30)
                                            Spacer()
                                            VStack{
                                                Text("Duration:")
                                                    .font(.caption)
                                                Text("\(buff.duration-1)")
                                                    .font(.caption)
                                            }
                                            .frame(maxWidth:70)
                                                
                                            Spacer()
                                            VStack{
                                                ForEach(buff.stat.indices, id: \.self){ index in
                                                    HStack{
                                                        Text(buff.stat[index])
                                                            .font(.caption)
                                                        Text("+\(buff.bonus[index])%")
                                                            .font(.caption)
                                                    }
                                                    
                                                }
                                            }
                                                    .frame(maxWidth:100)
                                                
                                            
                                            
                                        }
                                        .padding(10)
                                        .frame(minWidth:335,minHeight:80)
                                        .background(.thinMaterial)
                                        .cornerRadius(10)
                                    }
                                    
                                }
                            }
                        }
                        
                        
                        else if(statusSelection == 1){
                            ScrollView{
                                ForEach(Array(gameWorld.debuffList.keys).sorted(by: {$0 < $1}), id: \.self){ debuffName in
                                    if let debuff = gameWorld.debuffList[debuffName]{
                                        HStack{
                                            Text(debuff.name)
                                                .frame(maxWidth:100)
                                            Spacer()
                                            Image(debuff.image)
                                                .frame(maxWidth:30)
                                            Spacer()
                                            VStack{
                                                Text("Duration:")
                                                    .font(.caption)
                                                Text("\(debuff.duration-1)")
                                                    .font(.caption)
                                            }
                                            .frame(maxWidth:70)
                                                
                                            Spacer()
                                            VStack{
                                                ForEach(debuff.stat.indices, id: \.self){ index in
                                                    HStack{
                                                        Text(debuff.stat[index])
                                                            .font(.caption)
                                                        Text("+\(debuff.bonus[index])%")
                                                            .font(.caption)
                                                    }
                                                    
                                                }
                                            }
                                                    .frame(maxWidth:100)
                                                
                                            
                                            
                                        }
                                        .padding(10)
                                        .frame(minWidth:335,minHeight:80)
                                        .background(.thinMaterial)
                                        .cornerRadius(10)
                                    }
                                    
                                }
                            }
                        }
                        
                        
                    }
                    .padding(10)
                    
                    
                }
                .padding()
                .background(.white)
                .cornerRadius(10)
                .padding(.trailing,5)
                .padding(.leading,5)
            }
            
            else if(showGuide == true){
                VStack{
                    HStack{
                        Button {
                            withAnimation{
                                showGuide = false
                            }
                            
                        } label: {
                            Image("x.square.fill")
                        }
                        Spacer()
                        Text("Guide")
                            .font(.title)
                            .foregroundStyle(.black)
                            .fontWeight(.bold)
                        Spacer()
                        Button {
                            withAnimation{
                                showGuide = false
                            }
                            
                        } label: {
                            Image("x.square.fill")
                        }
                    }
                    //.padding()
                    
                    Divider()
                    
                    VStack{
                        
                        Text("Bestiary")
                            .font(.title2)
                            .padding()
                            .frame(minWidth:150)
                            .background(.blue)
                            .cornerRadius(10)
                            .onTapGesture{
                                withAnimation{
                                    showGuide = false
                                    showBestiary = true
                                }
                            }
                        
                        Text("Attributes")
                            .font(.title2)
                            .padding()
                            .frame(minWidth:150)
                            .background(.blue)
                            .cornerRadius(10)
                            .onTapGesture{
                                withAnimation{
                                    showGuide = false
                                    showAttribute = true
                                }
                            }
                        
                        Text("Abilities")
                            .font(.title2)
                            .padding()
                            .frame(minWidth:150)
                            .background(.blue)
                            .cornerRadius(10)
                            .onTapGesture{
                                withAnimation{
                                    showGuide = false
                                    showAbilities = true
                                }
                            }
                        Text("Statuses")
                            .font(.title2)
                            .padding()
                            .frame(minWidth:150)
                            .background(.blue)
                            .cornerRadius(10)
                            .onTapGesture{
                                withAnimation{
                                    showGuide = false
                                    showStatuses = true
                                }
                            }
                        
                        
                    }
                    .padding(5)
                    
                    
                }
                .padding()
                .background(.white)
                .cornerRadius(10)
                .padding(.trailing,5)
                .padding(.leading,5)
            }
            
            
            
            
        }
        
        .onAppear{
            gameWorld.startEnergyTimer()
            
        }
    }
}


struct CustomAlert: View {
    var title: String
    var message: String
    var picture: String
    var dismissAction: () -> Void

    var body: some View {
        VStack {
            Text(title)
                .font(.title2).bold()
                .foregroundStyle(.black)
                .padding(.top)
            if(picture != ""){
                Image(picture)
            }
            if(message != ""){
                Text(message)
                    .font(.body)
                    .foregroundStyle(.black)
                    .padding([.top, .horizontal])
            }
            Button(action: dismissAction) {
                Text("OK")
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
            }
        }
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 10)
        .padding()
    }
}

struct RewardAlert: View{
    var gameWorld: GameWorld
    var body: some View {
        VStack {
            Text("You Won")
                .font(.title2).bold()
                .foregroundStyle(.black)
                .padding(.top)
                Text("Rewards:")
                    .font(.body)
                    .foregroundStyle(.black)
                    .padding([.top, .horizontal])
            
            Button {
                gameWorld.playerWon = false
                
            } label: {
                Text("Collect")
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
            }
        }
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 10)
        .padding()
    }
}

#Preview {
    MainView(gameWorld:GameWorld())
}
