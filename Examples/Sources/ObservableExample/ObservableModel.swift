import Foundation
import Perception // Also works with `Observation`

private var animalList = [
    "Dog",
    "Cat",
    "Horse",
    "Elephant",
    "Giraffe",
    "Zebra",
    "Mouse",
    "Bird",
    "Fish",
    "Lizard",
    "Turtle",
    "Octopus",
    "Snake",
    "Crab",
    "Ant",
    "Bee",
    "Butterfly",
    "Bat",
    "Bat-eared fox",
    "Owl",
]

@Perceptible // Also works with `@Observable`
class ObservableModel {
    var automaticModeIsOn = false
    var windowTitle: String = "Window Title"
    var windowText: String = "Window Text"
    var view1Text: String = "View 1 Text"
    var view2Text: String = "View 2 Text"
    
    func startAutomaticMode() {
        guard !automaticModeIsOn else { return }
        automaticModeIsOn = true
        Task {
            while true {
                // Wait one second before changing the next text
                try await Task.sleep(nanoseconds: 1_000_000_000)
                
                let animal = animalList.randomElement()!
                let textIndex = Int.random(in: 0..<4)
                switch textIndex {
                case 0:
                    windowTitle = animal
                case 1:
                    windowText = animal
                case 2:
                    view1Text = animal
                default:
                    view2Text = animal
                }
            }
        }
    }
}
