//
//  Authentication.swift
//  project hacknroll
//
//  Created by Tristan on 14/01/2023.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct ViewDidLoadModifier: ViewModifier {
    
    @State private var didLoad = false
    private let action: (() -> Void)?
    
    init(perform action: (() -> Void)? = nil) {
        self.action = action
    }
    
    func body(content: Content) -> some View {
        content.onAppear {
            if didLoad == false {
                didLoad = true
                action?()
            }
        }
    }
}

struct signUpViewSwiftUI: View {
    
    // MARK: - Dismiss Presentation Mode
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - Feedback Haptics Generator
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
    
    // MARK: - Lists of accounts registered
    
    // MARK: - Information on all currently registered accounts
    @State var noOfAccounts = 0
    @State var currentUsernames = ""
    
    // MARK: - User Input
    @State var realUsername = ""
    @State var username = ""
    @State var password = ""
    @State var passwordConfirmation = ""
    
    // MARK: - Showing Alerts
    @State private var signUpAlert = false
    
    // MARK: - Showing Views
    @State private var isShowingsignInView: Bool = false
    
    // MARK: - Check whether SecureField is on
    @State private var isSecured = true
    @State private var isSecured2 = true
    
    // MARK: - Temporary Developer Mode Reset
    @AppStorage("tempDevMode", store: .standard) private var tempDevMode = 0
    
    // MARK: - Segmented Control for View switching
    @AppStorage("signInUpSegment", store: .standard) private var signInUpSegment = 0
    
    // MARK: - List and Count of all registered Usernames
    @AppStorage("usernameCountInt", store: .standard) private var usernameCountInt = 0
    @AppStorage("usernameArray", store: .standard) private var usernameArray = ""
    
    // MARK: - User Information
    @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    
    @State private var accFailed = false
    
    @State private var usernameIsFocused = false
    
    @AppStorage("showQRLogIn", store: .standard) var showQRLogIn = false
    
    @AppStorage("currUsernames", store: .standard) var currUsernames = ""
    
    @AppStorage("showingOnboarding", store: .standard) private var showingOnboarding = false
    
    @State private var actList = 0
    
    @State private var CurloadedSuccess = false
    
    @State private var showSheet = false
    @State private var showSheet4 = false
    
