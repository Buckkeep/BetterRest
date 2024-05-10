//
//  ContentView.swift
//  BetterRest
//
//  Created by Buhecha, Neeta (Trainee Engineer) on 08/05/2024.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    var predictedBedtime: String {
        var bedtime = ""
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)

            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60

            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))

            let sleepTime = wakeUp - prediction.actualSleep

            bedtime = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            bedtime = "Sorry, there was a problem calculating your bedtime."
        }
        return bedtime
    }
           
    
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    static var defaultBedTime: Date {
        var components = DateComponents()
        components.hour = 22
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var body: some View {
        NavigationStack {
            Form {

                Section("When do you want to wake up?") {
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                    }
                

                Section("Desired amount of sleep") {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                    }
                
                Section("Daily Coffee Intake") {
                    Picker("^[\(coffeeAmount) cup](inflect: true)",
                           selection: $coffeeAmount,
                           content: {
                        ForEach(0..<21) {
                            Text("\($0)")
                        }
                    }
                    )
                }
                
                Section("You should go to bed at")  {
                    Text(predictedBedtime)

                
                }
                
                
            }
            .navigationTitle("BetterRest")

        }
    }

    
}

#Preview {
    ContentView()
}
