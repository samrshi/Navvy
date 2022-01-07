//
//  QuickSearchView.swift
//  Navvy
//
//  Created by Samuel Shi on 1/7/22.
//

import MapKit
import SwiftUI

struct QuickSearchView: View {
    let didSelectCategory: (MKPointOfInterestCategory) -> Void

    var body: some View {
        VStack {
            Divider()
            
            ForEach(groups) { group in
                VStack(alignment: .leading) {
                    Text(group.name)
                        .font(.footnote)
                        .bold()

                    ScrollView(.horizontal, showsIndicators: false) {
                        groupGridView(group: group)
                    }
                }
            }
        }
    }

    func groupGridView(group: PointOfInterestCategoryGroup) -> some View {
        let rows: [GridItem] = [
            GridItem(.flexible(minimum: 50, maximum: 500)),
            GridItem(.flexible(minimum: 50, maximum: 500)),
        ]

        return LazyHGrid(rows: rows, spacing: 4) {
            ForEach(group.categories, id: \.rawValue) { category in
                categoryView(category: category)
            }
        }
        .padding(.vertical, 5)
    }

    func categoryView(category: MKPointOfInterestCategory) -> some View {
        Button {
            didSelectCategory(category)
        } label: {
            HStack(spacing: 8) {
                Image(category.toIcon())
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)

                Text(category.displayName)
                    .font(.callout)
            }
            .frame(minWidth: 160, alignment: .leading)
            .padding(4)
            .background(Color(uiColor: .secondaryBackground))
            .cornerRadius(10)
            .foregroundColor(.primary)
        }
    }
}

struct QuickSearchView_Previews: PreviewProvider {
    static var previews: some View {
        QuickSearchView(didSelectCategory: { _ in })
    }
}

struct PointOfInterestCategoryGroup: Identifiable {
    var id = UUID()

    let name: String
    let categories: [MKPointOfInterestCategory]
}

let groups = [
    PointOfInterestCategoryGroup(name: "Food and Drinks", categories: foodAndDrinks),
    PointOfInterestCategoryGroup(name: "Travel", categories: travel),
    PointOfInterestCategoryGroup(name: "Things to Do", categories: thingsToDo),
    PointOfInterestCategoryGroup(name: "Services", categories: services),
    PointOfInterestCategoryGroup(name: "Education", categories: education),
]

let foodAndDrinks: [MKPointOfInterestCategory] = [
    .bakery,
    .brewery,
    .cafe,
    .foodMarket,
    .restaurant,
    .winery,
]

let travel: [MKPointOfInterestCategory] = [
    .airport,
    .carRental,
    .evCharger,
    .gasStation,
    .hotel,
    .parking,
    .publicTransport,
]

let thingsToDo: [MKPointOfInterestCategory] = [
    .aquarium,
    .beach,
    .campground,
    .fitnessCenter,
    .marina,
    .movieTheater,
    .museum,
    .nationalPark,
    .nightlife,
    .park,
    .theater,
    .stadium,
    .store,
    .zoo,
    .amusementPark,
]

let services: [MKPointOfInterestCategory] = [
    .atm,
    .bank,
    .fireStation,
    .hospital,
    .laundry,
    .pharmacy,
    .police,
    .postOffice,
    .restroom,
]

let education: [MKPointOfInterestCategory] = [
    .library,
    .school,
    .university,
]
