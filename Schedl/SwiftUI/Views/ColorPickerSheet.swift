import SwiftUI

struct ColorPickerSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    let palettes: [ColorPalette] = [ColorPalette.pastel, ColorPalette.rustic, ColorPalette.foresty, ColorPalette.monochrome]
    @Binding var selectedColor: Color
    @State var sheetPresentationState: PresentationDetent = .medium
    let singleRowColumns = Array(repeating: GridItem(.fixed(44)), count: ColorPalette.pastel.colors.count)
    let multiRowColumns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                ForEach(palettes, id: \.name) { palette in
                    VStack(alignment: .leading, spacing: 0) {
                        Text(palette.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .fontDesign(.monospaced)
                            .tracking(-0.25)
                            .foregroundStyle(Color(hex: 0x333333))
                            .padding(.leading)
                        
                        ScrollView(sheetPresentationState == .large ? .vertical : .horizontal, showsIndicators: false) {
                            LazyVGrid(columns: sheetPresentationState == .large ? multiRowColumns : singleRowColumns, alignment: .leading) {
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
                            .padding()
                        }
                        .animation(.easeInOut(duration: 0.2), value: sheetPresentationState)
                    }
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
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


