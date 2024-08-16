import XCTest
import TiempoUI

import Combine

final class TiempoUITests: XCTestCase {
    func testExample() throws {
        
        let manager = CountDownManager()
        
        manager.setDuration(20)
        manager.isRunning = true
        
        XCTAssertNotNil(manager.countdownDuration)
        let startDate = try XCTUnwrap(manager.startDate)
        let endDate = try XCTUnwrap(manager.endDate)
        
        
        // Diference between endDate & startDate
        let timeInterval = endDate.timeIntervalSince(startDate)
        let seconds = Int(timeInterval)
        XCTAssertEqual(seconds, 20)
        
        // Remaining
        XCTAssertEqual(manager.remainingSeconds(), 20)
    }
}
