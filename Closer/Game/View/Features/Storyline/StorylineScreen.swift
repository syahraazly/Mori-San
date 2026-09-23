import SwiftUI

struct StorylineScreen: View {
    @ObservedObject var appFlow: AppFlowViewModel
    @StateObject private var viewModel: StorylineViewModel

    init(appFlow: AppFlowViewModel) {
        self.appFlow = appFlow
        _viewModel = StateObject(wrappedValue: StorylineViewModel(
            onComplete: { appFlow.openMap() }
        ))
    }

    var body: some View {
        StoryPageView(beat: viewModel.currentBeat)
            .contentShape(Rectangle())
            .onTapGesture {
                viewModel.advanceStory()
            }
            .safeAreaInset(edge: .top, alignment: .trailing, spacing: 0) {
                Button("Skip") {
                    viewModel.skipStory()
                }
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color(red: 0.38, green: 0.31, blue: 0.52))
                .padding(20)
            }
    }
}
