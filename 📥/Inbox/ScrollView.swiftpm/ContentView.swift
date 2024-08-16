import SwiftUI

struct ContentView: View {
    @State var offset = 0.0
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .offset(y: offset)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.red)
        .gesture(
            DragGesture()
                .onChanged {
                    offset = $0.translation.height 
                }
                .onEnded {
                    print($0.translation.height)
                }
        )
    }
}

extension View {
    func fullScreen() -> some View {
        self
            .frame(width: UIScreen.main.bounds.size.width)
            .frame(height: UIScreen.main.bounds.size.height)
            .edgesIgnoringSafeArea(.all)
    }
}




import Combine
import CombineSchedulers
import SwiftUI

final class ECScrollViewModel: ObservableObject {

    let didScroll = PassthroughSubject<Void, Never>()
    @Published private(set) var scrolling = false

    // MARK: - Private Properties

    private var cancellable: AnyCancellable?

    // MARK: - Lifecycle

    init(scheduler: AnySchedulerOf<DispatchQueue> = DispatchQueue.main.eraseToAnyScheduler()) {
        let stopped = didScroll
            .map({ false })
            .debounce(for: .seconds(0.5), scheduler: scheduler)
            .eraseToAnyPublisher()

        let scrolling = didScroll
            .map({ true })
            .eraseToAnyPublisher()

        cancellable = scrolling
            .merge(with: stopped)
            .assign(to: \.scrolling, on: self)
    }
}

public struct ECScrollView<Content: View>: View {

    private enum Constants {
        static var coordinateSpace: String { #function }
    }

    // MARK: - Private Properties

    @ObservedObject private var viewModel = ECScrollViewModel()

    /// Scroll view's content size
    @State private var contentSize = CGSize.zero

    /// Scroll view's content offset
    @State private var contentOffset = CGPoint.zero

    @State private var proxy: ScrollViewProxy?

    private let axes: Axis.Set
    private let showsIndicators: Bool
    private let onContentOffsetChanged: ((CGPoint, CGSize, ScrollViewProxy) -> Void)?
    private let didEndDecelerating: ((CGPoint, ScrollViewProxy) -> Void)?
    private let content: Content

    // MARK: - Initializers

    public init(
        _ axes: Axis.Set,
        showsIndicators: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        onContentOffsetChanged = nil
        didEndDecelerating = nil
        self.content = content()
    }

    private init(
        _ axes: Axis.Set,
        showsIndicators: Bool = true,
        onContentOffsetChanged: ((CGPoint, CGSize, ScrollViewProxy) -> Void)? = nil,
        didEndDecelerating: ((CGPoint, ScrollViewProxy) -> Void)? = nil,
        content: Content
    ) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.onContentOffsetChanged = onContentOffsetChanged
        self.didEndDecelerating = didEndDecelerating
        self.content = content
    }

    // MARK: - Public Properties

    public var body: some View {
        ScrollViewReader { proxy in
            ScrollView(axes, showsIndicators: showsIndicators) {
                ZStack {
                    content
                    GeometryReader { geometry in
                        Color.clear.preference(key: ContentOffsetPreferenceKey.self, value: geometry.frame(in: .named(Constants.coordinateSpace)).origin)
                        Color.clear.preference(key: ContentSizePreferenceKey.self, value: geometry.size)
                    }
                }
            }
            .coordinateSpace(name: Constants.coordinateSpace)
            .onPreferenceChange(ContentOffsetPreferenceKey.self) { contentOffset = $0 }
            .onPreferenceChange(ContentSizePreferenceKey.self) { contentSize = $0 }
            .onChange(of: contentOffset) {
                viewModel.didScroll.send()
                onContentOffsetChanged?($0, contentSize, proxy)
            }
            .onChange(of: contentSize) {
                onContentOffsetChanged?(contentOffset, $0, proxy)
            }
            .onChange(of: viewModel.scrolling) { scrolling in
                guard !scrolling else { return }
                didEndDecelerating?(contentOffset, proxy)
            }
        }
    }

    public func didEndDecelerating(_ didEndDecelerating: @escaping (CGPoint, ScrollViewProxy) -> Void) -> Self {
        ECScrollView(
            axes,
            showsIndicators: showsIndicators,
            onContentOffsetChanged: onContentOffsetChanged,
            didEndDecelerating: didEndDecelerating,
            content: content
        )
    }

