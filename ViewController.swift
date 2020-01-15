//
//  ViewController.swift
//  FrequencySignal
//
//  Created by Rosa Garza on 12/20/19.
//  Copyright © 2019 Rosa Garza. All rights reserved.
//

// GITHUB SOURCE:
/* https://github.com/AudioKit/AudioKit/blob/master/Examples/iOS/HelloWorld/HelloWorld/ViewController.swift
 */


import UIKit
import AudioKit
import AudioKitUI


class ViewController: UIViewController {

    //MARK: Properties
    
    // Creates a variable for main button
    @IBOutlet weak var MainButton: UIButton!
    @IBOutlet weak var microButton: UIButton!
    @IBOutlet private var frequencyLabel: UILabel!
    @IBOutlet private var amplitudeLabel: UILabel!
    
    var oscillator  = AKOscillator()
    
    // Function to make sure stuff is loaded in app
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        MainButton.setTitle("Button for Sound", for: .normal)
        microButton.setTitle("Use Microphone", for: .normal)
        // When button is pushed, the AudioKit instance is started
        AudioKit.output = AKMixer(oscillator)
        do {
            try AudioKit.start()
            print("Audio Engine started")
        } catch {
            print("Error starting Audio Engine")
        }
        
    }
    
    @IBAction func micButtonAction(_ sender: Any) {
        performSegue(withIdentifier: "segway", sender: nil)
    }
    
    // Action for button to be pressed
    @IBAction func ButtonPress(sender: Any) {
    
        // When button is pressed, a random amplitude, frequency create a sound for sine wave
        if oscillator.isPlaying {
            oscillator.stop()
            (sender as AnyObject).setTitle("Play Sine Wave", for: .normal)
        } else {
            oscillator.amplitude = random(0.5,1)
            oscillator.frequency = random(220, 880)
            oscillator.start()
            (sender as AnyObject).setTitle("Stop Sine Wave at \(Int(oscillator.frequency))Hz", for: .normal)
        }
    }

}

