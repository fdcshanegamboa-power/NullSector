//
//  ContentView.swift
//  NullSector
//
//  Created by Shane Gamboa - INTERN on 2/24/26.
//
//
import SwiftUI
import Foundation


struct ContentView: View {
    @State private var viewModel = UserViewModel()
    @State private var newUser = ""
    var body: some View {
        VStack {
            Text("Null Sector")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom)
            if viewModel.isLoading {
                ProgressView("Loading users...")
                Spacer()
            } else {
                //List of users
                List {
                    ForEach(viewModel.users){ user in
                        HStack {
                            Image(systemName: "person.fill")
                            Text(user.name)
                            Image(systemName: user.isVerified ? "checkmark.seal" : "")
                        }
                    }
                }
            }
            
            
                
        }
        .padding()
        
        .task{
            await viewModel.loadData()
        }
    }
}

#Preview {
    ContentView()
}
