//
//  File.swift
//  
//
//  Created by Cristian Felipe Patiño Rojas on 10/04/2024.
//

import SwiftUI
import SwiftUIIntrospect

//extension View {
//    var statusBarHeight: CGFloat {
//        let window = UIApplication.shared.windows.first
//        let statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
//        return statusBarHeight
//    }
//}

struct Movie: View, NetworkGetter, FeedbackGenerator {
  
    @StateObject var store      = Store()
    @StateObject var tabState   = Globals.tabState
    @StateObject var favorites  = FileBase.favorites
    @StateObject var ratings    = FileBase.ratings
    @Environment(\.theme) var theme
    
    /// Used to correct the offset obtained through scroll view delegate
    var setTabVideoURL: (URL?) -> Void = { Globals.tabState.videoURL = $0 }
    
    let props: JSON
    
    var body: some View {
        VStack {
            ProgressIcon(
                image: "star.fill",
                progress: store.progress,
                color: theme.starColor2
            )
            // @todo:
//            .opacity(abs(store.correctedOffset) >= statusBarHeight ? 1 : 0)
            .top(-ProgressIcon.height)
            .top(-store.navbarHeight)
            
            Header(isRating: $store.isRating) * { h in
                h.props = props
                h.isFavorite = favorites.contains(props.id)
                h.toggleFavorite = toggleFavorite
                h.isRated = ratings.contains(props.id)
                h.clearRate = {ratings.delete(props)}
                h.rate = {store.isRating = true}
            }
          
            
            InfoStack(props: props).top(.s6)
            StoryLine(props: props).top(.s9)
            CastSection().vertical(.s9)
        }
        .horizontal(.s6)
        .scrollify()
        .introspect(.scrollView, on: .iOS(.v15, .v16, .v17), customize: setScrollViewDelegate)
        .background(background.fullScreen())
        .onDisappear { setTabVideoURL(nil) }
        .task { await getTrailerURL() }
        .toolbar { ToolbarItem(placement: .navigationBarTrailing, content: toolbar) }
//        .text(statusBarHeight)
    }
    
    func setScrollViewDelegate(_ scrollView: UIScrollView) {
        scrollView.delegate = store
    }
    
    func toggleFavorite() {
        if favorites.contains(props.id) {
            favorites.delete(props)
        } else {
            favorites.upsert(props)
        }
    }
    
    // @add cache mecanism
    func getTrailerURL() async {
        let url = TMDb.videos(id: props.id)
        if let (data, _) = try? await fetchData(url: url) {
            let first = try? JSON(data: data).results.array.first
            if let key = first?.key.string {
                setTabVideoURL(youtubeURL(key: key))
            }
        }
    }
}

extension Movie {
    var background: Background {
        Background(url: props.backdrop_path.string?.tmdbImageURL)
    }
    
    func CastSection() -> some View {
        AsyncJSON(url: TMDb.credits(id: props.id)) { json in
            Cast(props: json.cast).horizontal(-.s6)
        }
    }
}

extension Movie {
    /// Stores Movie screen states
    final class Store: NSObject, ObservableObject, UIScrollViewDelegate {
        
        @Published var offset = CGPoint.zero
        @Published var navbarHeight = CGFloat.zero
        @Published var isRating = false
        
        private let threshold = 110.0
        
        var correctedOffset: CGFloat {
            let roundedOffset = (offset.y * 100).rounded() / 100
            let roundedInset  = (navbarHeight * 100).rounded() / 100
            return roundedOffset + roundedInset
        }
        
        var progress: CGFloat {
            let min = correctedOffset / threshold
            return -min
        }
        
        var scrollViewWillBeginDecelerating = {}
        
        // MARK: - Scroll view events
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.offset = scrollView.contentOffset
                if self.navbarHeight == .zero {
                    self.navbarHeight = -scrollView.contentOffset.y
                }
            }
        }
        
        func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                if self.progress >= 1 { self.isRating.toggle() }
            }
        }
    }
}

// MARK: - Navigation bar buttons (toolbar)
extension Movie {
    func toolbar() -> some View {
        HStack(spacing: .s4) {
            if let rating = ratings.read(id: props.id)?.user_rating.int {
                StarsButton(onTap: {store.isRating.toggle()}, rating: rating)
            }
            
            if favorites.contains(props.id) {
                HeartButton(onTap: toggleFavorite)
            }
        }
    }
    
