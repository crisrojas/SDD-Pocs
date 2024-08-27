import XCTest
@testable import IngredientsQueue

final class DataControllerTests: XCTestCase {
    
    var sut: Items.DataController!
    
    override func setUp() async throws {
        URLProtocol.AlwaysSuccess.startInterceptingRequests()
        await MainActor.run {
            sut = Items.DataController()
        }
    }
    
    override func tearDown() {
        URLProtocol.AlwaysSuccess.stopInterceptingRequests()
        sut = nil
    }
    
    @MainActor
    func test_EnqueueItem() async {
        // ** Given: Existent item
        let item = makeItem("Oranges")
        sut.data = [item]
        
        // ** When: Giving a value to the enqueuedIsChecked
        sut.enqueue(item.id)
        
        // ** Then: Item should be enqueued
        XCTAssertEqual(sut.enqueuedItems[0].id, item.id)
    }
    
    @MainActor
    func test_TogglingItem_QueuesItem_UpdatesIsChecked_DequeuesItem() async {
        // ** Given existent unchecked item
        let item = makeItem("Chicken")
        sut.data = [item]
        
        // ** When toggling item
        sut.toggle(item.id)
        
        // ** Then:
        // 1. Item should be queued
        XCTAssertEqual(sut.enqueuedItems[0].id, item.id)
        // 2. Task should be initiated
        XCTAssertNotNil(sut.debounceTask)
        await sut.debounceTask!.value
        // 3. DomainObject isChecked should be updated
        XCTAssert(sut.data[0].domainObject.isChecked)
        // 4. Item should be dequeued
        XCTAssertEqual(sut.enqueuedItems.count, 0)
    }
    
    @MainActor
    func test_TogglingItemTwiceRapidly_DequeusItemWithoutCall() async throws {
        // ** Given: Existing item
        let item = makeItem("Tomato")
        sut.data = [item]
        
        // ** When: User toggles twice rapidly
        sut.toggle(item.id)
        sut.toggle(item.id)
        
        // ** And: Debounce time has ellapsed
        try await Task.sleep(seconds: Items.DataController.debounceTime)
        
        // ** Then:
        // 1. Item should be dequeued
        XCTAssertEqual(sut.enqueuedItems.count, 0)
        // 2. Item domain object hasn't change
        XCTAssertEqual(sut.data[0].domainObject, item.domainObject)
        // 3. Network shouldn't had been reached
        XCTAssertEqual(URLProtocol.AlwaysSuccess.requests.count, 0)
    }
    
    @MainActor
    func test_TogglingSameItemThriceRapidly_DoesNotDuplicateItemInQueue() async {
        // ** Given: Existing unchecked item
        let item = makeItem("Carrot")
        sut.data = [item]
        
        // ** When: Toggling the same item thrice
        sut.toggle(item.id)
        sut.toggle(item.id)
        sut.toggle(item.id)
        
        // ** Then: The item should be enqueued only once
        XCTAssertEqual(sut.enqueuedItems.count, 1)
    }
    
    @MainActor
    func test_TogglingMultipleElements_ProcessesAllCorrectly() async {
        // ** Given: Existen items:
        let item1 = makeItem("Chicken")
        let item2 = makeItem("Tomato")
        let item3 = makeItem("Potatos", isChecked: true)
        let items = [item1, item2, item3]
        sut.data = items
        // ** When: Toggling items
        sut.toggle(item1.id)
        sut.toggle(item2.id)
        sut.toggle(item3.id)
        
        // ** And: Task has been completed
        await sut.debounceTask?.value
        
        // ** Then: Items should have been processed:
        for (processed, unprocessed) in zip(sut.data, items) {
            XCTAssertEqual(processed.domainObject.isChecked, !unprocessed.domainObject.isChecked)
            XCTAssertNil(processed.enqueuedIsChecked)
        }
    }
   
    // @todo:
    func test_NetworkError_DoesNotUpdateItem() async throws {}
    
    func makeItem(_ name: String, isChecked: Bool = false) -> Items.Model {
        let DO = Item(id: UUID(), name: name, isChecked: isChecked)
        return Items.Model(domainObject: DO)
    }
}

