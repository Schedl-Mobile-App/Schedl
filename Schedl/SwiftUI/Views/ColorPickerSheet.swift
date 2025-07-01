import SwiftUI

struct ColorPickerSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    let palettes: [ColorPalette] = [ColorPalette.pastel, ColorPalette.rustic, ColorPalette.foresty, ColorPalette.monochrome]
    @Binding var selectedColor: Color
    @State var sheetPresentationState: PresentationDetent = .medium
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 10) {
                switch sheetPresentationState {
                case .medium:
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(palettes, id: \.name) { palette in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(palette.name)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .fontDesign(.monospaced)
                                    .tracking(-0.25)
                                    .foregroundStyle(Color(hex: 0x333333))
                                    .padding(.leading)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(palette.colors, id: \.self) { color in
                                            Button(action: {
                                                selectedColor = color
                                            }) {
                                                ZStack {
                                                    Circle()
                                                        .fill(color)
                                                }
                                                .scaleEffect(selectedColor.toHex() == color.toHex() ? 1.125 : 1)
                                                .frame(width: 44, height: 44)
                                                .contentShape(Circle())
                                                .animation(.easeInOut(duration: 0.3), value: selectedColor.toHex() == color.toHex())
                                            }
                                            .frame(width: 50, height: 50)
                                            .buttonStyle(.plain)
                                        }
                                    }
                                    .padding(.leading)
                                }
                            }
                        }
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                case .large:
                    VStack(alignment: .leading, spacing: 25) {
                        ForEach(palettes, id: \.name) { palette in
                            VStack(alignment: .leading) {
                                Text(palette.name)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .fontDesign(.monospaced)
                                    .tracking(-0.25)
                                    .foregroundStyle(Color(hex: 0x333333))
                                
                                LazyVGrid(columns: columns) {
                                    ForEach(palette.colors, id: \.self) { color in
                                        Button(action: {
                                            selectedColor = color
                                        }) {
                                            ZStack {
                                                Circle()
                                                    .fill(color)
                                            }
                                            .scaleEffect(selectedColor.toHex() == color.toHex() ? 1.125 : 1)
                                            .frame(width: 44, height: 44)
                                            .contentShape(Circle())
                                            .animation(.easeInOut(duration: 0.3), value: selectedColor.toHex() == color.toHex())
                                        }
                                        .frame(width: 44, height: 44)
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                default:
                    EmptyView()
                    
                }
            }
            .navigationTitle("Select Color")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large], selection: $sheetPresentationState)
    }
}