    var body: some View {
        if signInUpSegment == 0 {
            NavigationView {
                VStack(spacing: 15) {
                    Spacer()
                    Spacer()
                    Spacer()
                    
                    HStack {
                        Text("Welcome to Failsafe!")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    .padding(.bottom, 20)
                    
                    Group {
                        TextField("Enter an Email", text: $username)
                            .padding(20)
                            .background(.thinMaterial)
                            .cornerRadius(10)
                            .textInputAutocapitalization(.never)
                        
                        ZStack(alignment: .trailing) {
                            Group {
                                if isSecured {
                                    SecureField("Enter a Password", text: $password)
                                        .padding(20)
                                        .background(.thinMaterial)
                                        .cornerRadius(10)
                                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: password.count < 6 && password.count > 0 ? 2 : 0).foregroundColor(.red))
                                } else {
                                    TextField("Enter a Password", text: $password)
                                        .padding(20)
                                        .background(.thinMaterial)
                                        .cornerRadius(10)
                                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: password.count < 6 && password.count > 0 ? 2 : 0).foregroundColor(.red))
                                }
                                Spacer()
                                Button(action: {
                                    isSecured.toggle()
                                    generator.impactOccurred(intensity: 0.5)
                                }) {
                                    Image(systemName: self.isSecured ? "eye.slash" : "eye")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 23, height: 23)
                                        .accentColor(.gray)
                                        .padding()
                                        .padding(.trailing, 3)
                                }
                                
                            }
                        }
                        
                        if password != "" {
                            if password.count < 6 {
                                Text("Passwords have to contain at least 6 characters")
                                    .font(.footnote)
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .foregroundColor(Color.red)
                            }
                        }
                        
                        ZStack(alignment: .trailing) {
                            Group {
                                if isSecured2 {
                                    SecureField("Confirm your Password", text: $passwordConfirmation)
                                        .padding(20)
                                        .background(.thinMaterial)
                                        .cornerRadius(10)
                                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: passwordConfirmation != password ? 2 : 0).foregroundColor(.red))
                                } else {
                                    TextField("Confirm your Password", text: $passwordConfirmation)
                                        .padding(20)
                                        .background(.thinMaterial)
                                        .cornerRadius(10)
                                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: passwordConfirmation != password ? 2 : 0).foregroundColor(.red))
                                }
                                Spacer()
                                Button(action: {
                                    isSecured2.toggle()
                                    generator.impactOccurred(intensity: 0.5)
                                }) {
                                    Image(systemName: self.isSecured2 ? "eye.slash" : "eye")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 23, height: 23)
                                        .accentColor(.gray)
                                        .padding()
                                        .padding(.trailing, 3)
                                }
                                
                            }
                        }
                        if passwordConfirmation != password {
                            Text("The two passwords dont match.")
                                .font(.footnote)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundColor(Color.red)
                        }
                    }
                    
                    Spacer()
                    Button {
                        FirebaseAuth.Auth.auth().createUser(withEmail: username, password: password, completion: { result, error in
                            guard error == nil else {
                                accFailed = true
                                print("account creation failed")
                                generator2.notificationOccurred(.error)
                                return
                            }
                            print("sign up successful")
                            generator2.notificationOccurred(.success)
                            
                            finalEmail = (Auth.auth().currentUser?.email!)!
                            finalPassword = password
                            isLoggedIn = true
                            
                            let array = finalEmail.components(separatedBy: "@")
                            
                            setNewAccount(email: finalEmail, password: finalPassword, name: array[0])
                            
                            showingOnboarding = false
                            presentationMode.wrappedValue.dismiss()
                            //showNext2 = false
                        })
                    } label: {
                        HStack {
                            Text("Create Account")
                                .fontWeight(.bold)
                            Image(systemName: "arrow.right")
                                .fontWeight(.bold)
                        }
                        .frame(width: 200, height: 60)
                        .background(.thinMaterial)
                        .cornerRadius(150)
                    }
                    .disabled(username == "" || username == " " || password == "" || password == " " || passwordConfirmation != password || password.count < 6)
                    
                    Spacer()
                    Button {
                        signInUpSegment = 1
                        generator.impactOccurred(intensity: 0.7)
                    } label: {
                        HStack {
                            Text("Already have an account?")
                                .foregroundColor(.primary)
                            Text("Log In!")
                                .foregroundColor(.blue)
                        }
                        .font(.headline)
                        .fontWeight(.bold)
                    }
                    .buttonStyle(.plain)
                    
                    /*
                     HStack {
                     Picker("Change View", selection: $signInUpSegment, content: {
                     Text("Sign Up").tag(0)
                     Text("Log In").tag(1)
                     if showQRLogIn {
                     Text("QR Log In").tag(2)
                     }
                     })
                     .pickerStyle(SegmentedPickerStyle())
                     .padding(.horizontal, 25)
                     }
                     */
                }
                .padding()
                .background(Color("bgColorTab"))
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Text("Sign Up")
                            .fontWeight(.bold)
                    }
                }                .background(NavigationConfigurator { nc in
                    nc.navigationBar.barTintColor = .systemBackground
                    nc.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.label]
                })
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .onLoad {
                if isLoggedIn {
                    presentationMode.wrappedValue.dismiss()
                }
                
                generator.impactOccurred(intensity: 0.7)
                
                tempDevMode = 0
            }
            .onAppear {
                currUsernames = ""
            }
        } else if signInUpSegment == 1 {
            signInViewSwiftUI()
        }
    }
    
    func setNewAccount(email: String, password: String, name: String) {
        Firestore.firestore().collection("users").document(email).setData([
            "email": email,
            "password": password,
            "name": name,
            "emergency-notify": "false"
        ])
    }
}

struct signInViewSwiftUI: View {
    
    // MARK: - Dismiss Presentation Mode
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - Feedback Haptics Generator
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
    
    // MARK: - Lists of accounts registered
    
    // MARK: - Information on all currently registered accounts
    @State var noOfAccounts = 0
    @State var currentUsernames = ""
    @State var currentPasswords = ""
    
    // MARK: - User Input
    @State var username = ""
    @State var password = ""
    
    // MARK: - Showing Alerts
    @State private var signUpAlert = false
    
    // MARK: - Showing Views
    @State private var isShowingsignInView: Bool = false
    @State private var isShowingForgotView: Bool = false
    
    // MARK: - Check whether SecureField is on
    @State private var isSecured = true
    
    // MARK: - Segmented Control for View switching
    @AppStorage("signInUpSegment", store: .standard) private var signInUpSegment = 0
    
