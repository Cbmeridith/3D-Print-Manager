//
//  Job.swift
//  PrintManager
//
//  Created by Cody Meridith on 11/5/18.
//  Copyright © 2018 Cody Meridith. All rights reserved.
//

import Foundation


struct FileDetail : Codable {
    let name: String?
    let origin: String?
    let size: Int?
    let date: Int?
    let path: String?
    let display: String?
    
    init() {
        name = ""
        origin = ""
        size = -1
        date = -1
        path = ""
        display = ""
    }
}


struct FilamentDetail : Codable {
    let length: Int?
    let volume: Double?
    
    init() {
        length = -1
        volume = -1.0
    }
}


struct JobDetail : Codable {
    let averagePrintTime: Double?
    let estimatedPrintTime: Double?
    let filament: FilamentDetail?
    let file: FileDetail?
    let lastPrintTime: Double?
    
    init() {
        file = FileDetail()
        estimatedPrintTime = -1
        filament = FilamentDetail()
        lastPrintTime = -1
        averagePrintTime = -1
    }
}


struct ProgressDetail : Codable {
    let completion: Double?
    let filepos: Int?
    let printTime: Int?
    let printTimeLeft: Int?
    let printTimeLeftOrigin: String?
    
    init() {
        completion = -1.0
        filepos = -1
        printTime = -1
        printTimeLeft = -1
        printTimeLeftOrigin = ""
    }
}


struct Job : Codable {
    let job: JobDetail?
    let progress: ProgressDetail?
    let state: String?
    
    init() {
        job = JobDetail()
        progress = ProgressDetail()
        state = ""
    }
}
