import SwiftUI

struct EntityDetailView: View {
    let entity: PlayerSearchData

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Titulek s názvem entity
                Text(entity.name)
                    .font(.largeTitle)
                    .padding(.top)
                    .multilineTextAlignment(.center)

                // Obrázek nebo placeholder
                if let imageUrl = entity.imageURL, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray)
                            .frame(width: 200, height: 200)
                    }
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray)
                        .frame(width: 200, height: 200)
                }

                // Informace o entitě
                VStack(alignment: .leading, spacing: 10) {
                    if !entity.country.isEmpty && entity.country != "Unknown" {
                        InfoRow(title: "Země", value: entity.country)
                    }
                    
                    if !entity.sport.isEmpty && entity.sport != "Unknown Sport" {
                        InfoRow(title: "Sport", value: entity.sport)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .shadow(radius: 2)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.body)
        }
    }
}

