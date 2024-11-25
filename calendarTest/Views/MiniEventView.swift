import SwiftUI

struct EventViewNoEdit: View {
    @State private var eventTitle: String = "Halloween"
    @State private var eventSubtitle: String = "October 31st, 9:00 PM"
    @State private var eventDescription: String = "BOOOOOOM, this event is gonna go CRAZY"
    @State private var eventPhotos: [String] = ["pic1", "pic2", "pic3"]
    @State private var eventCreator: String = "Garfield Lasang"
    @State private var eventLocation: String = "123 Party Ave, Fun City"

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 5) {
                //Title, Time, Location, Host
                Text(eventTitle)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                Text("Date: " + eventSubtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("Location: " + eventLocation)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("Host: " + eventCreator)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            //Gallery
            VStack(alignment: .leading) {
                Text("Gallery")
                    .font(.headline)

                TabView {
                    ForEach(eventPhotos, id: \.self) { photo in
                        Image(photo)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 300)
                            .clipped()
                            .cornerRadius(15)
                            .shadow(radius: 5)
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .frame(height: 300)

                Spacer().frame(height: 10)

                // Description
                VStack(alignment: .leading) {
                    Text("Description")
                        .font(.headline)
                        .padding(.bottom, 5)
                    Text(eventDescription)
                        .font(.body)
                        .foregroundColor(.primary)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

#Preview {
    EventViewNoEdit()
}