    struct HeartButton: View {
        @State var isPressed = false
        var onTap = {}
        var body: some View {
            Image(systemName: isPressed ? "heart" : "heart.fill")
                .foregroundColor(.red)
                .onTap(perform: onTap)
                .buttonStyle(PressTrackerStyle(onPress: onPress))
                .animation(.spring(), value: isPressed)
        }
        
        func onPress(_ b: Bool) {isPressed = b}
    }
    
    struct StarsButton: View {
        @Environment(\.theme) var theme
        var onTap = {}
        let rating: Int
        
        var body: some View {
            HStack(spacing: 0) {
                Spacer()
                    ForEach(Array(1...rating), id: \.self) { index in
                        Image(systemName: "star.fill")
                            .foregroundColor(theme.starColor2)
                            .shadow(color: .black.opacity(0.1),radius: 2, x: 2, y: 0)
                            .opacity(factor(index))
                            .scaleEffect(factor(index))
                            .trailing(index == rating ? 0 : -.s5)
                            .zIndex(Double(5 - index))
                    }
                }
            .onTap(perform: onTap)
            .buttonStyle(ScaleStyle(duration: 0.07))
        }
        
        func factor(_ index: Int) -> Double {
           makeFactors()[index - 1]
        }
        
        func makeOffsets() -> [Double] {
            let count = Array(1...rating).count
            let offsets = [50, 40, 30, 20, 0]
            let toDrop = 5 - count
            return Array(offsets.dropFirst(toDrop)).map {Double($0)}
        }
        
        func makeFactors() -> [Double] {
            let count = Array(1...rating).count
            let factors = [0.6, 0.7, 0.8, 0.9, 1].reversed()
            let toDrop = 5 - count
            return Array(factors.dropLast(toDrop))
        }
    }
}

// MARK: - Rating stack
extension Movie {
    struct RatingStack: View {
        @StateObject var tabState = Globals.tabState
        @StateObject var ratings  = FileBase.ratings
        @StateObject var store    = Store()
        @Environment(\.theme) var theme
        @Binding var shown: Bool
    
        @State var shouldAppear = false
        let movie: JSON
        
        var rating: Int {
            ratings.read(id: movie.id)?.user_rating ?? 0
        }
        
        var body: some View {
            Color.clear
                .background(.ultraThickMaterial)
                .height(60)
                .cornerRadius(.s2)
                .shadow(color: .black.opacity(0.2), radius: .s3)
                .horizontal(.s4)
                .overlay(
                    HStack(spacing: .s4) {
                        star(1)
                        star(2)
                        star(3)
                        star(4)
                        star(5)
                    }
                    .font(.title)
                    .foregroundColor(theme.starColor)
                )
                .height(shouldAppear ? 60 : 0)
                
                .scaleEffect(shouldAppear ? 1 : 0)
                .animation(.bouncy(duration: 0.2), value: shouldAppear)
                .onChange(of: shown) {shouldAppear = $0}
        }
        
        func star(_ index: Int) -> some View {
            Button(
                isShown: $shown,
                index: index,
                movie: movie
            )
            .environmentObject(store)
        }
    }
}

extension Movie.RatingStack {
    struct Button: View, FeedbackGenerator {
        @EnvironmentObject var store: Store
        @StateObject var ratings  = FileBase.ratings
        @StateObject var tabState = Globals.tabState
        @Binding var isShown: Bool
        var pressing: Bool { store.target != nil }
        let index: Int
        let movie: JSON
        var currentRating: Int {
            ratings.read(id: movie.id)?.user_rating ?? 0
        }
        
        var isFilled: Bool {
            index <= currentRating
        }
        
        var defaultStart: Star {
            isFilled ? .fill : .unfill
        }
        
        func star() -> Star {
            Star.make(
                target: store.target,
                currentRating: currentRating,
                index: index,
                defaultStar: defaultStart
            )
        }

        var body: some View {
            Text(star().rawValue)
                .onTap(perform: action)
                .buttonStyle(PressTrackerStyle(onPress: onPress))
                .font(pressing ? .largeTitle : .title)
                .animation(
                    .easeInOut(duration: 0.1),
                    value: store.target?.index
                )
        }
        
