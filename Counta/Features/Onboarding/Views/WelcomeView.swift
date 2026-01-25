import SwiftUI

struct WelcomeView: View {
    enum Context {
        case onboarding
        case settings

        var title: String {
            switch self {
            case .onboarding:
                return "欢迎使用 Counta"
            case .settings:
                return "连接 Fava"
            }
        }

        var subtitle: String {
            switch self {
            case .onboarding:
                return "请输入 Fava 地址以连接账本数据"
            case .settings:
                return "更新 Fava 地址和登录信息"
            }
        }

        var actionTitle: String {
            switch self {
            case .onboarding:
                return "开始使用"
            case .settings:
                return "保存"
            }
        }

        var navigationTitle: String {
            switch self {
            case .onboarding:
                return ""
            case .settings:
                return "Fava 连接"
            }
        }

        var shouldDismissOnSave: Bool {
            switch self {
            case .onboarding:
                return false
            case .settings:
                return true
            }
        }
    }

    let context: Context
    @Environment(\.dismiss) private var dismiss
    @AppStorage(AppStorageKeys.favaBaseURL) private var storedFavaBaseURL = ""
    @AppStorage(AppStorageKeys.favaApiURL) private var storedFavaApiURL = ""
    @AppStorage(AppStorageKeys.favaApiUsername) private var storedFavaApiUsername = ""
    @AppStorage(AppStorageKeys.favaUsesBasicAuth) private var storedUsesBasicAuth = false

    @State private var favaBaseURLInput = ""
    @State private var usesBasicAuth = false
    @State private var usernameInput = ""
    @State private var passwordInput = ""
    @State private var showValidationError = false
    @State private var validationMessage = ""
    @State private var isResolvingURL = false
    @FocusState private var focusedField: Field?

    private enum Field {
        case url
        case username
        case password
    }

    private var trimmedURL: String {
        FavaURLValidator.normalized(favaBaseURLInput)
    }

    private var trimmedUsername: String {
        usernameInput.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canContinue: Bool {
        !trimmedURL.isEmpty && (!usesBasicAuth || (!trimmedUsername.isEmpty && !passwordInput.isEmpty))
    }

    init(context: Context = .onboarding) {
        self.context = context
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                inputSection
                    .disabled(isResolvingURL)
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
        }
        .background(.background)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 12) {
                if showValidationError {
                    Text(validationMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }

                Button(action: handleContinue) {
                    HStack(spacing: 8) {
                        if isResolvingURL {
                            ProgressView()
                        }
                        Text(isResolvingURL ? "连接中..." : context.actionTitle)
                    }
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(!canContinue || isResolvingURL)
            }
            .padding(24)
            .background(.background)
            .overlay(Divider(), alignment: .top)
        }
        .onAppear(perform: loadStoredValues)
        .onChange(of: favaBaseURLInput) { clearValidation() }
        .onChange(of: usesBasicAuth) { clearValidation() }
        .onChange(of: usernameInput) { clearValidation() }
        .onChange(of: passwordInput) { clearValidation() }
        .navigationTitle(context.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 48))
                .foregroundStyle(.blue)
                .padding(12)
                .background(.blue.opacity(0.12), in: Circle())

            Text(context.title)
                .font(.title.bold())

            Text(context.subtitle)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Fava 地址")
                    .font(.headline)

                TextField("https://fava.pythonanywhere.com", text: $favaBaseURLInput)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.URL)
                    .textContentType(.URL)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .url)
                    .submitLabel(.next)
                    .onSubmit {
                        if usesBasicAuth {
                            focusedField = .username
                        } else {
                            handleContinue()
                        }
                    }
            }

            VStack(alignment: .leading, spacing: 8) {
                Toggle("需要登录（Basic Auth）", isOn: $usesBasicAuth)

                if usesBasicAuth {
                    TextField("用户名", text: $usernameInput)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .textContentType(.username)
                        .textFieldStyle(.roundedBorder)
                        .focused($focusedField, equals: .username)
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .password
                        }

                    SecureField("密码", text: $passwordInput)
                        .textContentType(.password)
                        .textFieldStyle(.roundedBorder)
                        .focused($focusedField, equals: .password)
                        .submitLabel(.done)
                        .onSubmit(handleContinue)
                }
            }
        }
    }

    private func loadStoredValues() {
        if storedFavaBaseURL.isEmpty {
            favaBaseURLInput = FavaURLResolver.baseURL(from: storedFavaApiURL)
        } else {
            favaBaseURLInput = storedFavaBaseURL
        }
        usesBasicAuth = storedUsesBasicAuth
        usernameInput = storedFavaApiUsername
        passwordInput = storedUsesBasicAuth
            ? (KeychainService.readString(for: KeychainKeys.favaApiPassword) ?? "")
            : ""
    }

    private func clearValidation() {
        showValidationError = false
        validationMessage = ""
    }

    private func handleContinue() {
        guard !isResolvingURL else { return }
        Task {
            await handleContinueAsync()
        }
    }

    @MainActor
    private func handleContinueAsync() async {
        let trimmedURL = trimmedURL
        guard FavaURLValidator.isValid(trimmedURL) else {
            showValidationError = true
            validationMessage = "请输入有效的链接（以 http 或 https 开头）"
            focusedField = .url
            return
        }

        let sanitizedUsername = trimmedUsername
        if usesBasicAuth {
            guard !sanitizedUsername.isEmpty else {
                showValidationError = true
                validationMessage = "请输入用户名"
                focusedField = .username
                return
            }
            guard !passwordInput.isEmpty else {
                showValidationError = true
                validationMessage = "请输入密码"
                focusedField = .password
                return
            }
        }

        clearValidation()
        isResolvingURL = true
        defer { isResolvingURL = false }

        let resolvedAPIURL: String
        do {
            let authHeader = usesBasicAuth
                ? FavaAuthorization.basicHeader(username: sanitizedUsername, password: passwordInput)
                : nil
            resolvedAPIURL = try await FavaURLResolver.resolveAPIBase(
                from: trimmedURL,
                authorizationHeader: authHeader
            )
        } catch {
            showValidationError = true
            validationMessage = (error as? LocalizedError)?.errorDescription ?? "无法解析 Fava 地址"
            focusedField = .url
            return
        }

        if usesBasicAuth {
            do {
                try KeychainService.saveString(passwordInput, for: KeychainKeys.favaApiPassword)
            } catch {
                showValidationError = true
                validationMessage = "无法保存密码，请重试"
                focusedField = .password
                return
            }
            storedFavaApiUsername = sanitizedUsername
        } else {
            storedFavaApiUsername = ""
            try? KeychainService.deleteString(for: KeychainKeys.favaApiPassword)
        }

        storedUsesBasicAuth = usesBasicAuth
        storedFavaBaseURL = FavaURLResolver.baseURL(from: trimmedURL)
        storedFavaApiURL = resolvedAPIURL
        clearValidation()
        focusedField = nil

        if context.shouldDismissOnSave {
            dismiss()
        }
    }
}

#Preview {
    PreviewContainer {
        WelcomeView()
    }
}
