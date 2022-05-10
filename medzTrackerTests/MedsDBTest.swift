//
//  MedsDBTest.swift
//  medzTrackerTests
//
//  Created by Alex Kaish on 3/4/22.
//

import XCTest
@testable import medzTracker
import CloudKit

class MedsDBTest: XCTestCase {
    var db : Model = Model()
    var medID : UUID = UUID() //to be overwritten
//    func testAddMed() throws {
//        var db = MedsDB()
//        XCTAssert(db.medications.contains(where: {$0 == med}))
//    }
    
    func testLatestDosage() throws {
        let time2 = Date() - 200
        //sleep(2)
        let med : Medication =  db.getMedicationByUUID(medID)!
        med.logDosage(time: time2, amount: 10)
        XCTAssert(med.getLatestDosage()!.time == time2)
        print(med.getLatestDosage()!.timeSinceDosageString)
        //print(med.getLatestDosage()?.timeString)
        
    }
    
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        db = Model()
        medID = db.addMedication(medName: "Adderall IR", dosage: 10, dosageUnit: Medication.DosageUnit.mg, schedule: Medication.Schedule.intervalSchedule(interval: TimeInterval(60 * 60 * 4)), maxDosage: 60, reminders: true)
//        med.logDosage(time: Date.now, amount: 10)

    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
