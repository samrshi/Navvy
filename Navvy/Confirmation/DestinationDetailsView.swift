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
            Text("Details")
                .font(.headline)
            
            VStack {
                if let address = address {
                    detailItem(title: "Address") {
                        copyMenu(textToCopy: address) {
                            Text(address)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    
                    Divider()
                }
                
                detailItem(title: "Coordinates") {
                    copyMenu(textToCopy: coordinates) {
                        Text(coordinates)
                            .multilineTextAlignment(.leading)
                    }
                }
                
                if let phoneNumber = phoneNumber {
                    Divider()
                    
                    detailItem(title: "Phone Number") {
                        Button {
                            callPhoneNumber(number: phoneNumber)
                        } label: {
                            Text(phoneNumber)
                                .multilineTextAlignment(.leading)
                        }
                    }
                }
                
                if let url = url {
                    Divider()
                    
                    detailItem(title: "Website") {
                        Button { openWebsite(url: url) } label: {
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
    
    func copyTextToClipboard(text: String) {
        let clipboard = UIPasteboard.general
        clipboard.string = text
    }
    
    func callPhoneNumber(number: String) {
        if let url = URL(string: "tel://" + number.rawPhoneNumber()) {
            UIApplication.shared.open(url)
        }
    }
    
    func openWebsite(url: URL) {
        UIApplication.shared.open(url)
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
    
    @ViewBuilder func copyMenu<Content: View>(textToCopy: String, @ViewBuilder content: () -> Content) -> some View {
        Menu {
            Button {
                copyTextToClipboard(text: textToCopy)
            } label: {
                Label("Copy", systemImage: "doc.on.doc")
            }
        } label: {
            content()
                .foregroundColor(.primary)
        }
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