        func action() {
            var copy = movie
            let isNotMin = index > 1
            let newRate = isNotMin ? index == currentRating
            ? index - 1
            : index
            : index
            
            copy.user_rating = newRate.json()
            ratings.upsert(copy)
            isShown = false
        }
        
        
        func onPress(_ pressing: Bool) {
            if pressing {
                store.target = (adding: !isFilled, index: index)
                generateFeedback(.rigid)
            }
            else { store.target = nil }
        }
    }
}

extension Movie.RatingStack.Button {
    enum Star: String {
        case fill = "★"
        case unfill = "☆"
    }
}

extension Movie.RatingStack.Button.Star {
    /// Star Rendering logic  (fills/unfills depending on if user is pressing
    static func make(target: (Bool, Int)?, currentRating: Int, index: Int, defaultStar: Self) -> Self {
        guard let target = target else {
            return defaultStar
        }
        if target.0 && target.1 >= index  {
            return .fill
        } else {
            if target.1 == index && index != 1 {
                return target.1 == currentRating
                ? .unfill
                : .fill
            }
            
            if target.1 < index {
                return .unfill
            }
        }
        return defaultStar
    }
}

extension Movie.RatingStack {
    final class Store: ObservableObject {
        @Published var target: (adding: Bool, index: Int)?
    }
}

// MARK: - Header
extension Movie {
    struct Header: View {
        
        @Environment(\.theme) var theme: Theme
        @Binding var isRating: Bool
        var props = JSON()
        var id: Int {props.id}
        var title: String {props.title}
        var voteAverage: Double {props.vote_average}
        var posterURL: URL? { props.poster_path.string?.tmdbImageURL }
        var isFavorite = false
        var isRated = false
        var toggleFavorite = {}
        var rate = {}
        var clearRate = {}
        
        var ratingStars: String { voteAverage.makeRatingStars() }
        
        var voteAverageRounded: String {
            voteAverage.reduceScale(to: 1).description
        }
        
        var favoriteButtonLabel: String {
            isFavorite ? "Remove from Favorites" : "Add to Favorites"
        }
        
        var favoriteButtonImage: String {
            isFavorite ? "heart.slash" : "heart"
        }
        
        var rateButtonLabel: String {
            isRated ? "Update rate" : "Rate movie"
        }
        
        
        var body: some View {
            
            VStack {
                posterView
                    .contextMenu {
                        Button {
                            toggleFavorite()
                        } label: {
                            Label(favoriteButtonLabel, systemImage: favoriteButtonImage)
                        }
                        
                        Button {
                            rate()
                        } label: {
                            Label(rateButtonLabel, systemImage: "star")
                        }
                        
                        if isRated {
                            Button {
                                clearRate()
                            } label: {
                                Label("Clear rate", systemImage: "star.slash")
                            }
                        }
                    }
                    .top(.s4)
                
                Movie.RatingStack(shown: $isRating, movie: props)
                
                Text(title)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundColor(theme.textPrimary)
                    .top(.s8)
                
                Text(voteAverageRounded)
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .foregroundColor(theme.textSecondary)
                    .top(.s3)
                
                Text(ratingStars)
                    .foregroundColor(theme.starColor)
                    .top(.s3)
                    .buttonStyle(ScaleStyle(duration: 0.1))
            }
            .animation(.bouncy, value: isRating)
        }
    }
}

private extension Movie.Header {
    var posterView: some View {
        AsyncImage(url: posterURL) { image in
            image.resizable()
        } placeholder: {
            theme.imgPlaceholder
                .overlay(ProgressView())
        }
        .cornerRadius(8)
        .shadow(radius: 8)
        .width(230)
        .height(310)
    }
}

// MARK: - InfoStack
extension Movie {
    struct InfoStack: View {
        let props: JSON
        
        var duration: String {
            guard props.runtime > 0 else {
                return "N/A"
            }
            
            return durationFormatter.string(from: props.runtime * 60) ?? "N/A"
        }
        
        var year: String {
            guard let releaseDate = dateFormatter.date(from: props.release_date) else {
                return "N/A"
            }
            return yearFormatter.string(from: releaseDate)
        }
        
        
        private let dateFormatter: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-mm-dd"
            return dateFormatter
        }()
        
