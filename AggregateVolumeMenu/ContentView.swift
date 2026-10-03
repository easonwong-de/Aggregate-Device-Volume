//
//  ContentView.swift
//  AggregateVolumeMenu
//
//  Created by emre argana on 30.09.2025.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var audioManager = AudioDeviceManager.shared
    @State private var hoveredDevice: AudioDevice?
    
    var volumePercentage: Int {
        Int(audioManager.currentVolume * 100)
    }
    
    func adjustVolumeByStep(_ delta: Float) {
        audioManager.adjustVolume(by: delta)
    }
    
    var volumeIcon: String {
        AudioDeviceManager.getVolumeIcon(for: audioManager.currentVolume,
                                         isMuted: audioManager.isMuted)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with Volume Control
            VStack(spacing: 14) {
                // Current Device Display
                HStack {
                    Image(systemName: audioManager.currentDevice?.iconName ?? "hifispeaker")
                        .foregroundStyle(Color.primary)
                        .font(.system(size: 14))
                        .frame(width: 20, height: 20)
                    
                    Text(audioManager.currentDevice?.name ?? "No Output Device")
                        .font(.system(size: 13, weight: .medium))
                        .lineLimit(1)
                        .frame(height: 20)
                    
                    Spacer()
                    
                    Text("\(volumePercentage)%")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .lineLimit(1)
                        .foregroundStyle(.secondary)
                        .frame(height: 20)
                        .padding(.horizontal, 6)
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)
                
                // Volume Slider Section
                HStack(spacing: 10) {
                    // Mute Button
                    Button(action: { audioManager.toggleMute() }) {
                        Image(systemName: volumeIcon)
                            .font(.system(size: 14))
                            .foregroundStyle(audioManager.isMuted ? Color.red : Color.secondary)
                            .frame(width: 20, height: 20)
                    }
                    .buttonStyle(.plain)
                    .focusable(false)
                    .focusEffectDisabled()
                    .help(audioManager.isMuted ? "Unmute" : "Mute")
                    .frame(width: 20, height: 20)
                    
                    // Native Volume Slider
                    Slider(
                        value: Binding(
                            get: { audioManager.currentVolume },
                            set: { audioManager.setCurrentVolume($0) }
                        ),
                        in: 0 ... 1
                    )
                    .tint(audioManager.isMuted ? Color.red : Color.primary)
                    .focusEffectDisabled()
                    .frame(height: 20)
                    
                    // Max Volume Icon
                    Image(systemName: "speaker.wave.3.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                        .frame(width: 20, height: 20)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 14)
            }
            
            Divider()
            
            // Devices List Section
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Label("Output Devices", systemImage: "speaker.wave.2")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text("\(audioManager.outputDevices.count)")
                        .font(.system(size: 11, weight: .medium))
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 4, style: .continuous))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                
                // Devices List
                if audioManager.outputDevices.isEmpty {
                    Text("No Output Devices Found")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, minHeight: 28)
                        .padding(.horizontal, 8)
                        .padding(.bottom, 4)
                } else {
                    VStack(spacing: 2) {
                        ForEach(audioManager.outputDevices, id: \.id) { device in
                            DeviceRow(
                                device: device,
                                isSelected: device == audioManager.currentDevice,
                                isHovered: hoveredDevice == device,
                                action: {
                                    audioManager.selectDevice(device)
                                }
                            )
                            .onHover { hovering in
                                hoveredDevice = hovering ? device : nil
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 4)
                }
            }
        }
        .frame(width: 320)
        .onAppear {
            audioManager.refreshDevices()
            audioManager.refreshCurrentDevice()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            audioManager.refreshDevices()
            audioManager.refreshCurrentDevice()
        }
        .focusable()
        .focusEffectDisabled()
        .onKeyPress { press in
            switch press.key {
            case .upArrow:
                DispatchQueue.main.async {
                    adjustVolumeByStep(0.05)
                }
                return .handled
            case .downArrow:
                DispatchQueue.main.async {
                    adjustVolumeByStep(-0.05)
                }
                return .handled
            case .space:
                DispatchQueue.main.async {
                    audioManager.toggleMute()
                }
                return .handled
            default:
                return .ignored
            }
        }
    }
}

struct DeviceRow: View {
    @Environment(\.colorScheme) private var colorScheme
    let device: AudioDevice
    let isSelected: Bool
    let isHovered: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                // Device Icon Badge
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.accentColor : Color.primary.opacity(0.08))
                    
                    Image(systemName: device.iconName)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(isSelected ? Color.white : Color.secondary)
                }
                .frame(width: 26, height: 26)
                
                // Device Name
                Text(device.name)
                    .font(.system(size: 13, weight: isSelected ? .medium : .regular))
                    .foregroundStyle(isSelected || isHovered ? Color.primary : Color.primary.opacity(0.85))
                    .lineLimit(1)
                    .frame(height: 26)
                
                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(isHovered ? (colorScheme == .dark ? Color.white.opacity(0.12) : Color.black.opacity(0.08)) : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .focusable(false)
        .focusEffectDisabled()
    }
}

#Preview {
    ContentView()
}
