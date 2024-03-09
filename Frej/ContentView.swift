import SwiftUI



struct ContentView: View {
    var body: some View {
        FrejView().background(Rectangle().fill(.black))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