    public func onContentOffsetChanged(_ onContentOffsetChanged: @escaping (CGPoint, CGSize, ScrollViewProxy) -> Void) -> Self {
        ECScrollView(
            axes,
            showsIndicators: showsIndicators,
            onContentOffsetChanged: onContentOffsetChanged,
            didEndDecelerating: didEndDecelerating,
            content: content
        )
    }
}

// MARK: - Preference Keys

struct ContentOffsetPreferenceKey: PreferenceKey {
    typealias Value = CGPoint

    static var defaultValue: CGPoint = .zero

    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
        let next = nextValue()
        value = CGPoint(
            x: value.x + -next.x,
            y: value.y + next.y
        )
    }
}

struct ContentSizePreferenceKey: PreferenceKey {
    typealias Value = CGSize

    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

import SwiftUI

// There are two type of positioning views - one that scrolls with the content,
// and one that stays fixed
private enum PositionType {
  case fixed, moving
}

// This struct is the currency of the Preferences, and has a type
// (fixed or moving) and the actual Y-axis value.
// It's Equatable because Swift requires it to be.
private struct Position: Equatable {
  let type: PositionType
  let y: CGFloat
}

// This might seem weird, but it's necessary due to the funny nature of
// how Preferences work. We can't just store the last position and merge
// it with the next one - instead we have a queue of all the latest positions.
private struct PositionPreferenceKey: PreferenceKey {
  typealias Value = [Position]

  static var defaultValue = [Position]()

  static func reduce(value: inout [Position], nextValue: () -> [Position]) {
    value.append(contentsOf: nextValue())
  }
}

private struct PositionIndicator: View {
  let type: PositionType

  var body: some View {
    GeometryReader { proxy in
        // the View itself is an invisible Shape that fills as much as possible
        Color.clear
          // Compute the top Y position and emit it to the Preferences queue
          .preference(key: PositionPreferenceKey.self, value: [Position(type: type, y: proxy.frame(in: .global).minY)])
     }
  }
}

// Callback that'll trigger once refreshing is done
public typealias RefreshComplete = () -> Void

// The actual refresh action that's called once refreshing starts. It has the
// RefreshComplete callback to let the refresh action let the View know
// once it's done refreshing.
public typealias OnRefresh = (@escaping RefreshComplete) -> Void

// The offset threshold. 68 is a good number, but you can play
// with it to your liking.
public let defaultRefreshThreshold: CGFloat = 68

// Tracks the state of the RefreshableScrollView - it's either:
// 1. waiting for a scroll to happen
// 2. has been primed by pulling down beyond THRESHOLD
// 3. is doing the refreshing.
public enum RefreshState {
  case waiting, primed, loading
}

// ViewBuilder for the custom progress View, that may render itself
// based on the current RefreshState.
public typealias RefreshProgressBuilder<Progress: View> = (RefreshState) -> Progress

// Default color of the rectangle behind the progress spinner
public let defaultLoadingViewBackgroundColor = Color(UIColor.systemBackground)

public struct RefreshableScrollView<Progress, Content>: View where Progress: View, Content: View {
  let showsIndicators: Bool // if the ScrollView should show indicators
  let shouldTriggerHapticFeedback: Bool // if key actions should trigger haptic feedback
  let loadingViewBackgroundColor: Color
  let threshold: CGFloat // what height do you have to pull down to trigger the refresh
  let onRefresh: OnRefresh // the refreshing action
  let progress: RefreshProgressBuilder<Progress> // custom progress view
  let content: () -> Content // the ScrollView content
  @State private var offset: CGFloat = 0
  @State private var state = RefreshState.waiting // the current state

  // Haptic Feedback
  let finishedReloadingFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
  let primedFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)

  // We use a custom constructor to allow for usage of a @ViewBuilder for the content
  public init(showsIndicators: Bool = true,
              shouldTriggerHapticFeedback: Bool = false,
              loadingViewBackgroundColor: Color = defaultLoadingViewBackgroundColor,
              threshold: CGFloat = defaultRefreshThreshold,
              onRefresh: @escaping OnRefresh,
              @ViewBuilder progress: @escaping RefreshProgressBuilder<Progress>,
              @ViewBuilder content: @escaping () -> Content) {
    self.showsIndicators = showsIndicators
    self.shouldTriggerHapticFeedback = shouldTriggerHapticFeedback
    self.loadingViewBackgroundColor = loadingViewBackgroundColor
    self.threshold = threshold
    self.onRefresh = onRefresh
    self.progress = progress
    self.content = content
  }

