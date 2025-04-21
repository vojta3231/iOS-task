import SwiftUI

struct SearchResultRow: View {
    let entity: PlayerSearchData
    
    var body: some View {
        HStack(spacing: 12) {
            // Entity image
            if let imageURL = entity.imageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(width: 50, height: 50)
                .cornerRadius(8)
            } else {
                Image(systemName: "photo")
                    .frame(width: 50, height: 50)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
            
            // Entity details
            VStack(alignment: .leading, spacing: 4) {
                Text(entity.name)
                    .font(.headline)
                
                HStack {
                    Image(systemName: "flag.fill")
                        .foregroundColor(.secondary)
                    Text(entity.country)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
        }

    }
}
