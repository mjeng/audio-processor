
//
//  ViewController.swift
//  Audio Processor
//
//  Created by Matthew Jeng on 7/26/18.
//  Copyright © 2018 Matthew Jeng. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    // how long each recording should be
    let recordingSeconds = 5.0
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var postButton: UIButton!
    
    // the scan button should perform recording, playback, and post
    @IBOutlet weak var scanButton: UIButton!
    
    
    var isRecording = false
    var audioRecorder: AVAudioRecorder?
    var player : AVAudioPlayer?
    var recordingExists = false
    
//    var recordingSession: AVAudioSession!
//    var audioRecorder: AVAudioRecorder!
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Asking user permission for accessing Microphone
        AVAudioSession.sharedInstance().requestRecordPermission () {
            [unowned self] allowed in
            if allowed {
                // Microphone allowed, do what you like!
                self.setUpUI()
            } else {
                // User denied microphone. Tell them off!
                
            }
        }
        print(getAudioFileUrl())
    }
    
    @IBAction func debugButtonPressed(_ sender: UIButton) {
        toggleDebug()
    }
    
    func toggleDebug() {
        for i in stride(from: 0, through: 2, by: 1) {
            UIView.animate(withDuration: 0.5, animations: {
                self.buttonStackView.arrangedSubviews[i].isHidden = !self.buttonStackView.arrangedSubviews[i].isHidden
                
            })
        }
    }


    func setUpUI() {
        print("I ain't needa do nothin")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

//    @IBAction func onRecordClick(_ sender: Any) {
//
//        guard let url = URL(string: "https://emilys-server.herokuapp.com/") else { return }
//
//        let session = URLSession.shared
//        session.dataTask(with: url) { (data, response, error) in
//            if let response = response {
//                print(response)
//            }
//
//            if let data = data {
//                do {
//                    let json = try JSONSerialization.jsonObject(with: data, options: [])
//                    print(json)
//                } catch {
//                    print(error)
//                }
//            }
//
//
//        }.resume()
//    }

    @IBAction func recordButtonWasPressed(_ sender: UIButton) {
        if isRecording {
            finishRecording()
        } else {
            startRecording()
        }
    }
    
    @IBAction func play(_ sender: UIButton) {
        playSound()
    }
    
    func playSound(){
        let url = getAudioFileUrl()
        
        do {
            // AVAudioPlayer setting up with the saved file URL
            let sound = try AVAudioPlayer(contentsOf: url)
            self.player = sound
            
            // Here conforming to AVAudioPlayerDelegate
            sound.delegate = self
            sound.prepareToPlay()
            sound.play()
            recordButton.isEnabled = false
        } catch {
            print("error loading file")
            // couldn't load file :(
        }
    }
    
    func startRecording() {
        //1. create the session
        let session = AVAudioSession.sharedInstance()
        
        do {
            // 2. configure the session for recording and playback
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
            try session.setActive(true)
            // 3. set up a high-quality recording session
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            // 4. create the audio recording, and assign ourselves as the delegate
            audioRecorder = try AVAudioRecorder(url: getAudioFileUrl(), settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            
            //5. Changing record icon to stop icon
            isRecording = true
            playButton.isEnabled = false
        }
        catch let error {
            print("ERROR in startRecording")
            print(error)
            // failed to record!
        }
    }
    
    // Stop recording
    func finishRecording() {
        audioRecorder?.stop()
        isRecording = false
        recordingExists = true
    }
    
    // Path for saving/retreiving the audio file
    func getAudioFileUrl() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docsDirect = paths[0]
        let audioUrl = docsDirect.appendingPathComponent("recording.m4a")
        return audioUrl
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            finishRecording()
        } else {
            // Recording interrupted by other reasons like call coming, reached time limit.
        }
        playButton.isEnabled = true
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            
        } else {
            // Playing interrupted by other reasons like call coming, the sound has not finished playing.
        }
        recordButton.isEnabled = true
    }

    @IBAction func postButton(_ sender: Any) {
        postToHeroku()
    }
    
    func postToHeroku() {
        if recordingExists {
            guard let url = URL(string: "https://emilys-server.herokuapp.com/process_audio") else { return }
            var request = URLRequest(url: url)
            request.setValue("audio/x-wav", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    print(error as Any)
                    return
                }
                DispatchQueue.main.async {
                    self.imageView.contentMode = .scaleAspectFit
                    self.imageView.image = UIImage(data: data)
                    self.titleLabel.text = "Scan complete"
                }
            }
            task.resume()
        }
    }
    
    
    @IBAction func scanButtonPressed(_ sender: UIButton) {
        titleLabel.text = "Scan in progress"
        startRecording()
        DispatchQueue.main.asyncAfter(deadline: .now() + recordingSeconds) {
            self.finishRecording()
            self.titleLabel.text = "Processing scan"
            self.postToHeroku()
            
        }
    }
}

