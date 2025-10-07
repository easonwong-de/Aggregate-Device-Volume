
//
//  MediaManager.swift
//  AggregateVolumeMenu
//
//  Created by Gurhan Polat on 22.12.2020.
//

import Foundation
import MediaRemoteAdapter
import AppKit

class MediaManager: ObservableObject {
    static let shared = MediaManager()
    
    private let mediaController = MediaController()
    
    @Published var trackTitle: String?
    @Published var trackArtist: String?
    @Published var trackArtwork: NSImage?
    @Published var isPlaying: Bool = false
    
    private init() {
        mediaController.onTrackInfoReceived = { [weak self] trackInfo in
            DispatchQueue.main.async {
                self?.trackTitle = trackInfo.payload.title
                self?.trackArtist = trackInfo.payload.artist
                self?.trackArtwork = trackInfo.payload.artwork
                self?.isPlaying = trackInfo.payload.isPlaying == true
            }
        }
        
        mediaController.onListenerTerminated = {
            print("MediaRemoteAdapter listener process was terminated.")
        }
        
        mediaController.startListening()
    }
    
    func play() {
        mediaController.play()
    }
    
    func pause() {
        mediaController.pause()
    }
    
    func togglePlayPause() {
        mediaController.togglePlayPause()
    }
    
    func nextTrack() {
        mediaController.nextTrack()
    }
    
    func previousTrack() {
        mediaController.previousTrack()
    }
}
