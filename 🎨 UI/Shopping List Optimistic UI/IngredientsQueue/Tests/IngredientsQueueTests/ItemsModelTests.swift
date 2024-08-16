import XCTest
@testable import IngredientsQueue

// MARK: Tests
final class ItemsModelTests: XCTestCase {
    
    func test_model_mapping() {
        let DO = Item(id: UUID(), name: "Chicken", isChecked: false)
        let item = Items.Model(domainObject: DO)
        
        XCTAssertEqual(item.isChecked, false)
    }
    
    // Optimistic UI
    func test_targetedIsChecked_updates_isCheckedComputation() {
        let DO = Item(id: UUID(), name: "Chicken", isChecked: false)
        var item = Items.Model(domainObject: DO)
        item.enqueuedIsChecked = true
        
        XCTAssertEqual(item.isChecked, true)
        
        item.enqueuedIsChecked = nil
        
        XCTAssertEqual(item.isChecked, false)
    }
}
