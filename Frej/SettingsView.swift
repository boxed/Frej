import SwiftUI
import CoreLocation

struct SettingsView: View {
    @ObservedObject var userSettings: UserSettings
    @Binding var gpsLocation: SavedLocation?
    @Environment(\.dismiss) var dismiss
    @State private var showAddLocation = false

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Temperature")) {
                    Picker("Unit", selection: $userSettings.unit) {
                        Text("Celsius (C)").tag("C")
                        Text("Fahrenheit (F)").tag("F")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section(header: Text("Display")) {
                    Toggle("Show UV Index on Sun Rays", isOn: $userSettings.showUVRays)
                }

                Section(header: Text("Locations")) {
                    if let gps = gpsLocation {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(.blue)
                            Text(gps.name.isEmpty ? "Current Location" : gps.name)
                            Spacer()
                            Text("GPS")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }

                    ForEach(userSettings.savedLocations) { location in
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.red)
                            Text(location.name)
                        }
                    }
                    .onDelete(perform: deleteLocations)
                    .onMove(perform: moveLocations)

                    Button(action: { showAddLocation = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                            Text("Add Location")
                        }
                    }
                }

                Section {
                    Link("Weather data by Open-Meteo.com", destination: URL(string: "https://open-meteo.com/")!)
                        .foregroundColor(.gray)
                }
            }
            #if os(iOS) || targetEnvironment(macCatalyst)
            .listStyle(InsetGroupedListStyle())
            #endif
            .navigationTitle("Settings")
            #if os(iOS) || targetEnvironment(macCatalyst)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            #endif
            .sheet(isPresented: $showAddLocation) {
                AddLocationView(userSettings: userSettings)
            }
        }
        .preferredColorScheme(.dark)
    }

    func deleteLocations(at offsets: IndexSet) {
        userSettings.savedLocations.remove(atOffsets: offsets)
    }

    func moveLocations(from source: IndexSet, to destination: Int) {
        userSettings.savedLocations.move(fromOffsets: source, toOffset: destination)
    }
}

struct AddLocationView: View {
    @ObservedObject var userSettings: UserSettings
    @Environment(\.dismiss) var dismiss

    @State private var searchText = ""
    @State private var searchResults: [CLPlacemark] = []
    @State private var isSearching = false
    @State private var searchTask: Task<Void, Never>?
    @FocusState private var isSearchFieldFocused: Bool

    private let geocoder = CLGeocoder()

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search city...", text: $searchText)
                        .focused($isSearchFieldFocused)
                        #if os(iOS)
                        .textInputAutocapitalization(.words)
                        #endif
                        .onSubmit { performSearch() }
                        .onChange(of: searchText) {
                            searchTask?.cancel()
                            guard !searchText.isEmpty else {
                                searchResults = []
                                return
                            }
                            searchTask = Task {
                                try? await Task.sleep(nanoseconds: 400_000_000)
                                guard !Task.isCancelled else { return }
                                await MainActor.run {
                                    performSearch()
                                }
                            }
                        }

                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding()

                if isSearching {
                    ProgressView("Searching...")
                        .padding()
                    Spacer()
                } else if searchResults.isEmpty && !searchText.isEmpty {
                    Text("No results found")
                        .foregroundColor(.gray)
                        .padding()
                    Spacer()
                } else {
                    List(searchResults, id: \.self) { placemark in
                        Button(action: { selectLocation(placemark) }) {
                            VStack(alignment: .leading) {
                                Text(placemark.locality ?? placemark.name ?? "Unknown")
                                    .font(.headline)
                                Text(formatAddress(placemark))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Location")
            #if os(iOS) || targetEnvironment(macCatalyst)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
            #endif
        }
        .preferredColorScheme(.dark)
        .onAppear {
            isSearchFieldFocused = true
        }
    }

    func performSearch() {
        guard !searchText.isEmpty else { return }
        isSearching = true

        geocoder.geocodeAddressString(searchText) { placemarks, error in
            isSearching = false
            if let placemarks = placemarks {
                searchResults = placemarks
            } else {
                searchResults = []
            }
        }
    }

    func selectLocation(_ placemark: CLPlacemark) {
        guard let coordinate = placemark.location?.coordinate else { return }

        let name = placemark.locality ?? placemark.name ?? "Unknown"
        let location = SavedLocation(
            name: name,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            isGPS: false
        )

        userSettings.savedLocations.append(location)
        dismiss()
    }

    func formatAddress(_ placemark: CLPlacemark) -> String {
        [placemark.administrativeArea, placemark.country]
            .compactMap { $0 }
            .joined(separator: ", ")
    }
}
