import SwiftUI

struct ColorPickerSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    let palettes: [ColorPalette] = [ColorPalette.pastel, ColorPalette.rustic, ColorPalette.foresty]
    @Binding var selectedColor: Color
    @Binding var alpha: Double
    @State var sheetPresentationState: PresentationDetent = .medium
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 10) {
                switch sheetPresentationState {
                case .medium:
                    // palette selection stack
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(palettes, id: \.name) { palette in
                            VStack(alignment: .leading) {
                                Text(palette.name)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .fontDesign(.monospaced)
                                    .tracking(-0.25)
                                    .foregroundStyle(Color(hex: 0x333333))
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(palette.colors, id: \.self) { color in
                                            Button(action: {
                                                selectedColor = color.opacity(alpha)
                                            }) {
                                                ZStack {
                                                    Circle()
                                                        .fill(color.opacity(alpha))
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
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
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
                                            selectedColor = color.opacity(alpha)
                                        }) {
                                            ZStack {
                                                Circle()
                                                    .fill(color.opacity(alpha))
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
                default:
                    EmptyView()
                    
                }
                
                Spacer()
                
                // Alpha (Opacity) Slider
                VStack(alignment: .leading, spacing: 10) {
                    Text("Opacity: \(Int(alpha * 100))%")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Slider(value: $alpha, in: 0...1, step: 0.01) {
                        Text("Opacity")
                    }
                    .tint(Color.accentColor)
                }
                .padding([.bottom, .horizontal])
            }
            .navigationTitle("Select Color")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .padding(.top)
        }
        .presentationDetents([.medium, .large], selection: $sheetPresentationState)
    }
}


