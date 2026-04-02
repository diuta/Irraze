import SwiftUI

struct InstructionsView: View {
    @Binding var firstGuide: Bool
    @Binding var secondGuide: Bool
    @Binding var thirdGuide: Bool
    @Binding var fourthGuide: Bool
    @Binding var showGame: Bool
    
    var body: some View {
        VStack {
            if firstGuide {
                VStack(spacing: 20) {
                    Text("RACE TO THE BOTTOM OF THE MAZE")
                        .font(.custom("PressStart2P-Regular", size: 10))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                    
                    CountdownBar(duration: 5.0)
                        .padding(.horizontal, 40)
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        firstGuide = false
                        secondGuide = true
                    }
                }
            } else if secondGuide {
                VStack(spacing: 20) {
                    Text("THERE WILL BE 3 POWERS ACROSS THE MAZE....")
                        .font(.custom("PressStart2P-Regular", size: 10))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                    
                    CountdownBar(duration: 5.0)
                        .padding(.horizontal, 40)
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        secondGuide = false
                        thirdGuide = true
                    }
                }
            } else if thirdGuide {
                VStack(spacing: 30){
                    VStack(spacing:10){
                        Circle()
                            .fill(Color(Constants.freezeColor))
                            .frame(width: 12, height: 12)
                            .shadow(radius: 3)
                        Text("FREEZE")
                            .font(.custom("PressStart2P-Regular", size: 10))
                            .foregroundColor(.black)
                        Text("Freeze opponent's movement")
                            .font(.custom("PressStart2P-Regular", size: 7))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                    }
                    VStack(spacing:10){
                        Circle()
                            .fill(Color.indigo)
                            .frame(width: 12, height: 12)
                            .shadow(radius: 3)
                        Text("SWAP")
                            .font(.custom("PressStart2P-Regular", size: 10))
                            .foregroundColor(.black)
                        Text("Swap position with the opponent's")
                            .font(.custom("PressStart2P-Regular", size: 7))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                    }
                    VStack(spacing:10){
                        Circle()
                            .fill(Color.brown)
                            .frame(width: 12, height: 12)
                            .shadow(radius: 3)
                        Text("FOG")
                            .font(.custom("PressStart2P-Regular", size: 10))
                            .foregroundColor(.black)
                        Text("Fog opponent's vision")
                            .font(.custom("PressStart2P-Regular", size: 7))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                    }
                    
                    CountdownBar(duration: 10.0)
                        .padding(.horizontal, 40)
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                        thirdGuide = false
                        fourthGuide = true
                    }
                }
            } else if fourthGuide {
                VStack(spacing: 30){
                    VStack{
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 40, height: 40)
                            .offset(x: -20)
                            .shadow(color: .black, radius: 0, x: 5, y: 5)
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 40, height: 40)
                            .offset(x: 20)
                            .shadow(color: .black, radius: 0, x: 5, y: 5)
                    }
                    
                    VStack(spacing: 10){
                        Text("SKILL BUTTONS")
                            .font(.custom("PressStart2P-Regular", size: 10))
                            .foregroundColor(.black)
                        Text("Will be available when you picked up a skill")
                            .font(.custom("PressStart2P-Regular", size: 7))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                    }
                    
                    CountdownBar(duration: 10.0)
                        .padding(.horizontal, 40)
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                        showGame = true
                        fourthGuide = false
                        firstGuide = true
                        SoundManager.shared.play("gamestart")
                    }
                }
            }
        }
    }
}

struct CountdownBar: View {
    let duration: Double
    @State private var progress: CGFloat = 0.0
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle()
                    .stroke(Color.black, lineWidth: 2)
                
                Rectangle()
                    .fill(Color.black)
                    .frame(width: max(0, geo.size.width * progress - 4))
                    .padding(2)
            }
        }
        .frame(height: 12)
        .onAppear {
            progress = 0.0
            withAnimation(.linear(duration: duration)) {
                progress = 1.0
            }
        }
    }
}
