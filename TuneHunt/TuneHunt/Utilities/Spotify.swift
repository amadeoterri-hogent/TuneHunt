import Foundation
import Combine
import UIKit
import SwiftUI
import KeychainAccess
import SpotifyWebAPI

/**
 This class is copied from
 © https://github.com/Peter-Schorn/SpotifyAPIExampleApp
 
 See documentation on
 https://github.com/Peter-Schorn/SpotifyAPI
*/

final class Spotify: ObservableObject {
    static let shared = Spotify()
    
    @Published var isAuthorized = false
    @Published var isRetrievingTokens = false
    @Published var currentUser: SpotifyUser? = nil
    
    private static let config = Config()
    private static let clientId: String = config.clientId
    private static let clientSecret: String = config.clientSecret
    private static let callback: String = config.callback
    private static let bundleId: String = config.bundleId
    
    let authorizationManagerKey = "authorizationManager"
    let loginCallbackURL = URL(
        string: Spotify.callback
    )!
    let keychain = Keychain(service: Spotify.bundleId)
    let api = SpotifyAPI(
        authorizationManager: AuthorizationCodeFlowManager(
            clientId: Spotify.clientId,
            clientSecret: Spotify.clientSecret
        )
    )

    var authorizationState = String.randomURLSafe(length: 128)
    var cancellables: Set<AnyCancellable> = []

    private init() {
        self.api.apiRequestLogger.logLevel = .trace
        self.api.logger.logLevel = .trace
        
        self.api.authorizationManagerDidChange
            .receive(on: RunLoop.main)
            .sink(receiveValue: authorizationManagerDidChange)
            .store(in: &cancellables)
        
        self.api.authorizationManagerDidDeauthorize
            .receive(on: RunLoop.main)
            .sink(receiveValue: authorizationManagerDidDeauthorize)
            .store(in: &cancellables)

        if let authManagerData = keychain[data: self.authorizationManagerKey] {

            do {
                let authorizationManager = try JSONDecoder().decode(
                    AuthorizationCodeFlowManager.self,
                    from: authManagerData
                )
                self.api.authorizationManager = authorizationManager
                
            } catch {
                print("could not decode authorizationManager from data:\n\(error)")
            }
        }
        else {
            print("did NOT find authorization information in keychain")
        }
        
    }
    
    func authorize() {
        
        let url = self.api.authorizationManager.makeAuthorizationURL(
            redirectURI: self.loginCallbackURL,
            showDialog: true,
            state: self.authorizationState,
            scopes: [
                .userReadPlaybackState,
                .userModifyPlaybackState,
                .playlistModifyPrivate,
                .playlistModifyPublic,
                .userLibraryRead,
                .userLibraryModify,
                .userReadRecentlyPlayed
            ]
        )!
        
        UIApplication.shared.open(url)
        
    }
    
    func authorizationManagerDidChange() {
        self.isAuthorized = self.api.authorizationManager.isAuthorized()
        self.retrieveCurrentUser()
        
        do {
            let authManagerData = try JSONEncoder().encode(
                self.api.authorizationManager
            )
            
            self.keychain[data: self.authorizationManagerKey] = authManagerData
            print("did save authorization manager to keychain")
            
        } catch {
            print(
                "couldn't encode authorizationManager for storage " +
                    "in keychain:\n\(error)"
            )
        }
        
    }
    
    func authorizationManagerDidDeauthorize() {
        self.isAuthorized = false
        self.currentUser = nil
        
        do {
            try self.keychain.remove(self.authorizationManagerKey)
            print("did remove authorization manager from keychain")
            
        } catch {
            print(
                "couldn't remove authorization manager " +
                "from keychain: \(error)"
            )
        }
    }

    func retrieveCurrentUser(onlyIfNil: Bool = true) {
        
        if onlyIfNil && self.currentUser != nil {
            return
        }

        guard self.isAuthorized else { return }

        self.api.currentUserProfile()
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("couldn't retrieve current user: \(error)")
                    }
                },
                receiveValue: { user in
                    self.currentUser = user
                }
            )
            .store(in: &cancellables)
        
    }

}

// Reads credentials from config.plist
extension Spotify {
    
    struct Config {
        let clientId: String
        let clientSecret: String
        let callback: String
        let bundleId: String
        
        init() {
            guard let path = Bundle.main.path(forResource: "config", ofType: "plist"),
                  let xml = FileManager.default.contents(atPath: path),
                  let plist = try? PropertyListSerialization.propertyList(from: xml, options: [], format: nil),
                  let dict = plist as? [String: Any] else {
                fatalError("Could not load config.plist")
            }
            
            guard let clientId = dict["client_id"] as? String,
                  let clientSecret = dict["client_secret"] as? String,
                  let callback = dict["callback"] as? String,
                  let bundleId = dict["bundle_id"] as? String
            else {
                fatalError("Config.plist is missing client_id, client_secret, callback or bundle_id")
            }
            
            self.clientId = clientId
            self.clientSecret = clientSecret
            self.callback = callback
            self.bundleId = bundleId
        }
    }
}

extension SpotifyAPI where AuthorizationManager: SpotifyScopeAuthorizationManager {
    func getAvailableDeviceThenPlay(_ playbackRequest: PlaybackRequest) -> AnyPublisher<Void, Error> {
        return self.availableDevices().flatMap {
            devices -> AnyPublisher<Void, Error> in
    
            let usableDevices = devices.filter { device in
                !device.isRestricted && device.id != nil
            }

            let device = usableDevices.first(where: \.isActive)
                    ?? usableDevices.first
            
            if let deviceId = device?.id {
                return self.play(playbackRequest, deviceId: deviceId)
            }
            else {
                return SpotifyGeneralError.other(
                    "No active or available devices",
                    localizedDescription:
                    "There are no devices available to play content on. " +
                    "Try opening the Spotify app on one of your devices."
                )
                .anyFailingPublisher()
            }
            
        }
        .eraseToAnyPublisher()
        
    }

}
