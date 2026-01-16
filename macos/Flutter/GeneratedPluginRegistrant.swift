//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import path_provider_foundation
import shared_preferences_foundation

/// Registers the generated Flutter plugins with the provided plugin registry.
/// - Parameter registry: The Flutter plugin registry used to obtain registrars for each generated plugin.
func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  PathProviderPlugin.register(with: registry.registrar(forPlugin: "PathProviderPlugin"))
  SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "SharedPreferencesPlugin"))
}