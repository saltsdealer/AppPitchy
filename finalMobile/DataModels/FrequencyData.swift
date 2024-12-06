//
//  FrequencyData.swift
//  pitchy
//
//  Created by firesalts on 7/29/24.
//  bean

import Foundation
import Combine

class FrequencyData: ObservableObject {
    @Published var frequencies: [Float] = []
}