  public var body: some View {
    // The root view is a regular ScrollView
    ScrollView(showsIndicators: showsIndicators) {
      // The ZStack allows us to position the PositionIndicator,
      // the content and the loading view, all on top of each other.
      ZStack(alignment: .top) {
        // The moving positioning indicator, that sits at the top
        // of the ScrollView and scrolls down with the content
        PositionIndicator(type: .moving)
          .frame(height: 0)

         // Your ScrollView content. If we're loading, we want
         // to keep it below the loading view, hence the alignmentGuide.
         content()
           .alignmentGuide(.top, computeValue: { _ in
             (state == .loading) ? -threshold + max(0, offset) : 0
            })

          // The loading view. It's offset to the top of the content unless we're loading.
          ZStack {
            Rectangle()
              .foregroundColor(loadingViewBackgroundColor)
              .frame(height: threshold)
            progress(state)
          }.offset(y: (state == .loading) ? -max(0, offset) : -threshold)
        }
      }
      // Put a fixed PositionIndicator in the background so that we have
      // a reference point to compute the scroll offset.
      .background(PositionIndicator(type: .fixed))
      // Once the scrolling offset changes, we want to see if there should
      // be a state change.
      .onPreferenceChange(PositionPreferenceKey.self) { values in
          DispatchQueue.main.async {
              // Compute the offset between the moving and fixed PositionIndicators
              let movingY = values.first { $0.type == .moving }?.y ?? 0
              let fixedY = values.first { $0.type == .fixed }?.y ?? 0
              offset = movingY - fixedY
              if state != .loading { // If we're already loading, ignore everything
                // Map the preference change action to the UI thread

                  // If the user pulled down below the threshold, prime the view
                  if offset > threshold && state == .waiting {
                    state = .primed
                    if shouldTriggerHapticFeedback {
                      self.primedFeedbackGenerator.impactOccurred()
                    }

                  // If the view is primed and we've crossed the threshold again on the
                  // way back, trigger the refresh
                  } else if offset < threshold && state == .primed {
                    state = .loading
                    onRefresh { // trigger the refreshing callback
                      // once refreshing is done, smoothly move the loading view
                      // back to the offset position
                      withAnimation {
                        self.state = .waiting
                      }
                      if shouldTriggerHapticFeedback {
                        self.finishedReloadingFeedbackGenerator.impactOccurred()
                      }
                    }
                  }
              }
          }
      }
  }
}

// Extension that uses default RefreshActivityIndicator so that you don't have to
// specify it every time.
public extension RefreshableScrollView where Progress == RefreshActivityIndicator {
    init(showsIndicators: Bool = true,
         loadingViewBackgroundColor: Color = defaultLoadingViewBackgroundColor,
         threshold: CGFloat = defaultRefreshThreshold,
         onRefresh: @escaping OnRefresh,
         @ViewBuilder content: @escaping () -> Content) {
        self.init(showsIndicators: showsIndicators,
                  loadingViewBackgroundColor: loadingViewBackgroundColor,
                  threshold: threshold,
                  onRefresh: onRefresh,
                  progress: { state in
                    RefreshActivityIndicator(isAnimating: state == .loading) {
                        $0.hidesWhenStopped = false
                    }
                 },
                 content: content)
    }
}

// Wraps a UIActivityIndicatorView as a loading spinner that works on all SwiftUI versions.
public struct RefreshActivityIndicator: UIViewRepresentable {
  public typealias UIView = UIActivityIndicatorView
  public var isAnimating: Bool = true
  public var configuration = { (indicator: UIView) in }

  public init(isAnimating: Bool, configuration: ((UIView) -> Void)? = nil) {
    self.isAnimating = isAnimating
    if let configuration = configuration {
      self.configuration = configuration
    }
  }

  public func makeUIView(context: UIViewRepresentableContext<Self>) -> UIView {
    UIView()
  }

  public func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<Self>) {
    isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    configuration(uiView)
  }
}

