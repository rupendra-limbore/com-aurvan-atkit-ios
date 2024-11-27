//
//  ATProgressOverlayModifier.swift
//  ATKit
//
//  Created by Rupendra on 27/11/24.
//

#if canImport(SwiftUI)
import SwiftUI
#endif

@available(iOS 14.0, *)
public struct ATProgressOverlayModifier: ViewModifier {
    var isTaskInProgress: Bool
    
    public func body(content: Content) -> some View {
        content
            .overlay(
                Group {
                    if self.isTaskInProgress {
                        Color.black
                            .opacity(0.4)
                            .ignoresSafeArea()
                        
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                            .scaleEffect(2.0)
                            .background(Color.clear)
                    }
                }
            )
    }
}

@available(iOS 14.0, *)
public extension View {
    func progressOverlay(isTaskInProgress pIsTaskInProgress: Bool) -> some View {
        self.modifier(ATProgressOverlayModifier(isTaskInProgress: pIsTaskInProgress))
    }
}
