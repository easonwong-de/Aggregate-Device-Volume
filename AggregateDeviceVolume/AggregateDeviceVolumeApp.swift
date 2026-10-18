//
//  AggregateDeviceVolumeApp.swift
//  AggregateDeviceVolume
//
//  Created by emre argana on 30.09.2025.
//

import ServiceManagement
import SwiftUI

@main
struct AggregateDeviceVolumeApp: App {
	@NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

	var body: some Scene {
		Settings {
			EmptyView()
		}
	}
}

class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
	private var statusItem: NSStatusItem?
	private var mainMenu: NSMenu?
	private var contextMenu: NSMenu?
	private var launchOnLoginMenuItem: NSMenuItem?
	private var hostingView: NSHostingView<ContentView>?
	private var audioManager = AudioDeviceManager.shared

	func applicationDidFinishLaunching(_ notification: Notification) {
		setupStatusItem()
		setupMediaKeyHandling()
		observeVolumeChangeNotifications()
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	private func setupStatusItem() {
		statusItem = NSStatusBar.system.statusItem(withLength: 30)
		if let button = statusItem?.button {
			button.target = self
			button.action = #selector(handleStatusItemClick(_:))
			button.sendAction(on: [.leftMouseUp, .rightMouseUp])
		}
		updateMenuBarIcon()
		setupMenus()
	}

	private func setupMenus() {
		setupMainMenu()
		setupContextMenu()
	}

	private func setupMainMenu() {
		let menu = NSMenu()
		menu.delegate = self

		let hosting = NSHostingView(rootView: ContentView())
		let item = NSMenuItem()
		item.view = hosting
		menu.addItem(item)

		self.mainMenu = menu
		hostingView = hosting
	}

	private func setupContextMenu() {
		let menu = NSMenu()
		menu.delegate = self

		let launchItem = NSMenuItem(
			title: "Turn on Launch on Login",
			action: #selector(toggleLaunchOnLogin),
			keyEquivalent: ""
		)
		launchItem.target = self
		menu.addItem(launchItem)
		self.launchOnLoginMenuItem = launchItem

		let quitItem = NSMenuItem(
			title: "Quit",
			action: #selector(quitApp),
			keyEquivalent: "q"
		)
		quitItem.target = self
		menu.addItem(quitItem)

		self.contextMenu = menu
		updateContextMenu()
	}

	@objc private func handleStatusItemClick(_ sender: NSStatusBarButton) {
		guard let event = NSApp.currentEvent else { return }

		let isRightClick = event.type == .rightMouseUp || event.modifierFlags.contains(.control)
		let targetMenu = isRightClick ? contextMenu : mainMenu

		statusItem?.menu = targetMenu
		statusItem?.button?.performClick(nil)
	}

	func menuWillOpen(_ menu: NSMenu) {
		if menu == mainMenu {
			audioManager.refreshDevices()
			audioManager.refreshCurrentDevice()
			updateMenuBarIcon()

			if let hostingView = hostingView {
				hostingView.layoutSubtreeIfNeeded()
				let fittingSize = hostingView.fittingSize
				hostingView.frame = NSRect(x: 0, y: 0, width: 320, height: ceil(fittingSize.height))
			}
		} else if menu == contextMenu {
			updateContextMenu()
		}
	}

	func menuDidClose(_ menu: NSMenu) {
		statusItem?.menu = nil
	}

	private func updateContextMenu() {
		let isEnabled = SMAppService.mainApp.status == .enabled
		launchOnLoginMenuItem?.title = isEnabled ? "Turn off Launch on Login" : "Turn on Launch on Login"
	}

	@objc private func toggleLaunchOnLogin() {
		do {
			if SMAppService.mainApp.status == .enabled {
				try SMAppService.mainApp.unregister()
			} else {
				try SMAppService.mainApp.register()
			}
		} catch {
			NSLog("Failed to toggle launch on login: %@", error.localizedDescription)
		}
		updateContextMenu()
	}

	@objc private func quitApp() {
		NSApp.terminate(nil)
	}

	private func observeVolumeChangeNotifications() {
		NotificationCenter.default.addObserver(
			self, selector: #selector(volumeDidChange), name: NSNotification.Name("volumeDidChange"), object: nil)
	}

	@objc private func volumeDidChange(_ notification: Notification) {
		updateMenuBarIcon()
	}

	private func updateMenuBarIcon() {
		guard let button = statusItem?.button else { return }

		let volume = audioManager.currentVolume
		let isMuted = audioManager.isMuted
		let volumePercentage = Int(volume * 100)

		let iconName = AudioDeviceManager.getVolumeIcon(for: volume, isMuted: isMuted)

		let image = NSImage(systemSymbolName: iconName, accessibilityDescription: "Volume: \(volumePercentage)%")
		image?.isTemplate = true

		button.image = image
		button.imagePosition = .imageOnly

		updateTooltip(button: button, volume: volumePercentage, isMuted: isMuted)
	}

	private func updateTooltip(button: NSButton, volume: Int, isMuted: Bool) {
		var tooltipComponents: [String] = []

		if isMuted {
			tooltipComponents.append("Muted")
		} else {
			tooltipComponents.append("Volume: \(volume)%")
		}

		if let device = audioManager.currentDevice {
			tooltipComponents.append("Device: \(device.name)")
		}

		tooltipComponents.append("Click to open • Space to mute")
		button.toolTip = tooltipComponents.joined(separator: "\n")
	}

	private func setupMediaKeyHandling() {
		NSEvent.addGlobalMonitorForEvents(matching: .systemDefined) { event in
			self.handleMediaKey(event: event)
		}

		NSEvent.addLocalMonitorForEvents(matching: .systemDefined) { event in
			self.handleMediaKey(event: event)
			return event
		}
	}

	private func handleMediaKey(event: NSEvent) {
		guard event.subtype == .screenChanged else { return }

		let keyCode = ((event.data1 & 0xFFFF_0000) >> 16)
		let keyFlags = (event.data1 & 0x0000_FFFF)
		let keyState = ((keyFlags & 0xFF00) >> 8) == 0xA

		if keyState {
			switch Int32(keyCode) {
			case NX_KEYTYPE_SOUND_UP:
				audioManager.adjustVolume(by: 0.0625)
				updateMenuBarIcon()

			case NX_KEYTYPE_SOUND_DOWN:
				audioManager.adjustVolume(by: -0.0625)
				updateMenuBarIcon()

			case NX_KEYTYPE_MUTE:
				audioManager.toggleMute()
				updateMenuBarIcon()

			default:
				break
			}
		}
	}
}