#if compiler(>=5.5)
// Allows using RefreshableScrollView with an async block.
@available(iOS 15.0, *)
public extension RefreshableScrollView {
    init(showsIndicators: Bool = true,
         loadingViewBackgroundColor: Color = defaultLoadingViewBackgroundColor,
         threshold: CGFloat = defaultRefreshThreshold,
         action: @escaping @Sendable () async -> Void,
         @ViewBuilder progress: @escaping RefreshProgressBuilder<Progress>,
         @ViewBuilder content: @escaping () -> Content) {
        self.init(showsIndicators: showsIndicators,
                  loadingViewBackgroundColor: loadingViewBackgroundColor,
                  threshold: threshold,
                  onRefresh: { refreshComplete in
                    Task {
                        await action()
                        refreshComplete()
                    }
                },
                  progress: progress,
                  content: content)
    }
}
#endif

public struct RefreshableCompat<Progress>: ViewModifier where Progress: View {
    private let showsIndicators: Bool
    private let loadingViewBackgroundColor: Color
    private let threshold: CGFloat
    private let onRefresh: OnRefresh
    private let progress: RefreshProgressBuilder<Progress>

    public init(showsIndicators: Bool = true,
                loadingViewBackgroundColor: Color = defaultLoadingViewBackgroundColor,
                threshold: CGFloat = defaultRefreshThreshold,
                onRefresh: @escaping OnRefresh,
                @ViewBuilder progress: @escaping RefreshProgressBuilder<Progress>) {
        self.showsIndicators = showsIndicators
        self.loadingViewBackgroundColor = loadingViewBackgroundColor
        self.threshold = threshold
        self.onRefresh = onRefresh
        self.progress = progress
    }

    public func body(content: Content) -> some View {
        RefreshableScrollView(showsIndicators: showsIndicators,
                              loadingViewBackgroundColor: loadingViewBackgroundColor,
                              threshold: threshold,
                              onRefresh: onRefresh,
                              progress: progress) {
            content
        }
    }
}

#if compiler(>=5.5)
@available(iOS 15.0, *)
public extension List {
    @ViewBuilder func refreshableCompat<Progress: View>(showsIndicators: Bool = true,
                                                        loadingViewBackgroundColor: Color = defaultLoadingViewBackgroundColor,
                                                        threshold: CGFloat = defaultRefreshThreshold,
                                                        onRefresh: @escaping OnRefresh,
                                                        @ViewBuilder progress: @escaping RefreshProgressBuilder<Progress>) -> some View {
        if #available(iOS 15.0, macOS 12.0, *) {
            self.refreshable {
                await withCheckedContinuation { cont in
                    onRefresh {
                        cont.resume()
                    }
                }
            }
        } else {
            self.modifier(RefreshableCompat(showsIndicators: showsIndicators,
                                            loadingViewBackgroundColor: loadingViewBackgroundColor,
                                            threshold: threshold,
                                            onRefresh: onRefresh,
                                            progress: progress))
        }
    }
}
#endif

public extension View {
    @ViewBuilder func refreshableCompat<Progress: View>(showsIndicators: Bool = true,
                                                        loadingViewBackgroundColor: Color = defaultLoadingViewBackgroundColor,
                                                        threshold: CGFloat = defaultRefreshThreshold,
                                                        onRefresh: @escaping OnRefresh,
                                                        @ViewBuilder progress: @escaping RefreshProgressBuilder<Progress>) -> some View {
        self.modifier(RefreshableCompat(showsIndicators: showsIndicators,
                                        loadingViewBackgroundColor: loadingViewBackgroundColor,
                                        threshold: threshold,
                                        onRefresh: onRefresh,
                                        progress: progress))
    }
}

struct TestView: View {
  @State private var now = Date()

  var body: some View {
    RefreshableScrollView(
      onRefresh: { done in
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
          self.now = Date()
          done()
        }
      }) {
        VStack {
          ForEach(1..<20) {
            Text("\(Calendar.current.date(byAdding: .hour, value: $0, to: now)!)")
               .padding(.bottom, 10)
           }
         }.padding()
       }
     }
}

struct TestViewWithLargerThreshold: View {
  @State private var now = Date()

  var body: some View {
    RefreshableScrollView(
      threshold: defaultRefreshThreshold * 3,
      onRefresh: { done in
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
          self.now = Date()
          done()
        }
      }) {
        VStack {
          ForEach(1..<20) {
            Text("\(Calendar.current.date(byAdding: .hour, value: $0, to: now)!)")
               .padding(.bottom, 10)
           }
         }.padding()
       }
     }
}

