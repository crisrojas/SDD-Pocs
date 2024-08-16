//
//  PlaygroundsTests.swift
//  PlaygroundsTests
//
//  Created by Cristian Patiño Rojas on 18/11/23.
//

import XCTest
@testable import Playgrounds
import SwiftUI

final class EasyDependencyInjection: XCTestCase {
    struct TestView: View, Mappable {
        var dependency = "default dependency"
        var otherView = SomeOtherView()
        
        var body: some View {
            otherView
        }
    }
    
    struct SomeOtherView: View {
        var dependency = "some default other view dependency"
        var body: some View {
            Text("some other view")
        }
    }
    
    
    func test_easy_dependency_injection_through_variable_override() {
        
        var testView = TestView()
        testView.dependency = "injected dependency"
        
        XCTAssertEqual(testView.dependency, "injected dependency")
        
        var otherView = SomeOtherView()
        otherView.dependency = "some other view injected dependency"
        
        testView.otherView = otherView
        XCTAssertEqual(testView.otherView.dependency, "some other view injected dependency")
    }
}

