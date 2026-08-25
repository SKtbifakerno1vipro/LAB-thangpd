//
//  SettingsView.swift
//  PancakeStore
//
//  Created by lunginspector on 1/11/26.
//

import SwiftUI
import PartyUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    
    @AppStorage("autoCleanApp") var autoCleanApp: Bool = true
    @AppStorage("selectedAnisettePreset") var selectedAnisettePreset: String = "auto"
    @AppStorage("customAnisetteURL") var customAnisetteURL: String = ""
    
    @State private var pingStatus: String = ""
    @State private var isTestingPing: Bool = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        AppInfoCell(build: appBuild)
                        HStack {
                            Button {
                                openURL(URL(string: "https://jailbreak.party/discord")!)
                            } label: {
                                ButtonLabel(text: String(localized: "action.discord"), icon: "discord", useImage: true)
                            }
                            .buttonStyle(TranslucentButtonStyle(color: .discord))

                            Button {
                                openURL(URL(string: "https://github.com/jailbreakdotparty/PancakeStore")!)
                            } label: {
                                ButtonLabel(text: String(localized: "action.github"), icon: "github", useImage: true)
                            }
                            .buttonStyle(TranslucentButtonStyle(color: .github))
                        }

                        Button {
                            openURL(URL(string: "https://jailbreak.party/")!)
                        } label: {
                            ButtonLabel(text: String(localized: "action.website"), icon: "globe")
                        }
                        .buttonStyle(TranslucentButtonStyle())
                    }
                } header: {
                    HeaderLabel(text: String(localized: "section.about.title"), icon: "info.circle")
                }

                Section {
                    Picker("Máy chủ Anisette", selection: $selectedAnisettePreset) {
                        Text("Tự động (Auto Fallback)").tag("auto")
                        Text("APSTeam Server").tag("https://anisette.apsteam.top/v3/provisioningData")
                        Text("SideStore Official").tag("https://ani.sidestore.io/v3/provisioningData")
                        Text("Side.Store Server").tag("https://anisette.side.store/v3/provisioningData")
                        Text("PureSign Server").tag("https://anisette.puresign.net/v3/provisioningData")
                        Text("Tùy chỉnh (Custom URL)").tag("custom")
                    }
                    
                    if selectedAnisettePreset == "custom" {
                        TextField("https://your-anisette.example.com", text: $customAnisetteURL)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .keyboardType(.URL)
                    }
                    
                    HStack {
                        Button {
                            testAnisetteConnection()
                        } label: {
                            if isTestingPing {
                                HStack {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text("Đang kiểm tra...")
                                }
                            } else {
                                Label("Kiểm tra kết nối", systemImage: "network")
                            }
                        }
                        .disabled(isTestingPing)
                        
                        Spacer()
                        
                        if !pingStatus.isEmpty {
                            Text(pingStatus)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    HeaderLabel(text: "Cấu hình Anisette V3", icon: "server.rack")
                } footer: {
                    Text("Anisette cung cấp dữ liệu xác thực SEP/iCloud độc lập cho máy chủ Apple.")
                }

                Section {
                    Toggle(isOn: $autoCleanApp) {
                        Text("settings.autoClean.title")
                        Text("settings.autoClean.subtitle")
                    }

                    Button("action.cleanDocuments") {
                        cleanUp()
                    }
                    
                    Button(role: .destructive) {
                        HistoryManager.shared.clearAll()
                    } label: {
                        Text("Xóa lịch sử hạ cấp")
                    }
                } header: {
                    HeaderLabel(text: String(localized: "section.data.title"), icon: "loupe")
                }

                Section {
                    LinkCreditCell(image: Image("mineek"), name: "mineek", description: String(localized: "credits.mineek"), url: "https://github.com/mineek")
                    LinkCreditCell(image: Image("lunginspector"), name: "lunginspector", description: String(localized: "credits.lunginspector"), url: "https://github.com/lunginspector")
                    LinkCreditCell(image: Image("skadz"), name: "Skadz", description: String(localized: "credits.skadz"), url: "https://github.com/skadz108")
                    
                    NavigationLink {
                        List {
                            TranslatorCreditCell(name: "Isacucho", languageKey: "language.spanish", url: "https://github.com/isacucho")
                            
                            TranslatorCreditCell(name: "gerda", languageKey: "language.russian", url: "https://github.com/ezn1hero")
                            
                            TranslatorCreditCell(name: "roooot", languageKey: "language.german", url: "https://github.com/rooootdev")
                            
                            TranslatorCreditCell(name: "TrollStoreX", languageKey: "language.chineseSimp", url: "https://github.com/TrollStoreX")
                            
                            TranslatorCreditCell(name: "neonmodder123", languageKey: "language.arabic", url: "https://github.com/neonmodder123")
                            
                            TranslatorCreditCell(name: "Jurre", languageKey: "language.dutch", url: "https://github.com/jurre111")
                            
                            TranslatorCreditCell(name: "MineTurtlee", languageKey: "language.vietnamese", url: "https://github.com/MineTurtlee")
                            
                            TranslatorCreditCell(name: "nxtcoreee3", languageKey: "language.swedish, language.romanian, language.norwegian", url: "https://github.com/nxtcoreee3")
                            
                            TranslatorCreditCell(name: "fil", languageKey: "language.italian", url: "https://github.com/tiziodied")
                        }
                        .navigationTitle("credits.translators.title")
                    } label: {
                        Text("credits.translators.title")
                    }
                } header: {
                    HeaderLabel(text: String(localized: "section.credits.title"), icon: "star")
                }
            }
            .navigationTitle("settings.title")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
    
    private func testAnisetteConnection() {
        isTestingPing = true
        pingStatus = "Đang kiểm tra..."
        
        var target = selectedAnisettePreset
        if selectedAnisettePreset == "custom" {
            target = customAnisetteURL.trimmingCharacters(in: .whitespacesAndNewlines)
            if !target.hasPrefix("http://") && !target.hasPrefix("https://") {
                target = "https://" + target
            }
        } else if selectedAnisettePreset == "auto" {
            target = "https://anisette.apsteam.top/v3/provisioningData"
        }
        
        guard let url = URL(string: target) else {
            pingStatus = "URL không hợp lệ"
            isTestingPing = false
            return
        }
        
        let start = Date()
        var req = URLRequest(url: url)
        req.timeoutInterval = 5
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: req) { _, response, error in
            let latency = Int(Date().timeIntervalSince(start) * 1000)
            DispatchQueue.main.async {
                isTestingPing = false
                if let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) {
                    pingStatus = "🟢 Hoạt động tốt (\(latency) ms)"
                } else if let error = error {
                    pingStatus = "🔴 Lỗi kết nối"
                } else {
                    let code = (response as? HTTPURLResponse)?.statusCode ?? 0
                    pingStatus = "🟡 Mã HTTP \(code)"
                }
            }
        }.resume()
    }
}