struct TestViewWithCustomProgress: View {
    @State private var now = Date()

    var body: some View {
       RefreshableScrollView(onRefresh: { done in
          DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.now = Date()
            done()
          }
        },
                             progress: { state in
           if state == .waiting {
               Text("Pull me down...")
           } else if state == .primed {
               Text("Now release!")
           } else {
               Text("Working...")
           }
       }
       ) {
          VStack {
            ForEach(1..<20) {
              Text("\(Calendar.current.date(byAdding: .hour, value: $0, to: now)!)")
                 .padding(.bottom, 10)
             }
           }.padding()
         }
       }
  }

#if compiler(>=5.5)
@available(iOS 15, *)
struct TestViewWithAsync: View {
  @State private var now = Date()

  var body: some View {
     RefreshableScrollView(action: {
         try? await Task.sleep(nanoseconds: 3_000_000_000)
         now = Date()
     }, progress: { state in
         RefreshActivityIndicator(isAnimating: state == .loading) {
             $0.hidesWhenStopped = false
         }
     }) {
        VStack {
          ForEach(1..<20) {
            Text("\(Calendar.current.date(byAdding: .hour, value: $0, to: now)!)")
               .padding(.bottom, 10)
           }
         }.padding()
       }
     }
}
#endif

struct TestViewCompat: View {
    @State private var now = Date()

  var body: some View {
      VStack {
          ForEach(1..<20) {
          Text("\(Calendar.current.date(byAdding: .hour, value: $0, to: now)!)")
            .padding(.bottom, 10)
        }
      }
      .refreshableCompat(showsIndicators: false,
                         onRefresh: { done in
          DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.now = Date()
            done()
          }
      }, progress: { state in
          RefreshActivityIndicator(isAnimating: state == .loading) {
              $0.hidesWhenStopped = false
          }
      })

   }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}

struct TestViewWithLargerThreshold_Previews: PreviewProvider {
    static var previews: some View {
        TestViewWithLargerThreshold()
    }
}

struct TestViewWithCustomProgress_Previews: PreviewProvider {
    static var previews: some View {
        TestViewWithCustomProgress()
    }
}

#if compiler(>=5.5)
@available(iOS 15, *)
struct TestViewWithAsync_Previews: PreviewProvider {
    static var previews: some View {
        TestViewWithAsync()
    }
}
#endif

struct TestViewCompat_Previews: PreviewProvider {
    static var previews: some View {
        TestViewCompat()
    }
}

//
//  ReverseScrollView.swift
//  SwiftUI-ScrollView-Demo
//
//  Created by Mickaël Rémond on 24/09/2019.
//  Copyright © 2019 ProcessOne. All rights reserved.
//

import SwiftUI

struct ReverseScrollView<Content>: View where Content: View {
    @State private var contentHeight: CGFloat = CGFloat.zero
    @State private var scrollOffset: CGFloat = CGFloat.zero
    @State private var currentOffset: CGFloat = CGFloat.zero
    
    var content: () -> Content
    
    // Calculate content offset
    func offset(outerheight: CGFloat, innerheight: CGFloat) -> CGFloat {
        print("outerheight: \(outerheight) innerheight: \(innerheight)")
        
        let totalOffset = currentOffset + scrollOffset
        return -((innerheight/2 - outerheight/2) - totalOffset)
    }
    
    var body: some View {
        GeometryReader { outerGeometry in
            // Render the content
            //  ... and set its sizing inside the parent
            self.content()
            .modifier(ViewHeightKey())
            .onPreferenceChange(ViewHeightKey.self) { self.contentHeight = $0 }
            .frame(height: outerGeometry.size.height)
            .offset(y: self.offset(outerheight: outerGeometry.size.height, innerheight: self.contentHeight))
            .clipped()
            .animation(.easeInOut)
            .gesture(
                 DragGesture()
                    .onChanged({ self.onDragChanged($0) })
                    .onEnded({ self.onDragEnded($0, outerHeight: outerGeometry.size.height)}))
        }
    }
    
    func onDragChanged(_ value: DragGesture.Value) {
        // Update rendered offset
        print("Start: \(value.startLocation.y)")
        print("Start: \(value.location.y)")
        self.scrollOffset = (value.location.y - value.startLocation.y)
        print("Scrolloffset: \(self.scrollOffset)")
    }
    
