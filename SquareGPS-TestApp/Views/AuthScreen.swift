import SwiftUI

struct AuthScreen<T: Services>: View {
    
    let emailPredicate = NSPredicate(
        format: "SELF MATCHES[c] %@",
        "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,64}$"
    )
    
    @State var username = "demo-eu@navixy.com"
    @FocusState var isUsernameFocused: Bool
    
    @State var password = "123456"
    @FocusState var isPasswordFocused: Bool
    
    @State var isAuthInProgress = false
    @State var contentHeight: CGFloat = 1
    
    @State var error: (any Error)?
    @State var isErrorAlertPresented = false
    
    @ObservedObject var authService: T._AuthService
    @Environment(\.dismiss) var dismiss
    
    private var isUsernameValid: Bool {
        emailPredicate.evaluate(with: username)
    }
    
    private var isPasswordValid: Bool {
        password.count > 1
    }
    
    init(_ services: T) {
        _authService = .init(initialValue: services.authService)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Username")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.leading, 4)
            TextField("Enter username", text: $username)
                .focused($isUsernameFocused)
                .textFieldStyle(.roundedBorder)
                .foregroundStyle(isUsernameFocused || isUsernameValid ? .black : .red)
                .textContentType(.emailAddress)
                .padding(.bottom)
            Text("Password")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.leading, 4)
            SecureField("Enter password", text: $password)
                .focused($isPasswordFocused)
                .textFieldStyle(.roundedBorder)
                .foregroundStyle(isPasswordFocused || isPasswordValid ? .black : .red)
                .textContentType(.password)
                .padding(.bottom)
            Button(action: { auth() }) {
                if isAuthInProgress {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Sign In")
                        .frame(maxWidth: .infinity)
                }
            }
            .disabled(isAuthInProgress || !isUsernameValid || !isPasswordValid)
            .frame(height: 32)
            .clipShape(Capsule())
            .glassEffect(.regular)
            
        }
        .padding()
        .background(.white)
        .navigationTitle("Sign In")
        .alert(
            error?.localizedDescription ?? "Unknown Error",
            isPresented: $isErrorAlertPresented
        ) {
            Button("OK") { isErrorAlertPresented = false }
        }
        .onContentSizeChange { contentHeight = $0.height }
        .presentationDetents([.height(contentHeight)])
    }
    
    func auth() {
        guard !isAuthInProgress else { return }
        isAuthInProgress = true
        Task {
            do {
                try await authService.auth(username: username, password: password)
                dismiss()
            } catch {
                self.error = error
                isErrorAlertPresented = true
            }
            isAuthInProgress = false
        }
    }
}

#Preview {
    NavigationStack {
        AuthScreen(ServicesMock())
    }
}