        private let yearFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy"
            return formatter
        }()
        
        private let durationFormatter: DateComponentsFormatter = {
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .abbreviated
            formatter.allowedUnits = [.hour, .minute]
            return formatter
        }()
        
        var body: some View {
            HStack {
                Info(title: "Length", value: duration)
                Spacer()
                
                Info(title: "Year", value: year)
                Spacer()
                
                Info(title: "Language", value: props.original_language.string ?? "N/A")
                Spacer ()
                
                Info(title: "Vote count", value: "\(props.vote_count.intValue)")
            }
        }
    }
}

extension Movie {
    struct Info: View {
        @Environment(\.theme) var theme: Theme
        let title: String
        let value: String
        var body: some View {
            VStack(alignment: .leading) {
                Text(title)
                    .foregroundColor(theme.textPrimary)
                    .fontWeight(.heavy)
                Text(value.uppercased())
                    .fontWeight(.heavy)
                    .foregroundColor(theme.textSecondary)
                    .padding(.top, 5)
            }.font(.footnote)
        }
    }
}

// MARK: - StoryLine
extension Movie {
    struct StoryLine: View {
        @Environment(\.theme) var theme: Theme
        let props: JSON
        var body: some View {
            VStack(
                alignment: .leading,
                spacing: .s5
            ) {
                Text("Storyline")
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.heavy)
                    .foregroundColor(theme.textPrimary)
                
                Text(props.overview)
                    .font(.system(.footnote, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(theme.textSecondary)
            }
            .alignX(.leading)
        }
    }
}

// MARK: - Cast
extension Movie {
    struct Cast: View {
        @Environment(\.theme) var theme: Theme
        let props: JSON
        
        var body: some View {
            
            VStack(alignment: .leading, spacing: .s6) {
                
                Text("Cast")
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.heavy)
                    .foregroundColor(theme.textPrimary)
                    .leading(.s6)
                
                Carousel(model: props, spacing: .s2) { item in
                    ActorAvatar(
                        path: item.profile_path,
                        id: item.credit_id
                    )
                    .onTapScaleDown()
                    .leading(item.id == props.first?.id ? .s6 : 0)
                    .trailing(item.id == props.last?.id ? .s6 : 0)
                }
            }
        }
    }
}

extension Movie.Cast {
    struct ActorAvatar: View {
        @Environment(\.theme) var theme
        let path: String
        let id: String?
        var profileURL: URL? {
            URL(string: "https://image.tmdb.org/t/p/w500\(path)")
        }
        
        var body: some View {
            AsyncImage(url: profileURL) { image in
                
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                
                
                
            } placeholder: {
                imagePlaceholder
            }
            .size(.s14)
            .cornerRadius(.s2)
        }
        
        var imagePlaceholder: some View {
            
            theme.imgPlaceholder
                .font(.largeTitle)
                .overlay(Text(randomEmoji()))
        }
        
        func randomEmoji() -> String {
            ["🤓", "😎","🥸","🧐","🤠"][Int.random(in: 0...4)]
        }
    }
}

// MARK: - Background
extension Movie {
    struct Background: View {
        let url: URL?
        
        var body: some View {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .fullScreen()
                    .opacity(0.7)
                    .saturation(0.0)
                    .blur(radius: .s1)
                    .clipped()
                    .edgesIgnoringSafeArea(.top)
                    .overlay(DefaultBackground().opacity(0.5))
                    .overlay(WhiteGradient())
            } placeholder: {
                DefaultBackground().fullScreen()
            }
        }
    }
}

extension Movie.Background {
    struct WhiteGradient: View {
        @Environment(\.theme) var theme: Theme
        
        var body: some View {
            LinearGradient(
                gradient: theme.secondGradient,
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }
}


// MARK: - Extension
fileprivate extension Double {
    func makeRatingStars() -> String {
        let rating = Int(self/2)
        let ratingText = (0..<rating).reduce("") { (acc, _) -> String in
            return acc + "★"
        }
        if rating < 5 {
            let numOfMissingStars = 5 - rating
            var missingStars = ""
            for _ in 1...numOfMissingStars {
                missingStars.append("✩")
            }
            return ratingText + missingStars
        }
        return ratingText
    }
}

fileprivate extension Double {
    func reduceScale(to places: Int) -> Double {
        let multiplier = pow(10, Double(places))
        let newDecimal = multiplier * self // move the decimal right
        let truncated = Double(Int(newDecimal)) // drop the fraction
        let originalDecimal = truncated / multiplier // move the decimal back
        return originalDecimal
    }
}