    func onDragEnded(_ value: DragGesture.Value, outerHeight: CGFloat) {
        // Update view to target position based on drag position
        let scrollOffset = value.location.y - value.startLocation.y
        print("Ended currentOffset=\(self.currentOffset) scrollOffset=\(scrollOffset)")
        
        let topLimit = self.contentHeight - outerHeight
        print("toplimit: \(topLimit)")
        
        // Negative topLimit => Content is smaller than screen size. We reset the scroll position on drag end:
        if topLimit < 0 {
             self.currentOffset = 0
        } else {
            // We cannot pass bottom limit (negative scroll)
            if self.currentOffset + scrollOffset < 0 {
                self.currentOffset = 0
            } else if self.currentOffset + scrollOffset > topLimit {
                self.currentOffset = topLimit
            } else {
                self.currentOffset += scrollOffset
            }
        }
        print("new currentOffset=\(self.currentOffset)")
        self.scrollOffset = 0
    }
}

struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value + nextValue()
    }
}

extension ViewHeightKey: ViewModifier {
    func body(content: Content) -> some View {
        return content.background(GeometryReader { proxy in
            Color.clear.preference(key: Self.self, value: proxy.size.height)
        })
    }
}

//
//  ScrollStatusMonitor.swift
//
//
//  Created by Yang Xu on 2022/9/7.
//

import Combine
import Foundation
import SwiftUI

public extension View {
    @ViewBuilder
    func scrollStatusMonitor(_ isScrolling: Binding<Bool>, monitorMode: ScrollStatusMonitorMode) -> some View {
        switch monitorMode {
        case .common:
            modifier(ScrollStatusMonitorCommonModifier(isScrolling: isScrolling))
        #if !os(macOS) && !targetEnvironment(macCatalyst)
        case .exclusion:
            modifier(ScrollStatusMonitorExclusionModifier(isScrolling: isScrolling))
        #endif
        }
    }

    func scrollSensor() -> some View {
        overlay(
            GeometryReader { proxy in
                Color.clear
                    .preference(
                        key: MinValueKey.self,
                        value: proxy.frame(in: .global)
                    )
            }
        )
    }
}

#if !os(macOS) && !targetEnvironment(macCatalyst)
struct ScrollStatusMonitorExclusionModifier: ViewModifier {
    @StateObject private var store = ExclusionStore()
    @Binding var isScrolling: Bool
    func body(content: Content) -> some View {
        content
            .environment(\.isScrolling, store.isScrolling)
            .onChange(of: store.isScrolling) { value in
                isScrolling = value
            }
            .onDisappear {
                store.cancellable = nil
            }
    }
}

final class ExclusionStore: ObservableObject {
    @Published var isScrolling = false

    private let idlePublisher = Timer.publish(every: 0.01, on: .main, in: .default).autoconnect()
    private let scrollingPublisher = Timer.publish(every: 0.01, on: .main, in: .tracking).autoconnect()

    private var publisher: some Publisher {
        scrollingPublisher
            .map { _ in 1 }
            .merge(with:
                idlePublisher
                    .map { _ in 0 }
            )
    }

    var cancellable: AnyCancellable?

    init() {
        cancellable = publisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { output in
                guard let value = output as? Int else { return }
                if value == 1,!self.isScrolling {
                    self.isScrolling = true
                }
                if value == 0, self.isScrolling {
                    self.isScrolling = false
                }
            })
    }
}
#endif

struct ScrollStatusMonitorCommonModifier: ViewModifier {
    @StateObject private var store = CommonStore()
    @Binding var isScrolling: Bool
    func body(content: Content) -> some View {
        content
            .environment(\.isScrolling, store.isScrolling)
            .onChange(of: store.isScrolling) { value in
                isScrolling = value
            }
            .onPreferenceChange(MinValueKey.self) { _ in
                store.preferencePublisher.send(1)
            }
            .onDisappear {
                store.cancellable = nil
            }
    }
}

final class CommonStore: ObservableObject {
    @Published var isScrolling = false
    private var timestamp = Date()

    let preferencePublisher = PassthroughSubject<Int, Never>()
    let timeoutPublisher = PassthroughSubject<Int, Never>()

