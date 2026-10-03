//
//  AudioDevice.swift
//  AggregateVolumeMenu
//
//  Created by Gurhan Polat on 22.12.2020.
//

import CoreAudio
import Foundation

struct AudioDevice: Equatable, Hashable {
    let id: AudioDeviceID
    let name: String
}

extension AudioDevice {
    var iconName: String {
        let lowercasedName = name.lowercased()
        if lowercasedName.contains("airpods") {
            return "airpodspro"
        } else if lowercasedName.contains("headphone") {
            return "headphones"
        } else if lowercasedName.contains("bluetooth") {
            return "wave.3.right"
        } else if lowercasedName.contains("hdmi") || lowercasedName.contains("display") {
            return "tv"
        } else if lowercasedName.contains("usb") {
            return "cable.connector"
        } else if lowercasedName.contains("aggregate") {
            return "square.stack.3d.up"
        } else if lowercasedName.contains("mac") || lowercasedName.contains("speaker") {
            return "macbook.and.visionpro"
        } else {
            return "hifispeaker"
        }
    }
}