    // MARK: - User Information
    @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    
    var body: some View {
        if signInUpSegment == 1 {
            NavigationView {
                VStack(spacing: 15) {
                    /*
                     Spacer()
                     Image(systemName: "person.crop.square.filled.and.at.rectangle")
                     .resizable()
                     .aspectRatio(contentMode: .fit)
                     .frame(width: 125, height: 125)
                     */
                    Spacer()
                    Spacer()
                    Spacer()
                    HStack {
                        Text("Welcome back to\nFailsafe!")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    .padding(.bottom, 20)
                    Group {
                        /*
                         HStack {
                         Text("Email")
                         .fontWeight(.bold)
                         .font(.subheadline)
                         .padding(.top, 37)
                         Spacer()
                         }
                         */
                        TextField("Enter Email", text: $username)
                            .padding(20)
                            .background(.thinMaterial)
                            .cornerRadius(10)
                            .textInputAutocapitalization(.never)
                        /*
                         Divider()
                         .padding(.vertical, 10)
                         */
                        /*
                         HStack {
                         Text("Password")
                         .fontWeight(.bold)
                         .font(.subheadline)
                         Spacer()
                         }
                         */
                        ZStack(alignment: .trailing) {
                            Group {
                                if isSecured {
                                    SecureField("Enter Password", text: $password)
                                        .padding(20)
                                        .background(.thinMaterial)
                                        .cornerRadius(10)
                                } else {
                                    TextField("Enter Password", text: $password)
                                        .padding(20)
                                        .background(.thinMaterial)
                                        .cornerRadius(10)
                                }
                                Spacer()
                                Button(action: {
                                    isSecured.toggle()
                                    generator.impactOccurred(intensity: 0.5)
                                }) {
                                    Image(systemName: self.isSecured ? "eye.slash" : "eye")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 23, height: 23)
                                        .accentColor(.gray)
                                        .padding()
                                        .padding(.trailing, 3)
                                }
                                
                            }
                        }
                    }
                    
                    HStack {
                        Spacer()
                        Text("Forgot Password?")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(Color.blue)
                            .opacity(0.8)
                            .onTapGesture {
                                isShowingForgotView = true
                            }
                            .sheet(isPresented: $isShowingForgotView) {
                                //forgotPasswordSwiftUI()
                            }
                    }
                    
                    Spacer()
                    Button {
                        if username != "" && password != "" {
                            
                            print("button in")
                            
                            FirebaseAuth.Auth.auth().signIn(withEmail: username, password: password, completion: { result, error in
                                guard error == nil else {
                                    print("could not find account")
                                    generator2.notificationOccurred(.error)
                                    return
                                }
                                
                                finalEmail = (Auth.auth().currentUser?.email!)!
                                finalPassword = password
                                isLoggedIn = true
                                print("successfully signed in")
                            })
                        } else {
                            generator2.notificationOccurred(.error)
                        }
                    } label: {
                        HStack {
                            Text("Log In")
                                .fontWeight(.bold)
                            Image(systemName: "arrow.right")
                                .fontWeight(.bold)
                        }
                        .frame(width: 175, height: 60)
                        .background(.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(150)
                    }
                    .disabled(username == "" || password == "")
                    Spacer()
                    Button {
                        signInUpSegment = 0
                    } label: {
                        HStack {
                            Text("New to Failsafe?")
                                .foregroundColor(.primary)
                            Text("Sign Up!")
                                .foregroundColor(.blue)
                        }
                        .font(.headline)
                        .fontWeight(.bold)
                    }
                    .buttonStyle(.plain)
                }
                .padding()
                .background(Color("bgColorTab"))
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Text("Log In")
                            .fontWeight(.bold)
                    }
                }
                .background(NavigationConfigurator { nc in
                    nc.navigationBar.barTintColor = .systemBackground
                    nc.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.label]
                })
            }
            .navigationViewStyle(StackNavigationViewStyle())
        } else if signInUpSegment == 0 {
            signUpViewSwiftUI()
        }
    }
}

extension UINavigationBar {
    static func changeAppearance() {
        let appearance = UINavigationBarAppearance()
        
        appearance.configureWithOpaqueBackground()
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}

struct NavigationConfigurator: UIViewControllerRepresentable {
    var configure: (UINavigationController) -> Void = { _ in }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<NavigationConfigurator>) -> UIViewController {
        UIViewController()
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<NavigationConfigurator>) {
        if let nc = uiViewController.navigationController {
            self.configure(nc)
        }
    }
    
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        signUpViewSwiftUI()
    }
}

struct LogoView: View {
    var body: some View {
        Image("FFIcon")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 175, height: 175)
            .padding(.bottom, 65)
            .padding(.top, 75)
    }
}

extension View {
    
    func onLoad(perform action: (() -> Void)? = nil) -> some View {
        modifier(ViewDidLoadModifier(perform: action))
    }
    
}
