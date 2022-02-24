//
//  ContentView.swift
//  DadJokes
//
//  Created by Russell Gordon on 2022-02-21.
//

import SwiftUI

struct ContentView: View {
    
    //MARK: Stored properties
    
    // Detect when an app moves between foreground, background,
    //and inactive states
    //Note: A complete list of keypaths that can be used
    //with @Envionment can be found here:
    @Environment(\.scenePhase) var scenePhase
    
    @State var currentJoke: DadJoke = DadJoke(id: "", joke: "Knock, knock...", status: 0)
    
    //This will keep track of our list of favorite jokes
    @State var favorites: [DadJoke] = []   //empty list to start
    
    //This will let us know whether the current joke exists as a favorite
    @State var currentJokeAddedToFavorites: Bool = false
    
    //MARK: Computed properties
    
    
    var body: some View {
        
        VStack {
            
            Text(currentJoke.joke)
                .font(.title)
                .minimumScaleFactor(0.5)
                .multilineTextAlignment(.leading)
                .padding(30)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.primary, lineWidth: 4)
                )
                .padding(10)
            
            Image(systemName: "heart.circle")
                .resizable()
                .frame(width: 40, height: 40)
            //                     CONDITION                           true     false
                .foregroundColor(currentJokeAddedToFavorites == true ? .red : .secondary)
                .onTapGesture {
                    
                    if currentJokeAddedToFavorites == false {
                        
                        //Adds the current joke to the list
                        favorites.append(currentJoke)
                        
                        //Record that we have marked this as a favorite
                        currentJokeAddedToFavorites = true
                    }
                    
                    
                }
            
            Button(action: {
                //The task type allows us to run asynchronous code
                //within a button and have the user interface be updated
                //when the data is ready.
                //Since ut is asynchronous, other tasks can run while
                //we wait for the data to come back from the web server.
                Task{
                    // Call the function that will get us a new joke!
                    await loadNewJoke()
                }
                
            }, label: {
                Text("Another one!")
            })
                .buttonStyle(.bordered)
                .padding()
            
            HStack {
                Text("Favourites")
                    .font(.title2)
                    .bold()
                Spacer()
            }
            
            
            //Iterate over the list of favorites
            //As we iterate, each individual favorite is
            //accessible via "currentFavorite"
            List (favorites, id: \.self) { currentFavorite in
                Text(currentFavorite.joke)
                
            }
            
            Spacer()
            
        }
        // When the app opens, get a new joke from the web service
        .task {
            //Load a joke from the endpoint!
            //We are "calling" or "invoking" the function
            // named "loadNewJoke"
            //A term for this is the "call site" of a function
            
            //This just  means that we, as the programmer, are aware
            //that this function is asynchronous.
            //Result might come right awat, or, take some time to complete.
            // ALSO: Any code below this call will run before the function call completes.
            await loadNewJoke()
            
            print("I tried to load a new joke")
        }
        // React to changes of state for the app (foreground, background, inactive)
        .onChange(of: scenePhase) { newPhase in
            
            if newPhase == .inactive {
                print("Inactive")
            } else if newPhase == .active {
                print("Active")
            } else {
                print("Background")
            }
            
        }
        .navigationTitle("icanhazdadjoke?")
        .padding()
    }
    
    //MARK: Functions
    //Define the function "loadNewFunction"
    //Teaching our app
    //Using the "aysnc" keyword means that this functon can potentially
    //be run alongside other tasks that the app needs to do (for example,
    //updating the user interface)
    func loadNewJoke() async {
        // Assemble the URL that points to the endpoint
        let url = URL(string: "https://icanhazdadjoke.com/")!
        
        // Define the type of data we want from the endpoint
        // Configure the request to the web site
        var request = URLRequest(url: url)
        // Ask for JSON data
        request.setValue("application/json",
                         forHTTPHeaderField: "Accept")
        
        // Start a session to interact (talk with) the endpoint
        let urlSession = URLSession.shared
        
        // Try to fetch a new joke
        // It might not work, so we use a do-catch block
        do {
            
            // Get the raw data from the endpoint
            let (data, _) = try await urlSession.data(for: request)
            
            // Attempt to decode the raw data into a Swift structure
            // Takes what is in "data" and tries to put it into "currentJoke"
            //                                 DATA TYPE TO DECODE TO
            //                                         |
            //                                         V
            currentJoke = try JSONDecoder().decode(DadJoke.self, from: data)
            
            
            // Reset the flag that racks whether the current joke
            //is a favorite
            currentJokeAddedToFavorites = false
        } catch {
            print("Could not retrieve or decode the JSON from endpoint.")
            // Print the contents of the "error" constant that the do-catch block
            // populates
            print(error)
        }
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ContentView()
        }
    }
}
