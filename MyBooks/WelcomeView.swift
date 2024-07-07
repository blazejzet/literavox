
import SwiftUI

struct WelcomeView: View {
    @State private var index: Int = 0
      
    
    
    var body: some View {
        VStack{
            
             VStack() {
                 HStack{
                     Spacer()
                     Button(action:{
                         MXContextMenuModel.global.hideContextMenu()
                         UserDefaults.standard.set(true, forKey: "WelcomeHidden")
                         UserDefaults.standard.synchronize()
                     }){
                         Image("xw").renderingMode(.original).resizable().frame(width: 25, height: 25)
                     }
                 }.padding(10).background{Rectangle().foregroundColor(.black)}
                TabView(selection: $index){
                    VStack(spacing: 0){
                        Spacer()

                        Image("white_logo_clipped").resizable().aspectRatio(contentMode: .fit).frame(height: 100)
                        Spacer()
                        Group{
                            Text("Welcome to LiteraVOX. One place for all Your Audiobooks")
                               .foregroundColor(.white)
                                .multilineTextAlignment(.center)

                            Spacer()
                            
                            Image("welcome-1")
                                .resizable()
                                
                                .aspectRatio(contentMode: .fit)
                            
                            Spacer()
                            
                            Text("Listen for Audiobooks from your own library.")
                                
                                .multilineTextAlignment(.center)
                                .layoutPriority(5)
                        }
                        Spacer()
                        Button(action: {
                            self.index+=1
                        }, label: {
                            Text("How to start?")
                                .padding().foregroundColor(.white)
                                .background(RoundedRectangle(cornerRadius: 15)
                                    .foregroundColor(.orange))
                        })
                        Spacer()
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .tag(0)
                    VStack( spacing: 0){
                        Spacer()
                        Image("white_logo_clipped").resizable().scaledToFit().frame(height: 100)
                        Spacer()

                        Group{
                            Text("You can use desktop app and mobile simultaneously.").foregroundColor(.white)
                                .multilineTextAlignment(.center)

                            Spacer()
                            
                            Image("welcome-2")
                                .resizable()
                                
                                .aspectRatio(contentMode: .fit)
                            
                            Spacer()
                            
                            Text(" They can work with the same library using iCloud folders.")
                                
                                .multilineTextAlignment(.center)
                                .layoutPriority(5)
//                                .padding(.horizontal, 20)
                        }
                        
                        Spacer()
                        Button(action: {
                            self.index+=1
                        }, label: {
                            Text("How to manage books?").foregroundColor(.white)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 15)
                                    .foregroundColor(.orange))

                        })
                        Spacer()
                    }
                    .foregroundColor(.white)

 
                    .padding(.horizontal, 20)
                    .tag(1)
                    
                    
                    
                    VStack( spacing: 0){
                        Spacer()
                        Image("white_logo_clipped").resizable().scaledToFit().frame(height: 100)
                        Spacer()

                        Group{
                            Text("Use Files app on Your device to manage on-device folders or Finder to manage iCloud Folders").foregroundColor(.white)
                                .multilineTextAlignment(.center)

                            Spacer()
                            
                            Image("welcome-3")
                                .resizable()
                                
                                .aspectRatio(contentMode: .fit)
                            
                            Spacer()
                            
                            Text("You can Also share iCloud folders among Your friends and family and give an access to Your library. ")
                                
                                .multilineTextAlignment(.center)
                                .layoutPriority(5)
//                                .padding(.horizontal, 20)
                        }
                        
                        Spacer()
                        Button(action: {
                            //                            self.index+=1
                            //UserSettings.shared.setWelcomeScreenEnabled(false)
                            UserDefaults.standard.set(true, forKey: "WelcomeHidden")
                            UserDefaults.standard.synchronize()
                            MXContextMenuModel.global.hideContextMenu()
                        }, label: {
                            Text("OK, let me try!").foregroundColor(.white)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 15)
                                    .foregroundColor(.orange))

                        })
                        Spacer()
                    }
                    .foregroundColor(.white)

 
                    .padding(.horizontal, 20)
                    .tag(2)

                }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut) // 2
                .transition(.slide) // 3
                  
                
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        CircleButton(isSelected: Binding<Bool>(get: { self.index == index }, set: { _ in })) {
                            withAnimation {
                                self.index = index
                            }
                        }
                    }
                }
                
                Spacer()
            }
             .background(Color.black)
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}

enum WelcomePageType{
    case start, end, middle
}



struct CircleButton: View {
    @Binding var isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            self.action()
        }) { Circle()
            .frame(width: 16, height: 16)
            .foregroundColor(self.isSelected ? Color.orange : Color.white.opacity(0.5))
        }
    }
}

