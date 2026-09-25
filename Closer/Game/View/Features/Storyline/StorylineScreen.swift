import SwiftUI

struct StorylineScreen: View {
    @ObservedObject var appFlow: AppFlowViewModel
    @StateObject private var viewModel: StorylineViewModel

    init(appFlow: AppFlowViewModel) {
        self.appFlow = appFlow
        _viewModel = StateObject(wrappedValue: StorylineViewModel(
            onComplete: { appFlow.completeStoryline() }
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
                .font(.custom("Montserrat-Medium", size: 15))
                .foregroundStyle(Color(.white))
                .padding(20)
            }
    }
}
