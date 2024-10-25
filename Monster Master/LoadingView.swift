//
//  LoadingView.swift
//  Monster Master
//
//  Created by Tony on 6/9/24.
//

import SwiftUI

struct LoadingView: View {
    
    var gameWorld: GameWorld
    
    @State private var loadingDone = false
    var body: some View {
        ZStack{
            
            Text("Loading")
            
            if(loadingDone == false){
                HomeView(gameWorld:gameWorld)
            }
            
        }
        .navigationBarTitle("")
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        
        .onAppear{
            gameWorld.loadGame()
        }
        
                
    }
    
}

#Preview {
    LoadingView(gameWorld:GameWorld())
}