    private var publisher: some Publisher {
        preferencePublisher
            .dropFirst(2)
            .handleEvents(
                receiveOutput: { _ in
                    // Ensure that when multiple scrolling components are scrolling at the same time,
                    // the stop state of each can still be obtained individually
                    self.timestamp = Date()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        if Date().timeIntervalSince(self.timestamp) > 0.1 {
                            self.timeoutPublisher.send(0)
                        }
                    }
                }
            )
            .merge(with: timeoutPublisher)
    }

    var cancellable: AnyCancellable?

    init() {
        cancellable = publisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { output in
                guard let value = output as? Int else { return }
                if value == 1,!self.isScrolling {
                    self.isScrolling = true
                }
                if value == 0, self.isScrolling {
                    self.isScrolling = false
                }
            })
    }
}

/// Monitoring mode for scroll status
public enum ScrollStatusMonitorMode {
    #if !os(macOS) && !targetEnvironment(macCatalyst)
    /// The judgment of the start and end of scrolling is more accurate and timely. ( iOS only )
    ///
    /// But only for scenarios where there is only one scrollable component in the screen
    case exclusion
    #endif
    /// This mode should be used when there are multiple scrollable parts in the scene.
    ///
    /// * The accuracy and timeliness are slightly inferior to the exclusion mode.
    /// * When using this mode, a **scroll sensor** must be added to the subview of the scroll widget.
    case common
}

//
//  Key.swift
//
//
//  Created by Yang Xu on 2022/9/7.
//

import Foundation
import SwiftUI

struct IsScrollingValueKey: EnvironmentKey {
    static var defaultValue = false
}

public extension EnvironmentValues {
    var isScrolling: Bool {
        get { self[IsScrollingValueKey.self] }
        set { self[IsScrollingValueKey.self] = newValue }
    }
}

public struct MinValueKey: PreferenceKey {
    public static var defaultValue: CGRect = .zero
    public static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}


import SwiftUI
//https://gist.github.com/jfuellert/67e91df63394d7c9b713419ed8e2beb7
struct ScrollableView<Content: View>: UIViewControllerRepresentable, Equatable {

    // MARK: - Coordinator
    final class Coordinator: NSObject, UIScrollViewDelegate {
        
        // MARK: - Properties
        private let scrollView: UIScrollView
        var offset: Binding<CGPoint>

        // MARK: - Init
        init(_ scrollView: UIScrollView, offset: Binding<CGPoint>) {
            self.scrollView          = scrollView
            self.offset              = offset
            super.init()
            self.scrollView.delegate = self
        }
        
