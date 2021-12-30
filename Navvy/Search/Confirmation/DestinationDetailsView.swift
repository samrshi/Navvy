//
//  DestinationConfirmationDetailsView.swift
//  Navvy
//
//  Created by Samuel Shi on 12/30/21.
//

import SwiftUI

struct DestinationConfirmationDetailsView: View {
    let address: String?
    let coordinates: String
    let phoneNumber: String?
    let url: URL?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Details").font(.headline)
            
            VStack {
                if let address = address {
                    detailItem(title: "Address") {
                        Text(address)
                    }
                    
                    Divider()
                }
                
                detailItem(title: "Coordinates") {
                    Text(coordinates)
                }
                
                if let phoneNumber = phoneNumber {
                    Divider()
                    
                    detailItem(title: "Phone Number") {
                        Text(phoneNumber)
                    }
                }
                
                if let url = url {
                    Divider()
                    
                    detailItem(title: "Website") {
                        Button {
                            UIApplication.shared.open(url)
                        } label: {
                            Text(url.absoluteString)
                                .multilineTextAlignment(.leading)
                        }
                    }
                }
            }
            .padding(15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(uiColor: .tertiaryBackground))
            .cornerRadius(10)
        }
    }
    
    @ViewBuilder func detailItem<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .foregroundColor(.secondary)
                .font(.footnote)
            
            content()
                .font(.callout)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct DestinationConfirmationDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        DestinationConfirmationDetailsView(
            address: "103 E Franklin St, Chapel Hill, NC 27514",
            coordinates: "36.2345 N, 70.2345 W", phoneNumber: "(919) 280-1610",
            url: URL(string: "https://www.starbucks.com"))
            .preferredColorScheme(.dark)
        
        DestinationConfirmationDetailsView(
            address: "103 E Franklin St, Chapel Hill, NC 27514",
            coordinates: "36.2345 N, 70.2345 W", phoneNumber: nil, url: nil)
    }
}
