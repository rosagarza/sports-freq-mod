//
//  SecondViewController.swift
//  FrequencySignal
//
//  Created by Rosa Garza on 1/13/20.
//  Copyright © 2020 Rosa Garza. All rights reserved.
//

/*
 https://github.com/AudioKit/AudioKit/blob/master/Examples/iOS/MicrophoneAnalysis/MicrophoneAnalysis/ViewController.swift
 */


import UIKit
import AudioKit
import AudioKitUI

class SecondViewController: UITableViewController {
    
    // Creates a variable for main button
    @IBOutlet private var frequencyLabel: UILabel!
    @IBOutlet private var amplitudeLabel: UILabel!
    @IBOutlet private var noteNameWithSharpsLabel: UILabel!
    @IBOutlet private var noteNameWithFlatsLabel: UILabel!
    @IBOutlet private var audioInputPlot: EZAudioPlot!

    /* FOR MICROPHONE*/
    var mic: AKMicrophone!
    var tracker: AKFrequencyTracker!
    var silence: AKBooster!

     /* FOR MICROPHONE */
    let noteFrequencies = [16.35, 17.32, 18.35, 19.45, 20.6, 21.83, 23.12, 24.5, 25.96, 27.5, 29.14, 30.87]
    let noteNamesWithSharps = ["C", "C♯", "D", "D♯", "E", "F", "F♯", "G", "G♯", "A", "A♯", "B"]
    let noteNamesWithFlats = ["C", "D♭", "D", "E♭", "E", "F", "G♭", "G", "A♭", "A", "B♭", "B"]

    override func viewDidLoad() {
        super.viewDidLoad()
        /* FOR MICROPHONE */
//        AKSettings.audioInputEnabled = true
//        AKLog("Settings.....")
//
//        let recordingFormat = AudioKit.engine.inputNode.inputFormat(forBus: 0);
//        AKSettings.sampleRate = recordingFormat.sampleRate
//        AKSettings.sampleRate = AudioKit.engine.inputNode.inputFormat(forBus: 0).sampleRate
//        let mic = AKMicrophone();
//        AKLog("Mic")
//
//        tracker = AKFrequencyTracker(mic)
//        AKLog("Tracker")
//
//        silence = AKBooster(tracker, gain: 0)
//        AKLog("Silence")
    }
    
//    @IBAction func useMicrophone(_ sender: Any) {
//
//    }

    /* FOR MICROPHONE */
    func setupPlot() {
        let plot = AKNodeOutputPlot(mic, frame: audioInputPlot.bounds)
        plot.translatesAutoresizingMaskIntoConstraints = false
        plot.plotType = .rolling
        plot.shouldFill = true
        plot.shouldMirror = true
        plot.color = UIColor.blue
        audioInputPlot.addSubview(plot)

        // Pin the AKNodeOutputPlot to the audioInputPlot
        var constraints = [plot.leadingAnchor.constraint(equalTo: audioInputPlot.leadingAnchor)]
        constraints.append(plot.trailingAnchor.constraint(equalTo: audioInputPlot.trailingAnchor))
        constraints.append(plot.topAnchor.constraint(equalTo: audioInputPlot.topAnchor))
        constraints.append(plot.bottomAnchor.constraint(equalTo: audioInputPlot.bottomAnchor))
        constraints.forEach { $0.isActive = true }
    }


//    /* FOR MICROPHONE */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _ = AudioKit.engine.inputNode;
        if let audioUnit = AudioKit.engine.inputNode.audioUnit {
        AudioOutputUnitStop(audioUnit);
        AudioUnitUninitialize(audioUnit);
        }
        AKSettings.audioInputEnabled = true
        AKLog("Settings.....")
                
        //        let recordingFormat = AudioKit.engine.inputNode.inputFormat(forBus: 0);
        //        AKSettings.sampleRate = recordingFormat.sampleRate
        AKSettings.sampleRate = AudioKit.engine.inputNode.inputFormat(forBus: 0).sampleRate
        let mic = AKMicrophone()
        AKLog("Mic")
                
        tracker = AKFrequencyTracker(mic)
        AKLog("Tracker")
                
        silence = AKBooster(tracker, gain: 0)
        AKLog("Silence")
        
        AudioKit.output = silence
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start!")
        }
        setupPlot()
        Timer.scheduledTimer(timeInterval: 0.1,
                             target: self,
                             selector: #selector(SecondViewController.updateUI),
                             userInfo: nil,
                             repeats: true)
    }


    @objc func updateUI() {
        if tracker.amplitude > 0.1 {
            frequencyLabel.text = String(format: "%0.1f", tracker.frequency)

            var frequency = Float(tracker.frequency)
            while frequency > Float(noteFrequencies[noteFrequencies.count - 1]) {
                frequency /= 2.0
            }
            while frequency < Float(noteFrequencies[0]) {
                frequency *= 2.0
            }

            var minDistance: Float = 10_000.0
            var index = 0

            for i in 0..<noteFrequencies.count {
                let distance = fabsf(Float(noteFrequencies[i]) - frequency)
                if distance < minDistance {
                    index = i
                    minDistance = distance
                }
            }
            let octave = Int(log2f(Float(tracker.frequency) / frequency))
            noteNameWithSharpsLabel.text = "\(noteNamesWithSharps[index])\(octave)"
            noteNameWithFlatsLabel.text = "\(noteNamesWithFlats[index])\(octave)"
        }
        amplitudeLabel.text = String(format: "%0.2f", tracker.amplitude)
    }


//    // MARK: - Actions
//    //    /* FOR MICROPHONE */

        @IBAction func didTapInputDevicesButton(_ sender: UIBarButtonItem) {
            let inputDevices = InputDeviceTableViewController()
            inputDevices.settingsDelegate = self as! InputDeviceDelegate
            let navigationController = UINavigationController(rootViewController: inputDevices)
            navigationController.preferredContentSize = CGSize(width: 300, height: 300)
            navigationController.modalPresentationStyle = .popover
            navigationController.popoverPresentationController!.delegate = self as! UIPopoverPresentationControllerDelegate
            self.present(navigationController, animated: true, completion: nil)
        }
}

//
//// MARK: - UIPopoverPresentationControllerDelegate
extension ViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        popoverPresentationController.permittedArrowDirections = .up
        popoverPresentationController.barButtonItem = navigationItem.rightBarButtonItem
    }
}

// MARK: - InputDeviceDelegate

//extension ViewController: InputDeviceDelegate {
//    func didSelectInputDevice(_ device: AKDevice) {
//
//        //        if let firstQuestion = allQuestions.list.randomElement() {
//        //            questionLabel.text = firstQuestion.questionText
//        //        }
//
//        do {
//            try mic.setDevice(device)
//        } catch {
//            AKLog("Error setting input device")
//        }
//    }
//
//}