        // MARK: - UIScrollViewDelegate
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            DispatchQueue.main.async {
                self.offset.wrappedValue = scrollView.contentOffset
            }
        }
    }
    
    // MARK: - Type
    typealias UIViewControllerType = UIScrollViewController<Content>
    
    // MARK: - Properties
    var offset: Binding<CGPoint>
    var animationDuration: TimeInterval
    var showsScrollIndicator: Bool
    var axis: Axis
    var content: () -> Content
    var onScale: ((CGFloat)->Void)?
    var disableScroll: Bool
    var forceRefresh: Bool
    var stopScrolling: Binding<Bool>
    private let scrollViewController: UIViewControllerType

    // MARK: - Init
    init(_ offset: Binding<CGPoint>, animationDuration: TimeInterval, showsScrollIndicator: Bool = true, axis: Axis = .vertical, onScale: ((CGFloat)->Void)? = nil, disableScroll: Bool = false, forceRefresh: Bool = false, stopScrolling: Binding<Bool> = .constant(false),  @ViewBuilder content: @escaping () -> Content) {
        self.offset               = offset
        self.onScale              = onScale
        self.animationDuration    = animationDuration
        self.content              = content
        self.showsScrollIndicator = showsScrollIndicator
        self.axis                 = axis
        self.disableScroll        = disableScroll
        self.forceRefresh         = forceRefresh
        self.stopScrolling        = stopScrolling
        self.scrollViewController = UIScrollViewController(rootView: self.content(), offset: self.offset, axis: self.axis, onScale: self.onScale)
    }
    
    // MARK: - Updates
    func makeUIViewController(context: UIViewControllerRepresentableContext<Self>) -> UIViewControllerType {
        self.scrollViewController
    }

    func updateUIViewController(_ viewController: UIViewControllerType, context: UIViewControllerRepresentableContext<Self>) {
        
        viewController.scrollView.showsVerticalScrollIndicator   = self.showsScrollIndicator
        viewController.scrollView.showsHorizontalScrollIndicator = self.showsScrollIndicator
        viewController.updateContent(self.content)

        let duration: TimeInterval                = self.duration(viewController)
        let newValue: CGPoint                     = self.offset.wrappedValue
        viewController.scrollView.isScrollEnabled = !self.disableScroll
        
        if self.stopScrolling.wrappedValue {
            viewController.scrollView.setContentOffset(viewController.scrollView.contentOffset, animated:false)
            return
        }
        
        guard duration != .zero else {
            viewController.scrollView.contentOffset = newValue
            return
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: [.allowUserInteraction, .curveEaseInOut, .beginFromCurrentState], animations: {
            viewController.scrollView.contentOffset = newValue
        }, completion: nil)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self.scrollViewController.scrollView, offset: self.offset)
    }
    
    //Calcaulte max offset
    private func newContentOffset(_ viewController: UIViewControllerType, newValue: CGPoint) -> CGPoint {
        
        let maxOffsetViewFrame: CGRect = viewController.view.frame
        let maxOffsetFrame: CGRect     = viewController.hostingController.view.frame
        let maxOffsetX: CGFloat        = maxOffsetFrame.maxX - maxOffsetViewFrame.maxX
        let maxOffsetY: CGFloat        = maxOffsetFrame.maxY - maxOffsetViewFrame.maxY
        
        return CGPoint(x: min(newValue.x, maxOffsetX), y: min(newValue.y, maxOffsetY))
    }
    
    //Calculate animation speed
    private func duration(_ viewController: UIViewControllerType) -> TimeInterval {
        
        var diff: CGFloat = 0
        
        switch axis {
            case .horizontal:
                diff = abs(viewController.scrollView.contentOffset.x - self.offset.wrappedValue.x)
            default:
                diff = abs(viewController.scrollView.contentOffset.y - self.offset.wrappedValue.y)
        }
        
        if diff == 0 {
            return .zero
        }
        
        let percentageMoved = diff / UIScreen.main.bounds.height
        
        return self.animationDuration * min(max(TimeInterval(percentageMoved), 0.25), 1)
    }
    
    // MARK: - Equatable
    static func == (lhs: ScrollableView, rhs: ScrollableView) -> Bool {
        return !lhs.forceRefresh && lhs.forceRefresh == rhs.forceRefresh
    }
}

final class UIScrollViewController<Content: View> : UIViewController, ObservableObject {

    // MARK: - Properties
    var offset: Binding<CGPoint>
    var onScale: ((CGFloat)->Void)?
    let hostingController: UIHostingController<Content>
    private let axis: Axis
    lazy var scrollView: UIScrollView = {
        
        let scrollView                                       = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.canCancelContentTouches                   = true
        scrollView.delaysContentTouches                      = true
        scrollView.scrollsToTop                              = false
        scrollView.backgroundColor                           = .clear
        
        if self.onScale != nil {
            scrollView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(self.onGesture)))
        }
        
        return scrollView
    }()
    
    @objc func onGesture(gesture: UIPinchGestureRecognizer) {
        self.onScale?(gesture.scale)
    }

    // MARK: - Init
    init(rootView: Content, offset: Binding<CGPoint>, axis: Axis, onScale: ((CGFloat)->Void)?) {
        self.offset                                 = offset
        self.hostingController                      = UIHostingController<Content>(rootView: rootView)
        self.hostingController.view.backgroundColor = .clear
        self.axis                                   = axis
        self.onScale                                = onScale
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: - Update
    func updateContent(_ content: () -> Content) {
        
        self.hostingController.rootView = content()
        self.scrollView.addSubview(self.hostingController.view)
        
        var contentSize: CGSize = self.hostingController.view.intrinsicContentSize
        
        switch axis {
            case .vertical:
                contentSize.width = self.scrollView.frame.width
            case .horizontal:
                contentSize.height = self.scrollView.frame.height
        }
        
        self.hostingController.view.frame.size = contentSize
        self.scrollView.contentSize            = contentSize
        self.view.updateConstraintsIfNeeded()
        self.view.layoutIfNeeded()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.scrollView)
        self.createConstraints()
        self.view.setNeedsUpdateConstraints()
        self.view.updateConstraintsIfNeeded()
        self.view.layoutIfNeeded()
    }
    
    // MARK: - Constraints
    fileprivate func createConstraints() {
        NSLayoutConstraint.activate([
            self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.scrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
}