var creditCell: CGFloat {
    if #available(iOS 19.0, *) { return 14 } else { return 16 }
}

// add to partyui?
struct TranslatorCreditCell: View {
    var name: String
    var languageDisplay: String
    var url: String
    @Environment(\.openURL) var openURL
    
    public init(name: String, languageKey: String, url: String = "") {
        self.name = name
        self.url = url
        
        let localizedNames = languageKey
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .map { String(localized: String.LocalizationValue($0)) }
        
        let formatter = ListFormatter()
        self.languageDisplay = formatter.string(from: localizedNames) ?? localizedNames.joined(separator: ", ")
    }
    
    public var body: some View {
        Button(action: {
            if !url.isEmpty, let link = URL(string: url) { openURL(link) }
        }) {
            HStack(spacing: creditCell) {
                VStack(alignment: .leading) {
                    Text(name)
                        .fontWeight(.semibold)
                    Text(languageDisplay)
                        .multilineTextAlignment(.leading)
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                if !url.isEmpty {
                    Spacer()
                    Image(systemName: "chevron.right")
                        .fontWeight(.semibold)
                        .foregroundStyle(.tertiary)
                        .imageScale(.small)
                }
            }
        }
        .foregroundStyle(Color(.label))
    }
}

#Preview {
    SettingsView()
}
